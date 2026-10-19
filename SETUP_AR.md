# إعداد «تقدر» من الصفر

هذا الدليل يأخذك من مستودع فارغ إلى تطبيق يعمل على الويب وiOS وAndroid.

## المتطلبات

- Flutter 3.35+ (`flutter doctor`)
- Node.js 22 و npm
- Firebase CLI: `npm i -g firebase-tools` ثم `firebase login`
- FlutterFire CLI: `dart pub global activate flutterfire_cli`
- لبناء iOS: جهاز Mac مع Xcode وحساب Apple Developer
- لبناء Android: Android Studio

## 1) مشروع Firebase

1. أنشئ مشروعاً في [console.firebase.google.com](https://console.firebase.google.com).
2. فعّل **Authentication → Email/Password**.
3. أنشئ قاعدة **Firestore** (وضع الإنتاج) و**Storage**.
4. غيّر خطة الفوترة إلى **Blaze** (Cloud Functions تحتاجها، والاستخدام الصغير ضمن الحد المجاني).
5. أضف التطبيقات (Web + iOS + Android) ثم ولّد ملف الإعداد:

```bash
flutterfire configure --project=YOUR_PROJECT_ID \
  --platforms=android,ios,web --out=lib/firebase_options.dart \
  --ios-bundle-id=sa.taqdir.app --android-package-name=sa.taqdir.app
```

هذا يستبدل `lib/firebase_options.dart` (القالب الحالي فيه `REPLACE_ME`) وينشئ
`android/app/google-services.json` و`ios/Runner/GoogleService-Info.plist`.

> لو غيّرت المعرّف `sa.taqdir.app`، عدّله أيضاً في `android/app/build.gradle.kts`
> و`ios/Runner.xcodeproj/project.pbxproj` و`functions/.env` (`ANDROID_PACKAGE_NAME`).

6. اربط المستودع بالمشروع:

```bash
# عدّل .firebaserc وضع معرّف مشروعك بدل YOUR_FIREBASE_PROJECT_ID
firebase use YOUR_PROJECT_ID
```

## 2) الباك إند (قواعد + فهارس + دوال)

```bash
cp functions/.env.example functions/.env     # واملأ القيم (انظر أدناه)
npm --prefix functions install
firebase deploy --only firestore,storage,functions
```

متغيرات `functions/.env`:

| المتغير | الوصف |
|---|---|
| `ANDROID_PACKAGE_NAME` | معرّف التطبيق في Google Play (`sa.taqdir.app`) |
| `APPLE_SHARED_SECRET` | App Store Connect → App → App Information → App-Specific Shared Secret |
| `ALGOLIA_*` | اختياري؛ اتركه فارغاً لتعطيل البحث |
| `ALLOW_DEV_GRANT` | `true` في بيئة التجربة فقط (يتيح للمشرف تفعيل اشتراك مؤقت من زر داخل التطبيق في وضع debug) |

للتحقق من مشتريات Google Play، أعطِ حساب خدمة الدوال (`PROJECT_ID@appspot.gserviceaccount.com`)
صلاحية **View financial data** في Google Play Console → Users and permissions.

## 3) البيانات التجريبية وأول مشرف

```bash
# مفتاح حساب خدمة من: Project settings → Service accounts → Generate new private key
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json
npm --prefix scripts install
node scripts/seed.js --project YOUR_PROJECT_ID
```

يضيف `seed.js` 11 حزمة (5 لفظي + 6 كمي) و53 بطاقة تجريبية من `scripts/qudurat_sample.js`.
استبدلها ببنك أسئلتك: كل عنصر فيه `section` و`name` و`isPaid` و`cards[]` بحقلي
`question` و`answer` (الإجابة تحتوي الشرح). أو استورد من Anki عبر لوحة الإدارة.

سجّل حساباً من التطبيق ثم اجعله مشرفاً:

```bash
node scripts/make-admin.js --project YOUR_PROJECT_ID you@example.com
```

بعدها سجّل خروجاً ودخولاً؛ سيظهر زر **لوحة الإدارة** في صفحة الملف الشخصي.

## 4) تشغيل التطبيق

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # عند تعديل الموديلات/المسارات فقط
flutter run -d chrome -t lib/main_prod.dart                 # ويب
flutter run -t lib/main_prod.dart                           # جوال متصل
```

خيارات `--dart-define`:

- `USE_EMULATOR=true` للعمل على Firebase Emulators (و`EMULATOR_HOST=10.0.2.2` لمحاكي Android).
- `ALGOLIA_APP_ID` و`ALGOLIA_SEARCH_KEY` (مفتاح البحث فقط) لتفعيل البحث.

## 5) النشر

### الموقع (Firebase Hosting)

```bash
flutter build web -t lib/main_prod.dart --release
firebase deploy --only hosting
```

أضف نطاقك من Hosting → Add custom domain، وأضفه أيضاً في
Authentication → Settings → Authorized domains.

### iOS

1. `open ios/Runner.xcworkspace` واختر فريق التوقيع (Signing & Capabilities) وفعّل **In-App Purchase**.
2. في App Store Connect أنشئ التطبيق بالمعرّف `sa.taqdir.app` واشتراكين تلقائيي التجديد:
   `taqdir_premium_monthly` و`taqdir_premium_yearly`.
3. `flutter build ipa -t lib/main_prod.dart --release` ثم ارفعه عبر Transporter أو Xcode.

### Android

1. في Google Play Console أنشئ التطبيق والاشتراكين بنفس المعرّفين أعلاه.
2. أنشئ مفتاح توقيع (`keytool`) واضبطه في `android/key.properties` كالمعتاد في Flutter.
3. `flutter build appbundle -t lib/main_prod.dart --release --flavor prod`.

## 6) تشغيل محلي كامل بالمحاكيات

```bash
firebase emulators:start --only auth,firestore,functions,storage --project demo-taqdir
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 node scripts/seed.js --project demo-taqdir
flutter run -d chrome -t lib/main_prod.dart --dart-define=USE_EMULATOR=true
```

> في وضع المحاكي يكفي أن يحتوي `firebase_options.dart` على `projectId: 'demo-taqdir'`
> وأي قيم غير فارغة للحقول الأخرى.

واختبارات الدوال والقواعد:

```bash
firebase emulators:exec --only auth,firestore,functions,storage \
  --project demo-taqdir "npm --prefix functions test"
```

## بنية Firestore

| المجموعة | الوصف |
|---|---|
| `packs/{id}` | `name, section (verbal/quant), isPaid, flashcardsCount, tags[], tagCounts{}` + `flashcard_ids/all_ids` |
| `flashcards/{id}` | `packId, question, answer, isPaid, tags[], questionImageUrl?, answerImageUrl?` |
| `tags/{id}` | `name` |
| `users/{uid}` | الملف الشخصي والإعدادات |
| `fcp_data/{uid}_{flashcardId}` | حالة FSRS لكل بطاقة ومستخدم + حفظ/تجاهل + لقطة البطاقة |
| `pp_data/{uid}_{packId}` | متى فُتحت الحزمة |
| `custom_sessions/{id}` | الجلسات المخصّصة (تُنشأ من الدالة) |
| `flashcard_reports/{flashcardId}/user_reports/{uid}` | البلاغات |
| `purchases/{uid}` | سجل الاشتراك (كتابة من الخادم فقط) |

صلاحيات المستخدم في custom claims: `roles: ["admin"]`، `premiumExp` (مللي ثانية)،
أو `entitlements: ["premium"]` لاشتراك دائم.
