package com.equipment.common;

import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.LocalDate;
import java.util.HexFormat;
import java.util.Base64;
import java.util.Objects;

public final class Values {
    private Values() {}
    private static final SecureRandom RANDOM = new SecureRandom();
    public static String text(String value, int max, String label) {
        if (value == null || value.isBlank() || value.trim().length() > max) throw ApiException.invalid("راجع " + label);
        return value.trim();
    }
    public static String note(String value) {
        if (value == null) return "";
        if(value.length()>1000) throw ApiException.invalid("الملاحظة لا تتجاوز 1000 حرف");
        return value.trim();
    }
    public static BigDecimal money(String value) {
        if(value==null || !value.matches("(?:0|[1-9][0-9]{0,8})\\.[0-9]{2}")) throw ApiException.invalid("اكتب المبلغ بمنزلتين عشريتين، مثل 350.00");
        BigDecimal amount = new BigDecimal(value);
        if(amount.signum()<=0) throw ApiException.invalid("اكتب مبلغًا أكبر من صفر");
        return amount;
    }
    public static LocalDate date(String value) {
        try { if(value == null || !value.matches("[0-9]{4}-[0-9]{2}-[0-9]{2}")) throw new IllegalArgumentException(); return LocalDate.parse(value); }
        catch (Exception e) { throw ApiException.invalid("اختر تاريخًا ميلاديًا صحيحًا"); }
    }
    public static String hash(String value) { return hash(value.getBytes(StandardCharsets.UTF_8)); }
    public static String payload(Object... parts) {
        StringBuilder framed=new StringBuilder();
        for(Object part:parts) { String value=Objects.toString(part,""); framed.append(value.length()).append(':').append(value); }
        return framed.toString();
    }
    public static String hash(byte[] bytes) {
        try { return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(bytes)); }
        catch (Exception e) { throw new IllegalStateException(e); }
    }
    public static String token() { byte[] bytes=new byte[32]; RANDOM.nextBytes(bytes); return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes); }
}
