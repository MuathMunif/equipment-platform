package com.equipment;

import java.net.*;
import java.net.http.*;
import java.time.Duration;
import java.math.BigDecimal;
import java.util.*;
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

@SpringBootTest(webEnvironment=SpringBootTest.WebEnvironment.RANDOM_PORT,properties={
 "spring.datasource.url=jdbc:postgresql://127.0.0.1:55433/equipment_test",
 "spring.datasource.username=equipment_test","spring.datasource.password=isolated-test-only"})
@ActiveProfiles({"dev","test"})
class M7ReportsTest {
 @DynamicPropertySource static void properties(DynamicPropertyRegistry r){r.add("app.storage-root",()->"../.local/test-objects/"+UUID.randomUUID());}
 @LocalServerPort int port;@Autowired JdbcTemplate db;
 final HttpClient client=HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build();
 static final JsonMapper JSON=JsonMapper.builder().build();
 record Reply(int status,JsonNode json){}
 record User(String token,String workspace,String id){}
 @BeforeEach void clean(){db.execute("truncate audit_event,idempotency_record,attachment,settlement,financial_entry,equipment,app_session,otp_challenge,membership,workspace,app_user restart identity cascade");}
 Reply call(String method,String path,Object body,String token,String key)throws Exception{
  var b=HttpRequest.newBuilder(URI.create("http://127.0.0.1:"+port+"/api/v1"+path)).timeout(Duration.ofSeconds(20)).header("Content-Type","application/json");
  if(token!=null)b.header("Authorization","Bearer "+token);if(key!=null)b.header("Idempotency-Key",key);
  b.method(method,body==null?HttpRequest.BodyPublishers.noBody():HttpRequest.BodyPublishers.ofByteArray(JSON.writeValueAsBytes(body)));
  var response=client.send(b.build(),HttpResponse.BodyHandlers.ofString());return new Reply(response.statusCode(),response.headers().firstValue("Content-Type").orElse("").contains("json")?JSON.readTree(response.body()):null);
 }
 Reply ok(String method,String path,Object body,String token,String key)throws Exception{Reply r=call(method,path,body,token,key);assertEquals(200,r.status,()->r.json==null?"":r.json.toString());return r;}
 User login(String phone)throws Exception{
  String challenge=ok("POST","/auth/challenges",Map.of("phone",phone),null,null).json.get("challengeId").asString();
  String token=ok("POST","/auth/verify",Map.of("challengeId",challenge,"code","123456","name","مستخدم","client","NATIVE"),null,null).json.get("accessToken").asString();
  JsonNode me=ok("GET","/auth/me",null,token,null).json;return new User(token,me.get("workspaces").get(0).get("id").asString(),me.get("userId").asString());
 }
 String w(User u){return "/workspaces/"+u.workspace;}
 String equipment(User u,String name)throws Exception{return ok("POST",w(u)+"/equipment",Map.of("name",name,"model","FH16"),u.token,UUID.randomUUID().toString()).json.get("id").asString();}
 String entry(User u,Map<String,Object> body)throws Exception{return ok("POST",w(u)+"/entries",body,u.token,UUID.randomUUID().toString()).json.get("id").asString();}
 String recorded(User u,String month){return w(u)+"/reports/recorded?fromDate="+month+"-01&toDate="+(month.equals("2026-09")?"2026-09-30":"2026-10-31");}
 String movements(User u,String month){return w(u)+"/reports/movements?fromDate="+month+"-01&toDate="+(month.equals("2026-09")?"2026-09-30":"2026-10-31");}
 @Test void crossMonthRefundsKeepOriginalsAndAllowNegativePeriodNet()throws Exception{
  User owner=login("0500000401");String eq=equipment(owner,"شاحنة"),base=w(owner);
  String expense=entry(owner,Map.of("equipmentId",eq,"amount","1000.00","category","FUEL","operationDate","2026-09-15","paymentStatus","UNPAID","partyName","مورد"));
  String income=entry(owner,Map.of("equipmentId",eq,"amount","1000.00","category","OTHER","operationDate","2026-09-15","paymentStatus","UNPAID","entryType","INCOME","partyName","عميل"));
  for(String id:List.of(expense,income)){
   ok("POST",base+"/entries/"+id+"/settlements",Map.of("amount","600.00","paidOn","2026-09-20"),owner.token,UUID.randomUUID().toString());
   ok("POST",base+"/entries/"+id+"/refunds",Map.of("amount","200.00","refundedOn","2026-10-03","reason","استرداد"),owner.token,UUID.randomUUID().toString());
  }
  JsonNode sep=ok("GET",recorded(owner,"2026-09"),null,owner.token,null).json;
  assertEquals("1000.00",sep.get("summary").get("recordedExpenses").asString());assertEquals("1000.00",sep.get("summary").get("recordedIncome").asString());
  assertEquals("0.00",ok("GET",recorded(owner,"2026-10"),null,owner.token,null).json.get("summary").get("recordedExpenses").asString());
  JsonNode sm=ok("GET",movements(owner,"2026-09"),null,owner.token,null).json.get("summary");assertEquals("600.00",sm.get("paid").asString());assertEquals("600.00",sm.get("collected").asString());
  JsonNode om=ok("GET",movements(owner,"2026-10"),null,owner.token,null).json.get("summary");assertEquals("-200.00",om.get("netPaid").asString());assertEquals("-200.00",om.get("netCollected").asString());
  JsonNode outstanding=ok("GET",base+"/reports/outstanding",null,owner.token,null).json;assertEquals("600.00",outstanding.get("summary").get("payable").asString());assertEquals("600.00",outstanding.get("summary").get("receivable").asString());assertEquals(2,outstanding.get("total").asInt());
 }
 @Test void sharedGeneralAndCancelledReconcileWithEquipmentScope()throws Exception{
  User owner=login("0500000402");String a=equipment(owner,"أ"),b=equipment(owner,"ب"),base=w(owner);
  String shared=entry(owner,Map.of("amount","1200.00","category","FUEL","operationDate","2026-09-05","paymentStatus","UNPAID","partyName","مورد","expenseScope","SHARED","allocations",List.of(Map.of("equipmentId",a,"amount","700.00"),Map.of("equipmentId",b,"amount","500.00"))));
  entry(owner,Map.of("amount","50.00","category","OTHER","operationDate","2026-09-06","paymentStatus","UNPAID","partyName","مورد","expenseScope","GENERAL"));
  String cancelled=entry(owner,Map.of("equipmentId",a,"amount","99.00","category","FUEL","operationDate","2026-09-07","paymentStatus","UNPAID","partyName","مورد"));
  ok("POST",base+"/entries/"+cancelled+"/cancellation",Map.of("reason","خطأ"),owner.token,null);
  JsonNode global=ok("GET",recorded(owner,"2026-09"),null,owner.token,null).json;assertEquals("1250.00",global.get("summary").get("recordedExpenses").asString());assertEquals(2,global.get("total").asInt());
  assertEquals(3,global.get("summary").get("groups").size());
  assertEquals("50.00",ok("GET",recorded(owner,"2026-09")+"&generalExpense=true",null,owner.token,null).json.get("summary").get("recordedExpenses").asString());
  assertEquals("700.00",ok("GET",recorded(owner,"2026-09")+"&equipmentId="+a,null,owner.token,null).json.get("summary").get("recordedExpenses").asString());
  assertEquals("500.00",ok("GET",recorded(owner,"2026-09")+"&equipmentId="+b,null,owner.token,null).json.get("summary").get("recordedExpenses").asString());
  ok("POST",base+"/entries/"+shared+"/settlements",Map.of("amount","600.00","paidOn","2026-10-01"),owner.token,UUID.randomUUID().toString());
  assertEquals("350.00",ok("GET",movements(owner,"2026-10")+"&equipmentId="+a,null,owner.token,null).json.get("summary").get("paid").asString());
  assertEquals("250.00",ok("GET",movements(owner,"2026-10")+"&equipmentId="+b,null,owner.token,null).json.get("summary").get("paid").asString());
 }
 @Test void reportPermissionAndRevocationApplyAtNextRequest()throws Exception{
  User owner=login("0500000403"),member=login("0500000404");String eq=equipment(owner,"مرئية"),base=w(owner);
  entry(owner,Map.of("equipmentId",eq,"amount","10.00","category","FUEL","operationDate","2026-09-01","paymentStatus","UNPAID","partyName","مورد"));
  String invitation=ok("POST",base+"/team/invitations",Map.of("displayName","محاسب","phone","0500000404","role","ACCOUNTANT","scope","SELECTED_EQUIPMENT","equipmentIds",List.of(eq)),owner.token,null).json.get("id").asString();
  ok("POST","/account/invitations/"+invitation+"/accept",null,member.token,null);
  assertEquals("10.00",ok("GET",recorded(owner,"2026-09"),null,member.token,null).json.get("summary").get("recordedExpenses").asString());
  db.update("update membership set capabilities=array['EQUIPMENT_VIEW','FINANCE_VIEW']::text[] where workspace_id=? and user_id=?",UUID.fromString(owner.workspace),UUID.fromString(member.id));
  assertEquals(404,call("GET",recorded(owner,"2026-09"),null,member.token,null).status);
  assertEquals(200,call("GET",base+"/dashboard?month=2026-09",null,member.token,null).status);
  db.update("update membership set capabilities=array['EQUIPMENT_VIEW']::text[] where workspace_id=? and user_id=?",UUID.fromString(owner.workspace),UUID.fromString(member.id));
  JsonNode dashboard=ok("GET",base+"/dashboard?month=2026-09",null,member.token,null).json;assertFalse(dashboard.has("summary"));assertEquals(1,dashboard.get("activeEquipmentCount").asInt());
  db.update("update membership set capabilities=array['FINANCE_VIEW']::text[] where workspace_id=? and user_id=?",UUID.fromString(owner.workspace),UUID.fromString(member.id));
  JsonNode financeOnly=ok("GET",base+"/dashboard?month=2026-09",null,member.token,null).json;
  assertEquals("10.00",financeOnly.get("summary").get("recordedExpenses").asString());
  assertFalse(financeOnly.has("activeEquipmentCount"));
  assertFalse(financeOnly.get("summary").has("groups"));
  db.update("update membership set capabilities=array[]::text[] where workspace_id=? and user_id=?",UUID.fromString(owner.workspace),UUID.fromString(member.id));
  assertEquals(404,call("GET",base+"/dashboard?month=2026-09",null,member.token,null).status);
 }
 @Test void restrictedScopeExcludesWholeSharedAndProjectGeneralWithoutMetadataLeak()throws Exception{
  User owner=login("0500000405"),member=login("0500000406");String base=w(owner),a=equipment(owner,"مرئية"),b=equipment(owner,"مخفية");
  String org=ok("POST",base+"/organizations",Map.of("name","مؤسسة"),owner.token,null).json.get("id").asString();
  ok("PUT",base+"/equipment/"+a+"/organization",Map.of("organizationId",org),owner.token,null);
  String project=ok("POST",base+"/projects",Map.of("name","عقد","kind","CONTRACT","organizationId",org),owner.token,null).json.get("id").asString();
  entry(owner,Map.of("equipmentId",a,"amount","10.00","category","FUEL","operationDate","2026-09-10","paymentStatus","UNPAID","partyName","مورد"));
  entry(owner,Map.of("amount","100.00","category","FUEL","operationDate","2026-09-11","paymentStatus","UNPAID","partyName","مورد","expenseScope","SHARED","allocations",List.of(Map.of("equipmentId",a,"amount","60.00"),Map.of("equipmentId",b,"amount","40.00"))));
  entry(owner,Map.of("amount","50.00","category","OTHER","operationDate","2026-09-12","paymentStatus","UNPAID","partyName","مورد","expenseScope","GENERAL","projectId",project));
  String invite=ok("POST",base+"/team/invitations",Map.of("displayName","محاسب","phone","0500000406","role","ACCOUNTANT","scope","SELECTED_ORGANIZATIONS","organizationIds",List.of(org)),owner.token,null).json.get("id").asString();
  ok("POST","/account/invitations/"+invite+"/accept",null,member.token,null);
  JsonNode visible=ok("GET",recorded(owner,"2026-09"),null,member.token,null).json;
  assertEquals("10.00",visible.get("summary").get("recordedExpenses").asString());assertEquals(1,visible.get("total").asInt());
  assertEquals("0.00",ok("GET",recorded(owner,"2026-09")+"&projectId="+project,null,member.token,null).json.get("summary").get("recordedExpenses").asString());
  assertEquals("0.00",ok("GET",base+"/projects/"+project+"/financial-summary",null,member.token,null).json.get("recordedExpenses").asString());
  assertEquals(404,call("GET",recorded(owner,"2026-09")+"&equipmentId="+b,null,member.token,null).status);
  ok("PUT",base+"/equipment/"+a+"/organization",Map.of(),owner.token,null);
  assertEquals("0.00",ok("GET",recorded(owner,"2026-09"),null,member.token,null).json.get("summary").get("recordedExpenses").asString());
 }

 @Test void fractionalMovementSharesReconcileToM2LifetimeShares()throws Exception{
  User owner=login("0500000407");String a=equipment(owner,"أ"),b=equipment(owner,"ب"),c=equipment(owner,"ج"),base=w(owner);
  String id=entry(owner,Map.of("amount","0.03","category","FUEL","operationDate","2026-09-01","paymentStatus","UNPAID","partyName","مورد","expenseScope","SHARED","allocations",List.of(Map.of("equipmentId",a,"amount","0.01"),Map.of("equipmentId",b,"amount","0.01"),Map.of("equipmentId",c,"amount","0.01"))));
  for(int day=1;day<=3;day++)ok("POST",base+"/entries/"+id+"/settlements",Map.of("amount","0.01","paidOn","2026-09-0"+day),owner.token,UUID.randomUUID().toString());
  assertEquals("0.03",ok("GET",movements(owner,"2026-09"),null,owner.token,null).json.get("summary").get("paid").asString());
  for(String equipment:List.of(a,b,c))assertEquals("0.01",ok("GET",movements(owner,"2026-09")+"&equipmentId="+equipment,null,owner.token,null).json.get("summary").get("paid").asString());
  ok("POST",base+"/entries/"+id+"/refunds",Map.of("amount","0.01","refundedOn","2026-10-01","reason","استرداد"),owner.token,UUID.randomUUID().toString());
  JsonNode entry=ok("GET",base+"/entries/"+id,null,owner.token,null).json;
  for(JsonNode allocation:entry.get("allocations")){
   String equipment=allocation.get("equipmentId").asString();
   JsonNode outstanding=ok("GET",base+"/reports/outstanding?equipmentId="+equipment,null,owner.token,null).json;
   String expected=allocation.get("remainingShare").asString();
   assertEquals(expected,outstanding.get("summary").get("payable").asString());
  }
 }

 @Test void settlementAfterRefundKeepsGrossAndRefundSharesAlignedWithM2()throws Exception{
  User owner=login("0500000408");String a=equipment(owner,"أ"),b=equipment(owner,"ب"),base=w(owner);
  String id=entry(owner,Map.of("amount","0.03","category","FUEL","operationDate","2026-09-01","paymentStatus","UNPAID","partyName","مورد","expenseScope","SHARED","allocations",List.of(Map.of("equipmentId",a,"amount","0.01"),Map.of("equipmentId",b,"amount","0.02"))));
  ok("POST",base+"/entries/"+id+"/settlements",Map.of("amount","0.02","paidOn","2026-09-03"),owner.token,UUID.randomUUID().toString());
  ok("POST",base+"/entries/"+id+"/refunds",Map.of("amount","0.01","refundedOn","2026-10-03","reason","استرداد"),owner.token,UUID.randomUUID().toString());
  ok("POST",base+"/entries/"+id+"/settlements",Map.of("amount","0.01","paidOn","2026-10-04"),owner.token,UUID.randomUUID().toString());
  JsonNode original=ok("GET",base+"/entries/"+id,null,owner.token,null).json;
  for(JsonNode part:original.get("allocations")){
   String equipment=part.get("equipmentId").asString();
   JsonNode september=ok("GET",movements(owner,"2026-09")+"&equipmentId="+equipment,null,owner.token,null).json;
   JsonNode october=ok("GET",movements(owner,"2026-10")+"&equipmentId="+equipment,null,owner.token,null).json;
   BigDecimal paid=new BigDecimal(september.get("summary").get("paid").asString()).add(new BigDecimal(october.get("summary").get("paid").asString()));
   BigDecimal refunded=new BigDecimal(october.get("summary").get("expenseRefunds").asString());
   assertEquals(0,paid.compareTo(new BigDecimal(part.get("paidShare").asString())));
   assertEquals(0,refunded.compareTo(new BigDecimal(part.get("refundedShare").asString())));
   assertEquals(0,paid.subtract(refunded).compareTo(new BigDecimal(part.get("netPaidShare").asString())));
  }
 }

 @Test void equalEntriesAndMultipleAttachmentsDoNotMultiplyRecordedOrMovements()throws Exception{
  User owner=login("0500000409");String eq=equipment(owner,"معدة"),base=w(owner);
  for(int i=0;i<2;i++){
   String id=entry(owner,Map.of("equipmentId",eq,"amount","10.00","category","FUEL","operationDate","2026-09-04","paymentStatus","UNPAID","partyName","مورد"));
   for(int file=0;file<2;file++)ok("POST",base+"/entries/"+id+"/attachments",Map.of("filename","receipt-"+i+"-"+file+".png","mediaType","image/png","size",4),owner.token,UUID.randomUUID().toString());
   for(int movement=0;movement<2;movement++)ok("POST",base+"/entries/"+id+"/settlements",Map.of("amount","5.00","paidOn","2026-09-05"),owner.token,UUID.randomUUID().toString());
  }
  JsonNode recorded=ok("GET",recorded(owner,"2026-09"),null,owner.token,null).json;
  assertEquals("20.00",recorded.get("summary").get("recordedExpenses").asString());assertEquals(2,recorded.get("total").asInt());
  JsonNode movements=ok("GET",movements(owner,"2026-09"),null,owner.token,null).json;
  assertEquals("20.00",movements.get("summary").get("paid").asString());assertEquals(4,movements.get("total").asInt());
 }

 @Test void totalIncludesRowsBeyondFirstPageAndCurrentClassificationOfArchivedEquipment()throws Exception{
  User owner=login("0500000410");String eq=equipment(owner,"معدة"),base=w(owner);
  String first=ok("POST",base+"/projects",Map.of("name","أول","kind","PROJECT"),owner.token,null).json.get("id").asString();
  String second=ok("POST",base+"/projects",Map.of("name","ثان","kind","PROJECT"),owner.token,null).json.get("id").asString();
  String classified=entry(owner,Map.of("equipmentId",eq,"amount","1.00","category","FUEL","operationDate","2026-09-05","paymentStatus","UNPAID","partyName","مورد","projectId",first));
  for(int i=0;i<30;i++)entry(owner,Map.of("equipmentId",eq,"amount","1.00","category","FUEL","operationDate","2026-09-05","paymentStatus","UNPAID","partyName","مورد"));
  JsonNode page0=ok("GET",recorded(owner,"2026-09"),null,owner.token,null).json;
  JsonNode page1=ok("GET",recorded(owner,"2026-09")+"&page=1",null,owner.token,null).json;
  assertEquals("31.00",page0.get("summary").get("recordedExpenses").asString());
  assertEquals(page0.get("summary").get("recordedExpenses").asString(),page1.get("summary").get("recordedExpenses").asString());
  assertEquals(31,page0.get("total").asInt());assertEquals(30,page0.get("items").size());assertEquals(1,page1.get("items").size());
  Set<String> ids=new HashSet<>();for(JsonNode row:page0.get("items"))ids.add(row.get("entryId").asString());for(JsonNode row:page1.get("items"))ids.add(row.get("entryId").asString());assertEquals(31,ids.size());
  ok("POST",base+"/equipment/"+eq+"/archive",null,owner.token,null);
  ok("PUT",base+"/entries/"+classified+"/project",Map.of("projectId",second),owner.token,null);
  assertEquals("0.00",ok("GET",recorded(owner,"2026-09")+"&projectId="+first,null,owner.token,null).json.get("summary").get("recordedExpenses").asString());
  assertEquals("1.00",ok("GET",recorded(owner,"2026-09")+"&projectId="+second,null,owner.token,null).json.get("summary").get("recordedExpenses").asString());
  assertEquals("31.00",ok("GET",recorded(owner,"2026-09")+"&equipmentId="+eq,null,owner.token,null).json.get("summary").get("recordedExpenses").asString());
 }

 @Test void projectSearchPagesAfterAuthorizationAndKeepsHistoricalSelectionReadable()throws Exception{
  User owner=login("0500000491"),member=login("0500000492");String base=w(owner);
  String permittedOrg=ok("POST",base+"/organizations",Map.of("name","Permitted"),owner.token,null).json.get("id").asString();
  String hiddenOrg=ok("POST",base+"/organizations",Map.of("name","Hidden"),owner.token,null).json.get("id").asString();
  String selected=ok("POST",base+"/projects",Map.of("name","Accessible older project","kind","PROJECT","organizationId",permittedOrg),owner.token,null).json.get("id").asString();
  String hidden=null;
  for(int i=0;i<101;i++){
   UUID id=UUID.randomUUID();hidden=id.toString();
   db.update("insert into project_or_contract(id,workspace_id,kind,name,organization_id,created_by,created_at) values(?,?,?,?,?,?,now()+ (? * interval '1 second'))",id,UUID.fromString(owner.workspace),"PROJECT","Hidden project "+i,UUID.fromString(hiddenOrg),UUID.fromString(owner.id),i);
  }
  JsonNode first=ok("GET",base+"/projects?page=0",null,owner.token,null).json;
  JsonNode second=ok("GET",base+"/projects?page=1",null,owner.token,null).json;
  assertEquals(100,first.size());assertEquals(2,second.size());
  assertEquals(1,ok("GET",base+"/projects?search=Accessible%20older%20project&page=0",null,owner.token,null).json.size());
  String invite=ok("POST",base+"/team/invitations",Map.of("displayName","Restricted","phone","0500000492","role","ACCOUNTANT","scope","SELECTED_ORGANIZATIONS","organizationIds",List.of(permittedOrg)),owner.token,null).json.get("id").asString();
  ok("POST","/account/invitations/"+invite+"/accept",null,member.token,null);
  JsonNode visible=ok("GET",base+"/projects?page=0",null,member.token,null).json;
  assertEquals(1,visible.size());assertEquals(selected,visible.get(0).get("id").asString());
  assertEquals(selected,ok("GET",base+"/projects/"+selected,null,member.token,null).json.get("id").asString());
  assertEquals(0,ok("GET",base+"/projects?search=Hidden&page=0",null,member.token,null).json.size());
  assertEquals(404,call("GET",base+"/projects/"+hidden,null,member.token,null).status);
 }

}
