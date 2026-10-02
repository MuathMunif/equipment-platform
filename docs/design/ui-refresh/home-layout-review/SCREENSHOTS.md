# صور تصحيح الرئيسية

المراجع المقدمة فُحصت فعليًا وبقيت في مسارها:
[المرجع](../../home-layout-review/reference-home.png)، [الرئيسية السابقة أعلى](../../home-layout-review/current-home-top.png)، [نفس الرئيسية السابقة أسفل](../../home-layout-review/current-home-activity.png).

## التطبيق الحقيقي المتصل

قبل: main/ef9e682. بعد: شيفرة فرعfix/home-dashboard-layout التي يحملها commit هذا التسليم؛ لا فرق إنتاجي بعد التصوير. المستخدم0802، OWNER نشط، مساحتي، أكتوبر2026، بيانات ثابتة. Screenshot وليست صورة مولدة أو gallery.

| الملف | الدليل |
|---|---|
| [before-ar-390.png](screenshots/before-ar-390.png) |قبل، ar390×844.|
| [after-ar-390-top.png](screenshots/after-ar-390-top.png) |بعد بنفس العرض والبيانات؛ عمودا المال، انتباه فارغ دون بطاقة.|
| [after-ar-390-lower.png](screenshots/after-ar-390-lower.png) |العمليات الثلاث ومعداتي والإضافة.|
| [after-ar-1440.png](screenshots/after-ar-1440.png) |ar1440×1000، العمليات والمعدات بعمودين.|
| [after-en-390.png](screenshots/after-en-390.png) |en390×844، LTR، محتوى المستخدم العربي محفوظ.|
| [after-ur-390.png](screenshots/after-ur-390.png) |ur390×844؛ عمود واحد للمال لأن اسم العملة الكامل لا يتسع.|
| [after-ar-320.png](screenshots/after-ar-320.png) |ar320×844، التفاف التحية وتراص المال.|
| [after-ios-ar-home.png](screenshots/after-ios-ar-home.png) |نافذة iPhone17Pro/iOS26.5، تطبيقlib/main.dart مصحح على بيانات المالك.|

## Harness — ليست جلسة مستخدم متصلة

`app/test/home_layout_test.dart` يرسم WorkspacePage وشاشات الإنتاج مع HTTP doubles وخطوط التطبيق، دون أي تعديل بيانات/fixtures فيAPI الحقيقي.

| الملف | الدليل |
|---|---|
| [harness-attention-ar-390.png](screenshots/harness-attention-ar-390.png) |ar390×844: أول3 بنود، مراجعة مجمعة7، ومستندان للاستكمال منفصلان.|
| [harness-attention-lower-ar-390.png](screenshots/harness-attention-lower-ar-390.png) |نفس الحالة مع رابط الاستكمال؛ لا تضخيم عدد البنود.|
| [harness-new-owner-ar-390.png](screenshots/harness-new-owner-ar-390.png) |مالك جديد دون معدات أو قيود؛ الإضافة بارزة.|
| [harness-ur-320-text200-top.png](screenshots/harness-ur-320-text200-top.png) |ur320×844، تكبير200%، اسم طويل، الجزء العلوي.|
| [harness-ur-320-text200-lower.png](screenshots/harness-ur-320-text200-lower.png) |نفس الحالة بعد التمرير إلى المعدات؛ الخط لم يُصغّر والنص يلتف.|

المراجعة البصرية ذاتية؛ لا اعتماد لغوي أردي أو فحص قارئ شاشة تفاعلي. الأيقونات في الأدلة النهائية محملة منMaterialIcons؛ الصور الأولية أثناء إعدادharness استُبدلت بعد تحميل الخط الصحيح.
