# القرار الحالي: A + F3 Almarai معتمد

اختار المالكF3 بعد مراجعة هذا التقرير. القرار محسوم؛ لا تنتظر هذه الوثيقة اختيارF1/F2/F3 مجددًا. دمج الخط في تجربة المعدة على الفرع نفسه موثق في [ALMARAI_PILOT.md](ALMARAI_PILOT.md). تعميم باقي التطبيق ينتظر تعليمات مستقلة.

التقرير التالي محفوظ تاريخيًا كما كان عند المقارنة`7f328d1`؛ أوصاف Noto/الانتظار/عدم تطبيق الخط فيه تخص تلك النقطة السابقة.

---

# Direction A — مقارنة الخطوط قبل التعميم

**2026-10-02 — تخطيط A معتمد، الخط الحالي مرفوض، اختيار F1/F2/F3 معلق، التعميم متوقف.**

الفرع `feat/ui-a-typography` بُني من تجربة المعدة النظيفة `ca6201d` بعد فحص Git. احتُفظ بالتجربة، والمعرض القديم، والصور، وإصلاح التاريخ. نقطة الحفظ هي commit هذه المقارنة على الفرع؛ يمكن الحصول على SHA بـ`git log -1 --oneline`. لا دمج أو تعديل main أو نشر أو PR. هذه معاينة ببيانات اصطناعية ثابتة؛ لا دخول أو API أو قاعدة بيانات أو قبول متصل جديد.

## الخط الحالي وما أثبته الفحص

| المسار | الإعداد الفعلي |
|---|---|
| تجربة المعدة الإنتاجية | `EquipmentA.family = EquipmentNoto` في `app/lib/design_system/equipment_a.dart`، theme محلي داخل صفحة المعدة |
| الأصل المسجل | `assets/design_fonts/NotoSansArabic[wdth,wght].ttf` عبر `pubspec.yaml`؛ لا weight صريح في تعريف الأصل |
| محاور الملف | Noto Sans Arabic متغير: `wght` من100 إلى900، الافتراضي400؛ `wdth` من62.5 إلى100، الافتراضي100 |
| العربية/الإنجليزية/الأردية/الأرقام | EquipmentNoto نفسه؛ لا تخصيص locale أو fallback صريح في theme الإنتاجي؛ لا `fontVariations` صريح |
| هرم تجربة المعدة | عنوان30/ارتفاع1.45، عنوان قسم24/1.5، عناوين20/1.5 و16/1.55، وزن600؛ نص14/1.6، ثانوي12/1.6؛ label14/1.5 بوزن600. أدوار Material غير المخصصة قد ترث500 |
| المعرض السابق | A: PreviewNoto؛ B: PreviewPlex بملفي400/600؛ C: نص Noto وعنوان Noto Naskh متغير400–700؛ override الأردية السابق يستخدم Noto في الاتجاهات الثلاثة |
| Overrides المعرض | مبلغ النموذج30 ووسوم/صفوف محددة كانت تطلب600. جُعل وزن التأكيد قابلًا للتمرير مع بقاء الافتراضي600، فلا يتغير المعرض القديم |

ملف FontManifest المبني للتجربة يربط EquipmentNoto بالأصل الصحيح. المعاينة الجديدة تنتظر `FontLoader.load()` قبل ظهور المحتوى؛ خادم8085 أعاد HTTP200 للملفات الستة ثم304 من الذاكرة المؤقتة. اختبار Flutter يرسم العبارة المختلطة ويقارن بكسلاتها بخط مفقود عمدًا: كل عائلة تختلف عنه وعن العائلات الأخرى، و400 يختلف عن الوزن المؤكد. Noto الحالي يرسم400 و600 بصورة مختلفة أيضًا. لذلك **لم يثبت فشل تحميل شامل أو تجاهل كامل للوزن**؛ هذا لا ينفي تفضيل المالك ولا يثبت نسبة كل حرف إلى ملف بعينه على كل منصة. لا حاجة لتغيير FontManifest الإنتاجي لتجربة بدائل الخط.

مقاييس عبارة الاختبار عند30px (دليل رندر محلي، وليست نسبًا قطعية لكل glyph): Plex635.70→663.51، Tajawal529.08→551.37، Almarai639.42→669.36، Noto679.59→704.37. السهم400→700 للبدائل و400→600 للأساس المرفوض.

## البدائل وضبط المقارنة

Noto هو الخط المرفوض بالفعل؛ استُبدل في المرشحين بـAlmarai، وبقي اختياريًا تحت اسم **BASELINE · rejected baseline** فقط.

| الخيار | الخط والأسلوب | العربية / الإنجليزية / الأرقام | الأردية | رأي بصري من الصور |
|---|---|---|---|---|
| F1 | IBM Plex Sans Arabic؛ Regular400 وBold700 | Plex | Plex | تقني واضح، مع تباين قوي بين النص والعنوان |
| F2 | Tajawal؛ Regular400 وBold700 | Tajawal | Plex لواجهة الأردية كاملة داخل locale ur | أنعم وأقصر بصريًا؛ النص الثانوي أخف عند المقاس نفسه |
| F3 | Almarai؛ Regular400 وBold700 | Almarai | Almarai | واضح في التسميات الصغيرة وأقل زخرفة؛ مرشحي الشخصي مع A |

رأيي: **F3** هو الأكثر اتزانًا لهذه الواجهة التشغيلية، بناءً على عينات الويب وiOS. هذا توصية لا اختيار نيابة عن المالك.

كل البدائل تستخدم ملفات فعلية400/700 ذات OS/2 weights مطابق، بلا محاور متغيرة ولا طلب500/600 مفقود. كل أدوار النص والأزرار والحقول والـchips تُضبط لنفس الهرم. لا تعديل بصري خاص لحجم/ارتفاع أي مرشح، ولا ضغط لمسافات العربية أو تصغير لإخفاء overflow. مقياس المعاينة1/1.6 يضاعف مقياس الوصول الخاص بالجهاز ويحتفظ بسلوكه غير الخطي.

تظل ألوان A، البطاقات، الشبكة، الأيقونات، والبيانات واحدة بين المرشحين. تفاصيل المعدة تعيد استخدام `EquipmentIdentity/Columns/Panel/Heading` من التجربة؛ المصروف هو `ExpensePreview` الموجود، لا ترحيل لنموذج الإنتاج. الجزء الإضافي المسمى FONT SPECIMEN معمل نص فقط، وليس حقلًا أو ميزة جديدة. يحتوي الاسم الطويل والتشكيل، حروف الأردية،0.00 و1,234.50 و-125.25، التاريخ، التحذير والخطأ. يستخدم منسقات المال والتاريخ الحالية؛ منطق التحويل والحساب لم يتغير.

## المصادر واللغات

الأصول من Google Fonts الرسمي، مثبتة عند `9710da1eacb3be272583c3224dcb70f9da6eadbb`، بترخيص SIL OFL1.1. ملفات الخطوط والـmetadata محفوظة دون تعديل. نصوص الترخيص وحقوق النشر محفوظة؛ حُذفت المسافات الزائدة بنهاية سطر في كل OFL فقط، وسُجل hash الأصلي والمحفوظ. [سجل العائلات والمصادر](../../../app/assets/typography_fonts/README.md)، [روابط كل ملف وSHA-256](../../../app/assets/typography_fonts/sources.json)، [نتيجة تدقيق الأوزان والمحارف](typography-font-audit.json). المصادر: [Plex](https://github.com/google/fonts/tree/9710da1eacb3be272583c3224dcb70f9da6eadbb/ofl/ibmplexsansarabic)، [Tajawal](https://github.com/google/fonts/tree/9710da1eacb3be272583c3224dcb70f9da6eadbb/ofl/tajawal)، [Almarai](https://github.com/google/fonts/tree/9710da1eacb3be272583c3224dcb70f9da6eadbb/ofl/almarai).

Plex وAlmarai يغطيان `ٹ ڈ ڑ ں ھ ہ ے پ چ ژ گ` في cmap. Tajawal يفتقد10 من11، لذلك F2 يستخدم Plex لكل واجهة ur؛ وفي النص المختلط داخل locale ar/en يُسمح بـPlex fallback للحروف الناقصة. لا ندّعي أن سطر الأردية داخل عينة Tajawal العربية مرسوم بالكامل بـTajawal. فُحصت الوصلات والنقاط والتشكيل والسطر الأساسي بصريًا؛ لا مربعات محارف مفقودة ظاهرة في العينات، ولا اعتماد لغوي بشري للأردية.

## الصور الفعلية

12 صورة أساسية، العربية، عند390×1000 و1440×1000 logical pixels. صور مباشرة من Flutter CanvasKit في المتصفح؛ لا تركيب أو تعديل للصورة.

| الخيار | المعدة390 | المعدة1440 | المصروف390 | المصروف1440 |
|---|---|---|---|---|
| F1 | [صورة](screenshots/typography/f1-equipment-ar-390.jpg) | [صورة](screenshots/typography/f1-equipment-ar-1440.jpg) | [صورة](screenshots/typography/f1-expense-ar-390.jpg) | [صورة](screenshots/typography/f1-expense-ar-1440.jpg) |
| F2 | [صورة](screenshots/typography/f2-equipment-ar-390.jpg) | [صورة](screenshots/typography/f2-equipment-ar-1440.jpg) | [صورة](screenshots/typography/f2-expense-ar-390.jpg) | [صورة](screenshots/typography/f2-expense-ar-1440.jpg) |
| F3 | [صورة](screenshots/typography/f3-equipment-ar-390.jpg) | [صورة](screenshots/typography/f3-equipment-ar-1440.jpg) | [صورة](screenshots/typography/f3-expense-ar-390.jpg) | [صورة](screenshots/typography/f3-expense-ar-1440.jpg) |

8 صور إضافية محدودة، جميعها فُحصت ذاتيًا:

- [F2 إنجليزي390](screenshots/typography/f2-expense-en-390.jpg): LTR، تسميات وقيم وتاريخ.
- [F2 أردي390](screenshots/typography/f2-equipment-ur-390.jpg): Plex companion معلن؛ النص الطويل يعيد التدفق.
- [Plex عينة أردية1440](screenshots/typography/f2-plex-specimen-ur-1440.jpg): تمثل عائلة F1 أيضًا؛ حروف وتشكيل وأموال وتحذير/خطأ.
- [Almarai عينة أردية1440](screenshots/typography/f3-specimen-ur-1440.jpg).
- [Tajawal عينة عربية1440](screenshots/typography/f2-specimen-ar-1440.jpg).
- [F2 نموذج320/160%](screenshots/typography/f2-expense-ar-320-text160.jpg).
- [F2 عينة نص320/160% بعد التمرير](screenshots/typography/f2-specimen-ar-320-text160.jpg): الجزء العلوي خارج مجال التمرير، لا قص قسري داخل النص.
- [F3 عربية على iPhone17 Pro /iOS26.5](screenshots/typography/f3-equipment-ar-ios.jpg): لقطة نافذة المحاكي الحقيقي المتاح، لا mockup.

إصلاح تركيب مقياس الجهاز أتى بعد الصور الأساسية، ولم يغيّر الرسم عند إعداد الجهاز1x: أُعيد فتح البناء النهائي ومقارنة JPEG شاشة F2/المصروف1440 بالسابقة، وكانت متطابقة byte-for-byte. لقطة iOS من البناء النهائي.

## التشغيل الذي جُرّب

من `/Users/muath/Desktop/equipment-platform/app`:

```sh
flutter build web --release -t lib/main_typography_preview.dart --output=../.local/typography/web
```

من `/Users/muath/Desktop/equipment-platform`، في طرفية منفصلة إذا8085 غير مستخدم:

```sh
python3 -m http.server 8085 --bind 127.0.0.1 --directory .local/typography/web
```

[F1](http://127.0.0.1:8085/?font=f1&screen=equipment&locale=ar) · [F2](http://127.0.0.1:8085/?font=f2&screen=equipment&locale=ar) · [F3](http://127.0.0.1:8085/?font=f3&screen=equipment&locale=ar). الخادم المحلي كان يعمل عند التسليم. زر الشرائح أعلى الصفحة يبدل الخط والشاشة واللغة والتكبير، ويحافظ على مبلغ النموذج المكتوب عند تبديل الخط. القيم: `font=f1|f2|f3|baseline`, `screen=equipment|expense`, `locale=ar|en|ur`, `scale=1|1.6` (يدعم1 إلى2). أحجام390/1440 أحجام viewport فعلية، وليست تصغير CSS.

اختبارات وأبنية جُرّبت من `app/`:

```sh
dart format lib/typography_preview/gallery.dart test/typography_preview_test.dart
flutter test test/typography_preview_test.dart test/design_preview_test.dart test/equipment_pilot_test.dart --reporter expanded
flutter test test/typography_preview_test.dart --reporter expanded
flutter analyze
flutter build web --release -t lib/main.dart --output=../.local/typography/production
flutter build ios --simulator --debug -t lib/main_typography_preview.dart --dart-define=TYPOGRAPHY_FONT=f3
```

ومن الجذر:

```sh
python3 scripts/audit-typography-fonts.py
xcrun simctl list devices booted
xcrun simctl install 657C142E-E597-481F-B8F9-8C07082C1D30 app/build/ios/iphonesimulator/Runner.app
xcrun simctl launch 657C142E-E597-481F-B8F9-8C07082C1D30 com.equipment.equipmentApp
git diff --check
```

## النتائج والحدود

| الفحص المنفذ | النتيجة |
|---|---|
| المجموعة المركزة الأولى |80/80 ناجح:24 typography +36 preview +20 pilot |
| بعد إصلاح احترام تكبير الجهاز |25/25 typography ناجح، يتضمن اختبارًا جديدًا:1.3 جهاز ×1.6 معاينة. المجموعة الأولى متداخلة مع هذه؛ لا يُجمع العدد كاختبارات فريدة |
| مصفوفة النصوص |12 حالة أساسية +9 خيارات/لغات320/160%، كل حالة ضيقة تفحص الشاشتين وعينة الحروف؛ لا overflow exceptions |
| تحميل/أوزان/عزل | بكسلات فعلية مختلفة لكل عائلة ووزن؛12/12 ملف مصدر/ترخيص/metadata يطابق hash/الحجم؛ manifest الإنتاجي بقي كما هو |
| التحليل/البناء | analyze بلا ملاحظات؛ preview web release وproduction web release وiOS simulator debug ناجحة |
| عزل الإنتاج | شجرة19 ملفًا محليًا، تشمل conditional imports، لا تستورد أي معرض؛ comparison markers غائبة من production JS |
| التفاعل المحدود | تبديل الخط مع بقاء125.25 ورسالة عدم الحفظ في الاختبار؛ المفتاح والشاشة جُرّبا أيضًا بالمتصفح؛ لا API instantiated |
| مراجعة بصرية |20 صورة ذاتية؛ لا مراجع مستقل أو وكيل فرعي في هذه المهمة |

لم تفشل اختبارات Flutter المنفذة. محاولات تشغيل Flutter داخل sandbox اصطدمت بصلاحية cache، ثم شُغلت ضمن الموافقات. `fontTools` لم يكن مثبتًا؛ استُخدم محلل مكتبة Python القياسية دون تثبيت. أمر إنهاء التطبيق في المحاكي رجع `nothing to terminate`؛ لم يكن التطبيق يعمل، ثم نجح install/launch. لا إعادة ضبط أو حذف بيانات.

تحذيران من الأدوات الموجودة: توقع CupertinoIcons في build web، و`open_filex` لم يتبنَّ Swift Package Manager؛ الأبنية نجحت، ولا ترقية dependencies. WASM dry run الحالي نجح، لكن لم يُشغّل تطبيق WASM.

لم تُعد المجموعة الكاملة أو اختبارات Backend أو OTP/قاعدة بيانات؛ لم تختبر Android/جهازًا فعليًا/مصفوفة native كاملة/قارئ شاشة تفاعلي. native هذه المرة F3/ar فقط. الخطوط الجديدة تضيف912,764 بايت غير مضغوطة إلى حزمة الأصول المشتركة؛ الإنتاج لا يسجل عائلاتها أو يستخدمها. معاينة iOS مثبتة في bundle التطوير الموجود؛ مسار الإنتاج على8081 لم يتغير. لا ادعاء glyph attribution أو اعتماد لغوي للأردية.

## الملفات والسياسة ونقطة التوقف

- التنفيذ: `app/lib/main_typography_preview.dart`، `app/lib/typography_preview/{fonts,gallery,equipment}.dart`، `app/test/typography_preview_test.dart`.
- التغيير المحدود المشترك: `app/lib/design_preview/{tokens,screens}.dart` لتمرير emphasis مع افتراضي600؛ `app/pubspec.yaml` لإضافة مجلد assets فقط. لم تتغير ملفات منطق الإنتاج أو منسقات المال/التاريخ أو backend.
- المصادر والأدلة: `app/assets/typography_fonts/`، `scripts/audit-typography-fonts.py`، `typography-font-audit.json`،20 JPEG تحت `screenshots/typography/`.
- التوثيق: هذه المقارنة، `STATUS.md`، `DECISIONS_PENDING.md`، `docs/HANDOFF.md`، وقرارUI في `docs/04_DECISIONS_AR.md`.
- الكاتب والمراجع الذاتي: الرئيسي وحده، **0 subagents**. استثناء Astra/High المأذون من المالك مستمر لهذه المهمة؛ هذا اختيار المالك المبلّغ، لا إثبات telemetry. لا بحث جديد عن الهوية أو تغيير إعدادات Codex.

**FULL_ROLLOUT_STATUS: PAUSED. USER_SELECTION_REQUIRED: F1 / F2 / F3.** التالي هو اختيار المالك، ثم مهمة محدودة مأذونة لتطبيق الخط المختار في تجربة المعدة. لا يبدأ تعميم التطبيق أو ترحيل مصروف الإنتاج تلقائيًا.
