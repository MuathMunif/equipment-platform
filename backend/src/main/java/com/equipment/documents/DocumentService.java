package com.equipment.documents;

import com.equipment.audit.Audit;
import com.equipment.common.*;
import com.equipment.identity.Actor;
import com.equipment.notifications.NotificationService;
import com.equipment.workspaces.Access;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.*;
import java.util.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class DocumentService {
    private final JdbcTemplate db;
    private final Access access;
    private final Audit audit;
    private final Idempotency retries;
    private final NotificationService notifications;
    private final Clock clock;
    private static final ZoneId WORKSPACE_ZONE=ZoneId.of("Asia/Riyadh");
    private static final Set<String> TYPES=Set.of("REGISTRATION","INSURANCE","PERIODIC_INSPECTION","LICENSE_PERMIT","OTHER");
    public DocumentService(JdbcTemplate db,Access access,Audit audit,Idempotency retries,NotificationService notifications,Clock clock) {this.db=db;this.access=access;this.audit=audit;this.retries=retries;this.notifications=notifications;this.clock=clock;}
    public record Input(String type,String customTypeName,String documentNumber,String issueDate,String expiryDate,String notes) {}
    public record Edit(UUID expectedVersionId,String type,String customTypeName,String documentNumber,String issueDate,String expiryDate,String notes) {}
    public record Renew(UUID expectedVersionId,String documentNumber,String issueDate,String expiryDate,String notes) {}
    private record Fields(String number,LocalDate issue,LocalDate expiry,String notes) {}
    private LocalDate today() {return LocalDate.now(clock.withZone(WORKSPACE_ZONE));}
    public static String status(LocalDate expiry,LocalDate today,boolean archived,boolean previous) {
        if(archived)return "ARCHIVED";
        if(previous)return "PREVIOUS_VERSION";
        if(expiry==null)return "MISSING_EXPIRY";
        long days=java.time.temporal.ChronoUnit.DAYS.between(today,expiry);
        return days<0?"EXPIRED":days==0?"EXPIRES_TODAY":days<=30?"EXPIRING_SOON":"VALID";
    }
    private String type(String raw) {if(raw==null || !TYPES.contains(raw))throw ApiException.invalid("اختر نوع مستند صحيحًا");return raw;}
    private String custom(String type,String raw) {if("OTHER".equals(type))return Values.text(raw,100,"اسم المستند");if(raw!=null && !raw.isBlank())throw ApiException.invalid("اسم مخصص لنوع أخرى فقط");return null;}
    private Fields fields(String number,String issue,String expiry,String notes,boolean requireExpiry) {
        String n=number==null || number.isBlank()?null:Values.text(number,100,"رقم المستند");
        LocalDate i=issue==null?null:Values.date(issue),e=expiry==null?null:Values.date(expiry);
        if(requireExpiry && e==null)throw ApiException.invalid("تاريخ الانتهاء مطلوب عند التجديد");
        if(i!=null && e!=null && i.isAfter(e))throw ApiException.invalid("تاريخ الإصدار بعد تاريخ الانتهاء");
        return new Fields(n,i,e,Values.note(notes));
    }
    private Map<String,Object> doc(UUID w,UUID id,boolean lock) {
        var rows=db.queryForList("select d.*,e.archived_at as equipment_archived_at from equipment_document d join equipment e on e.workspace_id=d.workspace_id and e.id=d.equipment_id where d.workspace_id=? and d.id=?"+(lock?" for update of d":""),w,id);
        if(rows.isEmpty())throw ApiException.missing();return rows.getFirst();
    }
    private Map<String,Object> version(UUID w,UUID doc,UUID version) {
        var rows=db.queryForList("select * from document_version where workspace_id=? and document_id=? and id=?",w,doc,version);
        if(rows.isEmpty())throw ApiException.missing();return rows.getFirst();
    }
    private Map<String,Object> view(Map<String,Object> d,Map<String,Object> v) {
        Map<String,Object> result=new LinkedHashMap<>();
        result.put("id",d.get("id"));result.put("equipmentId",d.get("equipment_id"));result.put("type",d.get("type"));result.put("customTypeName",d.get("custom_type_name"));
        result.put("currentVersionId",d.get("current_version_id"));result.put("archivedAt",d.get("archived_at"));result.put("equipmentArchived",d.get("equipment_archived_at")!=null);
        result.put("versionId",v.get("id"));result.put("versionNumber",v.get("version_number"));result.put("documentNumber",v.get("document_number"));
        result.put("issueDate",v.get("issue_date")==null?null:v.get("issue_date").toString());result.put("expiryDate",v.get("expiry_date")==null?null:v.get("expiry_date").toString());result.put("notes",v.get("notes"));result.put("createdAt",v.get("created_at"));
        result.put("status",status(v.get("expiry_date")==null?null:((Date)v.get("expiry_date")).toLocalDate(),today(),d.get("archived_at")!=null,!v.get("id").equals(d.get("current_version_id"))));
        return result;
    }
    private Map<String,Object> current(UUID w,UUID id) {var d=doc(w,id,false);return view(d,version(w,id,(UUID)d.get("current_version_id")));}
    public Map<String,Object> get(Actor actor,UUID w,UUID id) {access.resource(actor,w,"equipment_document",id,"DOCUMENT_VIEW");return current(w,id);}
    public Map<String,Object> getVersion(Actor actor,UUID w,UUID id,UUID version) {access.resource(actor,w,"equipment_document",id,"DOCUMENT_VIEW");return view(doc(w,id,false),version(w,id,version));}
    public List<Map<String,Object>> versions(Actor actor,UUID w,UUID id) {access.resource(actor,w,"equipment_document",id,"DOCUMENT_VIEW");var d=doc(w,id,false);return db.queryForList("select * from document_version where workspace_id=? and document_id=? order by version_number desc",w,id).stream().map(v->view(d,v)).toList();}
    public List<Map<String,Object>> list(Actor actor,UUID w,UUID equipment,boolean archived) {
        access.equipment(actor,w,equipment,"DOCUMENT_VIEW");equipment(w,equipment);
        return db.queryForList("select id from equipment_document where workspace_id=? and equipment_id=? and archived_at is "+(archived?"not null":"null")+" order by created_at desc,id desc",w,equipment).stream().map(r->current(w,(UUID)r.get("id"))).toList();
    }
    public List<Map<String,Object>> incomplete(Actor actor,UUID w) {
        Access.Member member=access.require(actor,w,"DOCUMENT_VIEW");
        return db.queryForList("select d.id from equipment_document d join equipment e on e.workspace_id=d.workspace_id and e.id=d.equipment_id join document_version v on v.workspace_id=d.workspace_id and v.id=d.current_version_id where d.workspace_id=? and d.archived_at is null and e.archived_at is null and v.expiry_date is null order by d.created_at desc",w).stream().filter(r->access.contains(member,w,(UUID)db.queryForMap("select equipment_id from equipment_document where workspace_id=? and id=?",w,r.get("id")).get("equipment_id"))).toList().stream().map(r->current(w,(UUID)r.get("id"))).toList();
    }
    private void equipment(UUID w,UUID id) {Boolean found=db.queryForObject("select exists(select 1 from equipment where workspace_id=? and id=?)",Boolean.class,w,id);if(!Boolean.TRUE.equals(found))throw ApiException.missing();}
    public List<Map<String,Object>> duplicate(Actor actor,UUID w,UUID equipment,String requestedType,String name) {
        access.equipment(actor,w,equipment,"DOCUMENT_VIEW");equipment(w,equipment);String t=type(requestedType),c=custom(t,name);
        return db.queryForList("select id from equipment_document where workspace_id=? and equipment_id=? and type=? and custom_type_name is not distinct from ? and archived_at is null order by created_at desc",w,equipment,t,c).stream().map(r->current(w,(UUID)r.get("id"))).toList();
    }
    @Transactional
    public Map<String,Object> create(Actor actor,UUID w,UUID equipment,String key,Input input) {
        access.equipment(actor,w,equipment,"DOCUMENT_MANAGE");equipment(w,equipment);
        if(db.queryForObject("select archived_at is not null from equipment where workspace_id=? and id=? for update",Boolean.class,w,equipment))throw new ApiException(409,"EQUIPMENT_ARCHIVED","استعد المعدة قبل إضافة مستند");
        String t=type(input.type()),c=custom(t,input.customTypeName());Fields f=fields(input.documentNumber(),input.issueDate(),input.expiryDate(),input.notes(),false);
        UUID id=retries.execute(w,actor.userId(),"document.create:"+equipment,key,Values.payload(t,c,f.number(),f.issue(),f.expiry(),f.notes()),()->{
            UUID created=UUID.randomUUID(),v=UUID.randomUUID();
            db.update("insert into equipment_document(id,workspace_id,equipment_id,type,custom_type_name,current_version_id,created_by) values(?,?,?,?,?,?,?)",created,w,equipment,t,c,v,actor.userId());
            db.update("insert into document_version(id,workspace_id,document_id,version_number,document_number,issue_date,expiry_date,notes,created_by) values(?,?,?,?,?,?,?,?,?)",v,w,created,1,f.number(),f.issue(),f.expiry(),f.notes(),actor.userId());
            audit.record(w,actor.userId(),"DOCUMENT_CREATED",created);notifications.currentState(w,created);return created;
        });return current(w,id);
    }
    @Transactional
    public Map<String,Object> edit(Actor actor,UUID w,UUID id,Edit input) {
        access.resource(actor,w,"equipment_document",id,"DOCUMENT_MANAGE");var d=doc(w,id,true);if(d.get("archived_at")!=null)throw new ApiException(409,"DOCUMENT_ARCHIVED","استعد المستند قبل تعديله");
        if(d.get("equipment_archived_at")!=null)throw new ApiException(409,"EQUIPMENT_ARCHIVED","استعد المعدة قبل تعديل المستند");
        if(input.expectedVersionId()==null || !input.expectedVersionId().equals(d.get("current_version_id")))throw new ApiException(409,"DOCUMENT_VERSION_CHANGED","تغيرت النسخة الحالية. حدّث الصفحة قبل التعديل");
        String t=type(input.type()),c=custom(t,input.customTypeName());
        Integer count=db.queryForObject("select count(*) from document_version where workspace_id=? and document_id=?",Integer.class,w,id);
        if(count!=null && count>1 && (!t.equals(d.get("type")) || !Objects.equals(c,d.get("custom_type_name"))))throw new ApiException(409,"TYPE_LOCKED","لا يمكن تغيير نوع المستند بعد تجديده");
        Fields f=fields(input.documentNumber(),input.issueDate(),input.expiryDate(),input.notes(),false);
        var before=version(w,id,(UUID)d.get("current_version_id"));
        db.update("update equipment_document set type=?,custom_type_name=? where workspace_id=? and id=?",t,c,w,id);
        db.update("update document_version set document_number=?,issue_date=?,expiry_date=?,notes=? where workspace_id=? and document_id=? and id=?",f.number(),f.issue(),f.expiry(),f.notes(),w,id,d.get("current_version_id"));
        audit.record(w,actor.userId(),"DOCUMENT_UPDATED",id,"{\"beforeExpiry\":"+jsonDate(before.get("expiry_date"))+",\"afterExpiry\":"+jsonDate(f.expiry())+"}");
        if(!Objects.equals(before.get("expiry_date"),f.expiry()==null?null:Date.valueOf(f.expiry())))notifications.currentState(w,id);return current(w,id);
    }
    private String jsonDate(Object value) {return value==null?"null":"\""+value+"\"";}
    @Transactional
    public Map<String,Object> renew(Actor actor,UUID w,UUID id,Renew input) {
        access.resource(actor,w,"equipment_document",id,"DOCUMENT_MANAGE");var d=doc(w,id,true);if(d.get("archived_at")!=null)throw new ApiException(409,"DOCUMENT_ARCHIVED","استعد المستند قبل التجديد");
        if(d.get("equipment_archived_at")!=null)throw new ApiException(409,"EQUIPMENT_ARCHIVED","استعد المعدة قبل تجديد المستند");
        if(input.expectedVersionId()==null || !input.expectedVersionId().equals(d.get("current_version_id")))throw new ApiException(409,"DOCUMENT_ALREADY_RENEWED","تم تجديد هذا المستند بالفعل. حدّث الصفحة لمشاهدة النسخة الحالية");
        Fields f=fields(input.documentNumber(),input.issueDate(),input.expiryDate(),input.notes(),true);
        Integer old=db.queryForObject("select version_number from document_version where workspace_id=? and document_id=? and id=?",Integer.class,w,id,input.expectedVersionId());
        UUID next=UUID.randomUUID();db.update("insert into document_version(id,workspace_id,document_id,version_number,document_number,issue_date,expiry_date,notes,created_by) values(?,?,?,?,?,?,?,?,?)",next,w,id,old+1,f.number(),f.issue(),f.expiry(),f.notes(),actor.userId());
        db.update("update equipment_document set current_version_id=? where workspace_id=? and id=?",next,w,id);audit.record(w,actor.userId(),"DOCUMENT_RENEWED",id);notifications.currentState(w,id);return current(w,id);
    }
    @Transactional
    public Map<String,Object> archive(Actor actor,UUID w,UUID id,String reason) {
        access.resource(actor,w,"equipment_document",id,"DOCUMENT_MANAGE");var d=doc(w,id,true);if(d.get("archived_at")!=null)return current(w,id);
        db.update("update equipment_document set archived_at=now(),archived_by=?,archive_reason=? where workspace_id=? and id=?",actor.userId(),Values.note(reason),w,id);
        audit.record(w,actor.userId(),"DOCUMENT_ARCHIVED",id);return current(w,id);
    }
    @Transactional
    public Map<String,Object> restore(Actor actor,UUID w,UUID id) {
        access.resource(actor,w,"equipment_document",id,"DOCUMENT_MANAGE");var d=doc(w,id,true);if(d.get("equipment_archived_at")!=null)throw new ApiException(409,"EQUIPMENT_ARCHIVED","استعد المعدة قبل المستند");
        if(d.get("archived_at")==null)return current(w,id);
        db.update("update equipment_document set archived_at=null,archived_by=null,archive_reason=null where workspace_id=? and id=?",w,id);
        audit.record(w,actor.userId(),"DOCUMENT_RESTORED",id);notifications.currentState(w,id);return current(w,id);
    }
    public void requireVersion(UUID w,UUID id,UUID v) {doc(w,id,false);version(w,id,v);}
}
