# صور التخطيط المضغوط — 2026-10-05

المقارنة على التطبيق الحقيقي `lib/main.dart`، حساب المالك التجريبي الموجود / مساحتي / أكتوبر2026: معدتان، مصروف2850 وإيراد4500. لا إنشاء بيانات ولا تعديل سجلات. الصور المرجعية في المجلد الأب ليست دليل تنفيذ.

- `before-web-*`: الأساس8d99179، واجهة عربية390×844 وتكبير100%.
- `after-web-*-390`: المصدر النهائي لهذا commit، نفس البيانات والشهر واللغة والحجم. لقطة home-equipment بتمرير لأسفل قبل وبعد.
- `after-web-*-1440`: واجهة عربية1440×1000 متصلة بالـAPI.
- `before-ios-*` / `after-ios-*`: التطبيق الأصلي على iPhone17Pro/iOS26.5، نفس الجهاز وإعدادات النص والبيانات. نافذة المحاكي قد تشمل إطار macOS؛ ليست صورة ويب داخله.
- `harness-*`: صور Widgets الفعلية بالخطوط المحلية الحقيقية وHTTP MockClient، ليست اتصالًا حيًا. بيانات طويلة مصطنعة داخل الاختبارات فقط، لم تحفظ في قاعدة البيانات. ثلاثة شاشات × ثلاث لغات × (390/100%،320/160%،320/200%،1440/100%) =36صورة.
- الحالات الفارغة/الفشل/الصلاحيات/انتباه موجود تحقق آليًا؛ لا تدّعي الصور المتصلة أن الحساب الحي يملك جميع تلك الحالات.

المراجعة الذاتية: مرور بصري أول للشاشات الثلاث على الويب390، ثم مرور نهائي ممثل للويب العريض/التكبير/اللغات والشاشات الأصلية الثلاث. لا تغيير إنتاجي بعد المرور الأول. فُحصت صور before الخمس المقدمة أيضًا. تعذر أمر تمرير آلي واحد على iOS من أداة التحكم؛ التنقل بالنقر نجح والصور الثلاث محفوظة. معداتي السفلية موثقة متصلة على الويب.

[مقارنة قبل وبعد](comparison.html)

## صور متصلة

- [after-ios-equipment-ar.png](after-ios-equipment-ar.png)
- [after-ios-home-ar.png](after-ios-home-ar.png)
- [after-ios-more-ar.png](after-ios-more-ar.png)
- [after-web-equipment-ar-1440.png](after-web-equipment-ar-1440.png)
- [after-web-equipment-ar-390.png](after-web-equipment-ar-390.png)
- [after-web-home-ar-1440.png](after-web-home-ar-1440.png)
- [after-web-home-ar-390.png](after-web-home-ar-390.png)
- [after-web-home-equipment-ar-390.png](after-web-home-equipment-ar-390.png)
- [after-web-more-ar-1440.png](after-web-more-ar-1440.png)
- [after-web-more-ar-390.png](after-web-more-ar-390.png)
- [before-ios-equipment-ar.png](before-ios-equipment-ar.png)
- [before-ios-home-ar.png](before-ios-home-ar.png)
- [before-ios-more-ar.png](before-ios-more-ar.png)
- [before-web-equipment-ar-390.png](before-web-equipment-ar-390.png)
- [before-web-home-ar-390.png](before-web-home-ar-390.png)
- [before-web-home-equipment-ar-390.png](before-web-home-equipment-ar-390.png)
- [before-web-more-ar-390.png](before-web-more-ar-390.png)

## صور harness — ليست API حيًا

- [harness-equipment-ar-1440-1.0.png](harness-equipment-ar-1440-1.0.png)
- [harness-equipment-ar-320-1.6.png](harness-equipment-ar-320-1.6.png)
- [harness-equipment-ar-320-2.0.png](harness-equipment-ar-320-2.0.png)
- [harness-equipment-ar-390-1.0.png](harness-equipment-ar-390-1.0.png)
- [harness-equipment-en-1440-1.0.png](harness-equipment-en-1440-1.0.png)
- [harness-equipment-en-320-1.6.png](harness-equipment-en-320-1.6.png)
- [harness-equipment-en-320-2.0.png](harness-equipment-en-320-2.0.png)
- [harness-equipment-en-390-1.0.png](harness-equipment-en-390-1.0.png)
- [harness-equipment-ur-1440-1.0.png](harness-equipment-ur-1440-1.0.png)
- [harness-equipment-ur-320-1.6.png](harness-equipment-ur-320-1.6.png)
- [harness-equipment-ur-320-2.0.png](harness-equipment-ur-320-2.0.png)
- [harness-equipment-ur-390-1.0.png](harness-equipment-ur-390-1.0.png)
- [harness-home-ar-1440-1.0.png](harness-home-ar-1440-1.0.png)
- [harness-home-ar-320-1.6.png](harness-home-ar-320-1.6.png)
- [harness-home-ar-320-2.0.png](harness-home-ar-320-2.0.png)
- [harness-home-ar-390-1.0.png](harness-home-ar-390-1.0.png)
- [harness-home-en-1440-1.0.png](harness-home-en-1440-1.0.png)
- [harness-home-en-320-1.6.png](harness-home-en-320-1.6.png)
- [harness-home-en-320-2.0.png](harness-home-en-320-2.0.png)
- [harness-home-en-390-1.0.png](harness-home-en-390-1.0.png)
- [harness-home-ur-1440-1.0.png](harness-home-ur-1440-1.0.png)
- [harness-home-ur-320-1.6.png](harness-home-ur-320-1.6.png)
- [harness-home-ur-320-2.0.png](harness-home-ur-320-2.0.png)
- [harness-home-ur-390-1.0.png](harness-home-ur-390-1.0.png)
- [harness-more-ar-1440-1.0.png](harness-more-ar-1440-1.0.png)
- [harness-more-ar-320-1.6.png](harness-more-ar-320-1.6.png)
- [harness-more-ar-320-2.0.png](harness-more-ar-320-2.0.png)
- [harness-more-ar-390-1.0.png](harness-more-ar-390-1.0.png)
- [harness-more-en-1440-1.0.png](harness-more-en-1440-1.0.png)
- [harness-more-en-320-1.6.png](harness-more-en-320-1.6.png)
- [harness-more-en-320-2.0.png](harness-more-en-320-2.0.png)
- [harness-more-en-390-1.0.png](harness-more-en-390-1.0.png)
- [harness-more-ur-1440-1.0.png](harness-more-ur-1440-1.0.png)
- [harness-more-ur-320-1.6.png](harness-more-ur-320-1.6.png)
- [harness-more-ur-320-2.0.png](harness-more-ur-320-2.0.png)
- [harness-more-ur-390-1.0.png](harness-more-ur-390-1.0.png)
