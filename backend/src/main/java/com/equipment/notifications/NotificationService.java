package com.equipment.notifications;

import com.equipment.common.ApiException;
import com.equipment.documents.DocumentService;
import com.equipment.identity.Actor;
import com.equipment.workspaces.Access;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.*;
import java.time.temporal.TemporalAdjusters;
import java.util.*;
import tools.jackson.databind.json.JsonMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

@Service
public class NotificationService {
    private static final Logger LOG=LoggerFactory.getLogger(NotificationService.class);
    private static final JsonMapper JSON=JsonMapper.builder().build();
    private static final ZoneId ZONE=ZoneId.of("Asia/Riyadh");
    private final JdbcTemplate db;private final Access access;private final Clock clock;private final PushNotificationSender push;
    public NotificationService(JdbcTemplate db,Access access,Clock clock,PushNotificationSender push){this.db=db;this.access=access;this.clock=clock;this.push=push;}
    public record Notification(UUID id,String type,String entityType,UUID entityId,String title,String body,String templateKey,Map<String,Object> params,String createdAt,String readAt) {}
    public record Page(List<Notification> items,int page,int pageSize,long total) {}
    private record Current(UUID workspace,UUID document,UUID version,UUID equipment,String equipmentName,String type,String customName,LocalDate expiry) {}
    private LocalDate today(){return LocalDate.now(clock.withZone(ZONE));}
    private List<Current> active(UUID workspace,UUID document){
        String sql="select d.workspace_id,d.id as document_id,d.current_version_id,d.equipment_id,e.name as equipment_name,d.type,d.custom_type_name,v.expiry_date from equipment_document d join equipment e on e.workspace_id=d.workspace_id and e.id=d.equipment_id join document_version v on v.workspace_id=d.workspace_id and v.id=d.current_version_id where d.archived_at is null and e.archived_at is null"+(workspace==null?"":" and d.workspace_id=?")+(document==null?"":" and d.id=?");
        Object[] args=workspace==null?new Object[]{}:document==null?new Object[]{workspace}:new Object[]{workspace,document};
        return db.query(sql,(rs,n)->new Current(rs.getObject("workspace_id",UUID.class),rs.getObject("document_id",UUID.class),rs.getObject("current_version_id",UUID.class),rs.getObject("equipment_id",UUID.class),rs.getString("equipment_name"),rs.getString("type"),rs.getString("custom_type_name"),rs.getDate("expiry_date")==null?null:rs.getDate("expiry_date").toLocalDate()),args);
    }
    private UUID owner(UUID workspace){
        var rows=db.query("select m.user_id from membership m join workspace w on w.id=m.workspace_id and w.owner_id=m.user_id where m.workspace_id=? and m.active=true and m.role='OWNER'",(rs,n)->rs.getObject(1,UUID.class),workspace);
        return rows.isEmpty()?null:rows.getFirst();
    }
    private String label(Current d){return "OTHER".equals(d.type())?d.customName():switch(d.type()){case "REGISTRATION"->"الاستمارة";case "INSURANCE"->"التأمين";case "PERIODIC_INSPECTION"->"الفحص الدوري";default->"الترخيص / التصريح";};}
    private String body(Current d,long days){
        String suffix=days<0?"منتهي منذ "+(-days)+" يوم":days==0?"ينتهي اليوم":days==1?"ينتهي غدًا":"ينتهي بعد "+days+" أيام";
        return label(d)+" — "+d.equipmentName()+": "+suffix;
    }
    private String bucket(long days){return days<0?"EXPIRED":days==0?"TODAY":days<=1?"1D":days<=7?"7D":days<=30?"30D":"FUTURE";}
    private String identity(Current d){return d.version()+":"+d.expiry();}
    private Map<String,Object> documentParams(Current d,long days){
        Map<String,Object> params=new LinkedHashMap<>();params.put("documentType",d.type());params.put("customTypeName",d.customName());params.put("equipmentName",d.equipmentName());params.put("daysRemaining",days);return params;
    }
    private String preferredLocale(UUID recipient){
        String locale=db.queryForObject("select preferred_locale from app_user where id=?",String.class,recipient);
        return locale==null?"ar":locale;
    }
    private boolean insert(UUID workspace,UUID recipient,String type,String entityType,UUID entity,String title,String body,String dedupe,String templateKey,Map<String,Object> params){
        UUID id=UUID.randomUUID();int written=db.update("insert into notification(id,workspace_id,recipient_user_id,type,entity_type,entity_id,title,body,dedupe_key,template_key,template_params) values(?,?,?,?,?,?,?,?,?,?,cast(? as jsonb)) on conflict (workspace_id,recipient_user_id,dedupe_key) do nothing",id,workspace,recipient,type,entityType,entity,title,body,dedupe,templateKey,JSON.writeValueAsString(params));
        if(written==1){
            Runnable delivery=()->{try{push.send(workspace,recipient,templateKey,params,preferredLocale(recipient));}catch(RuntimeException e){LOG.warn("Development push delivery failed for notification {}",id,e);}};
            if(TransactionSynchronizationManager.isSynchronizationActive())TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization(){@Override public void afterCommit(){delivery.run();}});
            else delivery.run();
        }
        return written==1;
    }
    /** Called inside the document mutation transaction, after the new current state is stored. */
    public void currentState(UUID workspace,UUID document){currentState(workspace,document,today());}
    public void currentState(UUID workspace,UUID document,LocalDate day){
        UUID recipient=owner(workspace);if(recipient==null)return;
        for(Current d:active(workspace,document)){
            if(d.expiry()==null)continue;long days=java.time.temporal.ChronoUnit.DAYS.between(day,d.expiry());if(days>30)continue;
            String key="DOCUMENT:"+identity(d)+":CURRENT_STATE:"+bucket(days);
            insert(workspace,recipient,"DOCUMENT_CURRENT_STATE","DOCUMENT",d.document(),label(d),body(d,days),key,"DOCUMENT_EXPIRY",documentParams(d,days));
        }
    }
    /** Re-evaluates current documents after equipment restore without touching historical versions. */
    public void equipmentRestored(UUID workspace,UUID equipment){
        for(var row:db.queryForList("select id from equipment_document where workspace_id=? and equipment_id=? and archived_at is null",workspace,equipment)) currentState(workspace,(UUID)row.get("id"));
    }
    private boolean hasKey(UUID workspace,UUID recipient,String key){
        Boolean exists=db.queryForObject("select exists(select 1 from notification where workspace_id=? and recipient_user_id=? and dedupe_key=?)",Boolean.class,workspace,recipient,key);
        return Boolean.TRUE.equals(exists);
    }
    @Transactional
    public int runDaily(LocalDate day){
        int count=0;
        for(Current d:active(null,null)){
            if(d.expiry()==null)continue;UUID recipient=owner(d.workspace());if(recipient==null)continue;
            long days=java.time.temporal.ChronoUnit.DAYS.between(day,d.expiry());String threshold=days==30?"30D":days==7?"7D":days==1?"1D":days==0?"TODAY":null;
            String prefix="DOCUMENT:"+identity(d)+":";
            if(threshold!=null){
                if(hasKey(d.workspace(),recipient,prefix+"CURRENT_STATE:"+threshold))continue;
                if(insert(d.workspace(),recipient,"DOCUMENT_"+threshold,"DOCUMENT",d.document(),label(d),body(d,days),"DOCUMENT:"+identity(d)+":"+threshold,"DOCUMENT_EXPIRY",documentParams(d,days)))count++;
            }else if(days<30 && days>=0){
                String stage=bucket(days);
                if(hasKey(d.workspace(),recipient,prefix+stage))continue;
                if(insert(d.workspace(),recipient,"DOCUMENT_CURRENT_STATE","DOCUMENT",d.document(),label(d),body(d,days),"DOCUMENT:"+identity(d)+":CURRENT_STATE:"+bucket(days),"DOCUMENT_EXPIRY",documentParams(d,days)))count++;
            }
        }
        return count;
    }
    @Transactional
    public int runWeekly(LocalDate day){
        if(day.getDayOfWeek()!=DayOfWeek.SUNDAY)return 0;
        Map<UUID,Integer> expired=new HashMap<>();
        for(Current d:active(null,null))if(d.expiry()!=null && d.expiry().isBefore(day))expired.merge(d.workspace(),1,Integer::sum);
        int count=0;LocalDate weekStart=day.with(TemporalAdjusters.previousOrSame(DayOfWeek.SUNDAY));
        for(var item:expired.entrySet()){
            UUID recipient=owner(item.getKey());if(recipient==null)continue;
            String body="لديك "+item.getValue()+" مستندات منتهية تحتاج متابعة.";
            if(insert(item.getKey(),recipient,"DOCUMENT_EXPIRED_WEEKLY","DOCUMENT_SUMMARY",null,"مستندات منتهية",body,"DOCUMENT:EXPIRED_WEEKLY:"+weekStart,"DOCUMENT_EXPIRED_WEEKLY",Map.of("count",item.getValue())))count++;
        }
        return count;
    }
    @SuppressWarnings("unchecked")
    private Notification view(Map<String,Object> row){
        Object raw=row.get("template_params");Map<String,Object> params=raw==null?null:JSON.readValue(raw.toString(),Map.class);
        return new Notification((UUID)row.get("id"),(String)row.get("type"),(String)row.get("entity_type"),(UUID)row.get("entity_id"),(String)row.get("title"),(String)row.get("body"),(String)row.get("template_key"),params,((Timestamp)row.get("created_at")).toInstant().toString(),row.get("read_at")==null?null:((Timestamp)row.get("read_at")).toInstant().toString());
    }
    public Page list(Actor actor,UUID workspace,int page){
        access.owner(actor,workspace);if(page<0 || page>100000)throw ApiException.invalid("رقم الصفحة غير صالح");
        var rows=db.queryForList("select * from notification where workspace_id=? and recipient_user_id=? order by created_at desc,id desc limit 30 offset ?",workspace,actor.userId(),page*30);
        Long total=db.queryForObject("select count(*) from notification where workspace_id=? and recipient_user_id=?",Long.class,workspace,actor.userId());
        return new Page(rows.stream().map(this::view).toList(),page,30,total);
    }
    public Map<String,Long> unreadCount(Actor actor,UUID workspace){
        access.owner(actor,workspace);Long count=db.queryForObject("select count(*) from notification where workspace_id=? and recipient_user_id=? and read_at is null",Long.class,workspace,actor.userId());return Map.of("unreadCount",count);
    }
    @Transactional
    public Notification read(Actor actor,UUID workspace,UUID id){
        access.owner(actor,workspace);int changed=db.update("update notification set read_at=coalesce(read_at,now()) where workspace_id=? and recipient_user_id=? and id=?",workspace,actor.userId(),id);
        if(changed==0)throw ApiException.missing();return view(db.queryForMap("select * from notification where workspace_id=? and recipient_user_id=? and id=?",workspace,actor.userId(),id));
    }
    @Transactional
    public Map<String,Integer> readAll(Actor actor,UUID workspace){
        access.owner(actor,workspace);int count=db.update("update notification set read_at=now() where workspace_id=? and recipient_user_id=? and read_at is null",workspace,actor.userId());return Map.of("markedRead",count);
    }
    public List<Map<String,Object>> attention(Actor actor,UUID workspace,UUID equipment){
        access.owner(actor,workspace);
        if(equipment!=null){Boolean found=db.queryForObject("select exists(select 1 from equipment where workspace_id=? and id=?)",Boolean.class,workspace,equipment);if(!Boolean.TRUE.equals(found))throw ApiException.missing();}
        LocalDate day=today();List<Map<String,Object>> items=new ArrayList<>();
        for(Current d:active(workspace,null)){
            if(equipment!=null && !equipment.equals(d.equipment()))continue;
            if(d.expiry()==null)continue;long days=java.time.temporal.ChronoUnit.DAYS.between(day,d.expiry());if(days>30)continue;
            Map<String,Object> item=new LinkedHashMap<>();item.put("documentId",d.document());item.put("equipmentId",d.equipment());item.put("equipmentName",d.equipmentName());item.put("type",d.type());item.put("customTypeName",d.customName());item.put("expiryDate",d.expiry());item.put("daysRemaining",days);item.put("status",DocumentService.status(d.expiry(),day,false,false));item.put("body",body(d,days));items.add(item);
        }
        items.sort(Comparator.comparingLong(i->(long)i.get("daysRemaining")));return items;
    }
    public List<Map<String,Object>> operationalAttention(Actor actor,UUID workspace,UUID equipment){
        access.owner(actor,workspace);
        List<Map<String,Object>> result=new ArrayList<>();
        for(var row:db.queryForList("select i.id,i.equipment_id,i.description,i.equipment_stopped,i.created_at,e.name as equipment_name from equipment_issue i join equipment e on e.workspace_id=i.workspace_id and e.id=i.equipment_id where i.workspace_id=? and i.status='OPEN' and e.archived_at is null"+(equipment==null?"":" and i.equipment_id=?")+" order by i.equipment_stopped desc,i.created_at desc,i.id desc",equipment==null?new Object[]{workspace}:new Object[]{workspace,equipment})){
            Map<String,Object> item=new LinkedHashMap<>();item.put("entityType","ISSUE");item.put("issueId",row.get("id"));item.put("equipmentId",row.get("equipment_id"));item.put("equipmentName",row.get("equipment_name"));item.put("description",row.get("description"));item.put("equipmentStopped",row.get("equipment_stopped"));item.put("status","OPEN");item.put("priorityRank",Boolean.TRUE.equals(row.get("equipment_stopped"))?1:4);item.put("createdAt",((Timestamp)row.get("created_at")).toInstant().toString());result.add(item);
        }
        for(var document:attention(actor,workspace,equipment)){
            Map<String,Object> item=new LinkedHashMap<>(document);long days=(long)item.get("daysRemaining");item.put("entityType","DOCUMENT");item.put("priorityRank",days<0?2:days==0?3:days<=1?5:days<=7?6:7);result.add(item);
        }
        result.sort(Comparator.comparingInt(i->(int)i.get("priorityRank")));
        return result;
    }
}
