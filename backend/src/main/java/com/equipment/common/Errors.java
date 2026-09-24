package com.equipment.common;

import java.util.Map;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.bind.MissingRequestHeaderException;

@RestControllerAdvice
public class Errors {
    @ExceptionHandler(ApiException.class)
    ResponseEntity<?> domain(ApiException e) { return ResponseEntity.status(e.status()).body(Map.of("code", e.code(), "message", e.getMessage())); }
    @ExceptionHandler({HttpMessageNotReadableException.class, MethodArgumentTypeMismatchException.class, MissingRequestHeaderException.class})
    ResponseEntity<?> malformed(Exception e) { return domain(ApiException.invalid("راجع البيانات المطلوبة وأعد المحاولة")); }
    @ExceptionHandler(MaxUploadSizeExceededException.class)
    ResponseEntity<?> tooLarge(Exception e) { return domain(new ApiException(413, "FILE_TOO_LARGE", "اختر ملفًا لا يتجاوز 10 ميغابايت")); }
}
