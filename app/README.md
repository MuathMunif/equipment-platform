# تطبيق إدارة المعدات

تطبيق Flutter عربي للجوال والويب، موصول بـAPI محلي فعلي. ابدأ من [تعليمات المشروع](../README.md) لمعرفة تشغيل API/PostgreSQL والدخول التطويري وقيود الملفات والجلسات.

```sh
flutter pub get
flutter analyze
flutter test
flutter build web --release --dart-define=API_BASE_URL=http://127.0.0.1:8080/api/v1
```

`API_BASE_URL` يحدد خادم التطوير؛ الإعداد الافتراضي هو loopback8080. لا توجد بيانات إنتاج أو مفاتيح مزودين في التطبيق.
