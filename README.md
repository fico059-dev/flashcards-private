# تقدر – بطاقات تعليمية لاختبار القدرات

<p align="center"><img src="assets/images/logo_full.png" width="180" alt="شعار تقدر"></p>

«تقدر» تطبيق بطاقات تعليمية (Flashcards) للاستعداد لاختبار القدرات العامة في السعودية.
كل بطاقة تعرض سؤالاً على نمط الاختبار، وعند إظهار الإجابة يظهر **الحل مع شرح مفصّل**.
التطبيق يعمل كموقع ويب وكتطبيق iOS وAndroid، وهو مبني على أساس كود Flashpedz
مع تعريب كامل (RTL) وهوية ذهبية/بيضاء.

## الأقسام

| القسم | أمثلة الحزم |
|---|---|
| **لفظي** | التناظر اللفظي، إكمال الجمل، المفردة الشاذة، الخطأ السياقي، استيعاب المقروء |
| **كمي** | الجبر، الهندسة، النسبة والتناسب، الحساب والأعداد، الإحصاء، المقارنة |

كل حزمة تنتمي إلى قسم واحد (حقل `section` في Firestore: `verbal` أو `quant`)،
وتظهر في تبويبها الخاص في شريط التنقل السفلي.

## الميزات

- **تكرار متباعد (FSRS)**: البطاقات التي تخطئ فيها تظهر أكثر، والتي تتقنها تظهر أقل.
- **شرح لكل إجابة**: الإجابة الصحيحة + سبب صحتها (وسبب خطأ البدائل عند الحاجة).
- **جلسات مخصّصة**: اختر حزماً ووسوماً وعدد أسئلة، وتُنشأ الجلسة من Cloud Function.
- **حفظ وتجاهل البطاقات**، ومراجعة المحفوظة، وتتبّع التقدّم وسلسلة الأيام.
- **حزم مجانية ومدفوعة**: الحزم المدفوعة تُفتح باشتراك واحد (`taqdir_premium_monthly` / `_yearly`).
- **لوحة إدارة** داخل التطبيق: إنشاء حزم وبطاقات، استيراد من Anki، إدارة البلاغات، تعيين مشرفين.
- **بحث** (اختياري) عبر Algolia.

## البنية

```
lib/            تطبيق Flutter (MVVM + BLoC، auto_route، Firebase)
functions/      Cloud Functions (Node 22): الإدارة، الجلسات المخصّصة، التحقق من المشتريات، Algolia
scripts/        seed.js (بيانات تجريبية) و make-admin.js (أول مشرف)
firestore.rules / storage.rules / firestore.indexes.json
design/         مصدر الشعار (SVG) والخط المستخدم فيه
```

لتشغيل المشروع وإعداد Firebase ونشر الموقع والتطبيق، راجع **[SETUP_AR.md](SETUP_AR.md)**.

## تشغيل سريع (محلياً على المحاكي)

```bash
# 1) المحاكيات + بيانات تجريبية
npm --prefix functions install && npm --prefix scripts install
firebase emulators:start --only auth,firestore,functions,storage --project demo-taqdir
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 node scripts/seed.js --project demo-taqdir

# 2) التطبيق على الويب
flutter run -d chrome -t lib/main_prod.dart --dart-define=USE_EMULATOR=true
```

## الاختبارات

```bash
flutter test                                   # اختبارات الواجهة
firebase emulators:exec --only auth,firestore,functions,storage \
  --project demo-taqdir "npm --prefix functions test"   # الدوال وقواعد Firestore
```

## الرخص

- الخط [IBM Plex Sans Arabic](https://github.com/IBM/plex) (واجهة) و[Tajawal](https://fonts.google.com/specimen/Tajawal) (الشعار) – SIL Open Font License.
