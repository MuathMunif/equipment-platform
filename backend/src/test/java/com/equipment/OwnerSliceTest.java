package com.equipment;

import com.equipment.common.DevelopmentBoundary;
import com.equipment.attachments.ContentValidator;
import java.awt.image.BufferedImage;
import java.io.*;
import java.net.*;
import java.net.http.*;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.*;
import java.util.concurrent.*;
import javax.imageio.ImageIO;
import org.apache.pdfbox.pdmodel.*;
import org.apache.pdfbox.pdmodel.interactive.annotation.PDAnnotationLink;
import org.apache.pdfbox.cos.*;
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.mock.env.MockEnvironment;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

@SpringBootTest(webEnvironment=SpringBootTest.WebEnvironment.RANDOM_PORT, properties={
 "spring.datasource.url=jdbc:postgresql://127.0.0.1:55433/equipment_test",
 "spring.datasource.username=equipment_test","spring.datasource.password=isolated-test-only"})
@ActiveProfiles({"dev","test"})
class OwnerSliceTest {
 @LocalServerPort int port; @Autowired JdbcTemplate db; @Autowired ContentValidator validator;
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
   var edit=new HashMap<String,Object>();edit.put("amount","2500.00");edit.put("operationDate","2026-09-05");edit.put("note","تصحيح موثق");edit.put("partyName","طرف ثان");edit.put("dueDate","2026-10-15");if(type.equals("EXPENSE"))edit.put("category","MAINTENANCE");
   var updated=request("PUT",path(user,"/entries/"+id),edit,user.token,null);assertEquals(200,updated.status);assertEquals("1500.00",updated.json.get("remaining").asString());assertEquals("PARTIAL",updated.json.get("settlementStatus").asString());assertEquals("2026-09-05",updated.json.get("operationDate").asString());assertEquals(firstSettlement,updated.json.get("settlements").get(0).get("id").asString());
   assertEquals(400,request("PUT",path(user,"/entries/"+id),Map.of("amount","500.00","operationDate","2026-09-05","partyName","طرف ثان","category",type.equals("EXPENSE")?"MAINTENANCE":"OTHER"),user.token,null).status);
   assertEquals(400,request("PUT",path(user,"/entries/"+id),Map.of("amount","1000.00","operationDate","2026-09-05","dueDate","2026-10-15","category",type.equals("EXPENSE")?"MAINTENANCE":"OTHER"),user.token,null).status);
   assertEquals(1,db.queryForObject("select count(*) from settlement where entry_id=?",Integer.class,UUID.fromString(id)));
   var audit=db.queryForMap("select metadata,actor_id from audit_event where resource_id=? and action=?",UUID.fromString(id),type.equals("INCOME")?"INCOME_EDITED":"EXPENSE_EDITED");assertEquals(UUID.fromString(user.user),audit.get("actor_id"));String metadata=audit.get("metadata").toString();assertTrue(metadata.contains("3000.00"));assertTrue(metadata.contains("2500.00"));
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
 @Test void cancelledIncomeKeepsCollectionHistoryAndRejectsAnotherCollection()throws Exception{
  User user=login("0500000001");String eq=equipment(user);var body=Map.of("equipmentId",eq,"entryType","INCOME","amount","500.00","operationDate","2026-09-01","paymentStatus","PARTIAL","initialPaid","200.00","paidOn","2026-09-20","partyName","عميل");
  String id=request("POST",path(user,"/entries"),body,user.token,key()).json.get("id").asString();String url=path(user,"/entries/"+id);
  var cancelled=request("POST",url+"/cancellation",Map.of("reason","إيراد مسجل بالخطأ"),user.token,null);assertEquals(200,cancelled.status);assertEquals("INCOME",cancelled.json.get("entryType").asString());assertEquals("CANCELLED",cancelled.json.get("lifecycle").asString());assertEquals("200.00",cancelled.json.get("paid").asString());assertEquals(1,cancelled.json.get("settlements").size());
  assertEquals(400,request("POST",url+"/settlements",Map.of("amount","100.00","paidOn","2026-09-21"),user.token,key()).status);
  assertEquals(1,db.queryForObject("select count(*) from settlement where entry_id=?",Integer.class,UUID.fromString(id)));
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
  User user=login("0500000001");String eq=equipment(user),key=key();String entry=request("POST",path(user,"/entries"),expense(eq),user.token,key).json.get("id").asString();byte[] png=image("png");String file=initiate(user,entry,png,"image/png");raw("PUT",path(user,"/attachments/"+file+"/content"),png,"image/png",user.token,null,Map.of());
  db.update("update membership set active=false where user_id=?",UUID.fromString(user.user));
  assertEquals(404,request("POST",path(user,"/entries"),expense(eq),user.token,key).status);assertEquals(404,request("GET",path(user,"/attachments/"+file+"/content"),null,user.token,null).status);assertEquals(403,request("GET","/auth/me",null,user.token,null).status);
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
}
