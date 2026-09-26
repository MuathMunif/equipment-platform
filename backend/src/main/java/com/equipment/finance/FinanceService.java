package com.equipment.finance;

import com.equipment.audit.Audit;
import com.equipment.common.*;
import com.equipment.equipment.EquipmentService;
import com.equipment.identity.Actor;
import com.equipment.workspaces.Access;
import java.math.BigDecimal;
import java.math.BigInteger;
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
    public record AllocationInput(UUID equipmentId,tools.jackson.databind.JsonNode amount) {}
    public record Create(UUID equipmentId,tools.jackson.databind.JsonNode amount,String category,String operationDate,String paidOn,String note,String paymentStatus,tools.jackson.databind.JsonNode initialPaid,String partyName,String dueDate,String entryType,String expenseScope,List<AllocationInput> allocations,UUID projectId) {
        public Create(UUID equipmentId,tools.jackson.databind.JsonNode amount,String category,String operationDate,String paidOn,String note,String paymentStatus,tools.jackson.databind.JsonNode initialPaid,String partyName,String dueDate,String entryType,String expenseScope,List<AllocationInput> allocations){this(equipmentId,amount,category,operationDate,paidOn,note,paymentStatus,initialPaid,partyName,dueDate,entryType,expenseScope,allocations,null);}
    }
    public record AddSettlement(tools.jackson.databind.JsonNode amount,String paidOn) {}
    public record Edit(tools.jackson.databind.JsonNode amount,String category,String operationDate,String note,String partyName,String dueDate,UUID equipmentId,String expenseScope,List<AllocationInput> allocations) {}
    public record Cancel(String reason) {}
    public record Settlement(UUID id,String amount,String paidOn) {}
    public record CreateRefund(tools.jackson.databind.JsonNode amount,String refundedOn,String reason,String partyName) {}
    public record Refund(UUID id,String amount,String refundedOn,String reason,UUID createdBy,String createdAt) {}
    public record Allocation(UUID equipmentId,String equipmentName,String amount,String paidShare,String refundedShare,String netPaidShare,String remainingShare) {}
    public record Draft(UUID id,UUID equipmentId,String equipmentName,String note,String lifecycle,UUID createdBy,String createdAt,UUID discardedBy,String discardedAt) {}
    public record CreateDraft(UUID equipmentId,String note) {}
    public record HistoryFilter(String search,String fromDate,String toDate,String entryType,UUID equipmentId,Boolean generalExpense,String lifecycle,String settlementStatus) {}
    private record AllocationAmount(UUID equipmentId,String equipmentName,BigDecimal amount) {}
    public record Entry(UUID id,UUID equipmentId,String equipmentName,String entryType,String amount,String currency,String category,String operationDate,String note,String lifecycle,String paid,String refunded,String netPaid,String refundable,String remaining,String settlementStatus,String partyName,String dueDate,String createdAt,String cancellationReason,String cancelledAt,UUID cancelledBy,List<Settlement> settlements,List<Refund> refunds,String expenseScope,List<Allocation> allocations,UUID createdBy,UUID completedBy,String completedAt,UUID submittedBy,UUID submissionId,UUID projectId) {}
    private static final JsonMapper JSON=JsonMapper.builder().build();
    public Entry get(Actor actor,UUID workspace,UUID id) { access.financial(actor,workspace,id,"FINANCE_VIEW"); return require(workspace,id); }
    public void requireAttachable(UUID workspace,UUID id) {
        var lifecycle=db.query("select lifecycle from financial_entry where workspace_id=? and id=?",(rs,n)->rs.getString(1),workspace,id);
        if(lifecycle.isEmpty() || lifecycle.getFirst().equals("DISCARDED")) throw ApiException.missing();
    }
    public Entry require(UUID workspace,UUID id) {
        var rows=db.queryForList("select f.*,e.name as equipment_name from financial_entry f left join equipment e on e.workspace_id=f.workspace_id and e.id=f.equipment_id where f.workspace_id=? and f.id=? and f.lifecycle in ('POSTED','CANCELLED')",workspace,id);
        if(rows.isEmpty()) throw ApiException.missing(); var row=rows.getFirst();
        var settlements=db.query("select * from settlement where workspace_id=? and entry_id=? order by paid_on,created_at",(rs,n)->new Settlement(rs.getObject("id",UUID.class),rs.getBigDecimal("amount").toPlainString(),rs.getDate("paid_on").toLocalDate().toString()),workspace,id);
        var refunds=db.query("select * from financial_refund where workspace_id=? and entry_id=? order by refunded_on,created_at,id",(rs,n)->new Refund(rs.getObject("id",UUID.class),rs.getBigDecimal("amount").toPlainString(),rs.getDate("refunded_on").toLocalDate().toString(),rs.getString("reason"),rs.getObject("created_by",UUID.class),rs.getTimestamp("created_at").toInstant().toString()),workspace,id);
        BigDecimal paid=settlements.stream().map(s->new BigDecimal(s.amount())).reduce(new BigDecimal("0.00"),BigDecimal::add),amount=(BigDecimal)row.get("amount");
        BigDecimal refunded=refunds.stream().map(r->new BigDecimal(r.amount())).reduce(new BigDecimal("0.00"),BigDecimal::add),netPaid=paid.subtract(refunded);
        BigDecimal remaining=amount.subtract(netPaid);
        List<Allocation> allocations=List.of();
        if("EXPENSE".equals(row.get("entry_type"))) {
            var parts=allocationAmounts(workspace,id);
            var paidShares=proportionalShares(parts,amount,paid);
            var netShares=boundedNetShares(parts,amount,paidShares,netPaid);
            allocations=parts.stream().map(part->{
                BigDecimal partPaid=paidShares.get(part.equipmentId()),partNet=netShares.get(part.equipmentId());
                BigDecimal partRefund=partPaid.subtract(partNet);
                return new Allocation(part.equipmentId(),part.equipmentName(),part.amount().toPlainString(),partPaid.toPlainString(),partRefund.toPlainString(),partNet.toPlainString(),part.amount().subtract(partNet).toPlainString());
            }).toList();
        }
        return new Entry(id,(UUID)row.get("equipment_id"),(String)row.get("equipment_name"),(String)row.get("entry_type"),amount.toPlainString(),"SAR",(String)row.get("category"),row.get("operation_date").toString(),(String)row.get("note"),(String)row.get("lifecycle"),paid.toPlainString(),refunded.toPlainString(),netPaid.toPlainString(),netPaid.toPlainString(),remaining.toPlainString(),remaining.signum()==0?"PAID":netPaid.signum()==0?"UNPAID":"PARTIAL",(String)row.get("party_name"),row.get("due_date")==null?null:row.get("due_date").toString(),((java.sql.Timestamp)row.get("created_at")).toInstant().toString(),(String)row.get("cancellation_reason"),row.get("cancelled_at")==null?null:((java.sql.Timestamp)row.get("cancelled_at")).toInstant().toString(),(UUID)row.get("cancelled_by"),settlements,refunds,(String)row.get("expense_scope"),allocations,(UUID)row.get("created_by"),(UUID)row.get("completed_by"),row.get("completed_at")==null?null:((java.sql.Timestamp)row.get("completed_at")).toInstant().toString(),(UUID)row.get("submitted_by"),(UUID)row.get("submission_id"),(UUID)row.get("project_id"));
    }
    private List<AllocationAmount> allocationAmounts(UUID workspace,UUID entryId) {
        return db.query("select a.equipment_id,e.name,a.amount from expense_allocation a join equipment e on e.workspace_id=a.workspace_id and e.id=a.equipment_id where a.workspace_id=? and a.entry_id=? order by a.equipment_id",(rs,n)->new AllocationAmount(rs.getObject("equipment_id",UUID.class),rs.getString("name"),rs.getBigDecimal("amount")),workspace,entryId);
    }
    // Hamilton's largest-remainder method in minor units; ties use equipment UUID order.
    // Calculated shares reconcile to the entry-level cash movement, never create cash records.
    private Map<UUID,BigDecimal> proportionalShares(List<AllocationAmount> parts,BigDecimal total,BigDecimal movement) {
        if(parts.isEmpty()) return Map.of();
        BigInteger denominator=total.movePointRight(2).toBigIntegerExact();
        BigInteger minor=movement.movePointRight(2).toBigIntegerExact();
        var ranked=new ArrayList<Map.Entry<UUID,BigInteger>>();
        var shares=new HashMap<UUID,BigInteger>();
        BigInteger assigned=BigInteger.ZERO;
        for(var part:parts) {
            var division=minor.multiply(part.amount().movePointRight(2).toBigIntegerExact()).divideAndRemainder(denominator);
            shares.put(part.equipmentId(),division[0]); assigned=assigned.add(division[0]);
            ranked.add(Map.entry(part.equipmentId(),division[1]));
        }
        ranked.sort(Comparator.<Map.Entry<UUID,BigInteger>,BigInteger>comparing(Map.Entry::getValue).reversed().thenComparing(Map.Entry::getKey));
        int remainder=minor.subtract(assigned).intValueExact();
        for(int i=0;i<remainder;i++) shares.merge(ranked.get(i).getKey(),BigInteger.ONE,BigInteger::add);
        var result=new HashMap<UUID,BigDecimal>();
        shares.forEach((id,value)->result.put(id,new BigDecimal(value,2)));
        return result;
    }
    /** Movement components follow M2's cumulative gross and refund shares. */
    public BigDecimal movementShareDelta(UUID workspace,UUID entryId,UUID equipmentId,BigDecimal entryTotal,BigDecimal priorPaid,BigDecimal priorRefunded,BigDecimal finalPaid,BigDecimal movement,boolean refund) {
        var parts=allocationAmounts(workspace,entryId);
        if(!refund){
            var before=proportionalShares(parts,entryTotal,priorPaid);
            var after=proportionalShares(parts,entryTotal,priorPaid.add(movement));
            return after.getOrDefault(equipmentId,BigDecimal.ZERO.setScale(2)).subtract(before.getOrDefault(equipmentId,BigDecimal.ZERO.setScale(2)));
        }
        // M2 can redistribute a refund's cents after a later settlement. Use the
        // current lifetime gross shares for every dated refund so movement sums
        // reconcile to the current M2 paidShare/refundedShare pair.
        var paid=proportionalShares(parts,entryTotal,finalPaid);
        var beforeNet=boundedNetShares(parts,entryTotal,paid,finalPaid.subtract(priorRefunded));
        var afterNet=boundedNetShares(parts,entryTotal,paid,finalPaid.subtract(priorRefunded).subtract(movement));
        BigDecimal gross=paid.getOrDefault(equipmentId,BigDecimal.ZERO.setScale(2));
        BigDecimal refundBefore=gross.subtract(beforeNet.getOrDefault(equipmentId,BigDecimal.ZERO.setScale(2)));
        BigDecimal refundAfter=gross.subtract(afterNet.getOrDefault(equipmentId,BigDecimal.ZERO.setScale(2)));
        return refundAfter.subtract(refundBefore);
    }
    /** Calculate one equipment's current obligation from totals already read by a report. */
    public BigDecimal remainingShare(UUID workspace,UUID entryId,UUID equipmentId,BigDecimal entryTotal,BigDecimal paid,BigDecimal refunded) {
        var parts=allocationAmounts(workspace,entryId);
        var paidShares=proportionalShares(parts,entryTotal,paid);
        var netShares=boundedNetShares(parts,entryTotal,paidShares,paid.subtract(refunded));
        return parts.stream().filter(part->part.equipmentId().equals(equipmentId))
            .map(part->part.amount().subtract(netShares.get(part.equipmentId())))
            .findFirst().orElse(BigDecimal.ZERO.setScale(2));
    }
    // Hamilton apportionment can lose a cent as its total grows (the Alabama paradox).
    // Bound net shares by each equipment's historical gross share so no calculated refund
    // is negative. Move any excess to the most under-quota eligible equipment, UUID tie break.
    private Map<UUID,BigDecimal> boundedNetShares(List<AllocationAmount> parts,BigDecimal total,Map<UUID,BigDecimal> paidShares,BigDecimal net) {
        var shares=new HashMap<>(proportionalShares(parts,total,net));
        int excess=0;
        for(var part:parts) {
            UUID id=part.equipmentId();
            BigDecimal paid=paidShares.get(id),current=shares.get(id);
            if(current.compareTo(paid)>0) {
                excess+=current.subtract(paid).movePointRight(2).intValueExact();
                shares.put(id,paid);
            }
        }
        BigInteger denominator=total.movePointRight(2).toBigIntegerExact(),netMinor=net.movePointRight(2).toBigIntegerExact();
        for(int i=0;i<excess;i++) {
            AllocationAmount best=null; BigInteger bestDeficit=null;
            for(var part:parts) {
                UUID id=part.equipmentId();
                if(shares.get(id).compareTo(paidShares.get(id))>=0) continue;
                BigInteger deficit=netMinor.multiply(part.amount().movePointRight(2).toBigIntegerExact())
                    .subtract(shares.get(id).movePointRight(2).toBigIntegerExact().multiply(denominator));
                if(best==null || deficit.compareTo(bestDeficit)>0 || deficit.equals(bestDeficit) && id.compareTo(best.equipmentId())<0) {
                    best=part;bestDeficit=deficit;
                }
            }
            if(best==null) throw new IllegalStateException("Net shares cannot reconcile with gross shares");
            shares.put(best.equipmentId(),shares.get(best.equipmentId()).add(new BigDecimal("0.01")));
        }
        return shares;
    }
    private String expenseScope(String type,String scope) {
        String resolved=scope==null?"SINGLE":scope;
        if(!Set.of("SINGLE","SHARED","GENERAL").contains(resolved) || (type.equals("INCOME") && !resolved.equals("SINGLE"))) throw ApiException.invalid("اختر ربط المصروف بالمعدات");
        return resolved;
    }
    private LinkedHashMap<UUID,BigDecimal> validateAllocations(UUID workspace,String type,String scope,UUID equipmentId,List<AllocationInput> requested,BigDecimal total) {
        var result=new LinkedHashMap<UUID,BigDecimal>();
        if(scope.equals("SINGLE")) {
            if(equipmentId==null) throw ApiException.invalid("حدد المعدة");
            equipment.require(workspace,equipmentId);
            if(requested!=null && !requested.isEmpty()) throw ApiException.invalid("لا تضف مبالغ معدات مع اختيار معدة واحدة");
            if(type.equals("EXPENSE")) result.put(equipmentId,total);
        } else if(scope.equals("GENERAL")) {
            if(equipmentId!=null || requested!=null && !requested.isEmpty()) throw ApiException.invalid("المصروف العام لا يرتبط بمعدة");
        } else {
            if(equipmentId!=null || requested==null || requested.size()<2 || requested.size()>100) throw ApiException.invalid("حدد معدتين على الأقل ومبلغ كل معدة");
            BigDecimal sum=BigDecimal.ZERO;
            for(var part:requested) {
                if(part==null || part.equipmentId()==null || part.amount()==null || !part.amount().isString()) throw ApiException.invalid("حدد المعدة ومبلغها");
                equipment.require(workspace,part.equipmentId());
                if(result.containsKey(part.equipmentId())) throw ApiException.invalid("اختر كل معدة مرة واحدة");
                BigDecimal value=Values.money(part.amount().asString());
                result.put(part.equipmentId(),value); sum=sum.add(value);
            }
            if(sum.compareTo(total)!=0) throw ApiException.invalid("مجموع مبالغ المعدات يجب أن يساوي إجمالي المصروف");
        }
        return result;
    }
    private void saveAllocations(UUID workspace,UUID entryId,Map<UUID,BigDecimal> parts) {
        db.update("delete from expense_allocation where workspace_id=? and entry_id=?",workspace,entryId);
        parts.forEach((equipmentId,amount)->db.update("insert into expense_allocation(workspace_id,entry_id,equipment_id,amount) values(?,?,?,?)",workspace,entryId,equipmentId,amount));
    }
    private void validateProject(Actor actor,UUID workspace,UUID projectId,String scope,UUID equipmentId,Collection<UUID> allocated) {
        if(projectId==null)return;
        access.project(actor,workspace,projectId,"PROJECT_VIEW");
        var rows=db.queryForList("select organization_id,archived_at from project_or_contract where workspace_id=? and id=? for share",workspace,projectId);
        if(rows.isEmpty()||rows.getFirst().get("archived_at")!=null)throw ApiException.missing();
        UUID organization=(UUID)rows.getFirst().get("organization_id");
        if(organization==null||"GENERAL".equals(scope))return;
        Collection<UUID> equipment="SHARED".equals(scope)?allocated:List.of(equipmentId);
        for(UUID id:equipment)if(!Boolean.TRUE.equals(db.queryForObject("select exists(select 1 from equipment_organization_assignment where workspace_id=? and equipment_id=? and organization_id=? and ended_at is null)",Boolean.class,workspace,id,organization)))throw new ApiException(409,"PROJECT_ORGANIZATION_MISMATCH","المعدة لا تتبع مؤسسة المشروع الحالية");
    }
    @Transactional public Entry classifyProject(Actor actor,UUID workspace,UUID entryId,UUID projectId) {
        Access.Member member=access.require(actor,workspace,"FINANCE_MANAGE");if(!"DIRECT".equals(member.financialMode())||!access.financial(member,workspace,entryId))throw ApiException.missing();
        var rows=db.queryForList("select * from financial_entry where workspace_id=? and id=? for update",workspace,entryId);if(rows.isEmpty())throw ApiException.missing();var row=rows.getFirst();if(!"POSTED".equals(row.get("lifecycle")))throw new ApiException(409,"FINANCIAL_CLASSIFICATION_LOCKED","لا يمكن تصنيف العملية الملغاة أو المسودة");
        List<UUID> allocations=db.queryForList("select equipment_id from expense_allocation where workspace_id=? and entry_id=?",workspace,entryId).stream().map(r->(UUID)r.get("equipment_id")).toList();
        validateProject(actor,workspace,projectId,(String)row.get("expense_scope"),(UUID)row.get("equipment_id"),allocations);
        UUID old=(UUID)row.get("project_id");if(!Objects.equals(old,projectId)){db.update("update financial_entry set project_id=? where workspace_id=? and id=?",projectId,workspace,entryId);Map<String,Object> detail=new HashMap<>();detail.put("previousProjectId",old);detail.put("projectId",projectId);audit.record(workspace,actor.userId(),"FINANCIAL_PROJECT_LINK_CHANGED",entryId,JSON.writeValueAsString(detail));}
        return require(workspace,entryId);
    }
    public Map<String,Object> list(Actor actor,UUID workspace,HistoryFilter selected,int page) {
        Access.Member member=access.require(actor,workspace,"FINANCE_VIEW"); if(page<0 || page>100000) throw ApiException.invalid("رقم الصفحة غير صالح");
        HistoryFilter query=selected==null?new HistoryFilter(null,null,null,null,null,null,null,null):selected;
        var conditions=new StringBuilder(" f.workspace_id=? and f.lifecycle in ('POSTED','CANCELLED')");
        var params=new ArrayList<Object>(); params.add(workspace);
        if(!member.scope().equals("ALL_EQUIPMENT")){conditions.append(" and ").append(access.financialPredicate(member));Collections.addAll(params,access.financialScopeArgs(member));}
        if(query.search()!=null && !query.search().isBlank()) {
            String term=query.search().trim();
            if(term.length()>100) throw ApiException.invalid("البحث لا يتجاوز 100 حرف");
            String like="%"+term.replace("\\","\\\\").replace("%","\\%").replace("_","\\_")+"%";
            conditions.append(" and (e.name ilike ? escape '\\' or ('EQ-'||lpad(e.reference::text,6,'0')) ilike ? escape '\\' or f.party_name ilike ? escape '\\' or f.note ilike ? escape '\\' or f.category ilike ? escape '\\' or exists (select 1 from expense_allocation a join equipment ae on ae.workspace_id=a.workspace_id and ae.id=a.equipment_id where a.workspace_id=f.workspace_id and a.entry_id=f.id and (ae.name ilike ? escape '\\' or ('EQ-'||lpad(ae.reference::text,6,'0')) ilike ? escape '\\')))");
            for(int i=0;i<7;i++) params.add(like);
        }
        LocalDate from=query.fromDate()==null || query.fromDate().isBlank()?null:Values.date(query.fromDate());
        LocalDate to=query.toDate()==null || query.toDate().isBlank()?null:Values.date(query.toDate());
        if(from!=null && to!=null && from.isAfter(to)) throw ApiException.invalid("بداية الفترة بعد نهايتها");
        if(from!=null) { conditions.append(" and f.operation_date>=?"); params.add(java.sql.Date.valueOf(from)); }
        if(to!=null) { conditions.append(" and f.operation_date<=?"); params.add(java.sql.Date.valueOf(to)); }
        if(query.entryType()!=null) {
            if(!Set.of("EXPENSE","INCOME").contains(query.entryType())) throw ApiException.invalid("نوع العملية غير صالح");
            conditions.append(" and f.entry_type=?"); params.add(query.entryType());
        }
        if(query.equipmentId()!=null) {
            access.equipment(actor,workspace,query.equipmentId(),"EQUIPMENT_VIEW");equipment.require(workspace,query.equipmentId());
            conditions.append(" and (f.equipment_id=? or exists (select 1 from expense_allocation a where a.workspace_id=f.workspace_id and a.entry_id=f.id and a.equipment_id=?))");
            params.add(query.equipmentId()); params.add(query.equipmentId());
        }
        if(query.generalExpense()!=null) {
            conditions.append(query.generalExpense()?" and f.expense_scope='GENERAL'":" and f.expense_scope<>'GENERAL'");
        }
        if(query.lifecycle()!=null) {
            if(!Set.of("POSTED","CANCELLED").contains(query.lifecycle())) throw ApiException.invalid("حالة العملية غير صالحة");
            conditions.append(" and f.lifecycle=?"); params.add(query.lifecycle());
        }
        if(query.settlementStatus()!=null) {
            if(!Set.of("PAID","PARTIAL","UNPAID").contains(query.settlementStatus())) throw ApiException.invalid("حالة التسوية غير صالحة");
            String net="(coalesce((select sum(s.amount) from settlement s where s.workspace_id=f.workspace_id and s.entry_id=f.id),0)-coalesce((select sum(r.amount) from financial_refund r where r.workspace_id=f.workspace_id and r.entry_id=f.id),0))";
            conditions.append(" and ").append(switch(query.settlementStatus()) { case "PAID" -> net+"=f.amount"; case "UNPAID" -> net+"=0"; default -> net+">0 and "+net+"<f.amount"; });
        }
        String base=" from financial_entry f left join equipment e on e.workspace_id=f.workspace_id and e.id=f.equipment_id where "+conditions;
        Long count=db.queryForObject("select count(*)"+base,Long.class,params.toArray());
        params.add(30); params.add(page*30);
        var ids=db.query("select f.id"+base+" order by f.created_at desc,f.id desc limit ? offset ?",(rs,n)->rs.getObject("id",UUID.class),params.toArray());
        return Map.of("items",ids.stream().map(id->require(workspace,id)).toList(),"page",page,"pageSize",30,"total",count);
    }
    public Map<String,String> totals(Actor actor,UUID workspace,UUID equipmentId) {
        Access.Member member=access.require(actor,workspace,"FINANCE_VIEW");
        if(equipmentId!=null){access.equipment(actor,workspace,equipmentId,"EQUIPMENT_VIEW");equipment.require(workspace,equipmentId);}
        if(!member.scope().equals("ALL_EQUIPMENT") && equipmentId==null)throw ApiException.missing();
        if(!member.scope().equals("ALL_EQUIPMENT")) {
            String allowed=access.financialPredicate(member);
            Object[] scoped=access.financialScopeArgs(member);Object[] args=new Object[2+scoped.length];args[0]=workspace;args[1]=equipmentId;System.arraycopy(scoped,0,args,2,scoped.length);
            BigDecimal e=db.queryForObject("select coalesce(sum(a.amount),0) from expense_allocation a join financial_entry f on f.workspace_id=a.workspace_id and f.id=a.entry_id where a.workspace_id=? and a.equipment_id=? and f.lifecycle='POSTED' and "+allowed,BigDecimal.class,args);
            BigDecimal i=db.queryForObject("select coalesce(sum(f.amount),0) from financial_entry f where f.workspace_id=? and f.equipment_id=? and f.entry_type='INCOME' and f.lifecycle='POSTED' and "+allowed,BigDecimal.class,args);
            return Map.of("expenseTotal",e.setScale(2).toPlainString(),"incomeTotal",i.setScale(2).toPlainString(),"generalExpenseTotal","0.00");
        }
        BigDecimal expense=equipmentId==null
            ? db.queryForObject("select coalesce(sum(amount),0) from financial_entry where workspace_id=? and entry_type='EXPENSE' and lifecycle='POSTED'",BigDecimal.class,workspace)
            : db.queryForObject("select coalesce(sum(a.amount),0) from expense_allocation a join financial_entry f on f.workspace_id=a.workspace_id and f.id=a.entry_id where a.workspace_id=? and a.equipment_id=? and f.lifecycle='POSTED'",BigDecimal.class,workspace,equipmentId);
        BigDecimal income=equipmentId==null
            ? db.queryForObject("select coalesce(sum(amount),0) from financial_entry where workspace_id=? and entry_type='INCOME' and lifecycle='POSTED'",BigDecimal.class,workspace)
            : db.queryForObject("select coalesce(sum(amount),0) from financial_entry where workspace_id=? and equipment_id=? and entry_type='INCOME' and lifecycle='POSTED'",BigDecimal.class,workspace,equipmentId);
        BigDecimal general=equipmentId==null
            ? db.queryForObject("select coalesce(sum(amount),0) from financial_entry where workspace_id=? and entry_type='EXPENSE' and expense_scope='GENERAL' and lifecycle='POSTED'",BigDecimal.class,workspace)
            : BigDecimal.ZERO;
        return Map.of("expenseTotal",expense.setScale(2).toPlainString(),"incomeTotal",income.setScale(2).toPlainString(),"generalExpenseTotal",general.setScale(2).toPlainString());
    }
    private Draft draftView(Map<String,Object> row) {
        return new Draft((UUID)row.get("id"),(UUID)row.get("equipment_id"),(String)row.get("equipment_name"),(String)row.get("note"),(String)row.get("lifecycle"),(UUID)row.get("created_by"),((java.sql.Timestamp)row.get("created_at")).toInstant().toString(),(UUID)row.get("discarded_by"),row.get("discarded_at")==null?null:((java.sql.Timestamp)row.get("discarded_at")).toInstant().toString());
    }
    private Draft requireDraft(UUID workspace,UUID id) {
        var rows=db.queryForList("select f.*,e.name as equipment_name from financial_entry f join equipment e on e.workspace_id=f.workspace_id and e.id=f.equipment_id where f.workspace_id=? and f.id=? and f.lifecycle='DRAFT'",workspace,id);
        if(rows.isEmpty()) throw ApiException.missing();
        return draftView(rows.getFirst());
    }
    public Draft getDraft(Actor actor,UUID workspace,UUID id) { access.financial(actor,workspace,id,"FINANCE_VIEW"); return requireDraft(workspace,id); }
    public Map<String,Object> listDrafts(Actor actor,UUID workspace,int page,UUID equipmentId) {
        Access.Member member=access.require(actor,workspace,"FINANCE_VIEW");
        if(page<0 || page>100000) throw ApiException.invalid("رقم الصفحة غير صالح");
        if(equipmentId!=null){access.equipment(actor,workspace,equipmentId,"EQUIPMENT_VIEW");equipment.require(workspace,equipmentId);}
        String filter=equipmentId==null?"":" and f.equipment_id=?";
        List<Object> params=new ArrayList<>();params.add(workspace);if(equipmentId!=null)params.add(equipmentId);
        if(!member.scope().equals("ALL_EQUIPMENT")){filter+=" and "+access.financialPredicate(member);Collections.addAll(params,access.financialScopeArgs(member));}
        Long count=db.queryForObject("select count(*) from financial_entry f where f.workspace_id=? and f.lifecycle='DRAFT'"+filter,Long.class,params.toArray());
        params.add(page*30);
        var rows=db.queryForList("select f.*,e.name as equipment_name from financial_entry f join equipment e on e.workspace_id=f.workspace_id and e.id=f.equipment_id where f.workspace_id=? and f.lifecycle='DRAFT'"+filter+" order by f.created_at desc,f.id desc limit 30 offset ?",params.toArray());
        return Map.of("items",rows.stream().map(this::draftView).toList(),"page",page,"pageSize",30,"total",count);
    }
    @Transactional
    public Draft createDraft(Actor actor,UUID workspace,String key,CreateDraft request) {
        if(request==null || request.equipmentId()==null) throw ApiException.invalid("حدد المعدة");
        access.directFinance(actor,workspace,request.equipmentId(),"EXPENSE","SINGLE");
        equipment.require(workspace,request.equipmentId());
        String note=Values.note(request.note());
        UUID id=retries.execute(workspace,actor.userId(),"finance.draft.create",key,Values.payload(request.equipmentId(),note),()->{
            UUID created=UUID.randomUUID();
            db.update("insert into financial_entry(id,workspace_id,equipment_id,amount,currency,category,operation_date,note,lifecycle,created_by,entry_type,expense_scope) values(?,?,?,null,'SAR',null,null,?,'DRAFT',?,null,'SINGLE')",created,workspace,request.equipmentId(),note,actor.userId());
            audit.record(workspace,actor.userId(),"FINANCIAL_DRAFT_CREATED",created,JSON.writeValueAsString(Map.of("equipmentId",request.equipmentId(),"note",note)));
            return created;
        });
        return requireDraft(workspace,id);
    }
    @Transactional
    public Draft discardDraft(Actor actor,UUID workspace,UUID id) {
        access.directFinancialEntry(actor,workspace,id);
        var rows=db.queryForList("select f.*,e.name as equipment_name from financial_entry f join equipment e on e.workspace_id=f.workspace_id and e.id=f.equipment_id where f.workspace_id=? and f.id=? and f.lifecycle in ('DRAFT','DISCARDED') for update of f",workspace,id);
        if(rows.isEmpty()) throw ApiException.missing();
        var previous=rows.getFirst();
        if("DRAFT".equals(previous.get("lifecycle"))) {
            db.update("update financial_entry set lifecycle='DISCARDED',discarded_by=?,discarded_at=now() where workspace_id=? and id=?",actor.userId(),workspace,id);
            audit.record(workspace,actor.userId(),"FINANCIAL_DRAFT_DISCARDED",id,JSON.writeValueAsString(Map.of("note",previous.get("note"),"equipmentId",previous.get("equipment_id"))));
        }
        return draftView(db.queryForList("select f.*,e.name as equipment_name from financial_entry f join equipment e on e.workspace_id=f.workspace_id and e.id=f.equipment_id where f.workspace_id=? and f.id=?",workspace,id).getFirst());
    }
    @Transactional
    public Entry create(Actor actor,UUID workspace,String key,Create request) {
        return post(actor,workspace,key,request,null,false);
    }
    @Transactional
    public Entry approveSubmission(Actor actor,UUID workspace,String key,Create request) {
        return post(actor,workspace,key,request,null,true);
    }
    @Transactional
    public Entry completeDraft(Actor actor,UUID workspace,UUID draftId,String key,Create request) {
        return post(actor,workspace,key,request,draftId,false);
    }
    private Entry post(Actor actor,UUID workspace,String key,Create request,UUID draftId,boolean review) {
        if(request==null) throw ApiException.invalid("أكمل بيانات العملية");
        if(review){access.equipment(actor,workspace,request.equipmentId(),"FINANCE_REVIEW");}else access.directFinance(actor,workspace,request.equipmentId(),request.entryType()==null?"EXPENSE":request.entryType(),request.expenseScope()==null?"SINGLE":request.expenseScope(),request.projectId());
        if(request.allocations()!=null){Access.Member member=access.member(actor,workspace);for(AllocationInput allocation:request.allocations())if(!access.contains(member,workspace,allocation.equipmentId()))throw ApiException.missing();}
        Map<String,Object> draftRow=null;
        if(draftId!=null) {
            var rows=db.queryForList("select * from financial_entry where workspace_id=? and id=? and lifecycle in ('DRAFT','POSTED')",workspace,draftId);
            if(rows.isEmpty()) throw ApiException.missing();
            draftRow=rows.getFirst();
            if(request==null || !Objects.equals(request.equipmentId(),draftRow.get("equipment_id")) || request.expenseScope()!=null && !request.expenseScope().equals("SINGLE") || request.allocations()!=null)
                throw ApiException.invalid("أكمل المسودة على المعدة نفسها دون تغيير ربطها");
        }
        if(request==null) throw ApiException.invalid("أكمل بيانات العملية");
        if(request.amount()==null || !request.amount().isString()) throw ApiException.invalid("أرسل المبلغ كنص عشري بمنزلتين، مثل 350.00");
        String type=request.entryType()==null?"EXPENSE":request.entryType();
        if(!Set.of("EXPENSE","INCOME").contains(type)) throw ApiException.invalid("اختر نوع العملية");
        BigDecimal amount=Values.money(request.amount().asString()); LocalDate date=Values.date(request.operationDate());
        String scope=expenseScope(type,request.expenseScope());
        var allocations=validateAllocations(workspace,type,scope,request.equipmentId(),request.allocations(),amount);
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
        String category=type.equals("INCOME")?"OTHER":Values.text(request.category(),30,"نوع المصروف"),note=Values.note(request.note()==null && draftRow!=null?(String)draftRow.get("note"):request.note());
        if(type.equals("INCOME") && request.category()!=null && !request.category().equals("OTHER")) throw ApiException.invalid("نوع الإيراد غير صالح");
        if(type.equals("EXPENSE") && !Set.of("FUEL","MAINTENANCE","OTHER").contains(category)) throw ApiException.invalid("اختر نوع المصروف");
        String payload=request.entryType()==null
            ? request.paymentStatus()==null
                ? Values.payload(request.equipmentId(),amount,category,date,paidOn,note)
                : Values.payload(request.equipmentId(),amount,category,date,paidOn,note,status,initial,party,due)
            : Values.payload(request.equipmentId(),amount,category,date,paidOn,note,status,initial,party,due,type);
        if(request.expenseScope()!=null || request.allocations()!=null) payload=Values.payload(payload,scope,allocations);
        if(request.projectId()!=null)payload=Values.payload(payload,request.projectId());
        if(draftId!=null) payload=Values.payload(draftId,payload);
        UUID id=retries.execute(workspace,actor.userId(),draftId==null?(type.equals("INCOME")?"income.create":"expense.create"):"finance.draft.complete:"+draftId,key,payload,()->{
            validateProject(actor,workspace,request.projectId(),scope,request.equipmentId(),allocations.keySet());
            UUID created=draftId==null?UUID.randomUUID():draftId;
            if(draftId==null)
                db.update("insert into financial_entry(id,workspace_id,equipment_id,amount,currency,category,operation_date,note,lifecycle,created_by,party_name,due_date,entry_type,expense_scope,project_id) values(?,?,?,?,'SAR',?,?,?,'POSTED',?,?,?,?,?,?)",created,workspace,request.equipmentId(),amount,category,java.sql.Date.valueOf(date),note,actor.userId(),party,due==null?null:java.sql.Date.valueOf(due),type,scope,request.projectId());
            else {
                var current=db.queryForList("select lifecycle,created_by,note from financial_entry where workspace_id=? and id=? for update",workspace,draftId);
                if(current.isEmpty() || !"DRAFT".equals(current.getFirst().get("lifecycle"))) throw ApiException.invalid("المسودة استُكملت أو استُبعدت مسبقًا");
                db.update("update financial_entry set amount=?,category=?,operation_date=?,note=?,lifecycle='POSTED',party_name=?,due_date=?,entry_type=?,completed_by=?,completed_at=now(),project_id=? where workspace_id=? and id=?",amount,category,java.sql.Date.valueOf(date),note,party,due==null?null:java.sql.Date.valueOf(due),type,actor.userId(),request.projectId(),workspace,draftId);
            }
            if(type.equals("EXPENSE")) saveAllocations(workspace,created,allocations);
            if(initial.signum()>0) db.update("insert into settlement(id,workspace_id,entry_id,amount,paid_on,created_by) values(?,?,?,?,?,?)",UUID.randomUUID(),workspace,created,initial,java.sql.Date.valueOf(paidOn),actor.userId());
            if(draftId==null) audit.record(workspace,actor.userId(),type.equals("INCOME")?"INCOME_CREATED":initial.compareTo(amount)==0?"PAID_EXPENSE_CREATED":"EXPENSE_CREATED",created);
            else audit.record(workspace,actor.userId(),"FINANCIAL_DRAFT_COMPLETED",created,JSON.writeValueAsString(Map.of("entryType",type,"amount",amount.toPlainString(),"completedBy",actor.userId(),"note",note)));
            return created;
        }); return require(workspace,id);
    }
    @Transactional
    public Entry settle(Actor actor,UUID workspace,UUID entryId,String key,AddSettlement request) {
        access.directFinancialEntry(actor,workspace,entryId); require(workspace,entryId);
        if(request.amount()==null || !request.amount().isString()) throw ApiException.invalid("أرسل المبلغ كنص عشري");
        BigDecimal amount=Values.money(request.amount().asString()); LocalDate paidOn=Values.date(request.paidOn());
        String type=require(workspace,entryId).entryType();
        retries.execute(workspace,actor.userId(),type.equals("INCOME")?"income.settle":"expense.settle",key,Values.payload(entryId,amount,paidOn),()->{
            var rows=db.queryForList("select amount,lifecycle from financial_entry where workspace_id=? and id=? for update",workspace,entryId);
            if(rows.isEmpty()) throw ApiException.missing();
            if(!"POSTED".equals(rows.getFirst().get("lifecycle"))) throw ApiException.invalid("أكمل المسودة أولًا؛ التسوية متاحة للعمليات النشطة فقط");
            BigDecimal total=(BigDecimal)rows.getFirst().get("amount");
            BigDecimal paid=db.queryForObject("select coalesce(sum(amount),0) from settlement where workspace_id=? and entry_id=?",BigDecimal.class,workspace,entryId);
            BigDecimal refunded=db.queryForObject("select coalesce(sum(amount),0) from financial_refund where workspace_id=? and entry_id=?",BigDecimal.class,workspace,entryId);
            if(amount.compareTo(total.subtract(paid.subtract(refunded)))>0) throw ApiException.invalid(type.equals("INCOME")?"التحصيل أكبر من المتبقي":"الدفعة أكبر من المتبقي");
            UUID settlementId=UUID.randomUUID();
            db.update("insert into settlement(id,workspace_id,entry_id,amount,paid_on,created_by) values(?,?,?,?,?,?)",settlementId,workspace,entryId,amount,java.sql.Date.valueOf(paidOn),actor.userId());
            audit.record(workspace,actor.userId(),type.equals("INCOME")?"INCOME_SETTLED":"EXPENSE_SETTLED",entryId);
            return settlementId;
        });
        return require(workspace,entryId);
    }
    @Transactional
    public Entry refund(Actor actor,UUID workspace,UUID entryId,String key,CreateRefund request) {
        access.directFinancialEntry(actor,workspace,entryId); require(workspace,entryId);
        if(request.amount()==null || !request.amount().isString()) throw ApiException.invalid("أرسل مبلغ الاسترداد كنص عشري");
        BigDecimal amount=Values.money(request.amount().asString());
        LocalDate refundedOn=Values.date(request.refundedOn());
        String reason=Values.text(request.reason(),500,"سبب الاسترداد");
        String suppliedParty=request.partyName()==null || request.partyName().isBlank()?null:Values.text(request.partyName(),100,"اسم الطرف");
        String payload=Values.payload(entryId,amount,refundedOn,reason);
        if(suppliedParty!=null) payload=Values.payload(payload,suppliedParty);
        retries.execute(workspace,actor.userId(),"finance.refund",key,payload,()->{
            var rows=db.queryForList("select lifecycle,amount,party_name from financial_entry where workspace_id=? and id=? for update",workspace,entryId);
            if(rows.isEmpty()) throw ApiException.missing();
            if(!"POSTED".equals(rows.getFirst().get("lifecycle"))) throw ApiException.invalid("الاسترداد متاح للعمليات النشطة فقط");
            BigDecimal total=(BigDecimal)rows.getFirst().get("amount");
            String existingParty=(String)rows.getFirst().get("party_name");
            BigDecimal paid=db.queryForObject("select coalesce(sum(amount),0) from settlement where workspace_id=? and entry_id=?",BigDecimal.class,workspace,entryId);
            BigDecimal refunded=db.queryForObject("select coalesce(sum(amount),0) from financial_refund where workspace_id=? and entry_id=?",BigDecimal.class,workspace,entryId);
            if(amount.compareTo(paid.subtract(refunded))>0) throw ApiException.invalid("مبلغ الاسترداد أكبر من المبلغ المتاح");
            if(total.subtract(paid.subtract(refunded).subtract(amount)).signum()>0 && existingParty==null && suppliedParty==null)
                throw ApiException.invalid("اكتب اسم الطرف؛ بعد الاسترداد سيبقى مبلغ مستحق");
            if(existingParty!=null && suppliedParty!=null && !existingParty.equals(suppliedParty))
                throw ApiException.invalid("اسم الطرف مسجل مسبقًا؛ عدّل العملية إذا لزم تصحيحه");
            // A backdated refund must leave nonnegative cash movements at every date, not only today.
            BigDecimal available=BigDecimal.ZERO;
            var movements=db.queryForList("select movement_date,sum(delta) as delta from ("+
                "select paid_on as movement_date,amount as delta from settlement where workspace_id=? and entry_id=? " +
                "union all select refunded_on as movement_date,-amount as delta from financial_refund where workspace_id=? and entry_id=? " +
                "union all select cast(? as date) as movement_date,-cast(? as numeric) as delta"+
                ") movements group by movement_date order by movement_date",workspace,entryId,workspace,entryId,java.sql.Date.valueOf(refundedOn),amount);
            for(var movement:movements) {
                available=available.add((BigDecimal)movement.get("delta"));
                if(available.signum()<0) throw ApiException.invalid("تاريخ الاسترداد أو مبلغه يسبق المال المتاح في ذلك التاريخ");
            }
            UUID refundId=UUID.randomUUID();
            if(existingParty==null && suppliedParty!=null) db.update("update financial_entry set party_name=? where workspace_id=? and id=?",suppliedParty,workspace,entryId);
            db.update("insert into financial_refund(id,workspace_id,entry_id,amount,refunded_on,reason,created_by) values(?,?,?,?,?,?,?)",refundId,workspace,entryId,amount,java.sql.Date.valueOf(refundedOn),reason,actor.userId());
            var metadata=new LinkedHashMap<String,Object>();metadata.put("refundId",refundId);metadata.put("amount",amount.toPlainString());metadata.put("refundedOn",refundedOn.toString());metadata.put("reason",reason);
            if(existingParty==null && suppliedParty!=null) metadata.put("partyName",suppliedParty);
            audit.record(workspace,actor.userId(),"FINANCIAL_REFUND_CREATED",entryId,JSON.writeValueAsString(metadata));
            return refundId;
        });
        return require(workspace,entryId);
    }
    @Transactional
    public Entry edit(Actor actor,UUID workspace,UUID entryId,Edit request) {
        access.directFinancialEntry(actor,workspace,entryId);
        var rows=db.queryForList("select * from financial_entry where workspace_id=? and id=? for update",workspace,entryId);
        if(rows.isEmpty()) throw ApiException.missing();
        var previous=rows.getFirst();
        if(!"POSTED".equals(previous.get("lifecycle"))) throw ApiException.invalid("لا يمكن تعديل عملية ملغاة");
        if(request.amount()==null || !request.amount().isString()) throw ApiException.invalid("أرسل المبلغ كنص عشري بمنزلتين");
        BigDecimal amount=Values.money(request.amount().asString());
        BigDecimal paid=db.queryForObject("select coalesce(sum(amount),0) from settlement where workspace_id=? and entry_id=?",BigDecimal.class,workspace,entryId);
        BigDecimal refunded=db.queryForObject("select coalesce(sum(amount),0) from financial_refund where workspace_id=? and entry_id=?",BigDecimal.class,workspace,entryId);
        BigDecimal netPaid=paid.subtract(refunded);
        BigDecimal originalAmount=(BigDecimal)previous.get("amount");
        boolean hasMovement=paid.signum()>0 || refunded.signum()>0;
        if(hasMovement && amount.compareTo(originalAmount)!=0) throw ApiException.invalid("لا يمكن تغيير الإجمالي بعد تسجيل دفعة أو تحصيل أو استرداد");
        String type=(String)previous.get("entry_type");
        String currentScope=(String)previous.get("expense_scope");
        String scope=request.expenseScope()==null?currentScope:expenseScope(type,request.expenseScope());
        UUID selectedEquipment=request.equipmentId()==null && scope.equals(currentScope)?(UUID)previous.get("equipment_id"):request.equipmentId();
        Map<UUID,BigDecimal> previousAllocations=new LinkedHashMap<>();
        if(type.equals("EXPENSE")) allocationAmounts(workspace,entryId).forEach(a->previousAllocations.put(a.equipmentId(),a.amount()));
        Map<UUID,BigDecimal> allocations=previousAllocations;
        if(type.equals("EXPENSE")) {
            if(request.allocations()!=null || !scope.equals(currentScope) || scope.equals("SINGLE"))
                allocations=validateAllocations(workspace,type,scope,selectedEquipment,request.allocations(),amount);
            else if(scope.equals("SHARED") && amount.compareTo((BigDecimal)previous.get("amount"))!=0)
                throw ApiException.invalid("حدّث مبالغ المعدات مع إجمالي المصروف");
        } else if(request.expenseScope()!=null || request.allocations()!=null || request.equipmentId()!=null) throw ApiException.invalid("لا يمكن تغيير ربط الإيراد بالمعدة");
        Access.Member editor=access.member(actor,workspace);
        if(!editor.scope().equals("ALL_EQUIPMENT")&&scope.equals("GENERAL"))throw ApiException.missing();
        if(selectedEquipment!=null&&!access.contains(editor,workspace,selectedEquipment))throw ApiException.missing();
        for(UUID equipmentId:allocations.keySet())if(!access.contains(editor,workspace,equipmentId))throw ApiException.missing();
        Boolean maintenanceLinked=db.queryForObject("select exists(select 1 from maintenance_expense_link where workspace_id=? and entry_id=?)",Boolean.class,workspace,entryId);
        if(Boolean.TRUE.equals(maintenanceLinked) && (!"SINGLE".equals(scope) || !Objects.equals(selectedEquipment,previous.get("equipment_id"))))
            throw new ApiException(409,"MAINTENANCE_EXPENSE_LINKED","افصل المصروف عن سجل الصيانة قبل تغيير ربطه بالمعدة");
        String category=type.equals("INCOME")?"OTHER":Values.text(request.category(),30,"نوع المصروف");
        if(type.equals("INCOME") && request.category()!=null && !request.category().equals("OTHER")) throw ApiException.invalid("نوع الإيراد غير صالح");
        if(type.equals("EXPENSE") && !Set.of("FUEL","MAINTENANCE","OTHER").contains(category)) throw ApiException.invalid("اختر نوع المصروف");
        LocalDate date=Values.date(request.operationDate()); String note=Values.note(request.note());
        String party=request.partyName()==null || request.partyName().isBlank()?null:Values.text(request.partyName(),100,"اسم الطرف");
        if(amount.compareTo(netPaid)>0 && party==null) throw ApiException.invalid("اكتب اسم الطرف عند وجود متبقٍ");
        LocalDate due=request.dueDate()==null || request.dueDate().isBlank()?null:Values.date(request.dueDate());
        if(amount.compareTo(netPaid)==0 && due!=null) throw ApiException.invalid("موعد الاستحقاق مطلوب فقط عند وجود متبقٍ");
        var before=financialSnapshot(previous,paid);
        db.update("update financial_entry set amount=?,category=?,operation_date=?,note=?,party_name=?,due_date=?,equipment_id=?,expense_scope=? where workspace_id=? and id=?",amount,category,java.sql.Date.valueOf(date),note,party,due==null?null:java.sql.Date.valueOf(due),selectedEquipment,scope,workspace,entryId);
        if(type.equals("EXPENSE") && !allocations.equals(previousAllocations)) saveAllocations(workspace,entryId,allocations);
        var after=new LinkedHashMap<String,Object>(before);
        after.put("amount",amount.toPlainString()); after.put("category",category); after.put("operationDate",date.toString()); after.put("note",note); after.put("partyName",party); after.put("dueDate",due==null?null:due.toString());
        if(type.equals("EXPENSE")) { before.put("expenseScope",currentScope); before.put("allocations",previousAllocations.toString()); after.put("expenseScope",scope); after.put("allocations",allocations.toString()); }
        audit.record(workspace,actor.userId(),type.equals("INCOME")?"INCOME_EDITED":"EXPENSE_EDITED",entryId,JSON.writeValueAsString(Map.of("before",before,"after",after)));
        return require(workspace,entryId);
    }
    @Transactional
    public Entry cancel(Actor actor,UUID workspace,UUID entryId,Cancel request) {
        access.directFinancialEntry(actor,workspace,entryId);
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
        BigDecimal refunded=db.queryForObject("select coalesce(sum(amount),0) from financial_refund where workspace_id=? and entry_id=?",BigDecimal.class,row.get("workspace_id"),row.get("id"));
        BigDecimal netPaid=paid.subtract(refunded);
        snapshot.put("entryType",row.get("entry_type")); snapshot.put("amount",((BigDecimal)row.get("amount")).toPlainString());
        snapshot.put("paid",paid.toPlainString()); snapshot.put("refunded",refunded.toPlainString()); snapshot.put("netPaid",netPaid.toPlainString()); snapshot.put("remaining",((BigDecimal)row.get("amount")).subtract(netPaid).toPlainString());
        snapshot.put("category",row.get("category")); snapshot.put("operationDate",row.get("operation_date").toString());
        snapshot.put("note",row.get("note")); snapshot.put("partyName",row.get("party_name"));
        snapshot.put("dueDate",row.get("due_date")==null?null:row.get("due_date").toString());
        snapshot.put("lifecycle",row.get("lifecycle"));
        return snapshot;
    }
}
