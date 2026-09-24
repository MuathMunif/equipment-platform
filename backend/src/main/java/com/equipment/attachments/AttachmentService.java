package com.equipment.attachments;

import com.equipment.audit.Audit;
import com.equipment.common.*;
import com.equipment.finance.FinanceService;
import com.equipment.identity.Actor;
import com.equipment.workspaces.Access;
import java.io.IOException;
import java.util.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AttachmentService {
    private final JdbcTemplate db; private final Access access; private final FinanceService finance; private final Idempotency retries; private final Audit audit; private final ObjectStorageService storage; private final ContentValidator validator;
    public AttachmentService(JdbcTemplate db,Access access,FinanceService finance,Idempotency retries,Audit audit,ObjectStorageService storage,ContentValidator validator) { this.db=db;this.access=access;this.finance=finance;this.retries=retries;this.audit=audit;this.storage=storage;this.validator=validator; }
    public record Initiate(String filename,String mediaType,Long size) {}
    public record Attachment(UUID id,UUID entryId,String filename,String mediaType,long size,String state,String scanStatus) {}
    public record Download(byte[] bytes,String mediaType,String filename) {}
    private Map<String,Object> require(UUID workspace,UUID id,boolean lock) {
        var rows=db.queryForList("select a.* from attachment a join financial_entry f on f.workspace_id=a.workspace_id and f.id=a.entry_id where a.workspace_id=? and a.id=? and f.lifecycle<>'DISCARDED'"+(lock?" for update of a":""),workspace,id);
        if(rows.isEmpty()) throw ApiException.missing(); return rows.getFirst();
    }
    private Attachment view(Map<String,Object> row) { return new Attachment((UUID)row.get("id"),(UUID)row.get("entry_id"),(String)row.get("original_name"),(String)row.get("declared_type"),((Number)row.get("declared_size")).longValue(),(String)row.get("state"),(String)row.get("scan_status")); }
    public Attachment get(Actor actor,UUID workspace,UUID id) { access.owner(actor,workspace); return view(require(workspace,id,false)); }
    public List<Attachment> list(Actor actor,UUID workspace,UUID entry) {
        access.owner(actor,workspace); finance.requireAttachable(workspace,entry);
        return db.queryForList("select * from attachment where workspace_id=? and entry_id=? order by created_at,id",workspace,entry).stream().map(this::view).toList();
    }
    @Transactional
    public Attachment initiate(Actor actor,UUID workspace,UUID entry,String key,Initiate request) {
        access.owner(actor,workspace); finance.requireAttachable(workspace,entry);
        String filename=Values.text(request.filename(),200,"اسم الملف");
        if(filename.contains("/") || filename.contains("\\") || filename.chars().anyMatch(c->c<32 || c==127)) throw ApiException.invalid("اختر اسم ملف دون رموز مسار");
        if(request.mediaType()==null || !ContentValidator.TYPES.contains(request.mediaType())) throw new ApiException(400,"UNSUPPORTED_FILE","الصيغ المدعومة: PNG وJPEG وPDF. حوّل HEIC إلى JPEG قبل الرفع");
        if(request.size()==null || request.size()<=0 || request.size()>ContentValidator.MAX_BYTES) throw new ApiException(413,"FILE_TOO_LARGE","اختر ملفًا لا يتجاوز 10 ميغابايت");
        UUID id=retries.execute(workspace,actor.userId(),"attachment.create:"+entry,key,Values.payload(filename,request.mediaType(),request.size()),()->{
            var parent=db.queryForList("select lifecycle from financial_entry where workspace_id=? and id=? for update",workspace,entry);
            if(parent.isEmpty() || "DISCARDED".equals(parent.getFirst().get("lifecycle"))) throw ApiException.missing();
            Long count=db.queryForObject("select count(*) from attachment where workspace_id=? and entry_id=?",Long.class,workspace,entry);
            if(count>=10) throw new ApiException(409,"ATTACHMENT_LIMIT","الحد التطويري 10 مرفقات للعملية؛ أعد محاولة المرفق المتعثر بدل إنشاء مرفق آخر");
            UUID created=UUID.randomUUID(); db.update("insert into attachment(id,workspace_id,entry_id,original_name,declared_type,declared_size,state,created_by) values(?,?,?,?,?,?,'PENDING',?)",created,workspace,entry,filename,request.mediaType(),request.size(),actor.userId());return created;
        });return view(require(workspace,id,false));
    }
    @Transactional(noRollbackFor=ApiException.class)
    public Attachment upload(Actor actor,UUID workspace,UUID id,String mediaType,byte[] bytes) {
        access.owner(actor,workspace);var row=require(workspace,id,true);String checksum=Values.hash(bytes);
        if(row.get("state").equals("READY")) {
            if(checksum.equals(row.get("checksum"))) return view(row);
            throw new ApiException(409,"IMMUTABLE_ATTACHMENT","المرفق محفوظ؛ أضف مرفقًا جديدًا إذا احتجت ملفًا آخر");
        }
        try {
            if(bytes.length!=((Number)row.get("declared_size")).longValue() || !Objects.equals(mediaType,row.get("declared_type"))) throw ApiException.invalid("حجم الملف أو صيغته لا يطابقان الملف المحدد؛ أعد رفع الملف نفسه");
            String actual=validator.validate(bytes,(String)row.get("declared_type"));
            String key=workspace+"/"+id+"/"+checksum; storage.putImmutable(key,bytes);
            db.update("update attachment set state='READY',verified_type=?,actual_size=?,checksum=?,object_key=?,updated_at=now() where workspace_id=? and id=?",actual,bytes.length,checksum,key,workspace,id);
            audit.record(workspace,actor.userId(),"ATTACHMENT_READY",id);
            return view(require(workspace,id,false));
        } catch(ApiException e) { db.update("update attachment set state='FAILED',updated_at=now() where workspace_id=? and id=?",workspace,id); throw e; }
        catch(IOException e) { db.update("update attachment set state='FAILED',updated_at=now() where workspace_id=? and id=?",workspace,id); throw new ApiException(503,"UPLOAD_FAILED","حُفظ السجل، وتعذر رفع المرفق؛ أعد محاولة رفع المرفق"); }
    }
    public Download download(Actor actor,UUID workspace,UUID id) {
        access.owner(actor,workspace);var row=require(workspace,id,false);
        if(!row.get("state").equals("READY")) throw new ApiException(409,"FILE_NOT_READY","لم يكتمل رفع المرفق؛ أعد المحاولة");
        try { byte[] bytes=storage.read((String)row.get("object_key"));
            if(!Values.hash(bytes).equals(row.get("checksum"))) throw new IOException("Checksum mismatch");
            return new Download(bytes,(String)row.get("verified_type"),(String)row.get("original_name"));
        } catch(IOException e) { throw new ApiException(503,"FILE_UNAVAILABLE","تعذر تحميل المرفق؛ أعد المحاولة لاحقًا"); }
    }
}
