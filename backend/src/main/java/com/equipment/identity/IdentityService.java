package com.equipment.identity;

import com.equipment.common.*;
import java.time.*;
import java.util.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class IdentityService {
    public static final String COOKIE = "equipment_session";
    private final JdbcTemplate db;
    private final int hours;
    public IdentityService(JdbcTemplate db, @Value("${app.session-hours:8}") int hours) { this.db=db; this.hours=hours; }
    public record Challenge(UUID challengeId, String expiresAt, int resendAfterSeconds) {}
    public record Login(boolean requiresName, String token, String csrfToken, UUID userId) {}
    private String phone(String value) {
        if(value==null) throw ApiException.invalid("اكتب رقم الجوال التجريبي");
        String normalized=value.replace(" ","").replace("-","");
        if(normalized.matches("05[0-9]{8}")) normalized="+966"+normalized.substring(1);
        if(!Set.of("+966500000001","+966500000002").contains(normalized))
            throw ApiException.invalid("بيئة التطوير تقبل الرقمين 0500000001 و0500000002 فقط");
        return normalized;
    }
    @Transactional
    public Challenge challenge(String input) {
        String phone=phone(input);
        db.queryForList("select pg_advisory_xact_lock(hashtextextended(?,0))","otp:"+phone);
        Integer recent=db.queryForObject("select count(*) from otp_challenge where phone=? and created_at>now()-interval '30 seconds'",Integer.class,phone);
        Integer hourly=db.queryForObject("select count(*) from otp_challenge where phone=? and created_at>now()-interval '1 hour'",Integer.class,phone);
        if(recent>0 || hourly>=10) throw new ApiException(429,"OTP_THROTTLED","انتظر قبل طلب رمز جديد ثم أعد المحاولة");
        // A resend invalidates earlier challenges; this never sends a real SMS.
        db.update("update otp_challenge set consumed=true where phone=? and consumed=false",phone);
        UUID id=UUID.randomUUID(); Instant expires=Instant.now().plusSeconds(300);
        db.update("insert into otp_challenge(id,phone,expires_at) values(?,?,?)",id,phone,java.sql.Timestamp.from(expires));
        return new Challenge(id,expires.toString(),30);
    }
    @Transactional(noRollbackFor=ApiException.class)
    public Login verify(UUID challengeId, String code, String name) {
        var rows=db.queryForList("select * from otp_challenge where id=? for update",challengeId);
        if(rows.isEmpty()) throw invalidOtp();
        var challenge=rows.getFirst();
        if((boolean)challenge.get("consumed") || (int)challenge.get("attempts")>=5 || ((java.sql.Timestamp)challenge.get("expires_at")).toInstant().isBefore(Instant.now())) throw invalidOtp();
        if(!"123456".equals(code)) {
            db.update("update otp_challenge set attempts=attempts+1 where id=?",challengeId);
            throw invalidOtp();
        }
        String phone=(String)challenge.get("phone");
        db.queryForList("select pg_advisory_xact_lock(hashtextextended(?,0))","owner:"+phone);
        var users=db.queryForList("select id from app_user where phone=?",phone);
        if(users.isEmpty() && (name==null || name.isBlank())) return new Login(true,null,null,null);
        UUID userId;
        if(users.isEmpty()) {
            String validName=Values.text(name,100,"الاسم");
            userId=UUID.randomUUID(); UUID workspaceId=UUID.randomUUID();
            db.update("insert into app_user(id,phone,name) values(?,?,?)",userId,phone,validName);
            db.update("insert into workspace(id,name,owner_id) values(?,?,?)",workspaceId,"مساحتي",userId);
            db.update("insert into membership(workspace_id,user_id,role) values(?,?,'OWNER')",workspaceId,userId);
        } else userId=(UUID)users.getFirst().get("id");
        db.update("update otp_challenge set consumed=true where id=?",challengeId);
        String token=Values.token(), csrf=Values.token();
        db.update("insert into app_session(token_hash,user_id,csrf_token,expires_at) values(?,?,?,?)",Values.hash(token),userId,csrf,java.sql.Timestamp.from(Instant.now().plusSeconds(hours*3600L)));
        return new Login(false,token,csrf,userId);
    }
    private ApiException invalidOtp() { return new ApiException(401,"INVALID_OTP","الرمز غير صحيح أو انتهت صلاحيته؛ راجعه أو اطلب رمزًا جديدًا"); }
    public Actor authenticate(String token) {
        if(token==null || token.length()>200) throw new ApiException(401,"SESSION_REQUIRED","سجّل الدخول للمتابعة");
        String hash=Values.hash(token);
        var rows=db.queryForList("select user_id,csrf_token from app_session where token_hash=? and expires_at>now()",hash);
        if(rows.isEmpty()) throw new ApiException(401,"SESSION_EXPIRED","انتهت جلستك؛ سجّل الدخول للمتابعة");
        return new Actor((UUID)rows.getFirst().get("user_id"),hash,(String)rows.getFirst().get("csrf_token"));
    }
    public Map<String,Object> me(Actor actor) {
        var rows=db.queryForList("select u.id,u.name,w.id as workspace_id,w.name as workspace_name from app_user u join membership m on m.user_id=u.id and m.active=true and m.role='OWNER' join workspace w on w.id=m.workspace_id where u.id=? order by w.created_at",actor.userId());
        if(rows.isEmpty()) throw new ApiException(403,"MEMBERSHIP_REQUIRED","لم تعد لديك صلاحية الوصول إلى مساحة العمل");
        var first=rows.getFirst();
        return Map.of("userId",actor.userId(),"name",first.get("name"),"csrfToken",actor.csrfToken(),"workspaces",rows.stream().map(r->Map.of("id",r.get("workspace_id"),"name",r.get("workspace_name"))).toList(),"development",true);
    }
    public void logout(Actor actor) { db.update("delete from app_session where token_hash=?",actor.sessionHash()); }
}
