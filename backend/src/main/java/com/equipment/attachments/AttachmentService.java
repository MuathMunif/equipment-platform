package com.equipment.attachments;

import com.equipment.audit.Audit;
import com.equipment.common.*;
import com.equipment.finance.FinanceService;
import com.equipment.finance.SubmissionService;
import com.equipment.documents.DocumentService;
import com.equipment.maintenance.MaintenanceService;
import com.equipment.identity.Actor;
import com.equipment.workspaces.Access;
import java.io.IOException;
import java.util.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AttachmentService {
    private final JdbcTemplate db; private final Access access; private final FinanceService finance; private final DocumentService documents; private final MaintenanceService maintenance; private final SubmissionService submissions; private final Idempotency retries; private final Audit audit; private final ObjectStorageService storage; private final ContentValidator validator;
    public AttachmentService(JdbcTemplate db,Access access,FinanceService finance,DocumentService documents,MaintenanceService maintenance,SubmissionService submissions,Idempotency retries,Audit audit,ObjectStorageService storage,ContentValidator validator) { this.db=db;this.access=access;this.finance=finance;this.documents=documents;this.maintenance=maintenance;this.submissions=submissions;this.retries=retries;this.audit=audit;this.storage=storage;this.validator=validator; }
    public record Initiate(String filename,String mediaType,Long size) {}
    public record Attachment(UUID id,UUID entryId,UUID documentVersionId,UUID issueId,UUID maintenanceId,String filename,String mediaType,long size,String state,String scanStatus) {}
    public record Download(byte[] bytes,String mediaType,String filename) {}
    private Map<String,Object> require(UUID workspace,UUID id,boolean lock) {
        var rows=db.queryForList("select a.* from attachment a left join financial_entry f on f.workspace_id=a.workspace_id and f.id=a.entry_id left join document_version v on v.workspace_id=a.workspace_id and v.id=a.document_version_id left join equipment_document d on d.workspace_id=v.workspace_id and d.id=v.document_id where a.workspace_id=? and a.id=? and (f.lifecycle<>'DISCARDED' or d.id is not null or a.issue_id is not null or a.maintenance_id is not null or a.submission_id is not null)"+(lock?" for update of a":""),workspace,id);
        if(rows.isEmpty()) throw ApiException.missing(); return rows.getFirst();
    }
    private Attachment view(Map<String,Object> row) { return new Attachment((UUID)row.get("id"),(UUID)row.get("entry_id"),(UUID)row.get("document_version_id"),(UUID)row.get("issue_id"),(UUID)row.get("maintenance_id"),(String)row.get("original_name"),(String)row.get("declared_type"),((Number)row.get("declared_size")).longValue(),(String)row.get("state"),(String)row.get("scan_status")); }
    private void authorize(Actor actor,UUID w,Map<String,Object> row,boolean write){
        String cap=write?"MANAGE":"VIEW";
        if(row.get("submission_id")!=null){submissions.get(actor,w,(UUID)row.get("submission_id"));if(write)throw ApiException.missing();return;}
        if(row.get("entry_id")!=null){if(write)access.directFinancialEntry(actor,w,(UUID)row.get("entry_id"));else access.financial(actor,w,(UUID)row.get("entry_id"),"FINANCE_VIEW");return;}
        if(row.get("issue_id")!=null){access.resource(actor,w,"equipment_issue",(UUID)row.get("issue_id"),"ISSUE_"+cap);return;}
        if(row.get("maintenance_id")!=null){access.resource(actor,w,"maintenance_record",(UUID)row.get("maintenance_id"),"MAINTENANCE_"+cap);return;}
        if(row.get("document_version_id")!=null){var docs=db.queryForList("select document_id from document_version where workspace_id=? and id=?",w,row.get("document_version_id"));if(docs.isEmpty())throw ApiException.missing();access.resource(actor,w,"equipment_document",(UUID)docs.getFirst().get("document_id"),"DOCUMENT_"+cap);return;}
        throw ApiException.missing();
    }
    public List<Attachment> listIssue(Actor actor,UUID w,UUID id){access.resource(actor,w,"equipment_issue",id,"ISSUE_VIEW");maintenance.requireIssue(w,id);return db.queryForList("select * from attachment where workspace_id=? and issue_id=? order by created_at,id",w,id).stream().map(this::view).toList();}
    public List<Attachment> listMaintenance(Actor actor,UUID w,UUID id){access.resource(actor,w,"maintenance_record",id,"MAINTENANCE_VIEW");maintenance.requireMaintenance(w,id);return db.queryForList("select * from attachment where workspace_id=? and maintenance_id=? order by created_at,id",w,id).stream().map(this::view).toList();}
    @Transactional public void removeOperational(Actor actor,UUID w,UUID id,boolean issue,UUID attachment){access.resource(actor,w,issue?"equipment_issue":"maintenance_record",id,issue?"ISSUE_MANAGE":"MAINTENANCE_MANAGE");if(issue)maintenance.requireIssue(w,id);else maintenance.requireMaintenance(w,id);var row=require(w,attachment,true);if(!id.equals(row.get(issue?"issue_id":"maintenance_id")))throw ApiException.missing();var parent=db.queryForList(issue?"select status from equipment_issue where workspace_id=? and id=? for update":"select cancelled_at from maintenance_record where workspace_id=? and id=? for update",w,id);if(parent.isEmpty() || (issue?"CLOSED".equals(parent.getFirst().get("status")):parent.getFirst().get("cancelled_at")!=null))throw new ApiException(409,"HISTORICAL_RECORD","السجل للقراءة فقط");db.update("delete from attachment where workspace_id=? and id=?",w,attachment);audit.record(w,actor.userId(),issue?"ISSUE_ATTACHMENT_REMOVED":"MAINTENANCE_ATTACHMENT_REMOVED",attachment);}
    @Transactional public Attachment initiateIssue(Actor actor,UUID w,UUID id,String key,Initiate request){return initiateOperational(actor,w,id,key,request,true);}
    @Transactional public Attachment initiateMaintenance(Actor actor,UUID w,UUID id,String key,Initiate request){return initiateOperational(actor,w,id,key,request,false);}
    private Attachment initiateOperational(Actor actor,UUID w,UUID parent,String key,Initiate request,boolean issue){access.resource(actor,w,issue?"equipment_issue":"maintenance_record",parent,issue?"ISSUE_MANAGE":"MAINTENANCE_MANAGE");if(issue)maintenance.requireIssue(w,parent);else maintenance.requireMaintenance(w,parent);String name=Values.text(request.filename(),200,"اسم الملف");if(name.contains("/")||name.contains("\\")||name.chars().anyMatch(c->c<32||c==127))throw ApiException.invalid("اسم الملف غير صالح");if(request.mediaType()==null || !ContentValidator.TYPES.contains(request.mediaType()) || (issue && "application/pdf".equals(request.mediaType())))throw new ApiException(400,"UNSUPPORTED_FILE","صيغة الملف غير مدعومة");if(request.size()==null||request.size()<=0||request.size()>ContentValidator.MAX_BYTES)throw new ApiException(413,"FILE_TOO_LARGE","الملف أكبر من الحد المسموح");String kind=issue?"issue":"maintenance";UUID attachment=retries.execute(w,actor.userId(),kind+".attachment.create:"+parent,key,Values.payload(name,request.mediaType(),request.size()),()->{var rows=db.queryForList(issue?"select status from equipment_issue where workspace_id=? and id=? for update":"select cancelled_at from maintenance_record where workspace_id=? and id=? for update",w,parent);if(rows.isEmpty())throw ApiException.missing();if(issue?"CLOSED".equals(rows.getFirst().get("status")):rows.getFirst().get("cancelled_at")!=null)throw new ApiException(409,"HISTORICAL_RECORD","السجل للقراءة فقط");Long count=db.queryForObject("select count(*) from attachment where workspace_id=? and "+(issue?"issue_id":"maintenance_id")+"=?",Long.class,w,parent);if(count>=10)throw new ApiException(409,"ATTACHMENT_LIMIT","الحد 10 مرفقات");UUID created=UUID.randomUUID();db.update("insert into attachment(id,workspace_id,"+(issue?"issue_id":"maintenance_id")+",original_name,declared_type,declared_size,state,created_by) values(?,?,?,?,?,?,'PENDING',?)",created,w,parent,name,request.mediaType(),request.size(),actor.userId());audit.record(w,actor.userId(),issue?"ISSUE_ATTACHMENT_ADDED":"MAINTENANCE_ATTACHMENT_ADDED",created);return created;});return view(require(w,attachment,false));}
    public Attachment get(Actor actor,UUID workspace,UUID id) { var row=require(workspace,id,false);authorize(actor,workspace,row,false); return view(row); }
    public List<Attachment> list(Actor actor,UUID workspace,UUID entry) {
        access.financial(actor,workspace,entry,"FINANCE_VIEW"); finance.requireAttachable(workspace,entry);
        return db.queryForList("select * from attachment where workspace_id=? and entry_id=? order by created_at,id",workspace,entry).stream().map(this::view).toList();
    }
    @Transactional
    public Attachment initiate(Actor actor,UUID workspace,UUID entry,String key,Initiate request) {
        access.directFinancialEntry(actor,workspace,entry); finance.requireAttachable(workspace,entry);
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
    public List<Attachment> listDocument(Actor actor,UUID workspace,UUID document,UUID version) {
        access.resource(actor,workspace,"equipment_document",document,"DOCUMENT_VIEW");documents.requireVersion(workspace,document,version);
        return db.queryForList("select * from attachment where workspace_id=? and document_version_id=? order by created_at,id",workspace,version).stream().map(this::view).toList();
    }
    @Transactional
    public Attachment initiateDocument(Actor actor,UUID workspace,UUID document,UUID version,String key,Initiate request) {
        access.resource(actor,workspace,"equipment_document",document,"DOCUMENT_MANAGE");documents.requireVersion(workspace,document,version);
        String filename=Values.text(request.filename(),200,"اسم الملف");
        if(filename.contains("/") || filename.contains("\\") || filename.chars().anyMatch(c->c<32 || c==127)) throw ApiException.invalid("اختر اسم ملف دون رموز مسار");
        if(request.mediaType()==null || !ContentValidator.TYPES.contains(request.mediaType())) throw new ApiException(400,"UNSUPPORTED_FILE","الصيغ المدعومة: PNG وJPEG وPDF. حوّل HEIC إلى JPEG قبل الرفع");
        if(request.size()==null || request.size()<=0 || request.size()>ContentValidator.MAX_BYTES) throw new ApiException(413,"FILE_TOO_LARGE","اختر ملفًا لا يتجاوز 10 ميغابايت");
        UUID id=retries.execute(workspace,actor.userId(),"document.attachment.create:"+version,key,Values.payload(filename,request.mediaType(),request.size()),()->{
            var parent=db.queryForList("select d.current_version_id,d.archived_at from equipment_document d join document_version v on v.workspace_id=d.workspace_id and v.document_id=d.id where d.workspace_id=? and d.id=? and v.id=? for update of d",workspace,document,version);
            if(parent.isEmpty())throw ApiException.missing();
            if(parent.getFirst().get("archived_at")!=null || !version.equals(parent.getFirst().get("current_version_id")))throw new ApiException(409,"HISTORICAL_VERSION","المرفقات الجديدة للنسخة الحالية فقط");
            Long count=db.queryForObject("select count(*) from attachment where workspace_id=? and document_version_id=?",Long.class,workspace,version);
            if(count>=10)throw new ApiException(409,"ATTACHMENT_LIMIT","الحد التطويري 10 مرفقات للمستند");
            UUID created=UUID.randomUUID();db.update("insert into attachment(id,workspace_id,document_version_id,original_name,declared_type,declared_size,state,created_by) values(?,?,?,?,?,?,'PENDING',?)",created,workspace,version,filename,request.mediaType(),request.size(),actor.userId());
            audit.record(workspace,actor.userId(),"DOCUMENT_ATTACHMENT_ADDED",created);return created;
        });return view(require(workspace,id,false));
    }
    @Transactional(noRollbackFor=ApiException.class)
    public Attachment upload(Actor actor,UUID workspace,UUID id,String mediaType,byte[] bytes) {
        var row=require(workspace,id,true);authorize(actor,workspace,row,true);String checksum=Values.hash(bytes);
        if(row.get("state").equals("READY")) {
            if(checksum.equals(row.get("checksum"))) return view(row);
            throw new ApiException(409,"IMMUTABLE_ATTACHMENT","المرفق محفوظ؛ أضف مرفقًا جديدًا إذا احتجت ملفًا آخر");
        }
        if(row.get("document_version_id")!=null) {
            var parent=db.queryForList("select d.current_version_id,d.archived_at from document_version v join equipment_document d on d.workspace_id=v.workspace_id and d.id=v.document_id where v.workspace_id=? and v.id=? for update of d",workspace,row.get("document_version_id"));
            if(parent.isEmpty() || parent.getFirst().get("archived_at")!=null || !row.get("document_version_id").equals(parent.getFirst().get("current_version_id")))
                throw new ApiException(409,"HISTORICAL_VERSION","المرفقات الجديدة للنسخة الحالية فقط");
        }
        if(row.get("issue_id")!=null){var parent=db.queryForList("select status from equipment_issue where workspace_id=? and id=? for update",workspace,row.get("issue_id"));if(parent.isEmpty() || "CLOSED".equals(parent.getFirst().get("status")))throw new ApiException(409,"HISTORICAL_RECORD","البلاغ مغلق");}
        if(row.get("maintenance_id")!=null){var parent=db.queryForList("select cancelled_at from maintenance_record where workspace_id=? and id=? for update",workspace,row.get("maintenance_id"));if(parent.isEmpty() || parent.getFirst().get("cancelled_at")!=null)throw new ApiException(409,"HISTORICAL_RECORD","سجل الصيانة ملغى");}
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
        var row=require(workspace,id,false);authorize(actor,workspace,row,false);
        if(!row.get("state").equals("READY")) throw new ApiException(409,"FILE_NOT_READY","لم يكتمل رفع المرفق؛ أعد المحاولة");
        try { byte[] bytes=storage.read((String)row.get("object_key"));
            if(!Values.hash(bytes).equals(row.get("checksum"))) throw new IOException("Checksum mismatch");
            return new Download(bytes,(String)row.get("verified_type"),(String)row.get("original_name"));
        } catch(IOException e) { throw new ApiException(503,"FILE_UNAVAILABLE","تعذر تحميل المرفق؛ أعد المحاولة لاحقًا"); }
    }
}
