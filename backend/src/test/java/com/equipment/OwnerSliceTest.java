package com.equipment;

import com.equipment.common.DevelopmentBoundary;
import com.equipment.attachments.ContentValidator;
import com.equipment.attachments.AttachmentCleanupService;
import com.equipment.attachments.DevelopmentFileStorage;
import java.awt.image.BufferedImage;
import java.io.*;
import java.net.*;
import java.net.http.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.nio.file.attribute.FileTime;
import java.time.Duration;
import java.time.Instant;
import java.util.*;
import java.util.concurrent.*;
import org.flywaydb.core.Flyway;
import org.flywaydb.core.api.MigrationVersion;
import javax.imageio.ImageIO;
import org.apache.pdfbox.pdmodel.*;
import org.apache.pdfbox.pdmodel.interactive.annotation.PDAnnotationLink;
import org.apache.pdfbox.cos.*;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.io.TempDir;
import static org.junit.jupiter.api.Assertions.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.mock.env.MockEnvironment;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.transaction.support.TransactionTemplate;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

@SpringBootTest(webEnvironment=SpringBootTest.WebEnvironment.RANDOM_PORT, properties={
 "spring.datasource.url=jdbc:postgresql://127.0.0.1:55433/equipment_test",
 "spring.datasource.username=equipment_test","spring.datasource.password=isolated-test-only"})
@ActiveProfiles({"dev","test"})
class OwnerSliceTest {
 @org.springframework.boot.test.context.TestConfiguration static class FixedDocumentClock {
  @org.springframework.context.annotation.Bean @org.springframework.context.annotation.Primary java.time.Clock fixedDocumentClock() {return java.time.Clock.fixed(java.time.Instant.parse("2026-09-24T21:00:00Z"),java.time.ZoneId.of("Asia/Riyadh"));}
 }
 @LocalServerPort int port; @Autowired JdbcTemplate db; @Autowired com.equipment.notifications.NotificationService notifications; @Autowired ContentValidator validator; @Autowired TransactionTemplate transactions;
 static final JsonMapper JSON=JsonMapper.builder().build();
 final HttpClient client=HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build();
 @DynamicPropertySource static void properties(DynamicPropertyRegistry registry) {registry.add("app.storage-root",()->"../.local/test-objects/"+UUID.randomUUID());}
 @BeforeEach void emptyIsolatedTestDatabase() throws Exception {
  try(var connection=Objects.requireNonNull(db.getDataSource()).getConnection()) {assertTrue(connection.getMetaData().getURL().equals("jdbc:postgresql://127.0.0.1:55433/equipment_test"),"Never reset a non-test database");}
  db.execute("truncate audit_event,idempotency_record,attachment,settlement,financial_entry,equipment,app_session,otp_challenge,membership,workspace,app_user restart identity cascade");
 }
 record Reply(int status,JsonNode json,HttpResponse<byte[]> raw) {}
 record User(String token,String workspace,String user) {}
 Reply request(String method,String path,Object body,String token,String key) throws Exception {return raw(method,path,body==null?null:JSON.writeValueAsBytes(body),"application/json",token,key,Map.of());}
 Reply raw(String method,String path,byte[] bytes,String type,String token,String key,Map<String,String> extra) throws Exception {
  var req=HttpRequest.newBuilder(URI.create("http://127.0.0.1:"+port+"/api/v1"+path)).timeout(Duration.ofSeconds(20)).header("Content-Type",type);
  if(token!=null)req.header("Authorization","Bearer "+token);if(key!=null)req.header("Idempotency-Key",key);extra.forEach(req::header);
  req.method(method,bytes==null?HttpRequest.BodyPublishers.noBody():HttpRequest.BodyPublishers.ofByteArray(bytes));
  var response=client.send(req.build(),HttpResponse.BodyHandlers.ofByteArray());JsonNode json=null;
  if(response.headers().firstValue("Content-Type").orElse("").contains("json"))json=JSON.readTree(response.body());
  return new Reply(response.statusCode(),json,response);
 }
 String challenge(String phone)throws Exception{var r=request("POST","/auth/challenges",Map.of("phone",phone),null,null);assertEquals(200,r.status);return r.json.get("challengeId").asString();}
 User login(String phone)throws Exception{
  var verify=request("POST","/auth/verify",Map.of("challengeId",challenge(phone),"code","123456","name","مالك تجريبي","client","NATIVE"),null,null);assertEquals(200,verify.status);
  String token=verify.json.get("accessToken").asString();var me=request("GET","/auth/me",null,token,null);assertEquals(200,me.status);
  return new User(token,me.json.get("workspaces").get(0).get("id").asString(),me.json.get("userId").asString());
 }
 String path(User user,String suffix){return "/workspaces/"+user.workspace+suffix;}
 String key(){return UUID.randomUUID().toString();}
 String equipment(User user)throws Exception{var r=request("POST",path(user,"/equipment"),Map.of("name","قلاب ١","model","FH16 / 2021"),user.token,key());assertEquals(200,r.status);return r.json.get("id").asString();}
 Map<String,Object> expense(String eq){return Map.of("equipmentId",eq,"amount","350.00","category","FUEL","operationDate","2026-09-01","paidOn","2026-09-20","note","تجربة فقط");}
 String entry(User user,String eq)throws Exception{var r=request("POST",path(user,"/entries"),expense(eq),user.token,key());assertEquals(200,r.status);return r.json.get("id").asString();}
 byte[] image(String type)throws Exception{var output=new ByteArrayOutputStream();var image=new BufferedImage(12,12,BufferedImage.TYPE_INT_RGB);assertTrue(ImageIO.write(image,type,output));return output.toByteArray();}
 String initiate(User user,String entry,byte[] bytes,String type)throws Exception{var r=request("POST",path(user,"/entries/"+entry+"/attachments"),Map.of("filename","synthetic-receipt."+(type.equals("application/pdf")?"pdf":"png"),"mediaType",type,"size",bytes.length),user.token,key());assertEquals(200,r.status);return r.json.get("id").asString();}

 @Test void issueLifecycleAttentionHistoryAndArchive()throws Exception{
  User owner=login("0500000001"),other=login("0500000002");String eq=equipment(owner);Map<String,Object> input=Map.of("description","حرارة المكينة مرتفعة","equipmentStopped",true);
  var created=request("POST",path(owner,"/equipment/"+eq+"/issues"),input,owner.token,key());assertEquals(200,created.status);String id=created.json.get("id").asString();assertTrue(created.json.get("reference").asString().startsWith("IS-"));assertEquals("OPEN",created.json.get("status").asString());
  assertEquals(404,request("GET",path(other,"/issues/"+id),null,other.token,null).status);assertEquals("ISSUE",request("GET",path(owner,"/attention"),null,owner.token,null).json.get(0).get("entityType").asString());
  assertEquals(400,request("POST",path(owner,"/issues/"+id+"/close"),Map.of(),owner.token,null).status);assertEquals(200,request("POST",path(owner,"/issues/"+id+"/start"),null,owner.token,null).status);assertEquals(0,request("GET",path(owner,"/attention"),null,owner.token,null).json.size());
  assertEquals(200,request("POST",path(owner,"/issues/"+id+"/close"),Map.of("resolution","تم تغيير الرديتر"),owner.token,null).status);assertEquals(409,request("PUT",path(owner,"/issues/"+id),input,owner.token,null).status);
  var reopened=request("POST",path(owner,"/issues/"+id+"/reopen"),null,owner.token,null);assertEquals(200,reopened.status);assertEquals(1,reopened.json.get("closures").size());assertEquals("تم تغيير الرديتر",reopened.json.get("closures").get(0).get("resolution").asString());
  assertEquals(200,request("POST",path(owner,"/equipment/"+eq+"/archive"),null,owner.token,null).status);assertEquals(0,request("GET",path(owner,"/attention"),null,owner.token,null).json.size());assertEquals(409,request("POST",path(owner,"/equipment/"+eq+"/issues"),input,owner.token,key()).status);
  assertEquals(200,request("POST",path(owner,"/equipment/"+eq+"/restore"),null,owner.token,null).status);assertEquals(1,request("GET",path(owner,"/attention"),null,owner.token,null).json.size());
 }
 @Test void maintenanceExpenseLinkUsesM2TotalsAndCancellationPreservesExpense()throws Exception{
  User owner=login("0500000001"),other=login("0500000002");String eq=equipment(owner),otherEq=equipment(owner);
  var issue=request("POST",path(owner,"/equipment/"+eq+"/issues"),Map.of("description","تهريب زيت"),owner.token,key());String issueId=issue.json.get("id").asString();assertFalse(issue.json.get("equipmentStopped").asBoolean());
  var invalid=request("POST",path(owner,"/equipment/"+otherEq+"/maintenance"),Map.of("description","تصليح","maintenanceDate","2026-09-25","issueId",issueId),owner.token,key());assertEquals(400,invalid.status);
  var record=request("POST",path(owner,"/equipment/"+eq+"/maintenance"),Map.of("description","تغيير الرديتر","maintenanceDate","2026-09-25","issueId",issueId),owner.token,key());assertEquals(200,record.status);String id=record.json.get("id").asString();
  assertEquals("2026-09-25",request("GET",path(owner,"/issues/"+issueId),null,owner.token,null).json.get("maintenance").get(0).get("maintenanceDate").asString());
  assertEquals(404,request("GET",path(other,"/maintenance/"+id),null,other.token,null).status);
  String entry=entry(owner,eq),wrong=entry(owner,otherEq);assertEquals(400,request("POST",path(owner,"/maintenance/"+id+"/expenses/"+wrong),null,owner.token,null).status);
  var linked=request("POST",path(owner,"/maintenance/"+id+"/expenses/"+entry),null,owner.token,null);assertEquals(200,linked.status);assertEquals("350.00",linked.json.get("financialSummary").get("totalActiveExpenseAmount").asString());
  var second=request("POST",path(owner,"/equipment/"+eq+"/maintenance"),Map.of("description","فحص","maintenanceDate","2026-09-25"),owner.token,key());String secondId=second.json.get("id").asString();assertEquals(409,request("POST",path(owner,"/maintenance/"+secondId+"/expenses/"+entry),null,owner.token,null).status);
  assertEquals(400,request("POST",path(owner,"/maintenance/"+id+"/cancellation"),Map.of(),owner.token,null).status);assertEquals(200,request("POST",path(owner,"/maintenance/"+id+"/cancellation"),Map.of("reason","مكرر"),owner.token,null).status);assertEquals("POSTED",request("GET",path(owner,"/entries/"+entry),null,owner.token,null).json.get("lifecycle").asString());
  assertEquals(0,request("GET",path(owner,"/maintenance?equipmentId="+eq),null,owner.token,null).json.get("items").size()-1);assertEquals(1,request("GET",path(owner,"/maintenance?cancelled=true"),null,owner.token,null).json.get("items").size());
 }
 @Test void maintenanceSummaryReflectsRefundAndNewExpenseIsAtomic()throws Exception{
  User owner=login("0500000001");String eq=equipment(owner);
  String id=request("POST",path(owner,"/equipment/"+eq+"/maintenance"),Map.of("description","صيانة مباشرة","maintenanceDate","2026-09-25"),owner.token,key()).json.get("id").asString();
  var created=request("POST",path(owner,"/maintenance/"+id+"/expenses"),expense(eq),owner.token,key());assertEquals(200,created.status);assertEquals("350.00",created.json.get("financialSummary").get("netPaid").asString());String entry=created.json.get("expenses").get(0).get("id").asString();
  assertEquals(200,request("POST",path(owner,"/entries/"+entry+"/refunds"),Map.of("amount","50.00","refundedOn","2026-10-02","reason","مرتجع","partyName","مورد"),owner.token,key()).status);
  var refreshed=request("GET",path(owner,"/maintenance/"+id),null,owner.token,null).json.get("financialSummary");assertEquals("300.00",refreshed.get("netPaid").asString());assertEquals("50.00",refreshed.get("remaining").asString());
  assertEquals(200,request("DELETE",path(owner,"/maintenance/"+id+"/expenses/"+entry),null,owner.token,null).status);assertEquals("POSTED",request("GET",path(owner,"/entries/"+entry),null,owner.token,null).json.get("lifecycle").asString());
 }
 @Test void issueAndMaintenanceAttachmentsTypesIsolationAndSearch()throws Exception{
  User owner=login("0500000001"),other=login("0500000002");String eq=equipment(owner);
  String issue=request("POST",path(owner,"/equipment/"+eq+"/issues"),Map.of("description","تهريب زيت","type","MECHANICAL"),owner.token,key()).json.get("id").asString();
  String maintenance=request("POST",path(owner,"/equipment/"+eq+"/maintenance"),Map.of("description","تغيير خرطوم","maintenanceDate","2026-09-25","workshop","ورشة النور"),owner.token,key()).json.get("id").asString();
  assertEquals(1,request("GET",path(owner,"/issues?search=تهريب&status=OPEN&equipmentId="+eq),null,owner.token,null).json.get("total").asInt());assertEquals(1,request("GET",path(owner,"/maintenance?search=النور"),null,owner.token,null).json.get("total").asInt());
  byte[] png=image("png");var init=request("POST",path(owner,"/issues/"+issue+"/attachments"),Map.of("filename","evidence.png","mediaType","image/png","size",png.length),owner.token,key());assertEquals(200,init.status);String attachment=init.json.get("id").asString();
  assertEquals(400,request("POST",path(owner,"/issues/"+issue+"/attachments"),Map.of("filename","report.pdf","mediaType","application/pdf","size",png.length),owner.token,key()).status);
  assertEquals(404,request("GET",path(other,"/attachments/"+attachment+"/content"),null,other.token,null).status);
  assertEquals(200,raw("PUT",path(owner,"/attachments/"+attachment+"/content"),png,"image/png",owner.token,null,Map.of()).status);
  assertEquals(200,request("GET",path(owner,"/attachments/"+attachment+"/content"),null,owner.token,null).status);
  assertEquals(200,request("DELETE",path(owner,"/issues/"+issue+"/attachments/"+attachment),null,owner.token,null).status);
  assertEquals(0,request("GET",path(owner,"/issues/"+issue+"/attachments"),null,owner.token,null).json.size());
  assertEquals(404,request("GET",path(other,"/maintenance/"+maintenance+"/attachments"),null,other.token,null).status);
 }

 @Test void authExpiredWrongReusedOtpThrottlingAndSingleOwner()throws Exception{
  String c=challenge("0500000001");assertEquals(429,request("POST","/auth/challenges",Map.of("phone","0500000001"),null,null).status);
  for(int i=0;i<5;i++)assertEquals(401,request("POST","/auth/verify",Map.of("challengeId",c,"code","000000","client","NATIVE"),null,null).status);
  assertEquals(5,db.queryForObject("select attempts from otp_challenge where id=?",Integer.class,UUID.fromString(c)));
  assertEquals(401,request("POST","/auth/verify",Map.of("challengeId",c,"code","123456","client","NATIVE"),null,null).status);
  db.update("update otp_challenge set created_at=now()-interval '31 seconds' where id=?",UUID.fromString(c));
  String resend=challenge("0500000001");assertTrue(db.queryForObject("select consumed from otp_challenge where id=?",Boolean.class,UUID.fromString(c)));
  var payload=Map.of("challengeId",resend,"code","123456","name","مالك","client","NATIVE");
  try(var pool=Executors.newVirtualThreadPerTaskExecutor()) {var futures=List.of(pool.submit(()->request("POST","/auth/verify",payload,null,null)),pool.submit(()->request("POST","/auth/verify",payload,null,null)));var statuses=new ArrayList<Integer>();for(var future:futures)statuses.add(future.get().status);Collections.sort(statuses);assertEquals(List.of(200,401),statuses);}
  assertEquals(1,db.queryForObject("select count(*) from workspace",Integer.class));assertEquals(1,db.queryForObject("select count(*) from app_session",Integer.class));
  String expired=challenge("0500000002");db.update("update otp_challenge set expires_at=now()-interval '1 second' where id=?",UUID.fromString(expired));assertEquals(401,request("POST","/auth/verify",Map.of("challengeId",expired,"code","123456","client","NATIVE"),null,null).status);
 }
 @Test void onboardingAsksForNameOnlyWhenNewAndDoesNotConsumeValidChallenge()throws Exception{
  String c=challenge("0500000001");var response=request("POST","/auth/verify",Map.of("challengeId",c,"code","123456","client","NATIVE"),null,null);assertTrue(response.json.get("requiresName").asBoolean());assertEquals(0,db.queryForObject("select count(*) from workspace",Integer.class));
  assertEquals(200,request("POST","/auth/verify",Map.of("challengeId",c,"code","123456","name","مالك","client","NATIVE"),null,null).status);assertEquals(1,db.queryForObject("select count(*) from workspace",Integer.class));
 }
 @Test void preferredLocaleBelongsToAuthenticatedUserAndSurvivesNewSession()throws Exception{
  User owner=login("0500000001"),other=login("0500000002");
  assertTrue(request("GET","/auth/me",null,owner.token,null).json.get("preferredLocale").isNull());
  assertEquals(400,request("PUT","/auth/me/locale",Map.of("preferredLocale","fr"),owner.token,null).status);
  assertEquals(200,request("PUT","/auth/me/locale",Map.of("preferredLocale","ur"),owner.token,null).status);
  assertEquals("ur",request("GET","/auth/me",null,owner.token,null).json.get("preferredLocale").asString());
  assertTrue(request("GET","/auth/me",null,other.token,null).json.get("preferredLocale").isNull());
  assertEquals(200,request("PUT","/auth/me/locale",Map.of("preferredLocale","en"),other.token,null).status);
  assertEquals("ur",request("GET","/auth/me",null,owner.token,null).json.get("preferredLocale").asString());
  db.update("update otp_challenge set created_at=now()-interval '31 seconds' where phone='+966500000001'");
  User again=login("0500000001");
  assertEquals("ur",request("GET","/auth/me",null,again.token,null).json.get("preferredLocale").asString());
 }
 @Test void legacyNotificationRemainsReadableAcrossLocaleChange()throws Exception{
  User owner=login("0500000001"),other=login("0500000002");UUID id=UUID.randomUUID();
  db.update("insert into notification(id,workspace_id,recipient_user_id,type,entity_type,title,body,dedupe_key) values(?,?,?,'DOCUMENT_EXPIRED_WEEKLY','DOCUMENT_SUMMARY',?,?,?)",id,UUID.fromString(owner.workspace),UUID.fromString(owner.user),"مستندات منتهية","سجل تطويري سابق","LEGACY:"+id);
  assertEquals(200,request("PUT","/auth/me/locale",Map.of("preferredLocale","en"),owner.token,null).status);
  var first=request("GET",path(owner,"/notifications"),null,owner.token,null).json.get("items").get(0);
  assertTrue(first.get("templateKey").isNull());assertTrue(first.get("params").isNull());
  assertEquals("سجل تطويري سابق",first.get("body").asString());
  assertEquals(404,request("POST",path(other,"/notifications/"+id+"/read"),null,other.token,null).status);
  assertEquals(200,request("POST",path(owner,"/notifications/"+id+"/read"),null,owner.token,null).status);
  assertEquals(0,request("GET",path(owner,"/notifications/unread-count"),null,owner.token,null).json.get("unreadCount").asInt());
 }
 @Test void fullyPaidExpenseIsAtomicExactAndConcurrentReplayDoesNotDuplicate()throws Exception{
  User user=login("0500000001");String eq=equipment(user),key=key();var body=expense(eq);var results=new ArrayList<Reply>();
  try(var pool=Executors.newVirtualThreadPerTaskExecutor()){var futures=new ArrayList<Future<Reply>>();for(int i=0;i<6;i++)futures.add(pool.submit(()->request("POST",path(user,"/entries"),body,user.token,key)));for(var future:futures)results.add(future.get());}
  for(var r:results){assertEquals(200,r.status);assertEquals(results.getFirst().json.get("id"),r.json.get("id"));assertEquals("350.00",r.json.get("paid").asString());assertEquals("0.00",r.json.get("remaining").asString());assertEquals("2026-09-01",r.json.get("operationDate").asString());assertEquals("2026-09-20",r.json.get("settlements").get(0).get("paidOn").asString());}
  assertEquals(1,db.queryForObject("select count(*) from financial_entry",Integer.class));assertEquals(1,db.queryForObject("select count(*) from settlement",Integer.class));
  var changed=new HashMap<>(body);changed.put("amount","351.00");assertEquals(409,request("POST",path(user,"/entries"),changed,user.token,key).status);
  assertEquals(1,request("GET",path(user,"/entries?equipmentId="+eq),null,user.token,null).json.get("total").asInt());
 }
 @Test void partialAndUnpaidExpensesKeepOneOriginalAndDatedSettlements()throws Exception{
  User user=login("0500000001");String eq=equipment(user);
  var partial=new HashMap<>(expense(eq));partial.put("paymentStatus","PARTIAL");partial.put("initialPaid","100.00");partial.put("partyName","ورشة المعدات");partial.put("dueDate","2026-10-15");
  var created=request("POST",path(user,"/entries"),partial,user.token,key());assertEquals(200,created.status);
  String id=created.json.get("id").asString();assertEquals("PARTIAL",created.json.get("settlementStatus").asString());assertEquals("250.00",created.json.get("remaining").asString());assertEquals("ورشة المعدات",created.json.get("partyName").asString());
  String url=path(user,"/entries/"+id+"/settlements");String settlementKey=key();var payment=Map.of("amount","150.00","paidOn","2026-10-02");
  assertEquals(200,request("POST",url,payment,user.token,settlementKey).status);
  var replay=request("POST",url,payment,user.token,settlementKey);assertEquals("250.00",replay.json.get("paid").asString());assertEquals("100.00",replay.json.get("remaining").asString());assertEquals(2,replay.json.get("settlements").size());
  assertEquals(409,request("POST",url,Map.of("amount","151.00","paidOn","2026-10-02"),user.token,settlementKey).status);
  assertEquals(400,request("POST",url,Map.of("amount","100.01","paidOn","2026-10-03"),user.token,key()).status);
  assertEquals(200,request("POST",url,Map.of("amount","100.00","paidOn","2026-10-03"),user.token,key()).status);
  var finalEntry=request("GET",path(user,"/entries/"+id),null,user.token,null);assertEquals("PAID",finalEntry.json.get("settlementStatus").asString());assertEquals("0.00",finalEntry.json.get("remaining").asString());
  var unpaid=new HashMap<>(expense(eq));unpaid.remove("paidOn");unpaid.put("paymentStatus","UNPAID");unpaid.put("partyName","مورد");
  var open=request("POST",path(user,"/entries"),unpaid,user.token,key());assertEquals(200,open.status);assertEquals("UNPAID",open.json.get("settlementStatus").asString());assertEquals(0,open.json.get("settlements").size());assertTrue(open.json.get("dueDate").isNull());
  assertEquals(2,db.queryForObject("select count(*) from financial_entry",Integer.class));assertEquals(3,db.queryForObject("select count(*) from settlement",Integer.class));
 }
 @Test void invalidOutstandingAndConcurrentFinalPaymentsAreRejected()throws Exception{
  User user=login("0500000001");String eq=equipment(user);var unpaid=new HashMap<>(expense(eq));unpaid.remove("paidOn");unpaid.put("paymentStatus","UNPAID");unpaid.put("partyName","مورد");
  var noParty=new HashMap<>(unpaid);noParty.remove("partyName");assertEquals(400,request("POST",path(user,"/entries"),noParty,user.token,key()).status);
  var tooMuch=new HashMap<>(expense(eq));tooMuch.put("paymentStatus","PARTIAL");tooMuch.put("initialPaid","350.00");tooMuch.put("partyName","مورد");assertEquals(400,request("POST",path(user,"/entries"),tooMuch,user.token,key()).status);
  String id=request("POST",path(user,"/entries"),unpaid,user.token,key()).json.get("id").asString();String url=path(user,"/entries/"+id+"/settlements");var body=Map.of("amount","350.00","paidOn","2026-09-22");
  try(var pool=Executors.newVirtualThreadPerTaskExecutor()) {var a=pool.submit(()->request("POST",url,body,user.token,key()));var b=pool.submit(()->request("POST",url,body,user.token,key()));assertEquals(Set.of(200,400),Set.of(a.get().status,b.get().status));}
  assertEquals(1,db.queryForObject("select count(*) from settlement",Integer.class));
  User other=login("0500000002");assertEquals(404,request("POST",path(other,"/entries/"+id+"/settlements"),body,other.token,key()).status);
 }
 @Test void incomePartialAndLaterReceiptRemainOneOriginalAcrossDates()throws Exception{
  User user=login("0500000001");String eq=equipment(user);String createKey=key();
  var income=new HashMap<String,Object>();income.put("equipmentId",eq);income.put("entryType","INCOME");income.put("amount","3000.00");income.put("operationDate","2026-09-01");income.put("paymentStatus","PARTIAL");income.put("initialPaid","1000.00");income.put("paidOn","2026-09-20");income.put("partyName","عميل اختبار");
  var created=request("POST",path(user,"/entries"),income,user.token,createKey);assertEquals(200,created.status);String id=created.json.get("id").asString();
  assertEquals("INCOME",created.json.get("entryType").asString());assertEquals("3000.00",created.json.get("amount").asString());assertEquals("1000.00",created.json.get("paid").asString());assertEquals("2000.00",created.json.get("remaining").asString());
  assertEquals(id,request("POST",path(user,"/entries"),income,user.token,createKey).json.get("id").asString());
  var changed=new HashMap<>(income);changed.put("amount","3001.00");assertEquals(409,request("POST",path(user,"/entries"),changed,user.token,createKey).status);
  String url=path(user,"/entries/"+id+"/settlements");String receiptKey=key();var receipt=Map.of("amount","2000.00","paidOn","2026-10-02");
  var settled=request("POST",url,receipt,user.token,receiptKey);assertEquals(200,settled.status);assertEquals("0.00",settled.json.get("remaining").asString());assertEquals("PAID",settled.json.get("settlementStatus").asString());
  assertEquals(2,request("POST",url,receipt,user.token,receiptKey).json.get("settlements").size());
  assertEquals("2026-09-01",settled.json.get("operationDate").asString());assertEquals("2026-10-02",settled.json.get("settlements").get(1).get("paidOn").asString());
  assertEquals(1,db.queryForObject("select count(*) from financial_entry where entry_type='INCOME'",Integer.class));assertEquals(2,db.queryForObject("select count(*) from settlement",Integer.class));
  assertEquals(0,db.queryForObject("select count(*) from financial_entry where entry_type='EXPENSE'",Integer.class));
 }
 @Test void unpaidIncomeRequiresPartyAndRejectsCrossTenantAndExcessReceipts()throws Exception{
  User owner=login("0500000001");String eq=equipment(owner);var income=new HashMap<String,Object>();income.put("equipmentId",eq);income.put("entryType","INCOME");income.put("amount","200.00");income.put("operationDate","2026-09-01");income.put("paymentStatus","UNPAID");
  assertEquals(400,request("POST",path(owner,"/entries"),income,owner.token,key()).status);
  income.put("partyName","عميل اختبار");var created=request("POST",path(owner,"/entries"),income,owner.token,key());assertEquals(200,created.status);String id=created.json.get("id").asString();assertEquals("UNPAID",created.json.get("settlementStatus").asString());assertEquals(0,created.json.get("settlements").size());
  String url=path(owner,"/entries/"+id+"/settlements");assertEquals(400,request("POST",url,Map.of("amount","200.01","paidOn","2026-09-02"),owner.token,key()).status);
  User other=login("0500000002");assertEquals(404,request("POST",path(other,"/entries/"+id+"/settlements"),Map.of("amount","1.00","paidOn","2026-09-02"),other.token,key()).status);
  assertEquals(0,db.queryForObject("select count(*) from settlement",Integer.class));
 }
 @Test void editExpenseAndIncomeRetainsSettlementsAndAuditsBeforeAfter()throws Exception{
  User user=login("0500000001");String eq=equipment(user);
  for(String type:List.of("EXPENSE","INCOME")) {
   var body=new HashMap<String,Object>();body.put("equipmentId",eq);body.put("entryType",type);body.put("amount","3000.00");body.put("operationDate","2026-09-01");body.put("paymentStatus","PARTIAL");body.put("initialPaid","1000.00");body.put("paidOn","2026-09-20");body.put("partyName","طرف أول");if(type.equals("EXPENSE"))body.put("category","FUEL");
   var created=request("POST",path(user,"/entries"),body,user.token,key());assertEquals(200,created.status);String id=created.json.get("id").asString();String firstSettlement=created.json.get("settlements").get(0).get("id").asString();
   var edit=new HashMap<String,Object>();edit.put("amount","3000.00");edit.put("operationDate","2026-09-05");edit.put("note","تصحيح موثق");edit.put("partyName","طرف ثان");edit.put("dueDate","2026-10-15");if(type.equals("EXPENSE"))edit.put("category","MAINTENANCE");
   var updated=request("PUT",path(user,"/entries/"+id),edit,user.token,null);assertEquals(200,updated.status);assertEquals("2000.00",updated.json.get("remaining").asString());assertEquals("PARTIAL",updated.json.get("settlementStatus").asString());assertEquals("2026-09-05",updated.json.get("operationDate").asString());assertEquals(firstSettlement,updated.json.get("settlements").get(0).get("id").asString());
   assertEquals(400,request("PUT",path(user,"/entries/"+id),Map.of("amount","500.00","operationDate","2026-09-05","partyName","طرف ثان","category",type.equals("EXPENSE")?"MAINTENANCE":"OTHER"),user.token,null).status);
   assertEquals(400,request("PUT",path(user,"/entries/"+id),Map.of("amount","1000.00","operationDate","2026-09-05","dueDate","2026-10-15","category",type.equals("EXPENSE")?"MAINTENANCE":"OTHER"),user.token,null).status);
   assertEquals(1,db.queryForObject("select count(*) from settlement where entry_id=?",Integer.class,UUID.fromString(id)));
   var audit=db.queryForMap("select metadata,actor_id from audit_event where resource_id=? and action=?",UUID.fromString(id),type.equals("INCOME")?"INCOME_EDITED":"EXPENSE_EDITED");assertEquals(UUID.fromString(user.user),audit.get("actor_id"));String metadata=audit.get("metadata").toString();assertTrue(metadata.contains("3000.00"));assertTrue(metadata.contains("طرف أول"));assertTrue(metadata.contains("طرف ثان"));
  }
 }
 @Test void cancellationRetainsHistoryAndFilesButBlocksMutationAndCrossTenantAccess()throws Exception{
  User owner=login("0500000001");String eq=equipment(owner);String id=entry(owner,eq);byte[] png=image("png");String file=initiate(owner,id,png,"image/png");assertEquals(200,raw("PUT",path(owner,"/attachments/"+file+"/content"),png,"image/png",owner.token,null,Map.of()).status);
  String url=path(owner,"/entries/"+id);assertEquals(400,request("POST",url+"/cancellation",Map.of("reason","  "),owner.token,null).status);
  assertEquals("POSTED",request("GET",url,null,owner.token,null).json.get("lifecycle").asString());
  User other=login("0500000002");var edit=Map.of("amount","350.00","category","FUEL","operationDate","2026-09-01");
  assertEquals(404,request("PUT",path(other,"/entries/"+id),edit,other.token,null).status);
  assertEquals(404,request("POST",path(other,"/entries/"+id+"/cancellation"),Map.of("reason","خطأ"),other.token,null).status);
  var cancelled=request("POST",url+"/cancellation",Map.of("reason","قيد مكرر بالخطأ"),owner.token,null);assertEquals(200,cancelled.status);assertEquals("CANCELLED",cancelled.json.get("lifecycle").asString());assertEquals("قيد مكرر بالخطأ",cancelled.json.get("cancellationReason").asString());assertEquals(owner.user,cancelled.json.get("cancelledBy").asString());assertFalse(cancelled.json.get("cancelledAt").isNull());assertEquals(1,cancelled.json.get("settlements").size());assertEquals("350.00",cancelled.json.get("paid").asString());
  assertEquals(400,request("PUT",url,edit,owner.token,null).status);
  assertEquals(400,request("POST",url+"/settlements",Map.of("amount","1.00","paidOn","2026-10-01"),owner.token,key()).status);
  assertEquals(400,request("POST",url+"/cancellation",Map.of("reason","مرة ثانية"),owner.token,null).status);
  assertEquals(1,db.queryForObject("select count(*) from settlement where entry_id=?",Integer.class,UUID.fromString(id)));
  assertEquals(200,request("GET",url,null,owner.token,null).status);assertEquals(200,request("GET",path(owner,"/attachments/"+file+"/content"),null,owner.token,null).status);
  assertEquals(1,request("GET",path(owner,"/entries?equipmentId="+eq),null,owner.token,null).json.get("total").asInt());
  assertEquals(404,request("GET",path(other,"/entries/"+id),null,other.token,null).status);
  assertEquals(404,request("GET",path(other,"/attachments/"+file+"/content"),null,other.token,null).status);
  assertEquals(0,db.queryForObject("select count(*) from financial_entry where workspace_id=? and lifecycle='POSTED'",Integer.class,UUID.fromString(owner.workspace)));
  var audit=db.queryForMap("select metadata,actor_id from audit_event where resource_id=? and action='FINANCIAL_ENTRY_CANCELLED'",UUID.fromString(id));assertEquals(UUID.fromString(owner.user),audit.get("actor_id"));assertTrue(audit.get("metadata").toString().contains("قيد مكرر"));
 }
 @Test void concurrentEditAndReceiptCannotLeaveTotalBelowSettlements()throws Exception{
  User user=login("0500000001");String eq=equipment(user);var body=new HashMap<String,Object>();body.put("equipmentId",eq);body.put("entryType","INCOME");body.put("amount","3000.00");body.put("operationDate","2026-09-01");body.put("paymentStatus","PARTIAL");body.put("initialPaid","1000.00");body.put("paidOn","2026-09-20");body.put("partyName","عميل");
  String id=request("POST",path(user,"/entries"),body,user.token,key()).json.get("id").asString();String url=path(user,"/entries/"+id);
  var edit=Map.of("amount","1000.00","operationDate","2026-09-01","partyName","عميل");var receipt=Map.of("amount","2000.00","paidOn","2026-10-01");
  try(var pool=Executors.newVirtualThreadPerTaskExecutor()) {var a=pool.submit(()->request("PUT",url,edit,user.token,null));var b=pool.submit(()->request("POST",url+"/settlements",receipt,user.token,key()));assertEquals(Set.of(200,400),Set.of(a.get().status,b.get().status));}
  var current=request("GET",url,null,user.token,null).json;assertTrue(new java.math.BigDecimal(current.get("amount").asString()).compareTo(new java.math.BigDecimal(current.get("paid").asString()))>=0);
  assertTrue(current.get("settlements").size()==1 || current.get("settlements").size()==2);
 }
 @Test void concurrentCancellationAndEditLeaveOneCancelledOriginal()throws Exception{
  User owner=login("0500000001");String id=entry(owner,equipment(owner)),url=path(owner,"/entries/"+id);
  var edit=Map.of("amount","350.00","category","FUEL","operationDate","2026-09-01","note","تصحيح متزامن");
  try(var pool=Executors.newVirtualThreadPerTaskExecutor()) {
   var change=pool.submit(()->request("PUT",url,edit,owner.token,null));var cancel=pool.submit(()->request("POST",url+"/cancellation",Map.of("reason","قيد مكرر"),owner.token,null));
   assertTrue(Set.of(200,400).contains(change.get().status));assertEquals(200,cancel.get().status);
  }
  var current=request("GET",url,null,owner.token,null).json;assertEquals("CANCELLED",current.get("lifecycle").asString());assertEquals(1,current.get("settlements").size());assertEquals("0.00",request("GET",path(owner,"/entries/totals"),null,owner.token,null).json.get("expenseTotal").asString());
  assertEquals(400,request("PUT",url,edit,owner.token,null).status);
  assertEquals(1,db.queryForObject("select count(*) from financial_entry where id=?",Integer.class,UUID.fromString(id)));
  assertEquals(1,db.queryForObject("select count(*) from audit_event where action='FINANCIAL_ENTRY_CANCELLED' and resource_id=?",Integer.class,UUID.fromString(id)));
 }
 @Test void cancelledIncomeKeepsCollectionHistoryAndRejectsAnotherCollection()throws Exception{
  User user=login("0500000001");String eq=equipment(user);var body=Map.of("equipmentId",eq,"entryType","INCOME","amount","500.00","operationDate","2026-09-01","paymentStatus","PARTIAL","initialPaid","200.00","paidOn","2026-09-20","partyName","عميل");
  String id=request("POST",path(user,"/entries"),body,user.token,key()).json.get("id").asString();String url=path(user,"/entries/"+id);
  var cancelled=request("POST",url+"/cancellation",Map.of("reason","إيراد مسجل بالخطأ"),user.token,null);assertEquals(200,cancelled.status);assertEquals("INCOME",cancelled.json.get("entryType").asString());assertEquals("CANCELLED",cancelled.json.get("lifecycle").asString());assertEquals("200.00",cancelled.json.get("paid").asString());assertEquals(1,cancelled.json.get("settlements").size());
  assertEquals(400,request("POST",url+"/settlements",Map.of("amount","100.00","paidOn","2026-09-21"),user.token,key()).status);
  assertEquals(1,db.queryForObject("select count(*) from settlement where entry_id=?",Integer.class,UUID.fromString(id)));
 }
 @Test void expenseRefundsPreserveSettlementsReopenOutstandingAndAudit()throws Exception{
  User user=login("0500000001");String eq=equipment(user);var body=new HashMap<>(expense(eq));body.put("amount","1000.00");body.put("initialPaid","600.00");body.put("paymentStatus","PARTIAL");body.put("partyName","مورد");
  var created=request("POST",path(user,"/entries"),body,user.token,key());assertEquals(200,created.status);String id=created.json.get("id").asString(),url=path(user,"/entries/"+id+"/refunds"),originalSettlement=created.json.get("settlements").get(0).get("id").asString();
  var refund=Map.of("amount","200.00","refundedOn","2026-10-02","reason","مرتجع من المورد");String refundKey=key();
  var first=request("POST",url,refund,user.token,refundKey);assertEquals(200,first.status);assertEquals("600.00",first.json.get("paid").asString());assertEquals("200.00",first.json.get("refunded").asString());assertEquals("400.00",first.json.get("netPaid").asString());assertEquals("400.00",first.json.get("refundable").asString());assertEquals("600.00",first.json.get("remaining").asString());assertEquals("PARTIAL",first.json.get("settlementStatus").asString());assertEquals(originalSettlement,first.json.get("settlements").get(0).get("id").asString());assertEquals("2026-09-20",first.json.get("settlements").get(0).get("paidOn").asString());
  assertEquals(1,request("POST",url,refund,user.token,refundKey).json.get("refunds").size());assertEquals(409,request("POST",url,Map.of("amount","201.00","refundedOn","2026-10-02","reason","مرتجع من المورد"),user.token,refundKey).status);
  assertEquals(400,request("POST",url,Map.of("amount","400.01","refundedOn","2026-10-03","reason","زيادة"),user.token,key()).status);
  var second=request("POST",url,Map.of("amount","400.00","refundedOn","2026-10-03","reason","باقي المرتجع"),user.token,key());assertEquals(200,second.status);assertEquals("600.00",second.json.get("refunded").asString());assertEquals("0.00",second.json.get("netPaid").asString());assertEquals("1000.00",second.json.get("remaining").asString());assertEquals("UNPAID",second.json.get("settlementStatus").asString());assertEquals(2,second.json.get("refunds").size());assertEquals(1,second.json.get("settlements").size());
  assertEquals(400,request("POST",url,Map.of("amount","0.00","refundedOn","2026-10-04","reason","صفر"),user.token,key()).status);
  assertEquals(400,request("POST",url,Map.of("amount","1.00","refundedOn","2026-10-04","reason","زيادة"),user.token,key()).status);
  assertEquals(400,request("POST",url,Map.of("amount","1.00","refundedOn","2026-10-04","reason","  "),user.token,key()).status);
  assertEquals(2,db.queryForObject("select count(*) from financial_refund where entry_id=?",Integer.class,UUID.fromString(id)));
  assertEquals(1,db.queryForObject("select count(*) from settlement where entry_id=?",Integer.class,UUID.fromString(id)));
  var audit=db.queryForMap("select actor_id,metadata from audit_event where resource_id=? and action='FINANCIAL_REFUND_CREATED' order by created_at limit 1",UUID.fromString(id));assertEquals(UUID.fromString(user.user),audit.get("actor_id"));assertTrue(audit.get("metadata").toString().contains("200.00"));assertTrue(audit.get("metadata").toString().contains("مرتجع من المورد"));
 }
 @Test void incomeRefundIsLinkedAndCanBeResettledWithoutChangingOriginalReceipt()throws Exception{
  User user=login("0500000001");String eq=equipment(user);var body=Map.of("equipmentId",eq,"entryType","INCOME","amount","3000.00","operationDate","2026-09-01","paidOn","2026-09-20");
  var created=request("POST",path(user,"/entries"),body,user.token,key());assertEquals(200,created.status);String id=created.json.get("id").asString(),url=path(user,"/entries/"+id);
  var refunded=request("POST",url+"/refunds",Map.of("amount","500.00","refundedOn","2026-10-02","reason","إعادة جزء للعميل","partyName","عميل النقل"),user.token,key());assertEquals(200,refunded.status);assertEquals("عميل النقل",refunded.json.get("partyName").asString());assertEquals("3000.00",refunded.json.get("paid").asString());assertEquals("500.00",refunded.json.get("refunded").asString());assertEquals("2500.00",refunded.json.get("netPaid").asString());assertEquals("500.00",refunded.json.get("remaining").asString());assertEquals("PARTIAL",refunded.json.get("settlementStatus").asString());assertEquals(1,refunded.json.get("settlements").size());assertEquals("2026-09-20",refunded.json.get("settlements").get(0).get("paidOn").asString());
  var collected=request("POST",url+"/settlements",Map.of("amount","500.00","paidOn","2026-10-10"),user.token,key());assertEquals(200,collected.status);assertEquals("3000.00",collected.json.get("netPaid").asString());assertEquals("0.00",collected.json.get("remaining").asString());assertEquals("PAID",collected.json.get("settlementStatus").asString());assertEquals(2,collected.json.get("settlements").size());assertEquals(1,collected.json.get("refunds").size());
  assertEquals(400,request("POST",url+"/settlements",Map.of("amount","0.01","paidOn","2026-10-11"),user.token,key()).status);
 }
 @Test void refundRejectsCancellationAndOtherWorkspace()throws Exception{
  User owner=login("0500000001");String id=entry(owner,equipment(owner)),url=path(owner,"/entries/"+id),otherUrl;User other=login("0500000002");otherUrl=path(other,"/entries/"+id);
  var body=Map.of("amount","100.00","refundedOn","2026-10-02","reason","عودة مال");
  assertEquals(404,request("POST",otherUrl+"/refunds",body,other.token,key()).status);assertEquals(404,request("GET",otherUrl,null,other.token,null).status);
  assertEquals(200,request("POST",url+"/cancellation",Map.of("reason","قيد خطأ"),owner.token,null).status);
  assertEquals(400,request("POST",url+"/refunds",body,owner.token,key()).status);
  assertEquals(0,db.queryForObject("select count(*) from financial_refund",Integer.class));
 }
 @Test void concurrentRefundsCannotExceedGrossSettled()throws Exception{
  User owner=login("0500000001");String id=entry(owner,equipment(owner)),url=path(owner,"/entries/"+id+"/refunds");var body=Map.of("amount","300.00","refundedOn","2026-10-02","reason","عودة مال","partyName","مورد");
  try(var pool=Executors.newVirtualThreadPerTaskExecutor()){var a=pool.submit(()->request("POST",url,body,owner.token,key()));var b=pool.submit(()->request("POST",url,body,owner.token,key()));assertEquals(Set.of(200,400),Set.of(a.get().status,b.get().status));}
  assertEquals("300.00",request("GET",path(owner,"/entries/"+id),null,owner.token,null).json.get("refunded").asString());
  assertEquals(1,db.queryForObject("select count(*) from financial_refund",Integer.class));
 }
 @Test void refundDateCannotPrecedeAvailableMoneyEvenWhenFinalTotalAllowsIt()throws Exception{
  User owner=login("0500000001");String eq=equipment(owner);var body=new HashMap<>(expense(eq));body.put("amount","200.00");body.put("initialPaid","100.00");body.put("paymentStatus","PARTIAL");body.put("partyName","مورد");
  String id=request("POST",path(owner,"/entries"),body,owner.token,key()).json.get("id").asString(),url=path(owner,"/entries/"+id);
  assertEquals(400,request("POST",url+"/refunds",Map.of("amount","50.00","refundedOn","2026-09-19","reason","قبل الدفع"),owner.token,key()).status);
  assertEquals(200,request("POST",url+"/settlements",Map.of("amount","100.00","paidOn","2026-10-20"),owner.token,key()).status);
  assertEquals(200,request("POST",url+"/refunds",Map.of("amount","100.00","refundedOn","2026-10-10","reason","مرتجع أول"),owner.token,key()).status);
  // Gross settled is 200 and only 100 is refunded, but at 10 October only 100 had been paid.
  assertEquals(400,request("POST",url+"/refunds",Map.of("amount","100.00","refundedOn","2026-09-25","reason","مرتجع مؤرخ سابقًا"),owner.token,key()).status);
  assertEquals(1,db.queryForObject("select count(*) from financial_refund",Integer.class));
 }
 @Test void oneFullExpenseRefundReopensEntireAmountWithoutCancellingEntry()throws Exception{
  User owner=login("0500000001");String id=entry(owner,equipment(owner)),url=path(owner,"/entries/"+id);
  var result=request("POST",url+"/refunds",Map.of("amount","350.00","refundedOn","2026-09-21","reason","أُعيد كامل المبلغ","partyName","مورد الوقود"),owner.token,key());
  assertEquals(200,result.status);assertEquals("POSTED",result.json.get("lifecycle").asString());assertEquals("350.00",result.json.get("paid").asString());assertEquals("350.00",result.json.get("refunded").asString());assertEquals("0.00",result.json.get("netPaid").asString());assertEquals("350.00",result.json.get("remaining").asString());assertEquals("UNPAID",result.json.get("settlementStatus").asString());assertEquals("0.00",result.json.get("refundable").asString());
  assertEquals(1,result.json.get("settlements").size());assertEquals(1,result.json.get("refunds").size());
 }
 @Test void refundReopeningRequiresPartyAndEditUsesNetSettledForExpenseAndIncome()throws Exception{
  User owner=login("0500000001");String eq=equipment(owner);
  for(String type:List.of("EXPENSE","INCOME")) {
   var body=new HashMap<String,Object>();body.put("equipmentId",eq);body.put("entryType",type);body.put("amount","350.00");body.put("operationDate","2026-09-01");body.put("paidOn","2026-09-20");if(type.equals("EXPENSE"))body.put("category","FUEL");
   String id=request("POST",path(owner,"/entries"),body,owner.token,key()).json.get("id").asString(),url=path(owner,"/entries/"+id);
   var missing=Map.of("amount","100.00","refundedOn","2026-09-21","reason","عودة جزء");var denied=request("POST",url+"/refunds",missing,owner.token,key());assertEquals(400,denied.status);assertTrue(denied.json.toString().contains("اسم الطرف"));
   assertEquals(0,db.queryForObject("select count(*) from financial_refund where entry_id=?",Integer.class,UUID.fromString(id)));
   var complete=new HashMap<String,Object>(missing);complete.put("partyName",type.equals("INCOME")?"عميل النقل":"مورد الوقود");String refundKey=key();
   var refund=request("POST",url+"/refunds",complete,owner.token,refundKey);assertEquals(200,refund.status);assertEquals(complete.get("partyName"),refund.json.get("partyName").asString());assertEquals("100.00",refund.json.get("remaining").asString());
   assertEquals(200,request("POST",url+"/refunds",complete,owner.token,refundKey).status);assertEquals(1,db.queryForObject("select count(*) from financial_refund where entry_id=?",Integer.class,UUID.fromString(id)));
   var edit=new HashMap<String,Object>();edit.put("amount","350.00");edit.put("operationDate","2026-09-01");if(type.equals("EXPENSE"))edit.put("category","FUEL");
   assertEquals(400,request("PUT",url,edit,owner.token,null).status);
   edit.put("partyName",complete.get("partyName"));edit.put("dueDate","2026-10-20");var updated=request("PUT",url,edit,owner.token,null);assertEquals(200,updated.status);assertEquals("100.00",updated.json.get("remaining").asString());assertEquals("2026-10-20",updated.json.get("dueDate").asString());
   var audit=db.queryForMap("select metadata from audit_event where resource_id=? and action=?",UUID.fromString(id),type.equals("INCOME")?"INCOME_EDITED":"EXPENSE_EDITED");assertTrue(audit.get("metadata").toString().contains("100.00"));
  }
 }
 @Test void v9RejectsNullPostedTypeWhileDraftKeepsItNull()throws Exception{
  User owner=login("0500000001");String eq=equipment(owner),posted=entry(owner,eq);
  assertThrows(org.springframework.dao.DataIntegrityViolationException.class,()->db.update("update financial_entry set entry_type=null where id=?",UUID.fromString(posted)));
  String draft=request("POST",path(owner,"/drafts"),Map.of("equipmentId",eq),owner.token,key()).json.get("id").asString();
  assertNull(db.queryForObject("select entry_type from financial_entry where id=?",String.class,UUID.fromString(draft)));
 }
 @Test void equipmentNeedsOnlyNameAndModelAndRejectsSystemFields()throws Exception{
  User user=login("0500000001");String key=key();var body=Map.of("name","قلاب ١","model","FH16");var first=request("POST",path(user,"/equipment"),body,user.token,key);var replay=request("POST",path(user,"/equipment"),body,user.token,key);
  assertEquals(first.json.get("id"),replay.json.get("id"));assertTrue(first.json.get("reference").asString().startsWith("EQ-"));assertEquals("FH16",first.json.get("model").asString());
  assertEquals(400,request("POST",path(user,"/equipment"),Map.of("name","قلاب","model","FH16","role","OWNER"),user.token,key()).status);
  assertEquals(400,request("POST",path(user,"/equipment"),Map.of("name","قلاب"),user.token,key()).status);
 }
 @Test void exactMoneyAndImmutableSystemInputsAreValidated()throws Exception{
  User user=login("0500000001");String eq=equipment(user);
  for(Object amount:List.of("0.00","-1.00","350.001","1000000000.00","3e2",350.0,350.25)){var body=new HashMap<>(expense(eq));body.put("amount",amount);assertEquals(400,request("POST",path(user,"/entries"),body,user.token,key()).status);}
  var body=new HashMap<>(expense(eq));body.put("paid",true);assertEquals(400,request("POST",path(user,"/entries"),body,user.token,key()).status);
  body=new HashMap<>(expense(eq));body.put("operationDate","2026-02-30");assertEquals(400,request("POST",path(user,"/entries"),body,user.token,key()).status);
  assertEquals(0,db.queryForObject("select count(*) from financial_entry",Integer.class));
 }
 @Test void filesRetryWithoutNewMoneyAndFinalizeIsImmutable()throws Exception{
  User user=login("0500000001");String entry=entry(user,equipment(user));byte[] bytes=image("png");String attachment=initiate(user,entry,bytes,"image/png");String content=path(user,"/attachments/"+attachment+"/content");
  assertEquals(409,request("GET",content,null,user.token,null).status);
  assertEquals(400,raw("PUT",content,new byte[bytes.length],"image/png",user.token,null,Map.of()).status);
  assertEquals("FAILED",request("GET",path(user,"/entries/"+entry+"/attachments"),null,user.token,null).json.get(0).get("state").asString());
  var ready=raw("PUT",content,bytes,"image/png",user.token,null,Map.of());assertEquals(200,ready.status);assertEquals("DEV_NOT_SCANNED",ready.json.get("scanStatus").asString());
  assertEquals(200,raw("PUT",content,bytes,"image/png",user.token,null,Map.of()).status);assertEquals(409,raw("PUT",content,new byte[bytes.length],"image/png",user.token,null,Map.of()).status);
  var download=request("GET",content,null,user.token,null);assertArrayEquals(bytes,download.raw.body());assertTrue(download.raw.headers().firstValue("Content-Disposition").orElse("").startsWith("attachment"));
  assertEquals(1,db.queryForObject("select count(*) from financial_entry",Integer.class));assertEquals(1,db.queryForObject("select count(*) from settlement",Integer.class));assertEquals(1,db.queryForObject("select count(*) from audit_event where action='ATTACHMENT_READY'",Integer.class));
 }
 @Test void crossTenantReadsWritesListsFilesAndReplayDenied()throws Exception{
  User a=login("0500000001"),b=login("0500000002");String eq=equipment(a),entry=entry(a,eq);byte[] png=image("png");String file=initiate(a,entry,png,"image/png");raw("PUT",path(a,"/attachments/"+file+"/content"),png,"image/png",a.token,null,Map.of());
  for(String suffix:List.of("/equipment","/equipment/"+eq,"/entries","/entries/"+entry,"/entries/"+entry+"/attachments","/attachments/"+file+"/content"))assertEquals(404,request("GET",path(a,suffix),null,b.token,null).status);
  assertEquals(404,request("GET",path(b,"/equipment/"+eq),null,b.token,null).status);
  assertEquals(404,request("POST",path(b,"/entries"),expense(eq),b.token,key()).status);
  assertEquals(404,request("POST",path(b,"/entries/"+entry+"/attachments"),Map.of("filename","x.png","mediaType","image/png","size",png.length),b.token,key()).status);
  assertEquals(404,raw("PUT",path(b,"/attachments/"+file+"/content"),png,"image/png",b.token,null,Map.of()).status);
  assertEquals(0,request("GET",path(b,"/entries"),null,b.token,null).json.get("total").asInt());
  assertThrows(org.springframework.dao.DataIntegrityViolationException.class,()->db.update("insert into financial_entry(id,workspace_id,equipment_id,amount,currency,category,operation_date,lifecycle,created_by) values(?,?,?,1.00,'SAR','FUEL',current_date,'POSTED',?)",UUID.randomUUID(),UUID.fromString(b.workspace),UUID.fromString(eq),UUID.fromString(b.user)));
 }
 @Test void membershipRevocationPreventsCurrentReadsDownloadsAndIdempotentReplay()throws Exception{
  User owner=login("0500000001"),member=login("0500000003");String eq=equipment(owner),key=key(),workspace="/workspaces/"+owner.workspace;
  String invitation=request("POST",path(owner,"/team/invitations"),Map.of("displayName","عضو اختبار","phone","0500000003","role","ACCOUNTANT"),owner.token,null).json.get("id").asString();
  assertEquals(200,request("POST","/account/invitations/"+invitation+"/accept",null,member.token,null).status);
  String entry=request("POST",workspace+"/entries",expense(eq),member.token,key).json.get("id").asString();byte[] png=image("png");
  String file=request("POST",workspace+"/entries/"+entry+"/attachments",Map.of("filename","synthetic-receipt.png","mediaType","image/png","size",png.length),member.token,key()).json.get("id").asString();
  assertEquals(200,raw("PUT",workspace+"/attachments/"+file+"/content",png,"image/png",member.token,null,Map.of()).status);
  assertEquals(200,request("DELETE",workspace+"/team/members/"+member.user,null,owner.token,null).status);
  assertEquals(404,request("POST",workspace+"/entries",expense(eq),member.token,key).status);assertEquals(404,request("GET",workspace+"/attachments/"+file+"/content",null,member.token,null).status);
  JsonNode profile=request("GET","/auth/me",null,member.token,null).json;assertEquals(1,profile.get("workspaces").size());assertEquals(member.workspace,profile.get("workspaces").get(0).get("id").asString());
  assertEquals(200,request("GET",path(member,"/equipment"),null,member.token,null).status);
 }
 @Test void browserCookieCsrfOriginAndLogoutAreEnforced()throws Exception{
  String c=challenge("0500000001");var verified=request("POST","/auth/verify",Map.of("challengeId",c,"code","123456","name","مالك","client","WEB"),null,null);assertNull(verified.json.get("accessToken"));String cookie=verified.raw.headers().firstValue("Set-Cookie").orElseThrow();assertTrue(cookie.contains("HttpOnly"));assertTrue(cookie.contains("SameSite=Strict"));cookie=cookie.split(";")[0];
  var me=raw("GET","/auth/me",null,"application/json",null,null,Map.of("Cookie",cookie));String workspace=me.json.get("workspaces").get(0).get("id").asString();String path="/workspaces/"+workspace+"/equipment";byte[] body=JSON.writeValueAsBytes(Map.of("name","قلاب","model","2021"));
  assertEquals(403,raw("POST",path,body,"application/json",null,key(),Map.of("Cookie",cookie)).status);
  assertEquals(403,raw("POST",path,body,"application/json",null,key(),Map.of("Cookie",cookie,"X-CSRF-Token","wrong")).status);
  String csrf=me.json.get("csrfToken").asString();assertEquals(403,raw("POST",path,body,"application/json",null,key(),Map.of("Cookie",cookie,"X-CSRF-Token",csrf,"Origin","https://untrusted.example")).status);
  assertEquals(200,raw("POST",path,body,"application/json",null,key(),Map.of("Cookie",cookie,"X-CSRF-Token",csrf,"Origin","http://localhost:8081")).status);
  assertEquals(200,raw("POST","/auth/logout",null,"application/json",null,null,Map.of("Cookie",cookie,"X-CSRF-Token",csrf)).status);assertEquals(401,raw("GET","/auth/me",null,"application/json",null,null,Map.of("Cookie",cookie)).status);
 }
 @Test void expiryPreventsProtectedCalls()throws Exception{User user=login("0500000001");db.update("update app_session set expires_at=now()-interval '1 second'");assertEquals(401,request("GET",path(user,"/equipment"),null,user.token,null).status);}
 @Test void contentTypesSizeCorruptionAndDirectNestedPdfActionsAreRejected()throws Exception{
  assertEquals("image/png",validator.validate(image("png"),"image/png"));assertEquals("image/jpeg",validator.validate(image("jpeg"),"image/jpeg"));
  assertThrows(RuntimeException.class,()->validator.validate(image("png"),"image/jpeg"));assertThrows(RuntimeException.class,()->validator.validate("<html>not an image</html>".getBytes(StandardCharsets.UTF_8),"image/png"));assertThrows(RuntimeException.class,()->validator.validate(new byte[ContentValidator.MAX_BYTES+1],"image/png"));
  try(var document=new PDDocument()){document.addPage(new PDPage());var output=new ByteArrayOutputStream();document.save(output);assertEquals("application/pdf",validator.validate(output.toByteArray(),"application/pdf"));
   for(String action:List.of("Launch","SubmitForm","JavaScript")){var link=new PDAnnotationLink();var nested=new COSDictionary();nested.setName(COSName.S,action);nested.setString(COSName.F,"test-only");link.getCOSObject().setItem(COSName.A,nested);document.getPage(0).getAnnotations().add(link);output.reset();document.save(output);byte[] active=output.toByteArray();assertThrows(RuntimeException.class,()->validator.validate(active,"application/pdf"));document.getPage(0).getAnnotations().clear();}}
 }
 @Test void productionAndMixedProfilesFailClosed(){assertThrows(IllegalStateException.class,()->new DevelopmentBoundary(new MockEnvironment().withProperty("spring.profiles.active","prod"),true));var env=new MockEnvironment();env.setActiveProfiles("dev","prod");assertThrows(IllegalStateException.class,()->new DevelopmentBoundary(env,true));env.setActiveProfiles("dev");assertThrows(IllegalStateException.class,()->new DevelopmentBoundary(env,false));assertDoesNotThrow(()->new DevelopmentBoundary(env,true));}
 @Test void sharedExpenseIsOneOriginalWithExactSharesAndEntryLevelMovements()throws Exception{
  User user=login("0500000001"),other=login("0500000002");String a=equipment(user),b=equipment(user),foreign=equipment(other);
  var body=new HashMap<String,Object>();body.put("expenseScope","SHARED");body.put("amount","1200.00");body.put("category","FUEL");body.put("operationDate","2026-09-01");body.put("paymentStatus","UNPAID");body.put("partyName","مورد");body.put("allocations",List.of(Map.of("equipmentId",a,"amount","700.00"),Map.of("equipmentId",b,"amount","500.00")));
  var badSum=new HashMap<>(body);badSum.put("allocations",List.of(Map.of("equipmentId",a,"amount","600.00"),Map.of("equipmentId",b,"amount","500.00")));assertEquals(400,request("POST",path(user,"/entries"),badSum,user.token,key()).status);
  var foreignAllocation=new HashMap<>(body);foreignAllocation.put("allocations",List.of(Map.of("equipmentId",a,"amount","700.00"),Map.of("equipmentId",foreign,"amount","500.00")));assertEquals(404,request("POST",path(user,"/entries"),foreignAllocation,user.token,key()).status);
  var created=request("POST",path(user,"/entries"),body,user.token,key());assertEquals(200,created.status);String id=created.json.get("id").asString();assertEquals(1,db.queryForObject("select count(*) from financial_entry",Integer.class));assertEquals(2,db.queryForObject("select count(*) from expense_allocation",Integer.class));
  assertEquals("1200.00",request("GET",path(user,"/entries/totals"),null,user.token,null).json.get("expenseTotal").asString());
  assertEquals("700.00",request("GET",path(user,"/entries/totals?equipmentId="+a),null,user.token,null).json.get("expenseTotal").asString());
  assertEquals("500.00",request("GET",path(user,"/entries/totals?equipmentId="+b),null,user.token,null).json.get("expenseTotal").asString());
  assertEquals(1,request("GET",path(user,"/entries?equipmentId="+a),null,user.token,null).json.get("total").asInt());
  assertEquals(404,request("GET",path(other,"/entries/"+id),null,other.token,null).status);
  assertEquals(404,request("GET",path(other,"/entries/totals?equipmentId="+a),null,other.token,null).status);
  assertEquals(200,request("POST",path(user,"/entries/"+id+"/settlements"),Map.of("amount","600.00","paidOn","2026-09-02"),user.token,key()).status);
  var refunded=request("POST",path(user,"/entries/"+id+"/refunds"),Map.of("amount","200.00","refundedOn","2026-09-03","reason","عودة جزء"),user.token,key());assertEquals(200,refunded.status);assertEquals("400.00",refunded.json.get("netPaid").asString());assertEquals("800.00",refunded.json.get("remaining").asString());
  var byEquipment=new HashMap<String,JsonNode>();for(var part:refunded.json.get("allocations"))byEquipment.put(part.get("equipmentId").asString(),part);
  assertEquals("350.00",byEquipment.get(a).get("paidShare").asString());assertEquals("250.00",byEquipment.get(b).get("paidShare").asString());
  assertEquals("116.67",byEquipment.get(a).get("refundedShare").asString());assertEquals("83.33",byEquipment.get(b).get("refundedShare").asString());
  assertEquals("233.33",byEquipment.get(a).get("netPaidShare").asString());assertEquals("166.67",byEquipment.get(b).get("netPaidShare").asString());
  assertEquals(1,db.queryForObject("select count(*) from settlement where entry_id=?",Integer.class,UUID.fromString(id)));assertEquals(1,db.queryForObject("select count(*) from financial_refund where entry_id=?",Integer.class,UUID.fromString(id)));
  assertEquals(200,request("POST",path(user,"/entries/"+id+"/cancellation"),Map.of("reason","قيد خاطئ"),user.token,null).status);
  assertEquals("0.00",request("GET",path(user,"/entries/totals"),null,user.token,null).json.get("expenseTotal").asString());
  assertEquals("0.00",request("GET",path(user,"/entries/totals?equipmentId="+a),null,user.token,null).json.get("expenseTotal").asString());
  assertEquals(2,request("GET",path(user,"/entries/"+id),null,user.token,null).json.get("allocations").size());
 }
 @Test void generalExpenseAndLegacySingleStaySeparatedFromEquipmentTotals()throws Exception{
  User user=login("0500000001");String eq=equipment(user),single=entry(user,eq);
  var existing=request("GET",path(user,"/entries/"+single),null,user.token,null);assertEquals("SINGLE",existing.json.get("expenseScope").asString());assertEquals("350.00",existing.json.get("allocations").get(0).get("amount").asString());
  var general=request("POST",path(user,"/entries"),Map.of("expenseScope","GENERAL","amount","100.00","category","OTHER","operationDate","2026-09-01","paidOn","2026-09-01"),user.token,key());assertEquals(200,general.status);assertTrue(general.json.get("equipmentId").isNull());assertEquals(0,general.json.get("allocations").size());
  assertEquals("450.00",request("GET",path(user,"/entries/totals"),null,user.token,null).json.get("expenseTotal").asString());assertEquals("100.00",request("GET",path(user,"/entries/totals"),null,user.token,null).json.get("generalExpenseTotal").asString());assertEquals("350.00",request("GET",path(user,"/entries/totals?equipmentId="+eq),null,user.token,null).json.get("expenseTotal").asString());
  var returned=request("POST",path(user,"/entries/"+general.json.get("id").asString()+"/refunds"),Map.of("amount","20.00","refundedOn","2026-09-02","reason","عودة جزء","partyName","المورد العام"),user.token,key());assertEquals(200,returned.status);assertEquals("GENERAL",returned.json.get("expenseScope").asString());assertEquals("20.00",returned.json.get("remaining").asString());
  assertEquals(200,request("POST",path(user,"/entries/"+general.json.get("id").asString()+"/cancellation"),Map.of("reason","قيد مكرر"),user.token,null).status);
  assertEquals("350.00",request("GET",path(user,"/entries/totals"),null,user.token,null).json.get("expenseTotal").asString());
  assertEquals(400,request("POST",path(user,"/entries/"+general.json.get("id").asString()+"/settlements"),Map.of("amount","20.00","paidOn","2026-09-03"),user.token,key()).status);
 }
 @Test void sharedAllocationEditKeepsTotalButAllowsClassificationCorrectionAfterCash()throws Exception{
  User user=login("0500000001");String a=equipment(user),b=equipment(user);
  var body=Map.of("expenseScope","SHARED","amount","100.00","category","OTHER","operationDate","2026-09-01","paymentStatus","UNPAID","partyName","مورد","allocations",List.of(Map.of("equipmentId",a,"amount","60.00"),Map.of("equipmentId",b,"amount","40.00")));
  String id=request("POST",path(user,"/entries"),body,user.token,key()).json.get("id").asString();
  var edit=Map.of("amount","120.00","category","OTHER","operationDate","2026-09-02","partyName","مورد","expenseScope","SHARED","allocations",List.of(Map.of("equipmentId",a,"amount","70.00"),Map.of("equipmentId",b,"amount","50.00")));
  assertEquals(200,request("PUT",path(user,"/entries/"+id),edit,user.token,null).status);
  assertEquals("70.00",request("GET",path(user,"/entries/totals?equipmentId="+a),null,user.token,null).json.get("expenseTotal").asString());
  assertEquals(200,request("POST",path(user,"/entries/"+id+"/settlements"),Map.of("amount","30.00","paidOn","2026-09-03"),user.token,key()).status);
  var changed=new HashMap<>(edit);changed.put("amount","130.00");assertEquals(400,request("PUT",path(user,"/entries/"+id),changed,user.token,null).status);
  var corrected=new HashMap<>(edit);corrected.put("allocations",List.of(Map.of("equipmentId",a,"amount","80.00"),Map.of("equipmentId",b,"amount","40.00")));
  var allocationEdit=request("PUT",path(user,"/entries/"+id),corrected,user.token,null);assertEquals(200,allocationEdit.status);assertEquals("80.00",request("GET",path(user,"/entries/totals?equipmentId="+a),null,user.token,null).json.get("expenseTotal").asString());
  var noteOnly=Map.of("amount","120.00","category","OTHER","operationDate","2026-09-02","partyName","مورد","note","تصحيح الوصف");
  var updated=request("PUT",path(user,"/entries/"+id),noteOnly,user.token,null);assertEquals(200,updated.status);assertEquals("30.00",updated.json.get("paid").asString());assertEquals(1,updated.json.get("settlements").size());
  var returned=request("POST",path(user,"/entries/"+id+"/refunds"),Map.of("amount","10.00","refundedOn","2026-09-04","reason","عودة جزء"),user.token,key());assertEquals(200,returned.status);assertEquals("100.00",returned.json.get("remaining").asString());
  assertEquals(400,request("PUT",path(user,"/entries/"+id),changed,user.token,null).status);
  updated=request("PUT",path(user,"/entries/"+id),noteOnly,user.token,null);assertEquals(200,updated.status);assertEquals(1,updated.json.get("settlements").size());assertEquals(1,updated.json.get("refunds").size());
 }
 @Test void q02CorrectsExpenseClassificationAfterMovementsWithoutChangingMoneyHistory()throws Exception{
  User owner=login("0500000001");String a=equipment(owner),b=equipment(owner),c=equipment(owner);
  User other=login("0500000002");String foreign=equipment(other);
  var create=Map.of("equipmentId",a,"amount","100.00","category","OTHER","operationDate","2026-09-01","paymentStatus","UNPAID","partyName","مورد");
  String id=request("POST",path(owner,"/entries"),create,owner.token,key()).json.get("id").asString(),url=path(owner,"/entries/"+id);
  var base=new HashMap<String,Object>();base.put("amount","100.00");base.put("category","OTHER");base.put("operationDate","2026-09-01");base.put("partyName","مورد");
  var beforeCash=new HashMap<>(base);beforeCash.put("amount","120.00");beforeCash.put("equipmentId",b);beforeCash.put("expenseScope","SINGLE");
  assertEquals(200,request("PUT",url,beforeCash,owner.token,null).status);
  assertEquals("120.00",request("GET",url,null,owner.token,null).json.get("amount").asString());
  base.put("amount","120.00");
  var settlement=request("POST",url+"/settlements",Map.of("amount","50.00","paidOn","2026-09-02"),owner.token,key());assertEquals(200,settlement.status);String settlementId=settlement.json.get("settlements").get(0).get("id").asString();
  var changedTotal=new HashMap<>(base);changedTotal.put("amount","121.00");assertEquals(400,request("PUT",url,changedTotal,owner.token,null).status);
  var shared=new HashMap<>(base);shared.put("expenseScope","SHARED");shared.put("allocations",List.of(Map.of("equipmentId",a,"amount","70.00"),Map.of("equipmentId",c,"amount","50.00")));
  assertEquals(200,request("PUT",url,shared,owner.token,null).status);
  var mismatch=new HashMap<>(shared);mismatch.put("allocations",List.of(Map.of("equipmentId",a,"amount","70.00"),Map.of("equipmentId",c,"amount","49.00")));assertEquals(400,request("PUT",url,mismatch,owner.token,null).status);
  var cross=new HashMap<>(shared);cross.put("allocations",List.of(Map.of("equipmentId",a,"amount","70.00"),Map.of("equipmentId",foreign,"amount","50.00")));assertEquals(404,request("PUT",url,cross,owner.token,null).status);
  var one=new HashMap<>(base);one.put("expenseScope","SINGLE");one.put("equipmentId",c);assertEquals(200,request("PUT",url,one,owner.token,null).status);
  var general=new HashMap<>(base);general.put("expenseScope","GENERAL");assertEquals(200,request("PUT",url,general,owner.token,null).status);
  assertEquals("120.00",request("GET",path(owner,"/entries/totals"),null,owner.token,null).json.get("generalExpenseTotal").asString());
  one.put("equipmentId",a);assertEquals(200,request("PUT",url,one,owner.token,null).status);
  var refund=request("POST",url+"/refunds",Map.of("amount","10.00","refundedOn","2026-09-03","reason","مرتجع"),owner.token,key());assertEquals(200,refund.status);String refundId=refund.json.get("refunds").get(0).get("id").asString();
  assertEquals(400,request("PUT",url,changedTotal,owner.token,null).status);
  assertEquals(200,request("PUT",url,shared,owner.token,null).status);
  var finalEntry=request("GET",url,null,owner.token,null).json;assertEquals("120.00",finalEntry.get("amount").asString());assertEquals(settlementId,finalEntry.get("settlements").get(0).get("id").asString());assertEquals(refundId,finalEntry.get("refunds").get(0).get("id").asString());
  var audit=db.queryForMap("select actor_id,metadata,created_at from audit_event where resource_id=? and action='EXPENSE_EDITED' order by created_at desc limit 1",UUID.fromString(id));assertEquals(UUID.fromString(owner.user),audit.get("actor_id"));assertNotNull(audit.get("created_at"));String metadata=audit.get("metadata").toString();assertTrue(metadata.contains("before"));assertTrue(metadata.contains("after"));assertTrue(metadata.contains("SINGLE"));assertTrue(metadata.contains("SHARED"));assertTrue(metadata.contains(a));assertTrue(metadata.contains(c));
  assertEquals(200,request("POST",url+"/cancellation",Map.of("reason","قيد خاطئ"),owner.token,null).status);assertEquals(400,request("PUT",url,general,owner.token,null).status);
 }
 @Test void q02IncomeTotalEditableOnlyBeforeMovement()throws Exception{
  User owner=login("0500000001");String eq=equipment(owner);var create=Map.of("equipmentId",eq,"entryType","INCOME","amount","100.00","operationDate","2026-09-01","paymentStatus","UNPAID","partyName","عميل");
  String id=request("POST",path(owner,"/entries"),create,owner.token,key()).json.get("id").asString(),url=path(owner,"/entries/"+id);
  var edit=new HashMap<String,Object>();edit.put("amount","120.00");edit.put("operationDate","2026-09-01");edit.put("partyName","عميل");assertEquals(200,request("PUT",url,edit,owner.token,null).status);
  assertEquals(200,request("POST",url+"/settlements",Map.of("amount","50.00","paidOn","2026-09-02"),owner.token,key()).status);
  edit.put("amount","119.00");assertEquals(400,request("PUT",url,edit,owner.token,null).status);
  assertEquals(200,request("POST",url+"/refunds",Map.of("amount","10.00","refundedOn","2026-09-03","reason","مرتجع"),owner.token,key()).status);
  edit.put("amount","121.00");assertEquals(400,request("PUT",url,edit,owner.token,null).status);
  edit.put("amount","120.00");edit.put("note","تصحيح وصف");assertEquals(200,request("PUT",url,edit,owner.token,null).status);
 }
 @Test void tinySharedSharesReconcileDeterministicallyAcrossPaymentsAndRefund()throws Exception{
  User user=login("0500000001");String a=equipment(user),b=equipment(user),c=equipment(user);
  var body=Map.of("expenseScope","SHARED","amount","0.03","category","OTHER","operationDate","2026-09-01","paymentStatus","UNPAID","partyName","مورد","allocations",List.of(Map.of("equipmentId",a,"amount","0.01"),Map.of("equipmentId",b,"amount","0.01"),Map.of("equipmentId",c,"amount","0.01")));
  String id=request("POST",path(user,"/entries"),body,user.token,key()).json.get("id").asString();String url=path(user,"/entries/"+id);
  assertEquals(200,request("POST",url+"/settlements",Map.of("amount","0.02","paidOn","2026-09-02"),user.token,key()).status);
  var afterRefund=request("POST",url+"/refunds",Map.of("amount","0.01","refundedOn","2026-09-03","reason","عودة جزء"),user.token,key());assertEquals(200,afterRefund.status);
  int paid=0,refund=0,net=0,remaining=0;for(var part:afterRefund.json.get("allocations")){paid+=Integer.parseInt(part.get("paidShare").asString().replace(".",""));refund+=Integer.parseInt(part.get("refundedShare").asString().replace(".",""));net+=Integer.parseInt(part.get("netPaidShare").asString().replace(".",""));remaining+=Integer.parseInt(part.get("remainingShare").asString().replace(".",""));}
  assertEquals(2,paid);assertEquals(1,refund);assertEquals(1,net);assertEquals(2,remaining);
  var again=request("GET",url,null,user.token,null);assertEquals(afterRefund.json.get("allocations"),again.json.get("allocations"));
  assertEquals(200,request("POST",url+"/settlements",Map.of("amount","0.02","paidOn","2026-09-04"),user.token,key()).status);
  var complete=request("GET",url,null,user.token,null);for(var part:complete.json.get("allocations"))assertEquals(part.get("amount").asString(),part.get("netPaidShare").asString());
 }
 @Test void v6MigrationBackfillsExistingExpenseWithoutChangingIncome()throws Exception{
  String schema="allocation_migration_"+UUID.randomUUID().toString().replace("-","");
  db.execute("create schema "+schema);
  try {
   var source=Objects.requireNonNull(db.getDataSource());
   Flyway.configure().dataSource(source).schemas(schema).defaultSchema(schema).locations("classpath:db/migration").target(MigrationVersion.fromVersion("5")).load().migrate();
   UUID user=UUID.randomUUID(),workspace=UUID.randomUUID(),equipment=UUID.randomUUID(),expense=UUID.randomUUID(),income=UUID.randomUUID();
   db.update("insert into "+schema+".app_user(id,phone,name) values(?,?,?)",user,"0501111111","مالك اختبار");
   db.update("insert into "+schema+".workspace(id,name,owner_id) values(?,?,?)",workspace,"اختبار",user);
   db.update("insert into "+schema+".equipment(id,workspace_id,name,model,created_by) values(?,?,?,?,?)",equipment,workspace,"قلاب","موديل",user);
   for(var pair:List.of(Map.entry(expense,"EXPENSE"),Map.entry(income,"INCOME")))
    db.update("insert into "+schema+".financial_entry(id,workspace_id,equipment_id,amount,currency,category,operation_date,lifecycle,created_by,entry_type) values(?,?,?,?,'SAR','OTHER',current_date,'POSTED',?,?)",pair.getKey(),workspace,equipment,new java.math.BigDecimal("350.00"),user,pair.getValue());
   Flyway.configure().dataSource(source).schemas(schema).defaultSchema(schema).locations("classpath:db/migration").load().migrate();
   assertEquals(1,db.queryForObject("select count(*) from "+schema+".expense_allocation where entry_id=?",Integer.class,expense));
   assertEquals("350.00",db.queryForObject("select amount::text from "+schema+".expense_allocation where entry_id=?",String.class,expense));
   assertEquals(0,db.queryForObject("select count(*) from "+schema+".expense_allocation where entry_id=?",Integer.class,income));
   assertEquals(2,db.queryForObject("select count(*) from "+schema+".financial_entry",Integer.class));
  } finally { db.execute("drop schema "+schema+" cascade"); }
 }
 @Test void proportionalRefundSharesNeverBecomeNegativeUnderRoundingParadox()throws Exception{
  User user=login("0500000001");String a=equipment(user),b=equipment(user),c=equipment(user);
  var body=Map.of("expenseScope","SHARED","amount","0.07","category","OTHER","operationDate","2026-09-01","paymentStatus","UNPAID","partyName","مورد","allocations",List.of(Map.of("equipmentId",a,"amount","0.01"),Map.of("equipmentId",b,"amount","0.03"),Map.of("equipmentId",c,"amount","0.03")));
  String id=request("POST",path(user,"/entries"),body,user.token,key()).json.get("id").asString();String url=path(user,"/entries/"+id);
  assertEquals(200,request("POST",url+"/settlements",Map.of("amount","0.04","paidOn","2026-09-02"),user.token,key()).status);
  var after=request("POST",url+"/refunds",Map.of("amount","0.03","refundedOn","2026-09-03","reason","عودة جزء"),user.token,key());assertEquals(200,after.status);
  int refunds=0,net=0;for(var part:after.json.get("allocations")){int partRefund=Integer.parseInt(part.get("refundedShare").asString().replace(".",""));int partNet=Integer.parseInt(part.get("netPaidShare").asString().replace(".",""));assertTrue(partRefund>=0);assertTrue(partNet>=0);refunds+=partRefund;net+=partNet;}
  assertEquals(3,refunds);assertEquals(1,net);
 }
 @Test void quickDraftCompletesInPlaceWithSameAttachmentAndAudit()throws Exception{
  User user=login("0500000001");String eq=equipment(user),draftKey=key();String drafts=path(user,"/drafts");
  var capture=Map.of("equipmentId",eq,"note","فاتورة وقود سريعة");
  var created=request("POST",drafts,capture,user.token,draftKey);assertEquals(200,created.status);String id=created.json.get("id").asString();
  assertEquals(id,request("POST",drafts,capture,user.token,draftKey).json.get("id").asString());
  assertEquals(409,request("POST",drafts,Map.of("equipmentId",eq,"note","مختلفة"),user.token,draftKey).status);
  assertEquals("DRAFT",created.json.get("lifecycle").asString());assertEquals("0.00",request("GET",path(user,"/entries/totals"),null,user.token,null).json.get("expenseTotal").asString());
  assertEquals(0,request("GET",path(user,"/entries"),null,user.token,null).json.get("total").asInt());
  assertEquals(1,request("GET",drafts,null,user.token,null).json.get("total").asInt());
  assertEquals(404,request("GET",path(user,"/entries/"+id),null,user.token,null).status);
  assertEquals(404,request("POST",path(user,"/entries/"+id+"/settlements"),Map.of("amount","1.00","paidOn","2026-09-24"),user.token,key()).status);
  assertEquals(400,request("PUT",path(user,"/entries/"+id),expense(eq),user.token,null).status);
  assertNull(db.queryForObject("select amount from financial_entry where id=?",java.math.BigDecimal.class,UUID.fromString(id)));
  byte[] bytes=image("png");String fileKey=key();var fileBody=Map.of("filename","receipt.png","mediaType","image/png","size",bytes.length);
  String attachment=request("POST",path(user,"/entries/"+id+"/attachments"),fileBody,user.token,fileKey).json.get("id").asString();
  assertEquals(attachment,request("POST",path(user,"/entries/"+id+"/attachments"),fileBody,user.token,fileKey).json.get("id").asString());
  assertEquals(200,raw("PUT",path(user,"/attachments/"+attachment+"/content"),bytes,"image/png",user.token,null,Map.of()).status);
  assertArrayEquals(bytes,request("GET",path(user,"/attachments/"+attachment+"/content"),null,user.token,null).raw.body());
  var incomplete=new HashMap<>(expense(eq));incomplete.remove("amount");assertEquals(400,request("POST",drafts+"/"+id+"/completion",incomplete,user.token,key()).status);
  assertEquals(1,request("GET",drafts,null,user.token,null).json.get("total").asInt());
  var completion=new HashMap<>(expense(eq));completion.remove("note");
  var completed=request("POST",drafts+"/"+id+"/completion",completion,user.token,"complete1234");assertEquals(200,completed.status);assertEquals(id,completed.json.get("id").asString());
  assertEquals("POSTED",completed.json.get("lifecycle").asString());assertEquals("فاتورة وقود سريعة",completed.json.get("note").asString());
  assertEquals(user.user,completed.json.get("createdBy").asString());assertEquals(user.user,completed.json.get("completedBy").asString());assertNotNull(completed.json.get("completedAt"));
  assertEquals(id,request("POST",drafts+"/"+id+"/completion",completion,user.token,"complete1234").json.get("id").asString());
  assertEquals(0,request("GET",drafts,null,user.token,null).json.get("total").asInt());assertEquals(1,request("GET",path(user,"/entries"),null,user.token,null).json.get("total").asInt());
  assertEquals("350.00",request("GET",path(user,"/entries/totals"),null,user.token,null).json.get("expenseTotal").asString());
  assertEquals(1,db.queryForObject("select count(*) from financial_entry",Integer.class));assertEquals(1,db.queryForObject("select count(*) from settlement",Integer.class));assertEquals(1,db.queryForObject("select count(*) from attachment",Integer.class));
  assertEquals(attachment,request("GET",path(user,"/entries/"+id+"/attachments"),null,user.token,null).json.get(0).get("id").asString());
  assertArrayEquals(bytes,request("GET",path(user,"/attachments/"+attachment+"/content"),null,user.token,null).raw.body());
  assertEquals(1,db.queryForObject("select count(*) from audit_event where resource_id=? and action='FINANCIAL_DRAFT_CREATED'",Integer.class,UUID.fromString(id)));
  assertEquals(1,db.queryForObject("select count(*) from audit_event where resource_id=? and action='FINANCIAL_DRAFT_COMPLETED'",Integer.class,UUID.fromString(id)));
 }
 @Test void discardedDraftIsHiddenWithoutFinancialCancellationAndTenantAccess()throws Exception{
  User owner=login("0500000001"),other=login("0500000002");String eq=equipment(owner),drafts=path(owner,"/drafts");
  String id=request("POST",drafts,Map.of("equipmentId",eq),owner.token,key()).json.get("id").asString();byte[] bytes=image("png");String file=initiate(owner,id,bytes,"image/png");raw("PUT",path(owner,"/attachments/"+file+"/content"),bytes,"image/png",owner.token,null,Map.of());
  assertEquals(404,request("GET",path(other,"/drafts/"+id),null,other.token,null).status);
  assertEquals(404,request("GET",path(other,"/drafts?equipmentId="+eq),null,other.token,null).status);
  assertEquals(404,request("POST",path(other,"/drafts/"+id+"/completion"),expense(eq),other.token,key()).status);
  assertEquals(404,request("DELETE",path(other,"/drafts/"+id),null,other.token,null).status);
  assertEquals(404,request("GET",path(other,"/attachments/"+file+"/content"),null,other.token,null).status);
  assertEquals("DISCARDED",request("DELETE",drafts+"/"+id,null,owner.token,null).json.get("lifecycle").asString());
  assertEquals("DISCARDED",request("DELETE",drafts+"/"+id,null,owner.token,null).json.get("lifecycle").asString());
  assertEquals(0,request("GET",drafts,null,owner.token,null).json.get("total").asInt());assertEquals(404,request("GET",drafts+"/"+id,null,owner.token,null).status);
  assertEquals(404,request("GET",path(owner,"/attachments/"+file+"/content"),null,owner.token,null).status);
  assertEquals(404,request("GET",path(owner,"/entries/"+id+"/attachments"),null,owner.token,null).status);
  assertEquals(404,request("POST",drafts+"/"+id+"/completion",expense(eq),owner.token,key()).status);
  assertEquals("0.00",request("GET",path(owner,"/entries/totals"),null,owner.token,null).json.get("expenseTotal").asString());
  assertEquals(1,db.queryForObject("select count(*) from audit_event where resource_id=? and action='FINANCIAL_DRAFT_DISCARDED'",Integer.class,UUID.fromString(id)));
  assertEquals(0,db.queryForObject("select count(*) from audit_event where resource_id=? and action='FINANCIAL_ENTRY_CANCELLED'",Integer.class,UUID.fromString(id)));
 }
 @Test void draftCanCompleteAsIncomeAndReuseMultipleAttachments()throws Exception{
  User user=login("0500000001");String eq=equipment(user),drafts=path(user,"/drafts");String id=request("POST",drafts,Map.of("equipmentId",eq),user.token,key()).json.get("id").asString();
  byte[] bytes=image("png");String first=initiate(user,id,bytes,"image/png"),second=initiate(user,id,bytes,"image/png");
  assertEquals(200,raw("PUT",path(user,"/attachments/"+first+"/content"),bytes,"image/png",user.token,null,Map.of()).status);
  assertEquals(200,raw("PUT",path(user,"/attachments/"+second+"/content"),bytes,"image/png",user.token,null,Map.of()).status);
  var income=Map.of("equipmentId",eq,"entryType","INCOME","amount","3000.00","operationDate","2026-09-24","paymentStatus","UNPAID","partyName","عميل");
  var result=request("POST",drafts+"/"+id+"/completion",income,user.token,key());assertEquals(200,result.status);assertEquals(id,result.json.get("id").asString());assertEquals("INCOME",result.json.get("entryType").asString());
  assertEquals("3000.00",request("GET",path(user,"/entries/totals"),null,user.token,null).json.get("incomeTotal").asString());
  assertEquals(2,request("GET",path(user,"/entries/"+id+"/attachments"),null,user.token,null).json.size());
  assertEquals(1,db.queryForObject("select count(*) from financial_entry",Integer.class));assertEquals(2,db.queryForObject("select count(*) from attachment",Integer.class));
 }
 @Test void financialHistorySearchAndCombinedFiltersStayWithinWorkspace()throws Exception{
  User owner=login("0500000001"),other=login("0500000002");String eq=equipment(owner),foreign=equipment(other),base=path(owner,"/entries");
  var equipmentDetail=request("GET",path(owner,"/equipment/"+eq),null,owner.token,null).json;
  String reference=equipmentDetail.get("reference").asString();
  var paid=new HashMap<String,Object>(expense(eq));paid.put("note","وقود الشمال");String expenseId=request("POST",base,paid,owner.token,key()).json.get("id").asString();
  var partial=Map.of("equipmentId",eq,"entryType","INCOME","amount","900.00","operationDate","2026-09-10","paymentStatus","PARTIAL","initialPaid","300.00","paidOn","2026-09-10","partyName","عميل الشرق","note","نقل خاص");
  String incomeId=request("POST",base,partial,owner.token,key()).json.get("id").asString();
  var general=Map.of("expenseScope","GENERAL","amount","75.00","category","OTHER","operationDate","2026-09-15","paidOn","2026-09-15","note","رسوم عامة");
  String generalId=request("POST",base,general,owner.token,key()).json.get("id").asString();
  assertEquals(200,request("POST",base+"/"+generalId+"/cancellation",Map.of("reason","قيد مكرر"),owner.token,null).status);
  request("POST",path(owner,"/drafts"),Map.of("equipmentId",eq,"note","عميل الشرق"),owner.token,key());
  assertEquals(3,request("GET",base,null,owner.token,null).json.get("total").asInt());
  assertEquals(expenseId,request("GET",base+"?search="+URLEncoder.encode("وقود الشمال",StandardCharsets.UTF_8),null,owner.token,null).json.get("items").get(0).get("id").asString());
  assertEquals(expenseId,request("GET",base+"?search=FUEL",null,owner.token,null).json.get("items").get(0).get("id").asString());
  assertEquals(0,request("GET",base+"?search=%25",null,owner.token,null).json.get("total").asInt());
  assertEquals(2,request("GET",base+"?search="+reference,null,owner.token,null).json.get("total").asInt());
  assertEquals(incomeId,request("GET",base+"?search="+URLEncoder.encode("عميل الشرق",StandardCharsets.UTF_8),null,owner.token,null).json.get("items").get(0).get("id").asString());
  assertEquals(1,request("GET",base+"?fromDate=2026-09-10&toDate=2026-09-10",null,owner.token,null).json.get("total").asInt());
  assertEquals(incomeId,request("GET",base+"?entryType=INCOME&equipmentId="+eq+"&settlementStatus=PARTIAL&lifecycle=POSTED",null,owner.token,null).json.get("items").get(0).get("id").asString());
  assertEquals(1,request("GET",base+"?generalExpense=true&lifecycle=CANCELLED&entryType=EXPENSE&settlementStatus=PAID",null,owner.token,null).json.get("total").asInt());
  assertEquals(0,request("GET",base+"?generalExpense=true&lifecycle=POSTED",null,owner.token,null).json.get("total").asInt());
  assertEquals(2,request("GET",base+"?generalExpense=false",null,owner.token,null).json.get("total").asInt());
  assertEquals(400,request("GET",base+"?fromDate=2026-10-01&toDate=2026-09-01",null,owner.token,null).status);
  assertEquals(400,request("GET",base+"?settlementStatus=UNKNOWN",null,owner.token,null).status);
  assertEquals(404,request("GET",base+"?equipmentId="+foreign,null,owner.token,null).status);
  assertEquals(0,request("GET",path(other,"/entries?search="+reference),null,other.token,null).json.get("total").asInt());
 }
 @Test void financialHistoryPaginationRemainsBoundedWithSearch()throws Exception{
  User user=login("0500000001");String eq=equipment(user),base=path(user,"/entries");
  for(int i=0;i<31;i++) {var body=new HashMap<String,Object>(expense(eq));body.put("note","صفحة سجل "+i);assertEquals(200,request("POST",base,body,user.token,key()).status);}
  var first=request("GET",base+"?page=0&search="+URLEncoder.encode("صفحة سجل",StandardCharsets.UTF_8),null,user.token,null).json;
  var second=request("GET",base+"?page=1&search="+URLEncoder.encode("صفحة سجل",StandardCharsets.UTF_8),null,user.token,null).json;
  assertEquals(31,first.get("total").asInt());assertEquals(30,first.get("items").size());assertEquals(1,second.get("items").size());
  assertNotEquals(first.get("items").get(0).get("id").asString(),second.get("items").get(0).get("id").asString());
  assertEquals(400,request("GET",base+"?page=100001",null,user.token,null).status);
 }
 @Test void developmentAttachmentCleanupRetainsFinancialHistoryAndIsRepeatSafe(@TempDir Path disk)throws Exception{
  User owner=login("0500000001"),other=login("0500000002");String eq=equipment(owner),posted=entry(owner,eq);byte[] png=image("png");
  String ready=initiate(owner,posted,png,"image/png");assertEquals(200,raw("PUT",path(owner,"/attachments/"+ready+"/content"),png,"image/png",owner.token,null,Map.of()).status);
  String cancelled=entry(owner,eq),cancelledFile=initiate(owner,cancelled,png,"image/png");assertEquals(200,raw("PUT",path(owner,"/attachments/"+cancelledFile+"/content"),png,"image/png",owner.token,null,Map.of()).status);
  assertEquals(200,request("POST",path(owner,"/entries/"+cancelled+"/cancellation"),Map.of("reason","قيد مكرر"),owner.token,null).status);
  String draft=request("POST",path(owner,"/drafts"),Map.of("equipmentId",eq),owner.token,key()).json.get("id").asString(),draftFile=initiate(owner,draft,png,"image/png");
  assertEquals(200,raw("PUT",path(owner,"/attachments/"+draftFile+"/content"),png,"image/png",owner.token,null,Map.of()).status);
  assertEquals(200,request("POST",path(owner,"/drafts/"+draft+"/completion"),expense(eq),owner.token,key()).status);
  String discarded=request("POST",path(owner,"/drafts"),Map.of("equipmentId",eq),owner.token,key()).json.get("id").asString(),discardedFile=initiate(owner,discarded,png,"image/png");
  assertEquals(200,raw("PUT",path(owner,"/attachments/"+discardedFile+"/content"),png,"image/png",owner.token,null,Map.of()).status);
  assertEquals(200,request("DELETE",path(owner,"/drafts/"+discarded),null,owner.token,null).status);
  String pending=initiate(owner,posted,png,"image/png"),recent=initiate(owner,posted,png,"image/png"),failed=initiate(owner,posted,png,"image/png"),retry=initiate(owner,posted,png,"image/png");
  assertEquals(400,raw("PUT",path(owner,"/attachments/"+failed+"/content"),png,"image/jpeg",owner.token,null,Map.of()).status);
  assertEquals(400,raw("PUT",path(owner,"/attachments/"+retry+"/content"),png,"image/jpeg",owner.token,null,Map.of()).status);
  assertEquals(200,raw("PUT",path(owner,"/attachments/"+retry+"/content"),png,"image/png",owner.token,null,Map.of()).status);
  assertEquals(404,request("GET",path(other,"/attachments/"+ready+"/content"),null,other.token,null).status);
  Instant now=Instant.now(),old=now.minus(Duration.ofDays(8));
  db.update("update attachment set updated_at=? where id in (?,?)",java.sql.Timestamp.from(old),UUID.fromString(pending),UUID.fromString(failed));
  db.update("update financial_entry set discarded_at=? where id=?",java.sql.Timestamp.from(old),UUID.fromString(discarded));
  var env=new MockEnvironment();env.setActiveProfiles("dev");var boundary=new DevelopmentBoundary(env,true);
  var storage=new DevelopmentFileStorage(disk.toString(),boundary);
  for(String file:List.of(ready,cancelledFile,draftFile,discardedFile)) {
   String objectKey=db.queryForObject("select object_key from attachment where id=?",String.class,UUID.fromString(file));storage.putImmutable(objectKey,png);Files.setLastModifiedTime(disk.resolve(objectKey),FileTime.from(old));
  }
  String orphan=owner.workspace+"/"+failed+"/"+"a".repeat(64);storage.putImmutable(orphan,png);Files.setLastModifiedTime(disk.resolve(orphan),FileTime.from(old));
  String retryObject=owner.workspace+"/"+recent+"/"+"b".repeat(64);storage.putImmutable(retryObject,png);Files.setLastModifiedTime(disk.resolve(retryObject),FileTime.from(old));
  Path oldTemp=disk.resolve(owner.workspace).resolve(pending).resolve("pending-123.tmp"),recentTemp=disk.resolve(owner.workspace).resolve(recent).resolve("pending-456.tmp");
  Files.createDirectories(oldTemp.getParent());Files.write(oldTemp,png);Files.setLastModifiedTime(oldTemp,FileTime.from(old));
  Files.createDirectories(recentTemp.getParent());Files.write(recentTemp,png);
  var cleanup=new AttachmentCleanupService(db,transactions,storage,boundary,7);
  var first=cleanup.clean(now);assertEquals(3,first.recordsRemoved());assertEquals(3,first.objectsRemoved());assertEquals(0,first.failures());
  assertEquals(0,db.queryForObject("select count(*) from attachment where id in (?,?,?)",Integer.class,UUID.fromString(pending),UUID.fromString(failed),UUID.fromString(discardedFile)));
  assertEquals(1,db.queryForObject("select count(*) from attachment where id=? and state='PENDING'",Integer.class,UUID.fromString(recent)));
  assertEquals(1,db.queryForObject("select count(*) from attachment where id=? and state='READY'",Integer.class,UUID.fromString(retry)));
  for(String file:List.of(ready,cancelledFile,draftFile)) {
   String objectKey=db.queryForObject("select object_key from attachment where id=?",String.class,UUID.fromString(file));assertArrayEquals(png,storage.read(objectKey));
  }
  assertTrue(Files.exists(recentTemp));assertFalse(Files.exists(oldTemp));assertThrows(IOException.class,()->storage.read(orphan));assertArrayEquals(png,storage.read(retryObject));
  assertEquals(200,request("GET",path(owner,"/attachments/"+draftFile+"/content"),null,owner.token,null).status);
  assertEquals(200,request("GET",path(owner,"/attachments/"+cancelledFile+"/content"),null,owner.token,null).status);
  var again=cleanup.clean(now);assertEquals(0,again.recordsRemoved());assertEquals(0,again.objectsRemoved());assertEquals(0,again.failures());
 }

 @Test void documentLifecycleVersionIsolationAndEquipmentArchive() throws Exception {
  User owner=login("0500000001"),other=login("0500000002");String eq=equipment(owner),base=path(owner,"/equipment/"+eq+"/documents");
  var bad=request("POST",base,Map.of("type","OTHER"),owner.token,key());assertEquals(400,bad.status);
  assertEquals(400,request("POST",base,Map.of("type","INSURANCE","issueDate","2026-10-02","expiryDate","2026-10-01"),owner.token,key()).status);
  assertEquals(404,request("POST",path(other,"/equipment/"+eq+"/documents"),Map.of("type","INSURANCE"),other.token,key()).status);
  String documentKey=key();var initial=Map.of("type","INSURANCE","documentNumber","OLD","notes","first");
  var created=request("POST",base,initial,owner.token,documentKey);assertEquals(200,created.status);
  assertEquals(created.json.get("id"),request("POST",base,initial,owner.token,documentKey).json.get("id"));
  String id=created.json.get("id").asString(),first=created.json.get("versionId").asString(),detail=path(owner,"/documents/"+id);
  assertEquals("MISSING_EXPIRY",created.json.get("status").asString());
  assertEquals(1,request("GET",base+"/duplicates?type=INSURANCE",null,owner.token,null).json.size());
  assertEquals(1,request("GET",path(owner,"/documents/incomplete"),null,owner.token,null).json.size());
  assertEquals(404,request("GET",path(other,"/documents/"+id),null,other.token,null).status);
  var edited=request("PUT",detail,Map.of("expectedVersionId",first,"type","INSURANCE","documentNumber","EDIT","issueDate","2026-10-01","expiryDate","2026-10-20"),owner.token,null);assertEquals(200,edited.status);assertEquals("EDIT",edited.json.get("documentNumber").asString());assertEquals("EXPIRING_SOON",edited.json.get("status").asString());
  assertEquals("2026-10-01",edited.json.get("issueDate").asString());assertEquals("2026-10-20",edited.json.get("expiryDate").asString());
  var second=request("POST",detail+"/renewals",Map.of("expectedVersionId",first,"expiryDate","2027-01-01","documentNumber","NEW"),owner.token,null);assertEquals(200,second.status);
  String next=second.json.get("versionId").asString();assertNotEquals(first,next);assertEquals(2,request("GET",detail+"/versions",null,owner.token,null).json.size());
  assertEquals("PREVIOUS_VERSION",request("GET",detail+"/versions/"+first,null,owner.token,null).json.get("status").asString());
  assertEquals(409,request("POST",detail+"/renewals",Map.of("expectedVersionId",first,"expiryDate","2028-01-01"),owner.token,null).status);
  assertEquals(409,request("PUT",detail,Map.of("expectedVersionId",first,"type","INSURANCE","documentNumber","STALE"),owner.token,null).status);
  assertEquals("NEW",request("GET",detail,null,owner.token,null).json.get("documentNumber").asString());
  assertEquals(409,request("PUT",detail,Map.of("expectedVersionId",next,"type","REGISTRATION"),owner.token,null).status);
  assertEquals(400,request("POST",detail+"/renewals",Map.of("expectedVersionId",next),owner.token,null).status);
  assertEquals(200,request("POST",detail+"/archive",Map.of("reason","replaced"),owner.token,null).status);
  assertEquals(0,request("GET",base,null,owner.token,null).json.size());
  assertEquals(1,request("GET",base+"?archived=true",null,owner.token,null).json.size());
  assertEquals(200,request("POST",path(owner,"/equipment/"+eq+"/archive"),null,owner.token,null).status);
  assertEquals(409,request("POST",detail+"/restore",null,owner.token,null).status);
  assertEquals(200,request("POST",path(owner,"/equipment/"+eq+"/restore"),null,owner.token,null).status);
  assertEquals(200,request("POST",detail+"/restore",null,owner.token,null).status);
  assertEquals(1,request("GET",base,null,owner.token,null).json.size());
  assertEquals(1,db.queryForObject("select count(*) from audit_event where action='DOCUMENT_RENEWED' and resource_id=?",Integer.class,UUID.fromString(id)));
 }
 @Test void concurrentDocumentRenewalAndVersionAttachments() throws Exception {
  User user=login("0500000001");String eq=equipment(user),base=path(user,"/equipment/"+eq+"/documents");
  var created=request("POST",base,Map.of("type","OTHER","customTypeName","بطاقة تشغيل","expiryDate","2026-10-01"),user.token,key());assertEquals(200,created.status);
  String id=created.json.get("id").asString(),first=created.json.get("versionId").asString(),detail=path(user,"/documents/"+id);
  byte[] bytes=image("png");String attach=detail+"/versions/"+first+"/attachments";
  var pending=request("POST",attach,Map.of("filename","old.png","mediaType","image/png","size",bytes.length),user.token,key());assertEquals(200,pending.status);
  String attachment=pending.json.get("id").asString();assertEquals(200,raw("PUT",path(user,"/attachments/"+attachment+"/content"),bytes,"image/png",user.token,null,Map.of()).status);
  var body=Map.of("expectedVersionId",first,"expiryDate","2027-01-01");
  try(var pool=Executors.newVirtualThreadPerTaskExecutor()) {
   var a=pool.submit(()->request("POST",detail+"/renewals",body,user.token,null));var b=pool.submit(()->request("POST",detail+"/renewals",body,user.token,null));assertEquals(Set.of(200,409),Set.of(a.get().status,b.get().status));
  }
  assertEquals(2,db.queryForObject("select count(*) from document_version where document_id=?",Integer.class,UUID.fromString(id)));
  String next=request("GET",detail,null,user.token,null).json.get("versionId").asString();
  assertEquals(1,request("GET",attach,null,user.token,null).json.size());
  assertEquals(0,request("GET",detail+"/versions/"+next+"/attachments",null,user.token,null).json.size());
  assertEquals(409,request("POST",attach,Map.of("filename","late.png","mediaType","image/png","size",bytes.length),user.token,key()).status);
  assertArrayEquals(bytes,request("GET",path(user,"/attachments/"+attachment+"/content"),null,user.token,null).raw.body());
  User other=login("0500000002");assertEquals(404,request("GET",path(other,"/attachments/"+attachment+"/content"),null,other.token,null).status);
 }
 @Test void documentStatusUsesFixedWorkspaceDate() {
  var day=java.time.LocalDate.of(2026,9,25);
  assertEquals("VALID",com.equipment.documents.DocumentService.status(day.plusDays(31),day,false,false));
  assertEquals("EXPIRING_SOON",com.equipment.documents.DocumentService.status(day.plusDays(30),day,false,false));
  assertEquals("EXPIRING_SOON",com.equipment.documents.DocumentService.status(day.plusDays(7),day,false,false));
  assertEquals("EXPIRING_SOON",com.equipment.documents.DocumentService.status(day.plusDays(1),day,false,false));
  assertEquals("EXPIRES_TODAY",com.equipment.documents.DocumentService.status(day,day,false,false));
  assertEquals("EXPIRED",com.equipment.documents.DocumentService.status(day.minusDays(1),day,false,false));
  assertEquals("MISSING_EXPIRY",com.equipment.documents.DocumentService.status(null,day,false,false));
  assertEquals("PREVIOUS_VERSION",com.equipment.documents.DocumentService.status(day,day,false,true));
  assertEquals("ARCHIVED",com.equipment.documents.DocumentService.status(day,day,true,false));
 }

 @Test void documentAttentionAndCurrentStateNotificationStayIndependent() throws Exception {
  User owner=login("0500000001"),other=login("0500000002");String eq=equipment(owner),base=path(owner,"/equipment/"+eq+"/documents");
  var urgent=request("POST",base,Map.of("type","INSURANCE","expiryDate","2026-09-30"),owner.token,key());assertEquals(200,urgent.status);
  String id=urgent.json.get("id").asString(),detail=path(owner,"/documents/"+id);
  assertEquals(1,request("GET",path(owner,"/attention/documents"),null,owner.token,null).json.size());
  var list=request("GET",path(owner,"/notifications"),null,owner.token,null);assertEquals(1,list.json.get("total").asInt());
  assertEquals("DOCUMENT_CURRENT_STATE",list.json.get("items").get(0).get("type").asString());
  assertEquals("DOCUMENT_EXPIRY",list.json.get("items").get(0).get("templateKey").asString());
  assertEquals("INSURANCE",list.json.get("items").get(0).get("params").get("documentType").asString());
  assertEquals(5,list.json.get("items").get(0).get("params").get("daysRemaining").asInt());
  assertEquals(id,list.json.get("items").get(0).get("entityId").asString());
  String notification=list.json.get("items").get(0).get("id").asString();
  assertEquals(1,request("GET",path(owner,"/notifications/unread-count"),null,owner.token,null).json.get("unreadCount").asInt());
  assertEquals(404,request("POST",path(other,"/notifications/"+notification+"/read"),null,other.token,null).status);
  assertEquals(200,request("POST",path(owner,"/notifications/"+notification+"/read"),null,owner.token,null).status);
  assertEquals(0,request("GET",path(owner,"/notifications/unread-count"),null,owner.token,null).json.get("unreadCount").asInt());
  assertEquals(1,request("GET",path(owner,"/attention/documents"),null,owner.token,null).json.size());
  assertEquals(404,request("GET",path(other,"/attention/documents?equipmentId="+eq),null,other.token,null).status);
  assertEquals(0,request("GET",path(other,"/notifications"),null,other.token,null).json.get("total").asInt());
  assertEquals(200,request("POST",detail+"/archive",Map.of(),owner.token,null).status);
  assertEquals(0,request("GET",path(owner,"/attention/documents"),null,owner.token,null).json.size());
  assertEquals(1,request("GET",path(owner,"/notifications"),null,owner.token,null).json.get("total").asInt());
  assertEquals(200,request("POST",detail+"/restore",null,owner.token,null).status);
  assertEquals(1,request("GET",path(owner,"/attention/documents"),null,owner.token,null).json.size());
  assertEquals(1,request("GET",path(owner,"/notifications"),null,owner.token,null).json.get("total").asInt());
  assertEquals(200,request("PUT",detail,Map.of("expectedVersionId",urgent.json.get("versionId").asString(),"type","INSURANCE","expiryDate","2027-01-01"),owner.token,null).status);
  assertEquals(0,request("GET",path(owner,"/attention/documents"),null,owner.token,null).json.size());
  assertEquals(1,request("GET",path(owner,"/notifications"),null,owner.token,null).json.get("total").asInt());
  assertEquals(200,request("PUT",detail,Map.of("expectedVersionId",urgent.json.get("versionId").asString(),"type","INSURANCE","expiryDate","2026-09-27"),owner.token,null).status);
  assertEquals(2,request("GET",path(owner,"/notifications"),null,owner.token,null).json.get("total").asInt());
  assertEquals(1,request("POST",path(owner,"/notifications/read-all"),null,owner.token,null).json.get("markedRead").asInt());
  assertEquals(1,request("GET",path(owner,"/attention/documents"),null,owner.token,null).json.size());
 }
 @Test void documentReminderThresholdsDeduplicateAndWeeklyExpiredAggregate() throws Exception {
  User owner=login("0500000001"),other=login("0500000002");String eq=equipment(owner),base=path(owner,"/equipment/"+eq+"/documents");
  String first=request("POST",base,Map.of("type","REGISTRATION","expiryDate","2026-12-01"),owner.token,key()).json.get("id").asString();
  String second=request("POST",base,Map.of("type","INSURANCE","expiryDate","2026-12-01"),owner.token,key()).json.get("id").asString();
  assertEquals(0,request("GET",path(owner,"/notifications"),null,owner.token,null).json.get("total").asInt());
  var expiry=java.time.LocalDate.of(2026,12,1);
  assertEquals(2,notifications.runDaily(expiry.minusDays(30)));
  assertEquals(0,notifications.runDaily(expiry.minusDays(30)));
  assertEquals(0,notifications.runDaily(expiry.minusDays(29)));
  assertEquals(2,notifications.runDaily(expiry.minusDays(7)));
  assertEquals(0,notifications.runDaily(expiry.minusDays(6)));
  assertEquals(2,notifications.runDaily(expiry.minusDays(1)));
  assertEquals(2,notifications.runDaily(expiry));
  assertEquals(0,notifications.runDaily(expiry));
  var sunday=java.time.LocalDate.of(2026,12,6);assertEquals(java.time.DayOfWeek.SUNDAY,sunday.getDayOfWeek());
  assertEquals(1,notifications.runWeekly(sunday));assertEquals(0,notifications.runWeekly(sunday));
  var items=request("GET",path(owner,"/notifications"),null,owner.token,null).json.get("items");assertEquals(9,items.size());
  assertEquals("DOCUMENT_EXPIRED_WEEKLY",items.get(0).get("type").asString());
  assertEquals("DOCUMENT_EXPIRED_WEEKLY",items.get(0).get("templateKey").asString());
  assertEquals(2,items.get(0).get("params").get("count").asInt());
  assertEquals("DOCUMENT_SUMMARY",items.get(0).get("entityType").asString());
  assertTrue(items.get(0).get("body").asString().contains("2"));
  assertEquals(0,request("GET",path(other,"/notifications"),null,other.token,null).json.get("total").asInt());
  request("POST",path(owner,"/documents/"+first+"/archive"),Map.of(),owner.token,null);
  assertEquals(0,notifications.runWeekly(sunday));
  assertEquals(0,notifications.runDaily(expiry));
  assertEquals(9,request("GET",path(owner,"/notifications"),null,owner.token,null).json.get("total").asInt());
 }
 @Test void missedThresholdUsesOneCurrentStateAndNoHistoricalBackfill() throws Exception {
  User owner=login("0500000001");String eq=equipment(owner);String id=request("POST",path(owner,"/equipment/"+eq+"/documents"),Map.of("type","LICENSE_PERMIT","expiryDate","2027-01-01"),owner.token,key()).json.get("id").asString();
  var expiry=java.time.LocalDate.of(2027,1,1);
  assertEquals(1,notifications.runDaily(expiry.minusDays(6)));
  assertEquals(0,notifications.runDaily(expiry.minusDays(5)));
  assertEquals(0,db.queryForObject("select count(*) from notification where type='DOCUMENT_7D'",Integer.class));
  assertEquals(1,notifications.runDaily(expiry.minusDays(1)));
  request("POST",path(owner,"/equipment/"+eq+"/archive"),null,owner.token,null);
  assertEquals(0,notifications.runDaily(expiry));
  assertEquals(0,request("GET",path(owner,"/attention/documents"),null,owner.token,null).json.size());
  assertEquals(2,request("GET",path(owner,"/notifications"),null,owner.token,null).json.get("total").asInt());
  request("POST",path(owner,"/equipment/"+eq+"/restore"),null,owner.token,null);
  assertEquals(0,request("GET",path(owner,"/attention/documents"),null,owner.token,null).json.size());
 }

 @Test void missingExpiryNeverNotifiesAndRenewalStopsOldVersionReminders() throws Exception {
  User owner=login("0500000001");String eq=equipment(owner),base=path(owner,"/equipment/"+eq+"/documents");
  var missing=request("POST",base,Map.of("type","OTHER","customTypeName","سجل اختبار"),owner.token,key());assertEquals(200,missing.status);
  assertEquals("MISSING_EXPIRY",missing.json.get("status").asString());
  assertEquals(1,request("GET",path(owner,"/documents/incomplete"),null,owner.token,null).json.size());
  assertEquals(0,notifications.runDaily(java.time.LocalDate.of(2026,9,25)));
  assertEquals(0,request("GET",path(owner,"/notifications"),null,owner.token,null).json.get("total").asInt());
  var created=request("POST",base,Map.of("type","INSURANCE","expiryDate","2027-01-01"),owner.token,key());
  String id=created.json.get("id").asString(),version=created.json.get("versionId").asString(),detail=path(owner,"/documents/"+id);
  var renewed=request("POST",detail+"/renewals",Map.of("expectedVersionId",version,"expiryDate","2027-02-01"),owner.token,null);assertEquals(200,renewed.status);
  assertEquals(0,notifications.runDaily(java.time.LocalDate.of(2026,12,2)));
  assertEquals(1,notifications.runDaily(java.time.LocalDate.of(2027,1,2)));
  assertEquals(0,notifications.runDaily(java.time.LocalDate.of(2027,1,2)));
  assertEquals(1,request("GET",path(owner,"/notifications"),null,owner.token,null).json.get("total").asInt());
  assertEquals(0,db.queryForObject("select count(*) from notification where dedupe_key like ?",Integer.class,"%"+version+"%"));
 }
}
