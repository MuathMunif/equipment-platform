package com.equipment.finance;

import com.equipment.audit.Audit;
import com.equipment.common.*;
import com.equipment.equipment.EquipmentService;
import com.equipment.identity.Actor;
import com.equipment.workspaces.Access;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class FinanceService {
    private final JdbcTemplate db; private final Access access; private final EquipmentService equipment; private final Idempotency retries; private final Audit audit;
    public FinanceService(JdbcTemplate db,Access access,EquipmentService equipment,Idempotency retries,Audit audit) { this.db=db; this.access=access; this.equipment=equipment; this.retries=retries; this.audit=audit; }
    public record Create(UUID equipmentId,tools.jackson.databind.JsonNode amount,String category,String operationDate,String paidOn,String note) {}
    public record Settlement(UUID id,String amount,String paidOn) {}
    public record Entry(UUID id,UUID equipmentId,String equipmentName,String amount,String currency,String category,String operationDate,String note,String lifecycle,String paid,String remaining,String settlementStatus,String createdAt,List<Settlement> settlements) {}
    public Entry get(Actor actor,UUID workspace,UUID id) { access.owner(actor,workspace); return require(workspace,id); }
    public Entry require(UUID workspace,UUID id) {
        var rows=db.queryForList("select f.*,e.name as equipment_name from financial_entry f join equipment e on e.workspace_id=f.workspace_id and e.id=f.equipment_id where f.workspace_id=? and f.id=?",workspace,id);
        if(rows.isEmpty()) throw ApiException.missing(); var row=rows.getFirst();
        var settlements=db.query("select * from settlement where workspace_id=? and entry_id=? order by paid_on,created_at",(rs,n)->new Settlement(rs.getObject("id",UUID.class),rs.getBigDecimal("amount").toPlainString(),rs.getDate("paid_on").toLocalDate().toString()),workspace,id);
        BigDecimal paid=settlements.stream().map(s->new BigDecimal(s.amount())).reduce(new BigDecimal("0.00"),BigDecimal::add),amount=(BigDecimal)row.get("amount"),remaining=amount.subtract(paid);
        return new Entry(id,(UUID)row.get("equipment_id"),(String)row.get("equipment_name"),amount.toPlainString(),"SAR",(String)row.get("category"),row.get("operation_date").toString(),(String)row.get("note"),"POSTED",paid.toPlainString(),remaining.toPlainString(),remaining.signum()==0?"PAID":paid.signum()==0?"UNPAID":"PARTIAL",((java.sql.Timestamp)row.get("created_at")).toInstant().toString(),settlements);
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
        BigDecimal amount=Values.money(request.amount().asString()); LocalDate date=Values.date(request.operationDate()),paidOn=Values.date(request.paidOn());
        String category=Values.text(request.category(),30,"نوع المصروف"),note=Values.note(request.note());
        if(!Set.of("FUEL","MAINTENANCE","OTHER").contains(category)) throw ApiException.invalid("اختر نوع المصروف");
        UUID id=retries.execute(workspace,actor.userId(),"expense.create",key,Values.payload(request.equipmentId(),amount,category,date,paidOn,note),()->{
            UUID created=UUID.randomUUID();
            db.update("insert into financial_entry(id,workspace_id,equipment_id,amount,currency,category,operation_date,note,lifecycle,created_by) values(?,?,?,?,'SAR',?,?,?,'POSTED',?)",created,workspace,request.equipmentId(),amount,category,java.sql.Date.valueOf(date),note,actor.userId());
            db.update("insert into settlement(id,workspace_id,entry_id,amount,paid_on,created_by) values(?,?,?,?,?,?)",UUID.randomUUID(),workspace,created,amount,java.sql.Date.valueOf(paidOn),actor.userId());
            audit.record(workspace,actor.userId(),"PAID_EXPENSE_CREATED",created); return created;
        }); return require(workspace,id);
    }
}
