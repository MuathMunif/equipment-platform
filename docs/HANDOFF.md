# حالة التسليم — M0/M1
آخر تحديث: 2026-09-24. **المهمة 001 مكتملة كشريحة محلية؛ V1 غير مكتمل. توقف التنفيذ هنا بطلب المالك، ولم تبدأ M2.**

## ما يعمل فعليًا
Flutter عربية RTL على الويب، مع اختبار تكامل على محاكي iOS، تتصل بـSpring Boot 4.1.1 وPostgreSQL 17.11 حقيقيين:
- دخول تطويري معزول، اسم للمستخدم الجديد فقط، ومساحة مالك تلقائية.
- معدة بالاسم والموديل النصي فقط، مرجع داخلي، قائمة/بحث وتفاصيل.
- مصروف مدفوع كاملًا، أصل وتسوية ذريّان بأرقام عشرية دقيقة؛ إعادة الطلب لا تكرر المال.
- رفع فاتورة PNG/JPEG/PDF، حالة وإعادة محاولة، عرض/تنزيل محميان؛ المرفق لا يضيف مصروفًا آخر.
- تفويض مساحة العمل والعضوية من الخادم، بما في ذلك الملفات وإعادة الطلب، وإبطال الجلسة عند الخروج.
- استرجاع البيانات والمرفق بعد تحديث الصفحة وإعادة تشغيل PostgreSQL والباك إند.

التخزين الفعلي الحالي `.local/objects` بديل تطوير معلن خلف adapter؛ S3 والفحص الخبيث غير متكاملين. لا SMS حقيقي، لا نشر، لا remote، لا بيانات/مفاتيح إنتاج.

## Git والملفات
الفرع `work/m0-m1`. حُفظت الحزمة الأصلية في `8aae033`، ثم فحص البيئة `a09a869`، وcore API في `e55d96a`. التزام التسليم النهائي موجود في `git log -1 --oneline` بعد تحديث هذا الملف؛ لم تتغير هوية Git العامة ولم يُنشأ remote.

الملفات المضافة/المعدلة: `.gitattributes` لضبط سطور Windows wrapper محليًا، `backend/` (22 مصدر Java، إعدادات، Flyway V1، اختبار HTTP/PostgreSQL، Maven Wrapper)، `app/` (Flutter API/UI/tests وAndroid/iOS/web وlockfiles)، `infra/compose.yaml`، `contracts/openapi.yaml`، `scripts/`، `tests/fixtures/`، README وdocs للحالة والقرارات والأدلة والمراجعة. لم تُحذف الحزمة السابقة أو بياناتها.

## أوامر التشغيل التي جُرّبت
من `/Users/muath/Desktop/equipment-platform`:

```sh
docker compose -f infra/compose.yaml --profile test up -d --wait
JAVA_HOME=/Users/muath/Library/Java/JavaVirtualMachines/ms-21.0.7/Contents/Home ./scripts/backend-dev.sh
```

في نافذة أخرى:

```sh
cd app
flutter build web --release --dart-define=API_BASE_URL=http://127.0.0.1:8080/api/v1
python3 -m http.server 8081 --bind 127.0.0.1 --directory build/web
```

افتح `http://127.0.0.1:8081`؛ API health: `http://127.0.0.1:8080/api/v1/health`. هوية التطوير `0500000001` أو `0500000002` ورمز التطوير `123456` فقط. كلا الحسابين أصبح له بيانات اختبار محفوظة، فلا تتوقع شاشة اسم جديد. مثال الويب: «قلاب ١»، موديل 2021، EQ-000003، مصروف وقود 350.00 مع الفاتورة الاصطناعية.

## نتائج التحقق الفعلية
- PASS: **12 backend + 7 Flutter + 1 iOS integration = 20 اختبارًا آليًا**؛ آخر تشغيل بلا فشل أو تجاهل.
- PASS: Flutter analyze، web release build، Xcode simulator build، migrations، تركيب OpenAPI ومراجعه المحلية، syntax السكربتات، diff whitespace.
- PASS: 25 assertions HTTP ثم 5 cookie/CSRF/CORS، فحص restart، مسار ويب حقيقي مع منتقي ملف فعلي ولقطات 1280×900 و390×844.
- فشل سابق ثم إصلاح وإعادة ناجحة: إعداد تمرير/focus باختبار widget، إعادة استخدام Widget state في اختبار iOS، parser للرد CORS غير JSON، توافق PDFBox الأول. PDF action المتداخل الذي وجده المراجع له regression ناجح.
- NOT RUN: Android native (SDK ناقص)، أجهزة فعلية، منتقي الملفات/PDF الأصليان على iOS، إدخال OTP في واجهة iOS، S3/scanner/real SMS/production/release/backup restore. اختيار ملف iOS محقون في الاختبار؛ الرفع وKeychain وAPI حقيقية.

التفاصيل الدقيقة والأوامر والمحدوديات: [M1_ACCEPTANCE](evidence/M1_ACCEPTANCE.md)، [API checks](evidence/API_MANUAL_CHECKS.md)، [ENVIRONMENT](ENVIRONMENT.md). اختبارات V1 الكاملة في acceptance catalog لم تُدَّع ناجحة.

## المراجعة المستقلة
استخدم كاتبًا واحدًا `/root/implement`، ومراجع مصدر مستقل `/root/review`، ومراجع UX مستقل `/root/ux`. القائد نفذ البيئة والتجارب الحية ووثق الأدلة. المراجعون قراءة فقط؛ لم يشغلوا اختبارات. راجعوا حدود الإنتاج والعزل والمال والملفات والفلو واللقطات، وأُصلحت الملاحظات المانعة. التفصيل في [M1_REVIEW](reviews/M1_REVIEW.md).

عيب معروف غير مانع P2: تاريخ الدفعة داخل الجملة العربية يظهر باتجاه بصري مختلف عن تاريخ العنوان؛ البيانات المخزنة صحيحة. يوصى بعزل التاريخ LTR عند المتابعة. مراجعة مستقلة إضافية للتعديلين الأخيرين (رفض amount كـJSON number والاحتفاظ بمفتاح الحفظ عند 5xx) تعذرت بحد threads؛ اختبارات الكاتب لهما نجحت.

إعدادات agents ورثت الجلسة بلا model/reasoning overrides. النسخة الدقيقة ومستوى reasoning غير مكشوفين في الأدوات؛ لا يُستنتجان من ملفات الدور. CLI 0.155.0-alpha.16.3 ودعم multi_agent والأدوار فُحص فعليًا؛ لا تعديل .codex أو إعدادات جهاز عامة.

## الموارد المحلية عند التسليم
- PostgreSQL dev/test healthy ضمن مشروع compose `equipment-platform-dev`، تخزين دائم منفصل ومنافذ loopback 55432/55433.
- API المحلي أعيد تشغيله بالسكريبت: session 6179، Java PID 17801 وقت التحقق. الويب session 59077 على 8081. تحقق من health قبل الاعتماد على بقاء عملية طرفية لاحقًا.
- iPhone 17 Pro/iOS 26.5 simulator تم تشغيله؛ اختبار التكامل انتهى. لا اختبار يجري بالخلفية.
- لإيقاف الخدمات دون فقد البيانات: Ctrl+C لعمليتي API/web؛ `docker compose -f infra/compose.yaml stop`. لا تستخدم `down -v`. لا reset لقاعدة التطوير؛ الاختبارات تنظف قاعدتها المعزولة فقط.

## التالي — توصية فقط
عند تكليف جديد: M2، ابدأ بمهمة محدودة لإنشاء أصل جزئي/غير مدفوع وتسويات متعددة مؤرخة، مع اختبارات الرصيد وعدم تكرار الأصل؛ ثم أكمل مهام M2 والتخزين الخاص بالترتيب. قرارات OPEN_QUESTIONS لم تُحسم خفية. لا عمل أو مراقبة مستمرة بعد انتهاء هذه الجولة.
