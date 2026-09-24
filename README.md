# إدارة المعدات — أول شريحة محلية

تطبيق Flutter عربي RTL وباك إند Spring Boot وPostgreSQL فعلي. هذه شريحة M0/M1 للتطوير المحلي، وليست إصدار V1 كاملًا أو تكامل إنتاج.

المسار المنفذ: دخول تطويري ← مساحة تلقائية ← معدة بالاسم والموديل ← مصروف مدفوع كاملًا ودفعة داخل العملية ← مرفق اختياري ← الرجوع للسجل والملف بعد التحديث. لا تحتاج مؤسسة أو فريقًا. المبلغ يُنقل كنص عشري ويحسب بـBigDecimal/PostgreSQL NUMERIC؛ إضافة المرفق لا تنشئ مصروفًا أو دفعة.

## التشغيل المحلي

المتطلبات المختبرة: Java 21، Maven Wrapper 3.9.11، Docker/Compose، Flutter 3.47.2 وDart 3.13.2، Python 3 لخادم الويب. الإصدارات والقيود التفصيلية في [ENVIRONMENT](docs/ENVIRONMENT.md).

من جذر المشروع:

```sh
docker compose -f infra/compose.yaml --profile test up -d --wait
```

تعمل قاعدة التطوير على `127.0.0.1:55432` وقاعدة الاختبار المنفصلة على `127.0.0.1:55433`. بياناتهما التطويرية معلنة في Compose؛ ليست بيانات إنتاج. أسماء volumes مقيدة بمشروع `equipment-platform-dev`.

في نافذة أخرى، مع `JAVA_HOME` يشير إلى JDK 21 مثبت عندك:

```sh
./scripts/backend-dev.sh
```

الأمر المباشر الذي جُرّب على هذا الجهاز:

```sh
cd backend
JAVA_HOME=/Users/muath/Library/Java/JavaVirtualMachines/ms-21.0.7/Contents/Home \
  mvn -B -ntp -Dmaven.repo.local=../.local/m2 \
  spring-boot:run -Dspring-boot.run.profiles=dev
```

ثم من الجذر:

```sh
cd app
flutter pub get
flutter build web --release --dart-define=API_BASE_URL=http://127.0.0.1:8080/api/v1
python3 -m http.server 8081 --bind 127.0.0.1 --directory build/web
```

افتح `http://127.0.0.1:8081`. فحص API: `http://127.0.0.1:8080/api/v1/health`. يلخص سكربت `scripts/web-dev.sh` أمر البناء والخادم نفسه. لا تخلط `localhost` و`127.0.0.1` في الجلسة الواحدة.

الأرقام التجريبية الوحيدة: `0500000001` و`0500000002`، والرمز التطويري `123456`. لا يُرسل SMS. أول دخول يطلب الاسم مرة واحدة وينشئ مساحة تلقائية. الرمز صالح خمس دقائق، خمس محاولات، وطلب جديد كل 30 ثانية بحد عشرة/ساعة.

للتجربة: أضف «قلاب ١» وموديل «2021» أو «FH16»، ثم مصروف وقود `350.00`. بعد حفظه أرفق [الفاتورة الاصطناعية](tests/fixtures/synthetic-receipt.png)، وافتحها من التفاصيل. تتيح صفحة السجل الرجوع للعملية؛ صفحة المعدة تصفّي سجلها.

## الجوال

مصادر Android وiOS موجودة ضمن `app`. ملف إعداد Android debug يسمح HTTP للعناوين المحلية فقط. إعداد iOS يسمح بالشبكة المحلية للتطوير. نسخة التطبيق الحالية اسمها ومعرّفها تطويريان؛ لا توقيع متجر أو نشر.

```sh
cd app
flutter devices
flutter run -d <device-id> --dart-define=API_BASE_URL=http://127.0.0.1:8080/api/v1
```

لـAndroid Emulator استخدم `http://10.0.2.2:8080/api/v1` مع توجيه اتصال مناسب؛ الباك إند مربوط بالـloopback ولا يُنشر للشبكة. نتائج المنصات التي اختُبرت بالفعل في [HANDOFF](docs/HANDOFF.md)، ولا تعني شاشة بعرض هاتف اختبار جهاز iOS/Android.

## الاختبارات

تشغيل PostgreSQL الاختباري أولًا عبر أمر Compose أعلاه، ثم:

```sh
cd backend
JAVA_HOME=/Users/muath/Library/Java/JavaVirtualMachines/ms-21.0.7/Contents/Home \
  MAVEN_USER_HOME=../.local/maven-user ./mvnw -B -ntp \
  -Dmaven.repo.local=../.local/m2 test
```

`OwnerSliceTest` يشغل خادم HTTP حقيقيًا وقاعدة PostgreSQL الاختبارية. لا H2 أو repository mocks. الاختبارات تفرغ فقط `equipment_test` بعد تحقق صريح من URL، ولا تمس قاعدة التطوير. تغطي OTP/expiry/logout/CSRF/revocation، عزل المستأجرين، المفاتيح الخارجية المركبة، المال الدقيق، أصلًا واحدًا ودفعة واحدة تحت ستة طلبات متزامنة، الرفع المتعثر ثم إعادته، ثبات الملف، والتحقق من الصور وPDF نشط بقاموس متداخل. تقرير التنفيذ: `backend/target/surefire-reports/`.

```sh
cd app
flutter analyze
flutter test
```

اختبارات Flutter تشمل المدخلات العربية الدقيقة، العرضين الضيق والواسع، الاسم المطلوب، مهلة HTTP كاملة، بقاء مفتاح الحفظ بعد فقد الرد، واستبدال مرفق مرفوض دون إنشاء عملية مالية جديدة. اختبارات widget تستخدم HTTP doubles ولا يُقدَّم نجاحها كدليل تكامل فعلي؛ تجربة التشغيل المستقلة موثقة في handoff/evidence.

## الجلسات والملفات والحدود

- الويب: cookie باسم `equipment_session` من نوع HttpOnly/SameSite=Strict، دون localStorage. `X-CSRF-Token` لكل كتابة بجلسة cookie. CORS لعناوين التطوير المحددة فقط.
- أخطاء التطبيق تعيد `code` و`message` بالعربية. استثناء النقل الموثق: رفض Origin غير المسموح بواسطة Spring يعيد `403` ونصًا عاديًا؛ العميل يتعامل مع الحالة دون افتراض JSON.
- الجوال: opaque Bearer في مخزن النظام الآمن. صلاحية ثماني ساعات، تسجيل خروج يبطل الجلسة فورًا، ولا refresh token. انتهاء الجلسة يعيد الدخول ولا يرسل النموذج القديم تلقائيًا.
- الإنتاج مغلق: يلزم profile `dev` صريح وتفعيل تطويري. `prod` أو مزج `dev,prod` أو تعطيل التطوير يرفض الإقلاع. مزود OTP ومخزن الإنتاج غير مهيئين.
- ملفات التطوير في `.local/objects` خارج DB مع metadata وحالة/checksum في PostgreSQL. PNG/JPEG/PDF حتى 10 MiB، عشرة مرفقات للعملية، حد 25 مليون بكسل و10000 لكل بعد، PDF حتى100صفحة. HEIC غير مدعوم ويحتاج تحويلًا إلىJPEG. الملفات المشفرة/النشطة تُرفض. لا فحص malware فعلي؛ الحالة `DEV_NOT_SCANNED` صريحة. تكامل S3 وscanner والتنظيف الدوري للمرفقات المهجورة غير منفذ.
- كل تنزيل/رفع يعيد التحقق من العضوية. لا bucket عام ولا رابط موقع محفوظ. الملف READY ثابت؛ إعادة bytes نفسها تعيد النتيجة، وbytes مختلفة تُرفض. يعرض التطبيق الصور داخله؛ PDF يُنزّل على الويب ويفتح نسخة مؤقتة على الجوال. الملفات المصدرة تبقى تحت تحكم الجهاز وتحتاج سياسة احتفاظ قبل الإنتاج.
- المصروف هنا مدفوع كاملًا فقط. الجزئي/غير المدفوع، الإيرادات، مشاركة المصروف، الاسترداد، الأرشفة، الفريق، والتنبيهات خارج الشريحة الحالية. لا GPS أو OCR أو بوابة دفع.

لإيقاف الخدمات دون حذف البيانات:

```sh
docker compose -f infra/compose.yaml stop
```

ثم `docker compose -f infra/compose.yaml --profile test up -d --wait` لإعادتها. أوقف عمليتي API وخادم الويب بـCtrl+C. لا تستخدم `down -v` للبيانات التي تريد الاحتفاظ بها. لا سكربت reset لقاعدة التطوير؛ الاختبارات وحدها تعيد بيانات قاعدتها المعزولة.

إعادة توليد fixture فقط:

```sh
java -Djava.awt.headless=true scripts/SyntheticReceipt.java
```

عقد API في [OpenAPI](contracts/openapi.yaml). الإصدارات، نتائج التنفيذ الفعلية، المراجعات، وأي فجوات NOT RUN تُحفظ في [HANDOFF](docs/HANDOFF.md) و[أدلة التحقق](docs/evidence/).
