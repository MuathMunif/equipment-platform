package com.equipment.attachments;

import com.equipment.common.ApiException;
import java.io.*;
import java.util.*;
import javax.imageio.ImageIO;
import org.apache.pdfbox.Loader;
import org.springframework.stereotype.Component;

@Component
public class ContentValidator {
    public static final int MAX_BYTES=10*1024*1024;
    public static final Set<String> TYPES=Set.of("image/png","image/jpeg","application/pdf");
    public String validate(byte[] bytes,String declared) {
        if(bytes.length==0 || bytes.length>MAX_BYTES) throw new ApiException(413,"FILE_TOO_LARGE","اختر ملفًا لا يتجاوز 10 ميغابايت");
        try {
            if(bytes.length>=5 && new String(bytes,0,5,java.nio.charset.StandardCharsets.US_ASCII).equals("%PDF-")) {
                if(!declared.equals("application/pdf")) throw invalid();
                try(var document=Loader.loadPDF(bytes)) {
                    if(document.isEncrypted() || document.getNumberOfPages()==0 || document.getNumberOfPages()>100) throw invalid();
                    // Active content is rejected in addition to parsing. This is not a malware scanner.
                    var queue=new ArrayDeque<org.apache.pdfbox.cos.COSBase>();
                    var seen=Collections.newSetFromMap(new IdentityHashMap<org.apache.pdfbox.cos.COSBase,Boolean>());
                    queue.add(document.getDocument().getTrailer());
                    while(!queue.isEmpty()) {
                        var object=queue.removeFirst(); if(!seen.add(object)) continue;
                        if(seen.size()>100000) throw invalid();
                        if(object instanceof org.apache.pdfbox.cos.COSObject indirect) { if(indirect.getObject()!=null) queue.add(indirect.getObject()); }
                        if(object instanceof org.apache.pdfbox.cos.COSArray array) for(var item:array) if(item!=null) queue.add(item);
                        if(object instanceof org.apache.pdfbox.cos.COSDictionary dict) {
                            for(String key:List.of("JS","JavaScript","AA","OpenAction","EmbeddedFiles","XFA","Launch","RichMedia"))
                                if(dict.containsKey(org.apache.pdfbox.cos.COSName.getPDFName(key))) throw invalid();
                            String action=dict.getNameAsString(org.apache.pdfbox.cos.COSName.S);
                            if(Set.of("JavaScript","Launch","GoToR","SubmitForm","ImportData").contains(action==null?"":action)) throw invalid();
                            for(var value:dict.getValues()) if(value!=null) queue.add(value);
                        }
                    }
                    return "application/pdf";
                }
            }
            try(var input=ImageIO.createImageInputStream(new ByteArrayInputStream(bytes))) {
                var readers=ImageIO.getImageReaders(input); if(!readers.hasNext()) throw invalid(); var reader=readers.next();
                try {
                    reader.setInput(input); String format=reader.getFormatName().toLowerCase(Locale.ROOT);
                    String actual=switch(format) { case "png" -> "image/png"; case "jpeg","jpg" -> "image/jpeg"; default -> throw invalid(); };
                    int width=reader.getWidth(0),height=reader.getHeight(0);
                    if(!actual.equals(declared) || width<=0 || height<=0 || width>10000 || height>10000 || (long)width*height>25000000) throw invalid();
                    if(reader.read(0)==null) throw invalid(); return actual;
                } finally { reader.dispose(); }
            }
        } catch(ApiException e) { throw e; } catch(Exception e) { throw invalid(); }
    }
    private ApiException invalid() { return new ApiException(400,"UNSUPPORTED_FILE","تعذر قراءة الملف؛ اختر صورة PNG أو JPEG سليمة، أو PDF دون محتوى نشط"); }
}
