# دليل تسليم M0/M1 المحلي — 2026-09-24

النتيجة: الشريحة الأولى تعمل محليًا بواجهة Flutter وباك إند وقاعدة PostgreSQL حقيقيين. لا يعني ذلك اكتمال V1 أو جاهزية الإنتاج. لم تبدأ M2. البيانات والأرقام والفاتورة اصطناعية بالكامل.

## الأوامر المنفذة والنتائج

الأوامر من الجذر ما لم يُذكر خلافه؛ إصدار Java المستخدم 21.0.7 وFlutter 3.47.2، والتفاصيل في ENVIRONMENT.md.

| الأمر / منفذه | النتيجة الفعلية |
|---|---|
| `docker compose -f infra/compose.yaml --profile test up -d --wait` — القائد | PASS؛ PostgreSQL 17.11 dev/test، منفذا loopback 55432/55433 |
| Maven compile + تشغيل Spring Boot dev — الكاتب | PASS؛ Flyway V1 على قاعدة جديدة، دون H2 |
| `JAVA_HOME=/Users/muath/Library/Java/JavaVirtualMachines/ms-21.0.7/Contents/Home MAVEN_USER_HOME=../.local/maven-user ./mvnw -B -ntp -Dmaven.repo.local=../.local/m2 test` من backend — الكاتب | PASS: 12 اختبارًا، 0 فشل/خطأ/تجاهل؛ أحدث تقرير 2.800 s |
| `flutter analyze` من app — الكاتب | PASS، No issues found؛ شمل integration_test في آخر تشغيل |
| `flutter test` من app — الكاتب | PASS: 7 اختبارات unit/widget؛ ليست دليل HTTP حي بمفردها |
| `flutter build web --release --dart-define=API_BASE_URL=http://127.0.0.1:8080/api/v1` من app — الكاتب | PASS؛ البناء الأخير بعد إصلاح الاحتفاظ بمفتاح الحفظ عند 5xx |
| `python3 -m http.server 8081 --bind 127.0.0.1 --directory app/build/web` — القائد | PASS؛ خادم محلي، IAB يتصل فعليًا بـAPI |
| `flutter test integration_test/owner_flow_test.dart -d 657C142E-E597-481F-B8F9-8C07082C1D30 --dart-define=API_BASE_URL=http://127.0.0.1:8080/api/v1` من app — القائد | PASS: اختبار واحد على iPhone 17 Pro/iOS 26.5؛ Xcode build 19.6 s، test 9 s |
| `docker compose -f infra/compose.yaml restart postgres` ثم `docker compose -f infra/compose.yaml up -d --wait postgres` — القائد | PASS؛ نفس المساحة/المعدة/العملية/الدفعة/بصمة الملف بعد restart |
| إيقاف Maven القديم من جلسة الكاتب ثم `JAVA_HOME=/Users/muath/Library/Java/JavaVirtualMachines/ms-21.0.7/Contents/Home ./scripts/backend-dev.sh` — القائد | PASS؛ PID جديد، validation migration V1، استرجاع السجل والملف من الويب بعد reload |
| `bash -n` للسكربتات الثلاثة + Ruby Psych parse وlocal `$ref` لعقد OpenAPI — الكاتب | PASS؛ 11 مسارًا؛ ليس semantic OpenAPI validator |
| `git diff --check` — القائد | PASS |

تقرير backend: `backend/target/surefire-reports/com.equipment.OwnerSliceTest.txt` (ناتج مولد غير مضاف إلى Git). لا توجد اختبارات فاشلة أو متجاهلة في آخر تشغيل للمجموعات الثلاث: **20 اختبارًا آليًا ناجحًا**.

## التحقق الحي

- القائد: 25 assertion HTTP حقيقية، ثم خمس حالات cookie/CSRF/CORS. التفاصيل في API_MANUAL_CHECKS.md. تشمل six concurrent retries، exact amount، رفض الوصول غير المخول، إعادة الرفع، bytes round-trip وإبطال الجلسة. مراجعة API تعزل user 2 عن user 1.
- المتصفح: دخول user 1 بالرقم التجريبي، الاسم مرة واحدة، مساحة تلقائية فارغة، إنشاء «قلاب ١» بموديل «2021» ومرجع `EQ-000003`. لم تُطلب شركة أو محاسب أو لوحة أو GPS.
- إنشاء مصروف وقود بإدخال `٣٥٠٫٠٠`: إجمالي 350.00، مدفوع 350.00، متبقٍ 0.00 ودفعة واحدة. اختيار الملف الفعلي من المتصفح ورفعه أظهر READY؛ عرضه داخل التطبيق نجح.
- فتح السجل العام من شريط تنقل الهاتف أظهر المصروف نفسه مرة واحدة؛ فتحه أعاد التفاصيل والمرفق. لقطة `web-ledger-mobile.png`.
- بعد reload ثم إعادة تشغيل API: الجلسة بقيت، واستُرجعت المعدة وعملية واحدة وملفها وعُرضت الصورة مجددًا. بعد إعادة PostgreSQL سابقًا استُرجعت سجلات user 2 وبصمة الملف نفسها.
- عرض الويب اختُبر عند 1280×900 و390×844؛ هذه تجربة متصفح وليست جهازًا أصليًا.
- اختبار iOS: API/PostgreSQL وKeychain حقيقية، نماذج Flutter للمعدة والمصروف، مرفق فعلي وbytes round-trip، استعادة جلسة ثم إعادة بناء واجهة التطبيق. منتقي الملف الأصلي استُبدل بحقن fixture في الاختبار، ولم يُدَّع اختبار واجهة منتقي الملفات أو PDF الأصلي. إدخال OTP في واجهة iOS نفسها NOT RUN؛ API auth فعلي وواجهة OTP اختُبرت على الويب.

لقطات فعلية في `screenshots/`: login/empty desktop، expense desktop/mobile، receipt desktop، receipt mobile after restart. ليست mockups.

## الإخفاقات التي حدثت ثم عولجت

- فحص staged diff كشف CRLF القياسي في Maven Windows wrapper كمسافات زائدة؛ أضيفت قاعدة `.gitattributes` محلية تحفظه CRLF عند checkout وLF في Git. لا تغيير لإعدادات Git العامة. أعيد فحص staged diff.
- Sandbox منع تنزيل Maven/كتابة Flutter cache أو الوصول إلى Docker/CoreSimulator/localhost أولًا. أُعيدت الأوامر باستخدام آلية الموافقات الفعلية؛ لم تُغيَّر إعدادات الأمان أو الجهاز العامة.
- عدم توافق استدعاء PDFBox أثناء أول compile عولج ثم البناء PASS. المراجع وجد PDF action متداخلًا؛ أضيف traversal شامل وregression PASS.
- أول harness لرفض CORS افترض JSON بينما Spring يعيد plain-text 403. صُحح parser بحسب Content-Type ثم PASS؛ الاستثناء موثق في API contract.
- اختبار Flutter للحفظ غير المؤكد أخفق بسبب lazy scrolling/focus/hit-test في harness؛ سُجل بعد ثلاث محاولات ثم صُحح viewport/focus دون حذف assertions. جميع 7 اختبارات مرت؛ تشمل تكرار نفس key/payload عند timeout ثم 503.
- اختبار iOS الأول أخفق في آخر assertion عند إعادة إنشاء Widget بنفس key فأعاد Flutter state القديم. صُحح مفتاح الجذر لا قواعد القبول؛ الإعادة PASS.
- أثناء إدخال CUA سريع كتبت أداة الإدخال `21` بدل `2021` دون تحقق مسبق. بقي السجل التجريبي EQ-000002 محفوظًا؛ أُعيد الاختبار بـfill مع قراءة قيمة الحقل قبل الحفظ فحُفظ 2021 صحيحًا. لا حذف أو تعديل بيانات قديمة، وليس ادعاء خلل في تخزين الموديل.

## المراجعات والحدود

كاتب واحد `/root/implement`؛ مراجع مصدر مستقل `/root/review`؛ مراجع UX مستقل `/root/ux`؛ القائد تولى البيئة وHTTP/CUA والأدلة وGit. المراجعون لم يشغّلوا الاختبارات. النتائج والإصلاحات في reviews/M1_REVIEW.md. لا finding مانع مفتوح؛ بقي P2 لاتجاه عرض تاريخ الدفعة داخل النص العربي.

كل agents ورثت إعدادات الجلسة بلا override. اسم النموذج الدقيق ومستوى reasoning غير متاحين في استجابات الأدوات؛ لا نفترض مطابقتهما لترشيحات ملفات .codex. تم التحقق من CLI الفعلي ودعم الأدوار، ولم تتغير إعدادات عامة أو .codex.

NOT RUN / غير منفذ: Android native (cmdline-tools ناقصة وترخيص غير متحقق)، أجهزة فعلية، توقيع/متاجر، منتقي الملفات/PDF native، S3، malware scanner، SMS حقيقي، release TLS، staging/deploy، backup/restore drill، وأجزاء V1 بعد M1. المصدر Android موجود لكنه ليس إثبات نجاح بناءه. التخزين المحلي DEV_NOT_SCANNED بديل معلن، لا تكامل إنتاج.

المهمة التالية الموصى بها فقط، دون بدئها: M2، أولًا أصل مالي جزئي/غير مدفوع وتسويات متعددة مؤرخة مع اختبارات الرصيد وعدم التكرار، ثم استكمال التخزين الخاص حسب نطاق M2. أصلح اتجاه التاريخ ضمن تلك المهمة. لا حاجة لقرارات جديدة لتجربة M1 المحلية.
