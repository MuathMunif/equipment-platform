package com.equipment.finance;

import com.equipment.audit.Audit;
import com.equipment.common.*;
import com.equipment.equipment.EquipmentService;
import com.equipment.identity.Actor;
import com.equipment.workspaces.Access;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;
import tools.jackson.databind.json.JsonMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class FinanceService {
    private final JdbcTemplate db; private final Access access; private final EquipmentService equipment; private final Idempotency retries; private final Audit audit;
    public FinanceService(JdbcTemplate db,Access access,EquipmentService equipment,Idempotency retries,Audit audit) { this.db=db; this.access=access; this.equipment=equipment; this.retries=retries; this.audit=audit; }
    public record Create(UUID equipmentId,tools.jackson.databind.JsonNode amount,String category,String operationDate,String paidOn,String note,String paymentStatus,tools.jackson.databind.JsonNode initialPaid,String partyName,String dueDate,String entryType) {}
    public record AddSettlement(tools.jackson.databind.JsonNode amount,String paidOn) {}
    public record Edit(tools.jackson.databind.JsonNode amount,String category,String operationDate,String note,String partyName,String dueDate) {}
    public record Cancel(String reason) {}
    public record Settlement(UUID id,String amount,String paidOn) {}
    public record Entry(UUID id,UUID equipmentId,String equipmentName,String entryType,String amount,String currency,String category,String operationDate,String note,String lifecycle,String paid,String remaining,String settlementStatus,String partyName,String dueDate,String createdAt,String cancellationReason,String cancelledAt,UUID cancelledBy,List<Settlement> settlements) {}
    private static final JsonMapper JSON=JsonMapper.builder().build();
    public Entry get(Actor actor,UUID workspace,UUID id) { access.owner(actor,workspace); return require(workspace,id); }
    public Entry require(UUID workspace,UUID id) {
        var rows=db.queryForList("select f.*,e.name as equipment_name from financial_entry f join equipment e on e.workspace_id=f.workspace_id and e.id=f.equipment_id where f.workspace_id=? and f.id=?",workspace,id);
        if(rows.isEmpty()) throw ApiException.missing(); var row=rows.getFirst();
        var settlements=db.query("select * from settlement where workspace_id=? and entry_id=? order by paid_on,created_at",(rs,n)->new Settlement(rs.getObject("id",UUID.class),rs.getBigDecimal("amount").toPlainString(),rs.getDate("paid_on").toLocalDate().toString()),workspace,id);
        BigDecimal paid=settlements.stream().map(s->new BigDecimal(s.amount())).reduce(new BigDecimal("0.00"),BigDecimal::add),amount=(BigDecimal)row.get("amount"),remaining=amount.subtract(paid);
        return new Entry(id,(UUID)row.get("equipment_id"),(String)row.get("equipment_name"),(String)row.get("entry_type"),amount.toPlainString(),"SAR",(String)row.get("category"),row.get("operation_date").toString(),(String)row.get("note"),(String)row.get("lifecycle"),paid.toPlainString(),remaining.toPlainString(),remaining.signum()==0?"PAID":paid.signum()==0?"UNPAID":"PARTIAL",(String)row.get("party_name"),row.get("due_date")==null?null:row.get("due_date").toString(),((java.sql.Timestamp)row.get("created_at")).toInstant().toString(),(String)row.get("cancellation_reason"),row.get("cancelled_at")==null?null:((java.sql.Timestamp)row.get("cancelled_at")).toInstant().toString(),(UUID)row.get("cancelled_by"),settlements);
    }
    public Map<String,Object> list(Actor actor,UUID workspace,UUID equipmentId,int page) {
        access.owner(actor,workspace); if(page<0 || page>100000) throw ApiException.invalid("رقم الصفحة غير صالح");
        if(equipmentId!=null) equipment.require(workspace,equipmentId);
        String filter=equipmentId==null?"":" and equipment_id=?";
        Object[] args=equipmentId==null?new Object[]{workspace,30,page*30}:new Object[]{workspace,equipmentId,30,page*30};
        var ids=db.query("select id from financial_entry where workspace_id=?"+filter+" order by created_at desc,id desc limit ? offset ?",(rs,n)->rs.getObject("id",UUID.class),args);
        Long count=equipmentId==null?db.queryForObject("select count(*) from financial_entry where workspace_id=?",Long.class,workspace):db.queryForObject("select count(*) from financial_entry where workspace_id=? and equipment_id=?",Long.class,workspace,equipmentId);
        return Map.of("items",ids.stream().map(id->require(workspace,id)).toList(),"page",page,"pageSize",30,"total",count);
    }
    @Transactional
    public Entry create(Actor actor,UUID workspace,String key,Create request) {
        access.owner(actor,workspace); if(request.equipmentId()==null) throw ApiException.invalid("حدد المعدة"); equipment.require(workspace,request.equipmentId());
        if(request.amount()==null || !request.amount().isString()) throw ApiException.invalid("أرسل المبلغ كنص عشري بمنزلتين، مثل 350.00");
        String type=request.entryType()==null?"EXPENSE":request.entryType();
        if(!Set.of("EXPENSE","INCOME").contains(type)) throw ApiException.invalid("اختر نوع العملية");
        BigDecimal amount=Values.money(request.amount().asString()); LocalDate date=Values.date(request.operationDate());
        String status=request.paymentStatus()==null?"FULL":request.paymentStatus();
        if(!Set.of("FULL","PARTIAL","UNPAID").contains(status)) throw ApiException.invalid(type.equals("INCOME")?"اختر حالة التحصيل":"اختر حالة الدفع");
        BigDecimal initial;
        if(status.equals("FULL")) {
            if(request.initialPaid()!=null) throw ApiException.invalid("المبلغ الأولي غير مطلوب عند الدفع الكامل");
            initial=amount;
        } else if(status.equals("PARTIAL")) {
            if(request.initialPaid()==null || !request.initialPaid().isString()) throw ApiException.invalid(type.equals("INCOME")?"حدد المبلغ المستلم أولًا":"حدد المبلغ المدفوع أولًا");
            initial=Values.money(request.initialPaid().asString());
            if(initial.compareTo(amount)>=0) throw ApiException.invalid(type.equals("INCOME")?"التحصيل الأول يجب أن يقل عن الإجمالي":"الدفعة الأولى يجب أن تقل عن الإجمالي");
        } else {
            if(request.initialPaid()!=null || request.paidOn()!=null) throw ApiException.invalid(type.equals("INCOME")?"لا يوجد تحصيل عند اختيار غير مستلم":"لا توجد دفعة عند اختيار غير مدفوع");
            initial=new BigDecimal("0.00");
        }
        LocalDate paidOn=initial.signum()>0?Values.date(request.paidOn()):null;
        String party=initial.compareTo(amount)<0?Values.text(request.partyName(),100,"اسم الطرف"):null;
        if(initial.compareTo(amount)==0 && request.partyName()!=null && !request.partyName().isBlank()) throw ApiException.invalid("اسم الطرف مطلوب فقط عند وجود متبقٍ");
        LocalDate due=request.dueDate()==null || request.dueDate().isBlank()?null:Values.date(request.dueDate());
        if(initial.compareTo(amount)==0 && due!=null) throw ApiException.invalid("موعد الاستحقاق مطلوب فقط عند وجود متبقٍ");
        String category=type.equals("INCOME")?"OTHER":Values.text(request.category(),30,"نوع المصروف"),note=Values.note(request.note());
        if(type.equals("INCOME") && request.category()!=null && !request.category().equals("OTHER")) throw ApiException.invalid("نوع الإيراد غير صالح");
        if(type.equals("EXPENSE") && !Set.of("FUEL","MAINTENANCE","OTHER").contains(category)) throw ApiException.invalid("اختر نوع المصروف");
        String payload=request.entryType()==null
            ? request.paymentStatus()==null
                ? Values.payload(request.equipmentId(),amount,category,date,paidOn,note)
                : Values.payload(request.equipmentId(),amount,category,date,paidOn,note,status,initial,party,due)
            : Values.payload(request.equipmentId(),amount,category,date,paidOn,note,status,initial,party,due,type);
        UUID id=retries.execute(workspace,actor.userId(),type.equals("INCOME")?"income.create":"expense.create",key,payload,()->{
            UUID created=UUID.randomUUID();
            db.update("insert into financial_entry(id,workspace_id,equipment_id,amount,currency,category,operation_date,note,lifecycle,created_by,party_name,due_date,entry_type) values(?,?,?,?,'SAR',?,?,?,'POSTED',?,?,?,?)",created,workspace,request.equipmentId(),amount,category,java.sql.Date.valueOf(date),note,actor.userId(),party,due==null?null:java.sql.Date.valueOf(due),type);
            if(initial.signum()>0) db.update("insert into settlement(id,workspace_id,entry_id,amount,paid_on,created_by) values(?,?,?,?,?,?)",UUID.randomUUID(),workspace,created,initial,java.sql.Date.valueOf(paidOn),actor.userId());
            audit.record(workspace,actor.userId(),type.equals("INCOME")?"INCOME_CREATED":initial.compareTo(amount)==0?"PAID_EXPENSE_CREATED":"EXPENSE_CREATED",created); return created;
        }); return require(workspace,id);
    }
    @Transactional
    public Entry settle(Actor actor,UUID workspace,UUID entryId,String key,AddSettlement request) {
        access.owner(actor,workspace); require(workspace,entryId);
        if(request.amount()==null || !request.amount().isString()) throw ApiException.invalid("أرسل المبلغ كنص عشري");
        BigDecimal amount=Values.money(request.amount().asString()); LocalDate paidOn=Values.date(request.paidOn());
        String type=require(workspace,entryId).entryType();
        retries.execute(workspace,actor.userId(),type.equals("INCOME")?"income.settle":"expense.settle",key,Values.payload(entryId,amount,paidOn),()->{
            var rows=db.queryForList("select amount,lifecycle from financial_entry where workspace_id=? and id=? for update",workspace,entryId);
            if(rows.isEmpty()) throw ApiException.missing();
            if(!"POSTED".equals(rows.getFirst().get("lifecycle"))) throw ApiException.invalid("لا يمكن إضافة تسوية لعملية ملغاة");
            BigDecimal total=(BigDecimal)rows.getFirst().get("amount");
            BigDecimal paid=db.queryForObject("select coalesce(sum(amount),0) from settlement where workspace_id=? and entry_id=?",BigDecimal.class,workspace,entryId);
            if(amount.compareTo(total.subtract(paid))>0) throw ApiException.invalid(type.equals("INCOME")?"التحصيل أكبر من المتبقي":"الدفعة أكبر من المتبقي");
            UUID settlementId=UUID.randomUUID();
            db.update("insert into settlement(id,workspace_id,entry_id,amount,paid_on,created_by) values(?,?,?,?,?,?)",settlementId,workspace,entryId,amount,java.sql.Date.valueOf(paidOn),actor.userId());
            audit.record(workspace,actor.userId(),type.equals("INCOME")?"INCOME_SETTLED":"EXPENSE_SETTLED",entryId);
            return settlementId;
        });
        return require(workspace,entryId);
    }
    @Transactional
    public Entry edit(Actor actor,UUID workspace,UUID entryId,Edit request) {
        access.owner(actor,workspace);
        var rows=db.queryForList("select * from financial_entry where workspace_id=? and id=? for update",workspace,entryId);
        if(rows.isEmpty()) throw ApiException.missing();
        var previous=rows.getFirst();
        if(!"POSTED".equals(previous.get("lifecycle"))) throw ApiException.invalid("لا يمكن تعديل عملية ملغاة");
        if(request.amount()==null || !request.amount().isString()) throw ApiException.invalid("أرسل المبلغ كنص عشري بمنزلتين");
        BigDecimal amount=Values.money(request.amount().asString());
        BigDecimal paid=db.queryForObject("select coalesce(sum(amount),0) from settlement where workspace_id=? and entry_id=?",BigDecimal.class,workspace,entryId);
        if(amount.compareTo(paid)<0) throw ApiException.invalid("الإجمالي لا يقل عن مجموع التسويات");
        String type=(String)previous.get("entry_type");
        String category=type.equals("INCOME")?"OTHER":Values.text(request.category(),30,"نوع المصروف");
        if(type.equals("INCOME") && request.category()!=null && !request.category().equals("OTHER")) throw ApiException.invalid("نوع الإيراد غير صالح");
        if(type.equals("EXPENSE") && !Set.of("FUEL","MAINTENANCE","OTHER").contains(category)) throw ApiException.invalid("اختر نوع المصروف");
        LocalDate date=Values.date(request.operationDate()); String note=Values.note(request.note());
        String party=request.partyName()==null || request.partyName().isBlank()?null:Values.text(request.partyName(),100,"اسم الطرف");
        if(amount.compareTo(paid)>0 && party==null) throw ApiException.invalid("اكتب اسم الطرف عند وجود متبقٍ");
        LocalDate due=request.dueDate()==null || request.dueDate().isBlank()?null:Values.date(request.dueDate());
        if(amount.compareTo(paid)==0 && due!=null) throw ApiException.invalid("موعد الاستحقاق مطلوب فقط عند وجود متبقٍ");
        var before=financialSnapshot(previous,paid);
        db.update("update financial_entry set amount=?,category=?,operation_date=?,note=?,party_name=?,due_date=? where workspace_id=? and id=?",amount,category,java.sql.Date.valueOf(date),note,party,due==null?null:java.sql.Date.valueOf(due),workspace,entryId);
        var after=new LinkedHashMap<String,Object>(before);
        after.put("amount",amount.toPlainString()); after.put("category",category); after.put("operationDate",date.toString()); after.put("note",note); after.put("partyName",party); after.put("dueDate",due==null?null:due.toString());
        audit.record(workspace,actor.userId(),type.equals("INCOME")?"INCOME_EDITED":"EXPENSE_EDITED",entryId,JSON.writeValueAsString(Map.of("before",before,"after",after)));
        return require(workspace,entryId);
    }
    @Transactional
    public Entry cancel(Actor actor,UUID workspace,UUID entryId,Cancel request) {
        access.owner(actor,workspace);
        String reason=Values.text(request.reason(),500,"سبب الإلغاء");
        var rows=db.queryForList("select * from financial_entry where workspace_id=? and id=? for update",workspace,entryId);
        if(rows.isEmpty()) throw ApiException.missing();
        var previous=rows.getFirst();
        if(!"POSTED".equals(previous.get("lifecycle"))) throw ApiException.invalid("العملية ملغاة مسبقًا");
        BigDecimal paid=db.queryForObject("select coalesce(sum(amount),0) from settlement where workspace_id=? and entry_id=?",BigDecimal.class,workspace,entryId);
        db.update("update financial_entry set lifecycle='CANCELLED',cancellation_reason=?,cancelled_at=now(),cancelled_by=? where workspace_id=? and id=?",reason,actor.userId(),workspace,entryId);
        audit.record(workspace,actor.userId(),"FINANCIAL_ENTRY_CANCELLED",entryId,JSON.writeValueAsString(Map.of("reason",reason,"before",financialSnapshot(previous,paid))));
        return require(workspace,entryId);
    }
    private Map<String,Object> financialSnapshot(Map<String,Object> row,BigDecimal paid) {
        var snapshot=new LinkedHashMap<String,Object>();
        snapshot.put("entryType",row.get("entry_type")); snapshot.put("amount",((BigDecimal)row.get("amount")).toPlainString());
        snapshot.put("paid",paid.toPlainString()); snapshot.put("remaining",((BigDecimal)row.get("amount")).subtract(paid).toPlainString());
        snapshot.put("category",row.get("category")); snapshot.put("operationDate",row.get("operation_date").toString());
        snapshot.put("note",row.get("note")); snapshot.put("partyName",row.get("party_name"));
        snapshot.put("dueDate",row.get("due_date")==null?null:row.get("due_date").toString());
        snapshot.put("lifecycle",row.get("lifecycle"));
        return snapshot;
    }
}
