package com.equipment;

import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.net.*;
import java.net.http.*;
import java.time.Duration;
import java.util.*;
import java.util.concurrent.*;
import javax.sql.DataSource;
import javax.imageio.ImageIO;
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

@SpringBootTest(webEnvironment=SpringBootTest.WebEnvironment.RANDOM_PORT, properties={
 "spring.datasource.url=jdbc:postgresql://127.0.0.1:55433/equipment_test",
 "spring.datasource.username=equipment_test","spring.datasource.password=isolated-test-only"})
@ActiveProfiles({"dev","test"})
class TeamM5Test {
 @DynamicPropertySource static void properties(DynamicPropertyRegistry r){r.add("app.storage-root",()->"../.local/test-objects/"+UUID.randomUUID());}
 @LocalServerPort int port;@Autowired JdbcTemplate db;@Autowired DataSource dataSource;
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
  String token=ok("POST","/auth/verify",Map.of("challengeId",challenge,"code","123456","name","عضو تجريبي","client","NATIVE"),null,null).json.get("accessToken").asString();
  JsonNode me=ok("GET","/auth/me",null,token,null).json;return new User(token,me.get("workspaces").get(0).get("id").asString(),me.get("userId").asString());
 }
 String path(User u,String suffix){return "/workspaces/"+u.workspace+suffix;}
 String equipment(User u,String name)throws Exception{return ok("POST",path(u,"/equipment"),Map.of("name",name,"model","FH16"),u.token,UUID.randomUUID().toString()).json.get("id").asString();}
 String invite(User owner,String phone,String role,Object scope,List<String> ids)throws Exception{
  Map<String,Object> body=new LinkedHashMap<>();body.put("displayName","عضو مدعو");body.put("phone",phone);body.put("role",role);if(scope!=null)body.put("scope",scope);if(ids!=null)body.put("equipmentIds",ids);
  return ok("POST",path(owner,"/team/invitations"),body,owner.token,null).json.get("id").asString();
 }
 void accept(User invited,String id)throws Exception{ok("POST","/account/invitations/"+id+"/accept",null,invited.token,null);}
 @Test void invitationNormalizationAcceptanceAndLiveRevocation()throws Exception{
  User owner=login("0500000001"),member=login("0500000003");String eq=equipment(owner,"شاحنة ١");
  String invitation=invite(owner,"966500000003","ACCOUNTANT","SELECTED_EQUIPMENT",List.of(eq));
  assertEquals(409,call("POST",path(owner,"/team/invitations"),Map.of("displayName","مكرر","phone","+966500000003","role","ACCOUNTANT","scope","SELECTED_EQUIPMENT","equipmentIds",List.of(eq)),owner.token,null).status);
  assertEquals(1,ok("GET","/account/invitations",null,member.token,null).json.size());accept(member,invitation);
  assertEquals(200,call("GET","/workspaces/"+owner.workspace+"/equipment/"+eq,null,member.token,null).status);
  assertEquals(404,call("GET","/workspaces/"+owner.workspace+"/equipment/"+equipment(owner,"شاحنة ٢"),null,member.token,null).status);
  ok("DELETE",path(owner,"/team/members/"+member.id),null,owner.token,null);
  assertEquals(404,call("GET","/workspaces/"+owner.workspace+"/equipment/"+eq,null,member.token,null).status);
  assertEquals(200,call("GET",path(member,"/equipment"),null,member.token,null).status);
 }
 @Test void driverAssignmentIssueAndFinancialApproval()throws Exception{
  User owner=login("0500000001"),driver=login("0500000004");String equipment=equipment(owner,"شاحنة السائق");String invitation=invite(owner,"0500000004","DRIVER",null,null);accept(driver,invitation);
  String workspace="/workspaces/"+owner.workspace;
  assertEquals(409,call("POST",workspace+"/financial-submissions",Map.of("note","وقود"),driver.token,null).status);
  ok("POST",workspace+"/drivers/assignments",Map.of("driverUserId",driver.id,"equipmentId",equipment),owner.token,null);
  assertEquals("DRIVER_ASSIGNED",ok("GET",workspace+"/notifications",null,driver.token,null).json.get("items").get(0).get("type").asString());
  assertEquals(equipment,ok("GET",workspace+"/drivers/me/assignment",null,driver.token,null).json.get("equipmentId").asString());
  String issue=ok("POST",workspace+"/equipment/"+equipment+"/issues",Map.of("description","تسريب زيت"),driver.token,UUID.randomUUID().toString()).json.get("id").asString();
  assertEquals("DRIVER_ISSUE",ok("GET",workspace+"/notifications",null,owner.token,null).json.get("items").get(0).get("type").asString());
  assertEquals("OPEN",ok("GET",workspace+"/issues/"+issue,null,owner.token,null).json.get("status").asString());
  String submission=ok("POST",workspace+"/financial-submissions",Map.of("note","فاتورة وقود"),driver.token,null).json.get("id").asString();
  assertEquals(1,ok("GET",workspace+"/financial-submissions/review-queue",null,owner.token,null).json.get("total").asInt());
  assertEquals("0.00",ok("GET",workspace+"/entries/totals",null,owner.token,null).json.get("expenseTotal").asString());
  Map<String,Object> expense=Map.of("equipmentId",equipment,"amount","120.00","category","FUEL","operationDate","2026-09-25","paidOn","2026-09-25","note","اعتماد");
  JsonNode approved=ok("POST",workspace+"/financial-submissions/"+submission+"/approve",expense,owner.token,null).json;
  assertEquals("APPROVED",approved.get("status").asString());assertEquals(409,call("POST",workspace+"/financial-submissions/"+submission+"/approve",expense,owner.token,null).status);
  assertEquals("120.00",ok("GET",workspace+"/entries/totals",null,owner.token,null).json.get("expenseTotal").asString());
  JsonNode entry=ok("GET",workspace+"/entries/"+approved.get("approvedFinancialEntryId").asString(),null,owner.token,null).json;
  assertEquals(owner.id,entry.get("createdBy").asString());assertEquals(driver.id,entry.get("submittedBy").asString());assertEquals(submission,entry.get("submissionId").asString());
 }
 @Test void reviewModeCannotMutateLegacyEntriesDraftsOrEntryAttachments()throws Exception{
  User owner=login("0500000001"),reviewer=login("0500000015"),driver=login("0500000016");String eq=equipment(owner,"شاحنة المراجعة"),w="/workspaces/"+owner.workspace;
  accept(reviewer,invite(owner,"0500000015","ACCOUNTANT",null,null));
  ok("PUT",w+"/team/members/"+reviewer.id,Map.of("financialMode","REVIEW"),owner.token,null);
  accept(driver,invite(owner,"0500000016","DRIVER",null,null));
  ok("POST",w+"/drivers/assignments",Map.of("driverUserId",driver.id,"equipmentId",eq),owner.token,null);
  String entry=ok("POST",w+"/entries",Map.of("equipmentId",eq,"amount","100.00","category","FUEL","operationDate","2026-09-25","paymentStatus","UNPAID","partyName","مورد","dueDate","2026-10-01"),owner.token,UUID.randomUUID().toString()).json.get("id").asString();
  String draft=ok("POST",w+"/drafts",Map.of("equipmentId",eq,"note","مسودة المالك"),owner.token,UUID.randomUUID().toString()).json.get("id").asString();
  String attachment=ok("POST",w+"/entries/"+entry+"/attachments",Map.of("filename","receipt.png","mediaType","image/png","size",4),owner.token,UUID.randomUUID().toString()).json.get("id").asString();
  assertEquals(200,call("GET",w+"/entries/"+entry,null,reviewer.token,null).status);
  assertEquals(200,call("GET",w+"/drafts/"+draft,null,reviewer.token,null).status);
  assertEquals(200,call("GET",w+"/entries/"+entry+"/attachments",null,reviewer.token,null).status);
  Map<String,Object> create=Map.of("equipmentId",eq,"amount","25.00","category","FUEL","operationDate","2026-09-25","paidOn","2026-09-25");
  Map<String,Object> edit=Map.of("equipmentId",eq,"amount","100.00","category","FUEL","operationDate","2026-09-25","partyName","مورد","dueDate","2026-10-01");
  for(User member:List.of(reviewer,driver)){
   assertEquals(404,call("POST",w+"/entries",create,member.token,UUID.randomUUID().toString()).status);
   assertEquals(404,call("POST",w+"/drafts",Map.of("equipmentId",eq,"note","ممنوع"),member.token,UUID.randomUUID().toString()).status);
   assertEquals(404,call("POST",w+"/drafts/"+draft+"/completion",create,member.token,UUID.randomUUID().toString()).status);
   assertEquals(404,call("DELETE",w+"/drafts/"+draft,null,member.token,null).status);
   assertEquals(404,call("PUT",w+"/entries/"+entry,edit,member.token,null).status);
   assertEquals(404,call("POST",w+"/entries/"+entry+"/settlements",Map.of("amount","10.00","paidOn","2026-09-25"),member.token,UUID.randomUUID().toString()).status);
   assertEquals(404,call("POST",w+"/entries/"+entry+"/refunds",Map.of("amount","5.00","refundedOn","2026-09-25","reason","اختبار"),member.token,UUID.randomUUID().toString()).status);
   assertEquals(404,call("POST",w+"/entries/"+entry+"/cancellation",Map.of("reason","اختبار"),member.token,null).status);
   assertEquals(404,call("POST",w+"/entries/"+entry+"/attachments",Map.of("filename","other.png","mediaType","image/png","size",4),member.token,UUID.randomUUID().toString()).status);
   assertEquals(404,call("PUT",w+"/attachments/"+attachment+"/content",Map.of("bytes","test"),member.token,null).status);
  }
  assertEquals(1,db.queryForObject("select count(*) from financial_entry where workspace_id=? and lifecycle='POSTED'",Integer.class,UUID.fromString(owner.workspace)));
  assertEquals(0,db.queryForObject("select count(*) from settlement where workspace_id=?",Integer.class,UUID.fromString(owner.workspace)));
  assertEquals(1,db.queryForObject("select count(*) from attachment where workspace_id=?",Integer.class,UUID.fromString(owner.workspace)));
  assertEquals(200,call("POST",w+"/financial-submissions",Map.of("equipmentId",eq,"amount","20.00"),reviewer.token,null).status);
  assertEquals(200,call("POST",w+"/financial-submissions",Map.of("amount","20.00"),driver.token,null).status);
  ok("PUT",w+"/team/members/"+reviewer.id,Map.of("financialMode","DIRECT"),owner.token,null);
  assertEquals(200,call("POST",w+"/entries/"+entry+"/settlements",Map.of("amount","10.00","paidOn","2026-09-25"),reviewer.token,UUID.randomUUID().toString()).status);
 }
 @Test void unassignWaitsForWorkspaceAssignmentLock()throws Exception{
  User owner=login("0500000001"),driver=login("0500000017");String eq=equipment(owner,"شاحنة القفل"),w="/workspaces/"+owner.workspace;
  accept(driver,invite(owner,"0500000017","DRIVER",null,null));
  ok("POST",w+"/drivers/assignments",Map.of("driverUserId",driver.id,"equipmentId",eq),owner.token,null);
  try(var connection=dataSource.getConnection();var pool=Executors.newVirtualThreadPerTaskExecutor()){
   connection.setAutoCommit(false);
   try(var lock=connection.prepareStatement("select pg_advisory_xact_lock(hashtextextended(?,0))")){lock.setString(1,"assign:"+owner.workspace);lock.executeQuery().close();}
   var request=pool.submit(()->call("DELETE",w+"/drivers/equipment/"+eq+"/assignment",null,owner.token,null));
   assertThrows(TimeoutException.class,()->request.get(750,TimeUnit.MILLISECONDS));
   connection.commit();
   assertEquals(200,request.get(10,TimeUnit.SECONDS).status);
  }
  assertEquals(0,db.queryForObject("select count(*) from driver_assignment where workspace_id=? and equipment_id=? and ended_at is null",Integer.class,UUID.fromString(owner.workspace),UUID.fromString(eq)));
 }
 @Test void cancelledInvitationAndOwnerProtection()throws Exception{
  User owner=login("0500000001"),member=login("0500000005");String invitation=invite(owner,"0500000005","MANAGER",null,null);
  ok("POST",path(owner,"/team/invitations/"+invitation+"/cancel"),null,owner.token,null);
  assertEquals(409,call("POST","/account/invitations/"+invitation+"/accept",null,member.token,null).status);
  assertEquals(404,call("DELETE",path(owner,"/team/members/"+owner.id),null,owner.token,null).status);
  assertEquals(404,call("PUT",path(owner,"/team/members/"+owner.id),Map.of("role","DRIVER"),owner.token,null).status);
  assertThrows(org.springframework.dao.DataIntegrityViolationException.class,()->db.update("update membership set active=false where workspace_id=? and user_id=?",UUID.fromString(owner.workspace),UUID.fromString(owner.id)));
 }
 @Test void scopedManagerSeesOnlyEligibleDriversAndCurrentDriverName()throws Exception{
  User owner=login("0500000001"),manager=login("0500000002"),insideDriver=login("0500000003"),outsideDriver=login("0500000004"),freeDriver=login("0500000005"),accountant=login("0500000006"),outsider=login("0500000007");
  String inside=equipment(owner,"داخل"),target=equipment(owner,"الهدف"),outside=equipment(owner,"خارج"),w="/workspaces/"+owner.workspace;
  equipment(outsider,"معدات المستأجر الآخر");
  accept(manager,invite(owner,"0500000002","MANAGER","SELECTED_EQUIPMENT",List.of(inside,target)));
  String first=ok("POST",w+"/team/invitations",Map.of("displayName","السائق الأول","phone","0500000003","role","DRIVER"),owner.token,null).json.get("id").asString();accept(insideDriver,first);
  String second=ok("POST",w+"/team/invitations",Map.of("displayName","السائق خارج النطاق","phone","0500000004","role","DRIVER"),owner.token,null).json.get("id").asString();accept(outsideDriver,second);
  String third=ok("POST",w+"/team/invitations",Map.of("displayName","السائق المتاح","phone","0500000005","role","DRIVER"),owner.token,null).json.get("id").asString();accept(freeDriver,third);
  accept(accountant,invite(owner,"0500000006","ACCOUNTANT",null,null));
  ok("POST",w+"/drivers/assignments",Map.of("driverUserId",insideDriver.id,"equipmentId",inside),owner.token,null);
  ok("POST",w+"/drivers/assignments",Map.of("driverUserId",outsideDriver.id,"equipmentId",outside),owner.token,null);
  JsonNode eligible=ok("GET",w+"/drivers/eligible?equipmentId="+target,null,manager.token,null).json;
  assertEquals(2,eligible.size());assertTrue(eligible.toString().contains(insideDriver.id));assertTrue(eligible.toString().contains(freeDriver.id));
  assertFalse(eligible.toString().contains(outsideDriver.id));assertFalse(eligible.toString().contains(accountant.id));assertFalse(eligible.toString().contains(owner.id));
  JsonNode current=ok("GET",w+"/drivers/equipment/"+inside+"/assignment",null,manager.token,null).json;
  assertEquals(insideDriver.id,current.get("driverUserId").asString());assertEquals("السائق الأول",current.get("driverName").asString());assertFalse(current.get("startedAt").isNull());
  JsonNode empty=ok("GET",w+"/drivers/equipment/"+target+"/assignment",null,manager.token,null).json;
  assertEquals(target,empty.get("equipmentId").asString());assertTrue(empty.get("driverUserId").isNull());assertTrue(empty.get("driverName").isNull());
  assertEquals(404,call("GET",w+"/drivers/eligible?equipmentId="+outside,null,manager.token,null).status);
  assertEquals(404,call("GET",w+"/drivers/equipment/"+outside+"/assignment",null,manager.token,null).status);
  assertEquals(404,call("GET",w+"/drivers/equipment/"+inside+"/assignment",null,outsider.token,null).status);
  assertEquals(404,call("GET",w+"/drivers/eligible?equipmentId="+inside,null,accountant.token,null).status);
  assertEquals(404,call("GET",w+"/drivers/equipment/"+inside+"/assignment",null,insideDriver.token,null).status);
  assertEquals(404,call("GET",w+"/team/members",null,manager.token,null).status);
  ok("POST",w+"/drivers/assignments",Map.of("driverUserId",insideDriver.id,"equipmentId",target),manager.token,null);
  assertEquals("السائق الأول",ok("GET",w+"/drivers/equipment/"+target+"/assignment",null,manager.token,null).json.get("driverName").asString());
  assertEquals(404,call("POST",w+"/drivers/assignments",Map.of("driverUserId",insideDriver.id,"equipmentId",outside),manager.token,null).status);
  ok("POST",w+"/drivers/assignments",Map.of("driverUserId",freeDriver.id,"equipmentId",inside),owner.token,null);
  JsonNode replaced=ok("GET",w+"/drivers/equipment/"+inside+"/assignment",null,manager.token,null).json;
  assertEquals("السائق المتاح",replaced.get("driverName").asString());
 }
 @Test void selectedScopeFiltersM0ThroughM4AndSharedFinance()throws Exception{
  User owner=login("0500000001"),accountant=login("0500000006");String inside=equipment(owner,"داخل النطاق"),outside=equipment(owner,"خارج النطاق"),w="/workspaces/"+owner.workspace;
  String docInside=ok("POST",w+"/equipment/"+inside+"/documents",Map.of("type","INSURANCE"),owner.token,UUID.randomUUID().toString()).json.get("id").asString();
  String docOutside=ok("POST",w+"/equipment/"+outside+"/documents",Map.of("type","INSURANCE"),owner.token,UUID.randomUUID().toString()).json.get("id").asString();
  String issueOutside=ok("POST",w+"/equipment/"+outside+"/issues",Map.of("description","بلاغ خارج النطاق"),owner.token,UUID.randomUUID().toString()).json.get("id").asString();
  String maintenanceOutside=ok("POST",w+"/equipment/"+outside+"/maintenance",Map.of("description","صيانة خارج النطاق","maintenanceDate","2026-09-25"),owner.token,UUID.randomUUID().toString()).json.get("id").asString();
  Map<String,Object> single=Map.of("equipmentId",inside,"amount","50.00","category","FUEL","operationDate","2026-09-25","paidOn","2026-09-25");
  String entryInside=ok("POST",w+"/entries",single,owner.token,UUID.randomUUID().toString()).json.get("id").asString();
  String entryOutside=ok("POST",w+"/entries",Map.of("equipmentId",outside,"amount","50.00","category","FUEL","operationDate","2026-09-25","paidOn","2026-09-25"),owner.token,UUID.randomUUID().toString()).json.get("id").asString();
  String shared=ok("POST",w+"/entries",Map.of("expenseScope","SHARED","amount","100.00","category","OTHER","operationDate","2026-09-25","paymentStatus","UNPAID","partyName","مورد","allocations",List.of(Map.of("equipmentId",inside,"amount","50.00"),Map.of("equipmentId",outside,"amount","50.00"))),owner.token,UUID.randomUUID().toString()).json.get("id").asString();
  String invitation=invite(owner,"0500000006","ACCOUNTANT","SELECTED_EQUIPMENT",List.of(inside));accept(accountant,invitation);
  assertEquals(200,call("GET",w+"/documents/"+docInside,null,accountant.token,null).status);
  assertEquals(404,call("GET",w+"/documents/"+docOutside,null,accountant.token,null).status);
  assertEquals(404,call("GET",w+"/issues/"+issueOutside,null,accountant.token,null).status);
  assertEquals(404,call("GET",w+"/maintenance/"+maintenanceOutside,null,accountant.token,null).status);
  assertEquals(200,call("GET",w+"/entries/"+entryInside,null,accountant.token,null).status);
  assertEquals(404,call("GET",w+"/entries/"+entryOutside,null,accountant.token,null).status);
  assertEquals(404,call("GET",w+"/entries/"+shared,null,accountant.token,null).status);
  assertEquals(404,call("GET",w+"/entries/"+entryOutside+"/attachments",null,accountant.token,null).status);
  String outsideVersion=ok("GET",w+"/documents/"+docOutside,null,owner.token,null).json.get("versionId").asString();
  assertEquals(404,call("GET",w+"/documents/"+docOutside+"/versions/"+outsideVersion+"/attachments",null,accountant.token,null).status);
  assertEquals(404,call("GET",w+"/issues/"+issueOutside+"/attachments",null,accountant.token,null).status);
  assertEquals(404,call("GET",w+"/maintenance/"+maintenanceOutside+"/attachments",null,accountant.token,null).status);
  assertEquals(1,ok("GET",w+"/entries",null,accountant.token,null).json.get("total").asInt());
  assertEquals("50.00",ok("GET",w+"/entries/totals?equipmentId="+inside,null,accountant.token,null).json.get("expenseTotal").asString());
  assertEquals(404,call("GET",w+"/entries/totals",null,accountant.token,null).status);
  assertEquals(0,ok("GET",w+"/issues",null,accountant.token,null).json.get("total").asInt());
  assertEquals(0,ok("GET",w+"/maintenance",null,accountant.token,null).json.get("total").asInt());
  String draft=ok("POST",w+"/drafts",Map.of("equipmentId",inside,"note","مسودة"),accountant.token,UUID.randomUUID().toString()).json.get("id").asString();
  assertEquals(1,ok("GET",w+"/drafts",null,accountant.token,null).json.get("total").asInt());
  assertEquals(404,call("POST",w+"/drafts",Map.of("equipmentId",outside,"note","خارج"),accountant.token,UUID.randomUUID().toString()).status);
  assertEquals(200,call("GET",w+"/drafts/"+draft,null,accountant.token,null).status);
  for(String equipmentId:List.of(inside,outside))db.update("insert into financial_submission(id,workspace_id,equipment_id,submitted_by,transaction_date,note) values(?,?,?,?,?,?)",UUID.randomUUID(),UUID.fromString(owner.workspace),UUID.fromString(equipmentId),UUID.fromString(owner.id),java.sql.Date.valueOf("2026-09-25"),"اختبار النطاق");
  assertEquals(1,ok("GET",w+"/financial-submissions/review-queue",null,accountant.token,null).json.get("total").asInt());
  JsonNode attention=ok("GET",w+"/attention",null,accountant.token,null).json;
  assertEquals("FINANCIAL_REVIEW",attention.get(0).get("entityType").asString());assertEquals(1,attention.get(0).get("pendingCount").asInt());
 }
 @Test void receiptOnlySubmissionSurvivesRevocationAndReusesObject()throws Exception{
  User owner=login("0500000001"),driver=login("0500000007");String eq=equipment(owner,"شاحنة");String w="/workspaces/"+owner.workspace;accept(driver,invite(owner,"0500000007","DRIVER",null,null));ok("POST",w+"/drivers/assignments",Map.of("driverUserId",driver.id,"equipmentId",eq),owner.token,null);
  ByteArrayOutputStream image=new ByteArrayOutputStream();assertTrue(ImageIO.write(new BufferedImage(12,12,BufferedImage.TYPE_INT_RGB),"png",image));
  String submission=ok("POST",w+"/financial-submissions",Map.of("receipt",Map.of("filename","receipt.png","mediaType","image/png","base64",Base64.getEncoder().encodeToString(image.toByteArray()))),driver.token,null).json.get("id").asString();
  String objectKey=db.queryForObject("select object_key from attachment where submission_id=?",String.class,UUID.fromString(submission));assertNotNull(objectKey);
  ok("DELETE",w+"/team/members/"+driver.id,null,owner.token,null);
  assertEquals(404,call("GET",w+"/financial-submissions/mine",null,driver.token,null).status);
  JsonNode approved=ok("POST",w+"/financial-submissions/"+submission+"/approve",Map.of("equipmentId",eq,"amount","75.00","category","FUEL","operationDate","2026-09-25","paidOn","2026-09-25"),owner.token,null).json;
  UUID entry=UUID.fromString(approved.get("approvedFinancialEntryId").asString());
  assertEquals(1,db.queryForObject("select count(*) from attachment where submission_id=? and entry_id=? and object_key=?",Integer.class,UUID.fromString(submission),entry,objectKey));
  assertEquals("75.00",ok("GET",w+"/entries/totals",null,owner.token,null).json.get("expenseTotal").asString());
 }
 @Test void concurrentDoubleApprovalCreatesOneEntry()throws Exception{
  User owner=login("0500000001"),driver=login("0500000008");String eq=equipment(owner,"شاحنة"),w="/workspaces/"+owner.workspace;accept(driver,invite(owner,"0500000008","DRIVER",null,null));ok("POST",w+"/drivers/assignments",Map.of("driverUserId",driver.id,"equipmentId",eq),owner.token,null);
  String submission=ok("POST",w+"/financial-submissions",Map.of("amount","25.00"),driver.token,null).json.get("id").asString();
  Map<String,Object> body=Map.of("equipmentId",eq,"amount","25.00","category","FUEL","operationDate","2026-09-25","paidOn","2026-09-25");
  try(var pool=Executors.newVirtualThreadPerTaskExecutor()){
   var a=pool.submit(()->call("POST",w+"/financial-submissions/"+submission+"/approve",body,owner.token,null));
   var b=pool.submit(()->call("POST",w+"/financial-submissions/"+submission+"/approve",body,owner.token,null));
   Set<Integer> statuses=Set.of(a.get().status,b.get().status);assertEquals(Set.of(200,409),statuses);
  }
  assertEquals(1,db.queryForObject("select count(*) from financial_entry where submission_id=?",Integer.class,UUID.fromString(submission)));
 }
 @Test void driverDirectModeIsExpenseOnlyAndPermissionChangesApplyImmediately()throws Exception{
  User owner=login("0500000001"),driver=login("0500000009");String eq=equipment(owner,"شاحنة"),w="/workspaces/"+owner.workspace;accept(driver,invite(owner,"0500000009","DRIVER",null,null));ok("POST",w+"/drivers/assignments",Map.of("driverUserId",driver.id,"equipmentId",eq),owner.token,null);
  ok("PUT",w+"/team/members/"+driver.id,Map.of("financialMode","DIRECT"),owner.token,null);
  assertEquals(200,call("POST",w+"/entries",Map.of("equipmentId",eq,"amount","20.00","category","FUEL","operationDate","2026-09-25","paidOn","2026-09-25"),driver.token,UUID.randomUUID().toString()).status);
  assertEquals(404,call("POST",w+"/entries",Map.of("equipmentId",eq,"amount","20.00","entryType","INCOME","operationDate","2026-09-25","paidOn","2026-09-25"),driver.token,UUID.randomUUID().toString()).status);
  assertEquals(404,call("POST",w+"/entries",Map.of("expenseScope","GENERAL","amount","20.00","category","OTHER","operationDate","2026-09-25","paidOn","2026-09-25"),driver.token,UUID.randomUUID().toString()).status);
  ok("PUT",w+"/team/members/"+driver.id,Map.of("capabilities",List.of("EQUIPMENT_VIEW")),owner.token,null);
  assertEquals(404,call("POST",w+"/entries",Map.of("equipmentId",eq,"amount","20.00","category","FUEL","operationDate","2026-09-25","paidOn","2026-09-25"),driver.token,UUID.randomUUID().toString()).status);
 }
 @Test void expiredInvitationWrongPhoneAndResend()throws Exception{
  User owner=login("0500000001"),target=login("0500000010"),wrong=login("0500000011");String id=invite(owner,"0500000010","MANAGER",null,null);
  assertEquals(404,call("POST","/account/invitations/"+id+"/accept",null,wrong.token,null).status);
  db.update("update workspace_invitation set expires_at=now()-interval '1 day' where id=?",UUID.fromString(id));
  assertEquals(409,call("POST","/account/invitations/"+id+"/accept",null,target.token,null).status);
  ok("POST",path(owner,"/team/invitations/"+id+"/resend"),null,owner.token,null);
  accept(target,id);assertEquals(0,ok("GET","/account/invitations",null,target.token,null).json.size());
 }
 @Test void reassignmentPreservesOwnSubmissionButEndsEquipmentAccess()throws Exception{
  User owner=login("0500000001"),driver=login("0500000012");String first=equipment(owner,"شاحنة ١"),second=equipment(owner,"شاحنة ٢"),w="/workspaces/"+owner.workspace;accept(driver,invite(owner,"0500000012","DRIVER",null,null));
  ok("POST",w+"/drivers/assignments",Map.of("driverUserId",driver.id,"equipmentId",first),owner.token,null);
  String submission=ok("POST",w+"/financial-submissions",Map.of("note","من الشاحنة الأولى"),driver.token,null).json.get("id").asString();
  ok("POST",w+"/drivers/assignments",Map.of("driverUserId",driver.id,"equipmentId",second),owner.token,null);
  assertEquals(404,call("GET",w+"/equipment/"+first,null,driver.token,null).status);
  assertEquals(200,call("GET",w+"/equipment/"+second,null,driver.token,null).status);
  assertEquals(submission,ok("GET",w+"/financial-submissions/mine",null,driver.token,null).json.get("items").get(0).get("id").asString());
  JsonNode history=ok("GET",w+"/drivers/"+driver.id+"/assignments",null,owner.token,null).json;assertEquals(2,history.size());assertNotNull(history.get(1).get("endedAt"));
  ok("PUT",w+"/team/members/"+driver.id,Map.of("role","ACCOUNTANT"),owner.token,null);
  assertEquals(0,db.queryForObject("select count(*) from driver_assignment where workspace_id=? and driver_user_id=? and ended_at is null",Integer.class,UUID.fromString(owner.workspace),UUID.fromString(driver.id)));
 }
 @Test void roleChangeResetsCapabilitiesButKeepsSelectedEquipment()throws Exception{
  User owner=login("0500000001"),member=login("0500000013");String inside=equipment(owner,"داخل"),outside=equipment(owner,"خارج"),w="/workspaces/"+owner.workspace;accept(member,invite(owner,"0500000013","ACCOUNTANT","SELECTED_EQUIPMENT",List.of(inside)));
  ok("PUT",w+"/team/members/"+member.id,Map.of("capabilities",List.of("EQUIPMENT_VIEW")),owner.token,null);
  assertEquals(404,call("GET",w+"/entries",null,member.token,null).status);
  JsonNode changed=ok("PUT",w+"/team/members/"+member.id,Map.of("role","MANAGER"),owner.token,null).json;
  assertEquals("SELECTED_EQUIPMENT",changed.get("scope").asString());
  assertTrue(changed.get("capabilities").toString().contains("FINANCE_VIEW"));
  assertEquals(200,call("GET",w+"/entries",null,member.token,null).status);
  assertEquals(404,call("GET",w+"/equipment/"+outside,null,member.token,null).status);
 }
 @Test void concurrentInvitationAcceptanceCreatesOneMembership()throws Exception{
  User owner=login("0500000001"),member=login("0500000014");String id=invite(owner,"0500000014","ACCOUNTANT",null,null);
  try(var pool=Executors.newVirtualThreadPerTaskExecutor()){
   var a=pool.submit(()->call("POST","/account/invitations/"+id+"/accept",null,member.token,null));
   var b=pool.submit(()->call("POST","/account/invitations/"+id+"/accept",null,member.token,null));
   assertEquals(Set.of(200,409),Set.of(a.get().status,b.get().status));
  }
  assertEquals(1,db.queryForObject("select count(*) from membership where workspace_id=? and user_id=? and active",Integer.class,UUID.fromString(owner.workspace),UUID.fromString(member.id)));
 }
 @Test void concurrentDriverMovesLeaveOneActiveAssignment()throws Exception{
  User owner=login("0500000001"),driver=login("0500000015");String one=equipment(owner,"شاحنة ١"),two=equipment(owner,"شاحنة ٢"),w="/workspaces/"+owner.workspace;accept(driver,invite(owner,"0500000015","DRIVER",null,null));
  try(var pool=Executors.newVirtualThreadPerTaskExecutor()){
   var a=pool.submit(()->call("POST",w+"/drivers/assignments",Map.of("driverUserId",driver.id,"equipmentId",one),owner.token,null));
   var b=pool.submit(()->call("POST",w+"/drivers/assignments",Map.of("driverUserId",driver.id,"equipmentId",two),owner.token,null));
   assertEquals(200,a.get().status);assertEquals(200,b.get().status);
  }
  assertEquals(1,db.queryForObject("select count(*) from driver_assignment where workspace_id=? and driver_user_id=? and ended_at is null",Integer.class,UUID.fromString(owner.workspace),UUID.fromString(driver.id)));
 }
 @Test void rejectionRequiresReasonAndDoesNotPostExpense()throws Exception{
  User owner=login("0500000001"),driver=login("0500000016");String eq=equipment(owner,"شاحنة"),w="/workspaces/"+owner.workspace;accept(driver,invite(owner,"0500000016","DRIVER",null,null));ok("POST",w+"/drivers/assignments",Map.of("driverUserId",driver.id,"equipmentId",eq),owner.token,null);
  String id=ok("POST",w+"/financial-submissions",Map.of("note","صورة غير واضحة"),driver.token,null).json.get("id").asString();
  assertEquals(400,call("POST",w+"/financial-submissions/"+id+"/reject",Map.of(),owner.token,null).status);
  ok("POST",w+"/financial-submissions/"+id+"/reject",Map.of("reason","الصورة غير واضحة"),owner.token,null);
  JsonNode own=ok("GET",w+"/financial-submissions/"+id,null,driver.token,null).json;assertEquals("REJECTED",own.get("status").asString());assertEquals("الصورة غير واضحة",own.get("rejectionReason").asString());
  assertEquals(0,db.queryForObject("select count(*) from financial_entry where submission_id=?",Integer.class,UUID.fromString(id)));
 }
}
