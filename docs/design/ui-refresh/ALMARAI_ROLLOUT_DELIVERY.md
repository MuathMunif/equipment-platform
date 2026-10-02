# تسليم التعميم الكامل A + F3 Almarai

## النتيجة والحدود
| بند التسليم | النتيجة |
|---|---|
| UI_A_ALMARAI_ROLLOUT_STATUS | اكتمل تنفيذ الدفعات الست والتحقق المحلي المتاح؛ جاهز لمراجعة PR البشرية ضمن الحدود المذكورة. نتيجةCI النهائية في PR ورد التسليم، ولا commit لمجرد تسجيل نجاحها. |
| APPROVED_COMBINATION | A «واضح وهادئ» + F3 Almarai المعتمد؛ لا إعادة اختيار. |
| SOURCE_BASELINE_AND_INHERITED_BRANCHES | `6f61d3bf965453e0c6f402efc9b86fe3db65ce46` على feat/ui-a-typography؛ يتضمن تصميم A/B/C، تجربة المعدة وTypography. كلها ancestry غير مدمجة في main عند البداية. `8aae24fddf37ec39d5a93b475e4a65a82d406923` سلف ويحتوي إصلاح التاريخ. |
| FEATURE_BRANCH_AND_FINAL_HEAD | `feat/ui-a-almarai-rollout`؛ commit الذي يحمل هذا الملف هو إغلاق التعميم بعد `25a65bf`. الرأس الكامل في رد التسليم/PR، أو `git rev-parse HEAD`. |
| COMMITS_BY_BATCH | 1:`30ff1c0`، 2:`1d6b36e`، 3:`3c5590c`، 4:`fd5326a`، 5:`6345219`، 6:`25a65bf`، ثم commit الإغلاق وتصحيح المراجعة. |

## ما تغيّر
| بند | النتيجة |
|---|---|
| DESIGN_SYSTEM_EVOLUTION | صفحة محدودة العرض، أقسام نموذج مستقرة تبقي validators مركبة، صفوف حقول وشبكات قيم متكيفة، تنقل يسمح بالتفاف النص، ألوان حالات مركزية. |
| CENTRAL_TYPOGRAPHY_AND_ROOT_THEME | EquipmentA.theme في الجذر، EquipmentTypography للوحدات والحوارات والحقول والقوائم والتاريخ والإشعارات والتنقل. |
| BODY_HEADING_WEIGHTS_AND_LOCALE_FALLBACKS | جسم وثانوي400، تأكيد/عناوين700 وفق F3؛ Almarai لكلar/en/ur مع Plex الموجود للحروف غير المدعومة. ملفات400/700 صريحة. لا تعطيل تكبير النص. |
| LEGACY_FONT_OVERRIDES_REMAINING | Noto في referenceTheme التاريخي ومعرض المقارنة فقط؛ الإنتاج يعيد تعيينه مركزيًا إلىAlmarai. لا override إنتاجي قديم خارج هذا الأساس. |
| APP_CONTROLLED_OVERLAYS_AND_NATIVE_EXCEPTIONS | dialog/date/dropdown/popup/snackbar/navigation على الخط المحدد. منتقي الملفات ولوحة مفاتيح النظام ومحتوى المرفق مستثناة من التحكم الطباعي. |
| SCREEN_COVERAGE_FILE | [COVERAGE.md](COVERAGE.md) يسمي كل وجهة/تدفق وحالته ونوع الأدلة. |
| MIGRATED_SCREEN_FAMILIES | الدخول، مساحة العمل، الرئيسية/الملخص، المعدات، الإضافة/التعديل، السجل، تفاصيل المال/دفعات/استرداد، المسودات/المرفقات، التقارير، المستندات/الإصدارات/التنبيه، الصيانة/البلاغات، الفريق/الدعوات/التعيين، السائق/المراجعة، المؤسسات والمشاريع/العقود، الإعدادات. |
| INTENTIONALLY_UNCHANGED | العقود والباك إند والمهاجرات والحسابات والصلاحيات وتكاملات الإنتاج، والمعرضان التاريخيان. لاGPS/مؤسسة أو فريق إلزامي/ميزة جديدة. |
| BLOCKED_OR_NOT_MIGRATED | لا عائلة واجهة تطبيق متروكة دون ترحيل. توجد فجوات تحقق منصة/حالات؛ ليست ادعاء اختبار كل permutation. |
| REAL_APP_VS_PREVIEW_SEPARATION | الصور من main.dart متصلAPI/DB؛ شجرة الإنتاج20 ملفDart لا تستورد أي معاينة. أبنية المعاينتين مستقلة. |
| SOURCE_DIFF_BOUNDARY_CHECK | لا تغيير Backend أو migrations أو OpenAPI/API client أو money/date helpers مقابل6f61d3b. استثناء frontend معلن: حذف initialPaid من FULL/UNPAID في الاعتماد وفق العقد الموجود، بدلnull الذي سبب400؛ قفل حقول التوزيع/المشروع أثناء حفظ غير مؤكد؛ تسميات الحالة/الخطأ فقط. لا تغيير حسابات أو قواعد وصول. |

## السلوك واللغات والأدلة
| بند | النتيجة |
|---|---|
| FINANCIAL_AND_DATE_BEHAVIOR_PRESERVED | exact arithmetic وقفل الإجمالي وإصلاح التصنيف وFULL/PARTIAL/UNPAID باقية؛ لا تسمية صافي المال ربحًا/رصيدًا. المسجل/الحركات/المتبقي وأساس التاريخ محفوظة. |
| PERMISSION_SCOPE_AND_REVIEW_MODE_PRESERVED | حراس الأفعال DIRECT/REVIEW والنطاق ومسارات backend الأصلية باقية. رحلة السائق لا تعرض دفتر المالك أو الموافقة؛ تبديل المساحة يخفي بيانات السابقة. لا توسيع صلاحيات. |
| DRIVER_SIMPLICITY | الصفحة والأفعال البسيطة مستقلة؛ معدات السائق وطلباته فقط، حالة الطلب المعتمد للقراءة. |
| AR_EN_UR_RESULTS | صور فعلية للعربية/الإنجليزية/الأردية تشمل المال والنماذج والمستندات والفريق/المراجعة والسائق؛ tests ثلاثية اللغة عند320 و160%/200%. ترجمة الأردية لغويًا تحتاج اعتمادًا بشريًا لاحقًا. |
| ACCESSIBILITY_CHECKS_AND_LIMITS | اختبار تباين زر البحث، labels/semantics، تنقل لوحة المفاتيح، تكبير200%، حفظ الحقول بعدresize/locale/insets؛ iOS حقل مبلغ ولوحة مفاتيح وتأكيد رجوع. لا اختبار قارئ شاشة تفاعلي/شهادة وصول أو كل الأجهزة. تعذر scroll أصلي بأداة الإحداثيات، فلا ندعي وصول كل الأزرار الأصلية فوق keyboard. |
| ACTUAL_SCREENSHOT_INDEX | [فهرس الصور](ALMARAI_ROLLOUT_SCREENSHOTS.md)، مع source/role/locale/viewport ونوعالدليل؛ لقطات تاريخية قبل تصحيحات صغيرة معلّمة. |
| CONNECTED_JOURNEYS_AND_EVIDENCE_TYPE | A:1000/600/200/net400/remaining600 +فاتورة محمية. B:تقرير→أصل→عودة، والمشروع/family/datebasis محفوظة. C:تجديد2027 ونسخة2026 read-only مع مرفقها. D:IS6→صيانة→أصل1000→إغلاق بلا مال جديد. E:طلب250→اعتماد→M2واحد→حالةالسائق (UI معSQLقراءة للتفرد/الهوية). F:مساحةسائق→شخصيةفارغة→عودة، بلا بقايا. كلها تطبيق فعلي، لاauth injection. الحساب المحاسب المقيّد ليس رحلة متصلة جديدة. |

## الاختبارات والأبنية المنفذة
الأوامر من `app/` ما لم يُذكر غير ذلك. الأعداد المتداخلة لا تُجمع.

| الفحص | النتيجة الفعلية |
|---|---|
| TEST_RESULTS — `flutter test --reporter expanded` | **211/211 ناجحة مرة واحدة** بعد الدفعة6 وقبل تصحيح لون زر المغادرة بثلاثة أسطر. |
| `flutter test test/widget_test.dart test/almarai_rollout_test.dart --concurrency=1 --reporter expanded` | **57/57 ناجحة** بعد التصحيح النهائي. المحاولة السابقة فشلت عند التحميل بسبب امتلاء القرص قبل تنفيذ الاختبارات. |
| اختبارات الدفعات | 83،53/16،54،54،56/36/37/12،70/50 ناجحة في مراحلها؛ أعداد متداخلة. محاولات الفشل الأولية وإصلاحاتها في [سجل التنفيذ](ALMARAI_ROLLOUT.md). اختبارات التجربة التاريخية ليست نتائج جديدة لهذه المهمة. |
| `flutter analyze` | نظيف بعد التعديل النهائي. |
| PRODUCTION_WEB_BUILD | `flutter build web --release -t lib/main.dart --output=../.local/almarai-rollout/web-production` ناجح بعد التصحيح النهائي؛ الحوار المصحح فُحص فعليًا. |
| DESIGN_AND_TYPOGRAPHY_PREVIEW_BUILDS | كلا الأمرين أدناه ناجح؛ ملفات المعاينتين لم تتغير بعدهما. |
| IOS_BUILD_AND_RUN | بناء المحاكي ناجح قبل وبعد التصحيح. install/launch على iPhone17Pro/iOS26.5 ناجح مع الجلسة الموجودة. رحلة iOS والصور قبل تصحيح اللون؛ البناء النهائي ناجح وتصحيح اللون فُحص على الويب. |
| ANDROID_BUILD_AND_RUN | بناء APK العادي ناجح قبل تصحيح اللون. إعادة البناء النهائية ARM64 **فشلت بنقص القرص**؛ لا ندعي APK مطابقًا للتصحيح الأخير. محاولة تشغيل AVD الموجود فشلت للسبب نفسه. لا تنزيل نظام أو مسح بيانات. |
| تدقيق الملفات | `git diff --check` ناجح؛ أداة تدقيق الخطوط نُفذت؛12/12 بصمة مصدر/ترخيص مطابقة. شجرة الإنتاج20 ملف Dart بلا استيراد للمعاينات. فحص أنماط المفاتيح بلا نتائج. |
| Backend محلي | لم يُعد تشغيله لتغييرات العرض. التحقق من Backend tests وFlutter checks يكون في PR عند الرأس النهائي. |

أوامر البناء المجربة:
```sh
flutter build web --release -t lib/main_design_preview.dart --output=../.local/almarai-rollout/web-design-preview
flutter build web --release -t lib/main_typography_preview.dart --output=../.local/almarai-rollout/web-typography-preview
flutter build ios --simulator --debug -t lib/main.dart
flutter build apk --debug -t lib/main.dart --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
# المحاولة النهائية الفاشلة بنقص القرص:
flutter build apk --debug --target-platform android-arm64 -t lib/main.dart --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

السجلات محليًا تحت `.local/rollout-*`. أزيلت فقط ملفات `app/build/app/intermediates/merged_native_libs` المؤقتة التي ولدتها محاولة Android الحالية، مع إبقاء APK والمصادر وبيانات المحاكيات وPostgreSQL والأعمال السابقة. تحذيرا Cupertino وopen_filex الموجودان سابقًا لا يمنعان الأبنية الناجحة.

## المراجعة والقيود
| بند | النتيجة |
|---|---|
| INDEPENDENT_REVIEWS_OR_SELF_REVIEW | مراجعتان مستقلتان متتاليتان للقراءة فقط: مالية/نماذج ساكنة بعد الدفعة2 بلا ملاحظات؛ وبصرية نهائية قارنت4 صور للتجربة و14 للتعميم، بلا P0–P2 وملاحظة P3 واحدة. الرئيسي نفذ الكود والاختبارات والرحلات وتصحيح الملاحظة. |
| CONFIRMED_ISSUES_FIXED | تثبيت حالة الحقول عند تغيير العرض، بقاء التحقق مركبًا، الالتفاف والتكبير، عرض حوار اللغة، محاذاة المبالغ، منع تعديل حقول الحفظ غير المؤكد، تصحيح إرسال initialPaid، تسمية العضوية المسحوبة واتجاه الهاتف، رسالة منع أرشفة المؤسسة، وتمييز المغادرة بلون إتلافي. |
| REMAINING_ISSUES_WITH_SEVERITY | عائق بيئة: نقص القرص يمنع تشغيل Android وإعادة بنائه النهائية. ملاحظة منخفضة وسابقة: ملخص الرئيسية بعد الاعتماد يحتاج تحديثًا عاديًا؛ القيمة صحيحة في قاعدة البيانات وبعد إعادة الدخول. لا P0–P2 مؤكدة في المراجعات؛ لا اعتماد لغوي أردي أو اختبار جهاز فعلي/قارئ شاشة، ولم تُعد كل حالات الإلغاء وسحب الوصول على بيانات حقيقية. |
| MODEL_CONFIGURED_VS_OBSERVED | إعداد المشروع القابل للفحص `gpt-6-sol/low`. المالك بلّغ اختيار الجلسة Astra/High وأجاز الاستثناء لهذه المهمة. هوية التشغيل الفعلية غير مكشوفة؛ لا ادعاء إثباتها أو تغيير الإعدادات. |
| SUBAGENTS_USED | `rollout_behavior_review` ثم `rollout_final_visual_review`؛ طُلب كلاهما صراحةً `gpt-6-astra/high` مع `fork_turns:none` ومراجعة للقراءة فقط. لم ينفذا اختبارات، ولا وكيل تنفيذ فرعي أو تفويض متداخل. |
| RESOURCE_POLICY_EXCEPTIONS | استثناء Astra/High المعتمد لهذه المهمة فقط؛ الكاتب الرئيسي وحده، مراجع واحد في كل مرة، دون تغيير config/auth/billing/credentials. |

## التسليم والاستخدام
| بند | النتيجة |
|---|---|
| ملفات التغيير | [القائمة الدقيقة](ALMARAI_ROLLOUT_FILES.md) مقابل baseline التعميم. |
| PR_CREATED_AND_URL | يُنشأ بعد commit الإغلاق؛ الرابط في رد التسليم. [مقارنة الفرع](https://github.com/MuathMunif/equipment-platform/compare/main...feat/ui-a-almarai-rollout). لا PR مكرر عند الفحص. |
| CI_AT_FINAL_HEAD | يجب التحقق من Backend tests وFlutter checks على الرأس النهائي. النتيجة في PR ورد التسليم؛ لا commit لمجرد تسجيل نجاح CI. فحص حماية الفرع أعاد404 Branch not protected؛ لم تتغير الحماية. |
| WORKTREE_STATUS | commit الإغلاق يجمع التصحيح والتوثيق والأدلة؛ الحالة النهائية تُفحص بعده وتُذكر في الرد. |
| MAIN_UNCHANGED | main وorigin/main بقيا عند8aae24f أثناء الفحص. لا دمج أو نشر أو مستودع جديد. |
| HOW_TO_OPEN_THE_REAL_APP | `http://127.0.0.1:8081/` يخدم بناء الإنتاج، API المحلي على8080. الحساب0500000802 والرمز123456 للتطوير المحلي فقط؛ لا SMS حقيقي. |
| READY_FOR_USER_MERGE_REVIEW | نعم بعد نجاح CI المطلوب، ضمن حد Android المعلن. لا يعني نشرًا أو قبول كل V1. |
| NEXT_SINGLE_ACTION | مراجعة المالك للـPR واتخاذ قراره. يتوقف الوكيل دون بدء ميزة أو دمج. |

من الجذر، أمر الخادم المجرب:
```sh
python3 -m http.server 8081 --bind 127.0.0.1 --directory .local/almarai-rollout/web-production
```

التثبيت والتشغيل المجربان على محاكي iOS الموجود:
```sh
xcrun simctl install 657C142E-E597-481F-B8F9-8C07082C1D30 app/build/ios/iphonesimulator/Runner.app
xcrun simctl launch --terminate-running-process 657C142E-E597-481F-B8F9-8C07082C1D30 com.equipment.equipmentApp
```
