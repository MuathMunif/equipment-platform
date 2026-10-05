# إصلاح مسار الرئيسية ← عرض السجل — 2026-10-05

## السبب والتصحيح

الفرع `fix/journal-navigation-shell` من main المدمج `9ea913b0a0141367c86ff229eedcae5dd017a3cc`. تحقق GitHub أن PR#10 مدمج وتطابق مصدر التخطيط المضغوط مع6713ac6. بدأ العمل من شجرة نظيفة بعد fetch وpull بـ`--ff-only`، دون حذف عمل. مرفق التكليف نص فقط دون صورة مستقلة؛ الأدلة هنا من إعادة إنتاج فعلية.

أُعيد العطل في `lib/main.dart` بالنقر على الرئيسية ثم «عرض السجل» في iPhone والويب. المدخل السفلي يعمل قبل الإصلاح. في `app/lib/reports.dart` كان زر `homeViewJournal` ومساعد البطاقات الشهرية `openLedger` يدفعان `LedgerPage` مباشرة. هذا جسم مشترك في `app/lib/main.dart`؛ تبويب مساحة العمل وتفاصيل المعدة يزودانه بـScaffold. المسار المدفوع شقيق للمتصل وليس داخل Scaffold الخاص به.

Theme الجذري باقٍ، لكن غياب Material/Scaffold يجعل Text الوصف غير المنسق يرث DefaultTextStyle التحذيري من MaterialApp. المصدر المثبت في SDK المحلي `/opt/homebrew/share/flutter/packages/flutter/lib/src/material/app.dart` يعرّفه: monospace بحجم48 ووزن900، أحمر وتسطير أصفر مزدوج. الاختبار الجذري قبل الإصلاح وجد فعلًا monospace بدل EquipmentAlmarai. ليست مشكلة خط مفقود أو Navigator متداخل.

ملف الإنتاج الوحيد المتغير `app/lib/reports.dart`: يجمع `openLedger([String? type])` المداخل المدفوعة داخل `Scaffold + AppBar + LedgerPage` بالنمط القائم. زر الرجوع يحافظ على push/pop؛ لا شريط تنقل سفلي إضافي أو MaterialApp جديد أو تنسيق محلي لإخفاء المشكلة.

AppBar يستهلك مساحة الحالة العلوية؛ `EquipmentPageBody` القائم يستخدم `SafeArea(top: false)` ويحمي الحواف السفلية والجانبية، وScaffold يتعامل مع مساحة لوحة المفاتيح. لا ارتفاع ثابت للشق. «عرض السجل» يبقى بلا فلتر نوع/شهر؛ بطاقتا المصروفات والإيرادات تحتفظان بالنوع وبداية/نهاية الشهر. لم يكن لهذا المساعد فلتر مشروع؛ واجهة الفلاتر ودلالاتها لم تتغير. API ومساحة العمل وcanManage وcanSubmitReview تمر كما كانت.

## الفحوص المنفذة

الأوامر من `app/`؛ السجلات المحلية `.local/journal-*.log` غير مرفوعة.

| الأمر/الفحص | النتيجة الفعلية |
| --- | --- |
| `flutter test --no-pub test/journal_navigation_shell_test.dart --plain-name 'root Home View journal has Material Almarai and safe insets ar x1.0' --reporter expanded` قبل الإصلاح | فشل متوقع1/1: monospace بدل EquipmentAlmarai |
| `flutter test --no-pub test/journal_navigation_shell_test.dart test/home_layout_test.dart test/reports_test.dart --dart-define=JOURNAL_SHELL_EVIDENCE=true --reporter expanded` أول تشغيل بعده |32ناجح/6فاشلة: harness اعتبر decoration=null مختلفًا عن none. جميع الاختبارات القائمة30نجحت. صُحح تمثيل غياب الزخرفة في الاختبار فقط، دون حذف assertions |
| `flutter test --no-pub test/journal_navigation_shell_test.dart --dart-define=JOURNAL_SHELL_EVIDENCE=true --reporter expanded` |8/8ناجح بعد تصحيح harness |
| `flutter test --no-pub --reporter expanded` |256/256ناجح، الكامل مرة واحدة بعد استقرار الإصلاح |
| `flutter analyze --no-pub` | ناجح بلا ملاحظات |
| `flutter build web --release --no-pub -t lib/main.dart --output=../.local/almarai-rollout/web-production` | ناجح28.8ث؛ تحذير CupertinoIcons القائم |
| `flutter build ios --simulator --debug --no-pub -t lib/main.dart --dart-define=API_BASE_URL=http://127.0.0.1:8080/api/v1` | ناجح9.5ث؛ تحذير open_filex/SPM القائم |
| `git diff --check` من الجذر | ناجح |

الاختبارات الثمانية في `app/test/journal_navigation_shell_test.dart` تشغّل EquipmentApp الحقيقي من الجذر مع HTTP fixture، دون Scaffold/Theme صناعي. تتحقق من النمط الفعال والخلفية الفاتحة وScaffold/Material واحد وحدود59علوي/34سفلي، ورجوع التفاصيل مع حفظ البحث وموضع التمرير، ولوحة مفاتيح280، والدخول المتكرر والتبويب السفلي، وفلاتر البطاقات الشهرية، وصلاحيات DIRECT/REVIEW وعدم وجود مدخل/طلب بيانات مالية للمستخدم غير المخول. العربية والإنجليزية بتكبير1 والأردية بتكبير2 مع اتجاهاتهما الطبيعية؛ هذه حالات widget وليست اختبارات أجهزة أو مراجعة لغوية.

بصمات13ملفًا تطابق `compact-layout-review/FONT_BASELINE.json`: Almarai400/700 وPlex fallback والأصول وأحجام النص وارتفاعاته وتكبير النظام والثيم دون تغيير. التخطيط المضغوط وBackend وAPI وmigrations والحسابات والصلاحيات والبيانات لم تتغير. لا حملة Backend محلية؛ CI المطلوب يعمل طبيعيًا على الرأس الجديد.

## التطبيق الحي والأدلة

- المحاكي القائم iPhone17Pro/iOS26.5، UDID `657C142E-E597-481F-B8F9-8C07082C1D30`، bundle `com.equipment.equipmentApp`. التثبيت والتشغيل نجحا مع حفظ جلسة OWNER/مساحتي وبيانات أكتوبر2026 القائمة، دون OTP أو حقن جلسة.
- من جذر المشروع جُرّب: `xcrun simctl install 657C142E-E597-481F-B8F9-8C07082C1D30 app/build/ios/iphonesimulator/Runner.app` ثم `xcrun simctl launch --terminate-running-process 657C142E-E597-481F-B8F9-8C07082C1D30 com.equipment.equipmentApp`. إعادة التشغيل تخص هذا التطبيق فقط، دون مسح بياناته أو إيقاف خدمة أخرى.
- Home→View journal نُقر فعليًا بعد البناء على iOS والويب؛ فُتح القيد القائم ورُجع للسجل والرئيسية. مدخل السجل السفلي تحقق قبل الإصلاح وبعده على iOS، ثم أُعيد فتح المسار المطلوب وتُرك عليه التطبيق. الصور تُظهر النمط والحواف الصحيحة.
- التمرير الحي على الويب نجح. أوامر scroll ثم drag للمحاكي لم تغير موضع العرض؛ **تمرير iOS يدويًا غير متحقق بهذه الأداة**. اختبار widget يثبت التمرير وحفظ الموضع بدقة. صورة رجوع الويب تثبت بقاء سياق السجل، لكن تركيز المتصفح قد يزيح الصف قليلًا؛ ليست مقارنة بكسلية للموضع.
- أُعيد استخدام API8080 وWeb8081 وPostgreSQL55432. لم تُنشأ أو تُعدل سجلات أو مرفقات، ولم تُعد تهيئة قاعدة/محاكي أو تنظيف ملفات. الجلسات والحاويات والخدمات محفوظة.
- [صور قبل/بعد](screenshots/INDEX.md). مراجعة ذاتية فقط وصفر وكلاء؛ لم تتغير إعدادات النموذج أو SDK أو الاعتماديات. القبول البصري بيد المالك.
- CI المطلوب Backend tests وFlutter checks يُتحقق على رأس PR الجديد ويُرفق في PR/رد التسليم، دون commit إضافي لتسجيل نجاحه. لا دمج أو نشر.

## الحدود والخطوة التالية

بناء وتشغيل Android النهائيان غير مكتملين بسبب سعة القرص؛ اختبار جهاز فعلي معلق؛ قارئ شاشة تفاعلي معلق؛ مراجعة الأردية من متحدث أصلي معلقة. لا توسيع للحملة أو تنظيف قرص في هذه المهمة. بعد CI: مراجعة المالك للإصلاح وPR، ثم انتظار تعليماته.
