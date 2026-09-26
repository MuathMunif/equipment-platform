package com.equipment;

import java.net.*;
import java.net.http.*;
import java.time.Duration;
import java.util.*;
import java.util.concurrent.*;
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
class M6OrganizationsProjectsTest {
 @DynamicPropertySource static void properties(DynamicPropertyRegistry r){r.add("app.storage-root",()->"../.local/test-objects/"+UUID.randomUUID());r.add("spring.datasource.url",TestDatabase::url);}
 @LocalServerPort int port;@Autowired JdbcTemplate db;
 final HttpClient client=HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build();
 static final JsonMapper JSON=JsonMapper.builder().build();
 record Reply(int status,JsonNode json){}
 record User(String token,String workspace,String id){}
 @BeforeEach void clean()throws Exception{TestDatabase.requireIsolated(db);db.execute("truncate audit_event,idempotency_record,attachment,settlement,financial_entry,equipment,app_session,otp_challenge,membership,workspace,app_user restart identity cascade");}
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
 String path(User u,String suffix){return "/workspaces/"+u.workspace+suffix;}
 String equipment(User u,String name)throws Exception{return ok("POST",path(u,"/equipment"),Map.of("name",name,"model","FH16"),u.token,UUID.randomUUID().toString()).json.get("id").asString();}
 String organization(User u,String name)throws Exception{return ok("POST",path(u,"/organizations"),Map.of("name",name),u.token,null).json.get("id").asString();}
 String project(User u,String name,String kind,String organization)throws Exception{Map<String,Object> body=new HashMap<>(Map.of("name",name,"kind",kind));if(organization!=null)body.put("organizationId",organization);return ok("POST",path(u,"/projects"),body,u.token,null).json.get("id").asString();}
 @Test void optionalityAssignmentsAndProjectLifecycle()throws Exception{
  User owner=login("0500000301");String w=path(owner,""),eq=equipment(owner,"شاحنة");
  assertEquals(0,ok("GET",w+"/organizations",null,owner.token,null).json.size());
  String a=organization(owner,"المؤسسة أ"),b=organization(owner,"المؤسسة ب");
  ok("PUT",w+"/equipment/"+eq+"/organization",Map.of("organizationId",a),owner.token,null);
  String p=project(owner,"مشروع أ","PROJECT",a);
  ok("POST",w+"/projects/"+p+"/equipment/"+eq,null,owner.token,null);
  assertEquals(p,ok("GET",w+"/projects/equipment/"+eq+"/active-projects",null,owner.token,null).json.get(0).get("id").asString());
  assertEquals(409,call("PUT",w+"/equipment/"+eq+"/organization",Map.of("organizationId",b),owner.token,null).status);
  Reply blocked=call("POST",w+"/organizations/"+a+"/archive",null,owner.token,null);assertEquals(409,blocked.status);assertTrue(blocked.json.get("message").asString().contains("1 معدة"));assertTrue(blocked.json.get("message").asString().contains("1 مشروع"));
  ok("POST",w+"/projects/"+p+"/complete",null,owner.token,null);
  assertEquals(0,ok("GET",w+"/projects/equipment/"+eq+"/active-projects",null,owner.token,null).json.size());
  assertFalse(ok("GET",w+"/projects/"+p+"/equipment",null,owner.token,null).json.get(0).get("unlinked_at").isNull());
  ok("PUT",w+"/equipment/"+eq+"/organization",Map.of("organizationId",b),owner.token,null);
  assertEquals(2,ok("GET",w+"/equipment/"+eq+"/organization-history",null,owner.token,null).json.size());
  ok("POST",w+"/projects/"+p+"/reopen",null,owner.token,null);
  assertEquals(1,ok("GET",w+"/projects/"+p+"/equipment",null,owner.token,null).json.size());
  ok("POST",w+"/projects/"+p+"/archive",null,owner.token,null);
  ok("POST",w+"/organizations/"+a+"/archive",null,owner.token,null);
 }
 @Test void projectSearchFiltersAndDates()throws Exception{
  User owner=login("0500000311");String w=path(owner,""),org=organization(owner,"مؤسسة");
  assertEquals(400,call("POST",w+"/projects",Map.of("kind","CONTRACT","name","خطأ","startDate","2026-10-10","endDate","2026-10-01"),owner.token,null).status);
  String id=ok("POST",w+"/projects",Map.of("kind","CONTRACT","name","تنفيذ","organizationId",org,"clientName","العميل المحدد","contractNumber","CN-981","startDate","2026-10-01","endDate","2026-10-10"),owner.token,null).json.get("id").asString();
  assertEquals(id,ok("GET",w+"/projects?search=CN-981&kind=CONTRACT&status=ACTIVE&organizationId="+org,null,owner.token,null).json.get(0).get("id").asString());
  assertEquals(1,ok("GET",w+"/projects?search=%D8%A7%D9%84%D8%B9%D9%85%D9%8A%D9%84",null,owner.token,null).json.size());
  ok("POST",w+"/projects/"+id+"/complete",null,owner.token,null);
  assertEquals(0,ok("GET",w+"/projects?status=ACTIVE",null,owner.token,null).json.size());
  assertEquals(1,ok("GET",w+"/projects?status=COMPLETED",null,owner.token,null).json.size());
 }
 @Test void concurrentOrganizationAssignmentsLeaveOneCurrentRow()throws Exception{
  User owner=login("0500000312");String w=path(owner,""),eq=equipment(owner,"معدة"),a=organization(owner,"أ"),b=organization(owner,"ب");
  try(var pool=Executors.newVirtualThreadPerTaskExecutor()){
   var first=pool.submit(()->call("PUT",w+"/equipment/"+eq+"/organization",Map.of("organizationId",a),owner.token,null));
   var second=pool.submit(()->call("PUT",w+"/equipment/"+eq+"/organization",Map.of("organizationId",b),owner.token,null));
   assertEquals(200,first.get(10,TimeUnit.SECONDS).status);
   assertEquals(200,second.get(10,TimeUnit.SECONDS).status);
  }
  assertEquals(1,db.queryForObject("select count(*) from equipment_organization_assignment where workspace_id=? and equipment_id=? and ended_at is null",Integer.class,UUID.fromString(owner.workspace),UUID.fromString(eq)));
 }
 @Test void organizationScopeUpdatesWithoutReloginAndProjectSecurity()throws Exception{
  User owner=login("0500000302"),member=login("0500000303");String w=path(owner,"");String a=organization(owner,"أ"),b=organization(owner,"ب"),first=equipment(owner,"أولى"),second=equipment(owner,"ثانية");
  ok("PUT",w+"/equipment/"+first+"/organization",Map.of("organizationId",a),owner.token,null);
  ok("PUT",w+"/equipment/"+second+"/organization",Map.of("organizationId",b),owner.token,null);
  assertEquals(1,ok("GET",w+"/equipment?organizationId="+a,null,owner.token,null).json.get("total").asInt());
  String invite=ok("POST",w+"/team/invitations",Map.of("displayName","محاسب","phone","0500000303","role","ACCOUNTANT","scope","SELECTED_ORGANIZATIONS","organizationIds",List.of(a)),owner.token,null).json.get("id").asString();
  ok("POST","/account/invitations/"+invite+"/accept",null,member.token,null);
  assertEquals(200,call("GET",w+"/equipment/"+first,null,member.token,null).status);
  assertEquals(404,call("GET",w+"/equipment/"+second,null,member.token,null).status);
  String pa=project(owner,"تابع أ","PROJECT",a),pb=project(owner,"تابع ب","CONTRACT",b),global=project(owner,"عام","PROJECT",null);
  assertEquals(200,call("GET",w+"/projects/"+pa,null,member.token,null).status);
  assertEquals(404,call("GET",w+"/projects/"+pb,null,member.token,null).status);
  assertEquals(404,call("GET",w+"/projects/"+global,null,member.token,null).status);
  ok("POST",w+"/projects/"+pa+"/equipment/"+first,null,owner.token,null);
  ok("POST",w+"/projects/"+pa+"/complete",null,owner.token,null);
  assertEquals(1,ok("GET",w+"/projects/"+pa+"/equipment",null,member.token,null).json.size());
  String issue=ok("POST",w+"/equipment/"+first+"/issues",Map.of("description","عطل"),owner.token,UUID.randomUUID().toString()).json.get("id").asString();
  String entry=ok("POST",w+"/entries",Map.of("equipmentId",first,"amount","10.00","category","FUEL","operationDate","2026-09-25","paymentStatus","UNPAID","partyName","مورد","projectId",pa),owner.token,UUID.randomUUID().toString()).json.get("id").asString();
  ok("POST",w+"/entries/"+entry+"/attachments",Map.of("filename","receipt.png","mediaType","image/png","size",4),owner.token,UUID.randomUUID().toString());
  assertEquals("10.00",ok("GET",w+"/projects/"+pa+"/financial-summary",null,member.token,null).json.get("recordedExpenses").asString());
  assertEquals(200,call("GET",w+"/entries/"+entry+"/attachments",null,member.token,null).status);
  ok("PUT",w+"/equipment/"+first+"/organization",Map.of("organizationId",b),owner.token,null);
  assertEquals(0,ok("GET",w+"/projects/"+pa+"/equipment",null,member.token,null).json.size());
  assertEquals(404,call("GET",w+"/equipment/"+first,null,member.token,null).status);
  assertEquals(404,call("GET",w+"/issues/"+issue,null,member.token,null).status);
  assertEquals(404,call("GET",w+"/entries/"+entry+"/attachments",null,member.token,null).status);
  assertEquals("0.00",ok("GET",w+"/projects/"+pa+"/financial-summary",null,member.token,null).json.get("recordedExpenses").asString());
  ok("PUT",w+"/equipment/"+second+"/organization",Map.of("organizationId",a),owner.token,null);
  assertEquals(200,call("GET",w+"/equipment/"+second,null,member.token,null).status);
  db.update("update membership set capabilities=array['PROJECT_VIEW']::text[] where workspace_id=? and user_id=?",UUID.fromString(owner.workspace),UUID.fromString(member.id));
  assertEquals(200,call("GET",w+"/projects/"+pa,null,member.token,null).status);
  assertEquals(404,call("GET",w+"/projects/"+pa+"/financial-summary",null,member.token,null).status);
 }
 @Test void projectFinanceRemainsM2OwnedAndClassificationMutable()throws Exception{
  User owner=login("0500000304");String w=path(owner,""),eq=equipment(owner,"آلة"),p=project(owner,"عقد","CONTRACT",null);
  Map<String,Object> expense=new HashMap<>(Map.of("equipmentId",eq,"amount","100.00","category","FUEL","operationDate","2026-09-25","paymentStatus","UNPAID","partyName","مورد"));expense.put("projectId",p);
  String entry=ok("POST",w+"/entries",expense,owner.token,UUID.randomUUID().toString()).json.get("id").asString();
  assertEquals("100.00",ok("GET",w+"/projects/"+p+"/financial-summary",null,owner.token,null).json.get("recordedExpenses").asString());
  ok("POST",w+"/entries/"+entry+"/settlements",Map.of("amount","40.00","paidOn","2026-09-25"),owner.token,UUID.randomUUID().toString());
  assertEquals("40.00",ok("GET",w+"/projects/"+p+"/financial-summary",null,owner.token,null).json.get("paid").asString());
  ok("POST",w+"/entries/"+entry+"/refunds",Map.of("amount","10.00","refundedOn","2026-09-25","reason","استرداد"),owner.token,UUID.randomUUID().toString());
  assertEquals("30.00",ok("GET",w+"/projects/"+p+"/financial-summary",null,owner.token,null).json.get("paid").asString());
  ok("PUT",w+"/entries/"+entry+"/project",Map.of(),owner.token,null);
  assertEquals("0.00",ok("GET",w+"/projects/"+p+"/financial-summary",null,owner.token,null).json.get("recordedExpenses").asString());
  assertEquals("40.00",ok("GET",w+"/entries/"+entry,null,owner.token,null).json.get("paid").asString());
  assertEquals("10.00",ok("GET",w+"/entries/"+entry,null,owner.token,null).json.get("refunded").asString());
  ok("POST",w+"/entries/"+entry+"/cancellation",Map.of("reason","قيد خاطئ"),owner.token,null);
  assertEquals(409,call("PUT",w+"/entries/"+entry+"/project",Map.of("projectId",p),owner.token,null).status);
 }
 @Test void projectOrganizationCompatibilitySharedExpenseAndTenantIsolation()throws Exception{
  User owner=login("0500000305"),other=login("0500000306");String w=path(owner,"");String a=organization(owner,"أ"),b=organization(owner,"ب"),eqA=equipment(owner,"معدات أ"),eqB=equipment(owner,"معدات ب");
  ok("PUT",w+"/equipment/"+eqA+"/organization",Map.of("organizationId",a),owner.token,null);
  ok("PUT",w+"/equipment/"+eqB+"/organization",Map.of("organizationId",b),owner.token,null);
  String scoped=project(owner,"خاص أ","PROJECT",a),global=project(owner,"مشترك","CONTRACT",null);
  assertEquals(409,call("POST",w+"/projects/"+scoped+"/equipment/"+eqB,null,owner.token,null).status);
  ok("POST",w+"/projects/"+global+"/equipment/"+eqA,null,owner.token,null);
  ok("POST",w+"/projects/"+global+"/equipment/"+eqB,null,owner.token,null);
  Map<String,Object> shared=new HashMap<>(Map.of("amount","100.00","category","FUEL","operationDate","2026-09-25","paymentStatus","UNPAID","partyName","مورد","expenseScope","SHARED","allocations",List.of(Map.of("equipmentId",eqA,"amount","60.00"),Map.of("equipmentId",eqB,"amount","40.00"))));
  shared.put("projectId",scoped);
  assertEquals(409,call("POST",w+"/entries",shared,owner.token,UUID.randomUUID().toString()).status);
  shared.put("projectId",global);
  String entry=ok("POST",w+"/entries",shared,owner.token,UUID.randomUUID().toString()).json.get("id").asString();
  assertEquals("100.00",ok("GET",w+"/projects/"+global+"/financial-summary",null,owner.token,null).json.get("recordedExpenses").asString());
  assertEquals(404,call("GET",path(other,"/projects/"+global),null,other.token,null).status);
  assertEquals(404,call("PUT",path(other,"/entries/"+entry+"/project"),Map.of("projectId",global),other.token,null).status);
 }
 @Test void selectedEquipmentCannotOpenProjectOrItsAttachments()throws Exception{
  User owner=login("0500000307"),member=login("0500000308");String w=path(owner,""),eq=equipment(owner,"آلة"),p=project(owner,"سري","PROJECT",null);
  String invitation=ok("POST",w+"/team/invitations",Map.of("displayName","عضو","phone","0500000308","role","ACCOUNTANT","scope","SELECTED_EQUIPMENT","equipmentIds",List.of(eq)),owner.token,null).json.get("id").asString();
  ok("POST","/account/invitations/"+invitation+"/accept",null,member.token,null);
  assertEquals(404,call("GET",w+"/projects/"+p,null,member.token,null).status);
  assertEquals(0,ok("GET",w+"/projects",null,member.token,null).json.size());
  assertEquals(404,call("GET",w+"/projects/"+p+"/attachments",null,member.token,null).status);
  assertEquals(404,call("GET",w+"/projects/"+p+"/financial-summary",null,member.token,null).status);
 }
 @Test void reviewerClassifiesDriverSubmissionWithoutDuplicateMoney()throws Exception{
  User owner=login("0500000309"),driver=login("0500000310");String w=path(owner,""),eq=equipment(owner,"شاحنة"),p=project(owner,"توريد","PROJECT",null);
  String invitation=ok("POST",w+"/team/invitations",Map.of("displayName","سائق","phone","0500000310","role","DRIVER"),owner.token,null).json.get("id").asString();
  ok("POST","/account/invitations/"+invitation+"/accept",null,driver.token,null);
  ok("POST",w+"/drivers/assignments",Map.of("driverUserId",driver.id,"equipmentId",eq),owner.token,null);
  String submission=ok("POST",w+"/financial-submissions",Map.of("note","وقود"),driver.token,null).json.get("id").asString();
  Map<String,Object> approved=Map.of("equipmentId",eq,"amount","25.00","category","FUEL","operationDate","2026-09-25","paidOn","2026-09-25","projectId",p);
  JsonNode result=ok("POST",w+"/financial-submissions/"+submission+"/approve",approved,owner.token,null).json;
  assertEquals("APPROVED",result.get("status").asString());
  assertEquals(1,db.queryForObject("select count(*) from financial_entry where workspace_id=? and lifecycle='POSTED'",Integer.class,UUID.fromString(owner.workspace)));
  assertEquals(p,ok("GET",w+"/entries/"+result.get("approvedFinancialEntryId").asString(),null,owner.token,null).json.get("projectId").asString());
  assertEquals("25.00",ok("GET",w+"/projects/"+p+"/financial-summary",null,owner.token,null).json.get("recordedExpenses").asString());
 }
}
