# صور مسار السجل — قبل/بعد

صور iOS من التطبيق الأصلي `lib/main.dart` على iPhone17Pro/iOS26.5، وصور الويب من التطبيق الحقيقي على8081. جميعها تستخدم API8080 وبيانات مساحة «مساحتي» القائمة؛ ليست معرض تصميم. لم تُعدّل الصور أو تُنشأ بيانات لملئها. صور harness منفصلة أدناه وتستخدم HTTP fixture.

| المدخل الفعلي | قبل | بعد |
| --- | --- | --- |
| iPhone: الرئيسية ← عرض السجل | [العطل الأسود والنمط الأحمر](before-ios-home-view-journal.png) | [المسار المصحح والحافة العلوية](after-ios-home-view-journal.png) |
| iPhone: تبويب السجل السفلي | [قبل الإصلاح](before-ios-bottom-journal.png) | [بعد الإصلاح](after-ios-bottom-journal.png) |
| Web: الرئيسية ← عرض السجل | [الوصف الأحمر المتضخم](before-web-home-view-journal.png) | [النمط الطبيعي](after-web-home-view-journal.png) |

- [Web: تبويب السجل قبل الإصلاح](before-web-bottom-journal.png).
- iPhone: [فتح تفاصيل القيد](after-ios-entry-detail.png)، [الرجوع إلى السجل](after-ios-detail-back-journal.png).
- Web: [تمرير السجل](after-web-journal-scrolled.png)، [فتح القيد](after-web-entry-detail.png)، [الرجوع إلى سياق السجل](after-web-detail-back-retains-scroll.png). اسم الصورة الأخير لا يدعي تطابقًا بكسليًا؛ التركيز في المتصفح قد يحرّك الصف، بينما اختبار widget يتحقق من offset بدقة.
- حالات root-widget مع inset علوي59 وسفلي34: [عربية1×](harness-ar-scale1.0-inset59.png)، [إنجليزية1×](harness-en-scale1.0-inset59.png)، [أردية2×](harness-ur-scale2.0-inset59.png). هذه صور اختبار Flutter مرسومة فعليًا، لا جلسات API حية أو مراجعة لغوية.

التمرير عبر أدوات التحكم بالمحاكي لم يُثبت؛ التمرير الفعلي مثبت على الويب وبالاختبار الآلي فقط. [السبب والفحوص والحدود](../FIX.md).
