package com.equipment.common;

public class ApiException extends RuntimeException {
    private final int status;
    private final String code;
    public ApiException(int status, String code, String message) { super(message); this.status = status; this.code = code; }
    public int status() { return status; }
    public String code() { return code; }
    public static ApiException missing() { return new ApiException(404, "NOT_FOUND", "تعذر العثور على السجل المطلوب"); }
    public static ApiException invalid(String message) { return new ApiException(400, "INVALID_INPUT", message); }
}
