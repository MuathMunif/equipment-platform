# M2 — مصروف جزئي أو غير مدفوع ودفعات مؤرخة

الحالة: شريحة محلية منفذة في 2026-09-24. بقية M2 وV1 غير مكتملة.

## النطاق
- إنشاء مصروف كامل/جزئي/غير مدفوع من واجهة عربية؛ الجزء الأول دفعة في الأصل نفسه.
- اسم الطرف إلزامي عند وجود متبقٍ، والموعد اختياري. الحالة والرصيد محسوبان من الدفعات المحفوظة.
- إضافة دفعات لاحقة مؤرخة إلى المصروف نفسه، مع منع الدفع الزائد والتكرار والتسوية المتزامنة الزائدة.
- Flyway V2 تضيف `party_name` و`due_date` دون تعديل سجلات M1 القديمة؛ عقد OpenAPI محدّث.

## التحقق
- PASS: `MAVEN_USER_HOME=/Users/muath/Desktop/equipment-platform/.local/maven-user JAVA_HOME=/Users/muath/Library/Java/JavaVirtualMachines/ms-21.0.7/Contents/Home ./mvnw -B -ntp -q -Dmaven.repo.local=/Users/muath/Desktop/equipment-platform/.local/m2 test` من `backend/`؛ 14 اختبار HTTP/PostgreSQL، بلا فشل، على قاعدة `equipment_test` المعزولة. يشمل FIN-02/03/05/06/08 للمصروف.
- PASS: `dart format lib/main.dart test/widget_test.dart`, `flutter analyze`, `flutter test` من `app/`؛ 8 اختبارات widget/unit، بلا فشل.
- PASS: تحليل YAML لعقد OpenAPI بواسطة Ruby Psych، و`git diff --check`.
- NOT RUN: فحص شاشة M2 يدوي على ويب/جوال حقيقي، iOS integration بعد هذه الإضافة، Android native، مزود S3 خاص وفحص البرمجيات الخبيثة. اختبار الواجهة يستخدم MockClient؛ اختبارات الخادم تستخدم PostgreSQL وHTTP فعليين.

## متابعة
أول عمل مناسب بعد هذه الشريحة: التحقق اليدوي لرحلة المصروف الجزئي على الويب بعرض ضيق وعريض، ثم مهمة دخل جزئي/غير مستلم مستقلة. لا يُعد M2 مكتملًا قبل بقية عناصر القائمة وتكامل التخزين المختار.
