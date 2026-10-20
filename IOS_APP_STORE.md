# Publishing Taqdir on the App Store (iOS)

Checklist from a fresh Mac to an app live on the App Store.
Everything in the repo is already prepared: bundle ID `sa.taqdir.app`, iOS 15+,
iPhone-only, Arabic as the main language, portrait only, account deletion,
restore purchases, and subscription disclosure with privacy/terms links on the paywall.

## 1. Accounts and tools

- **Apple Developer Program**: [developer.apple.com/programs](https://developer.apple.com/programs/enroll/) ($99/year).
  Enrol as an *individual*, or as an *organization* if you have a commercial registration and a D-U-N-S number.
  Approval can take 1–2 days.
- **Xcode**: install it from the Mac App Store, open it once, and accept the licence.
- **CocoaPods**: `brew install cocoapods` (or `sudo gem install cocoapods`).

## 2. Paperwork in App Store Connect (do this early, it blocks purchases)

[appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **Business** (or *Agreements, Tax, and Banking*):
sign the **Paid Apps Agreement**, then add your bank account and tax forms.
Subscriptions won't work, even in testing, until this is *Active*.

## 3. Create the app record

**Apps → + → New App**
- Platform: iOS · Name: **تقدر** (if it's taken, try "تقدر - قدرات")
- Primary language: **Arabic** · Bundle ID: `sa.taqdir.app`.
  If it isn't in the list, register it first at developer.apple.com → Certificates, IDs & Profiles → Identifiers → +.
- SKU: `taqdir-ios`

## 4. Subscriptions

App → **Monetization → Subscriptions** → create a group "تقدر المميّز", then add:

| Product ID | Duration |
|---|---|
| `taqdir_premium_monthly` | 1 month |
| `taqdir_premium_yearly` | 1 year |

For each one: set a price, add an Arabic display name and description, and attach a review
screenshot of the paywall (Home → «الاشتراك المميّز»).

Then **App Information → App-Specific Shared Secret → Generate**, put it in `functions/.env`
as `APPLE_SHARED_SECRET=...`, and run `firebase deploy --only functions`.

## 5. Build and upload

```bash
cd taqdir
git pull
flutter clean && flutter pub get
cd ios && pod install --repo-update && cd ..
open ios/Runner.xcworkspace
```

In Xcode: **Runner** target → **Signing & Capabilities**
1. Tick *Automatically manage signing* and pick your **Team**.
2. **+ Capability → In-App Purchase**.

Then:

```bash
flutter build ipa -t lib/main_prod.dart --release
```

Upload `build/ios/ipa/*.ipa` with the **Transporter** app (Mac App Store), or use
Xcode → Product → Archive → Distribute App. Every upload needs a higher build number:
bump the `+1` in `pubspec.yaml` (`version: 1.0.0+2`, `+3`, …).

## 6. Test with TestFlight

After 10–30 minutes of processing, the build shows up under **TestFlight**. Add yourself as an
internal tester and install it with the TestFlight app on your iPhone. Check:

- Register, verify your email, and log in
- Open a verbal pack and a quant pack, reveal answers, and rate cards
- Buy a subscription. TestFlight purchases are free sandbox purchases, and paid packs should unlock.
- Restore purchases
- Delete account

## 7. The store listing (App Store tab)

- **Screenshots**: 6.9" iPhone, 1320 × 2868 px, 3–10 images. Take them on an iPhone 16 Pro Max
  simulator (`open -a Simulator`, then `Cmd+S` saves a screenshot).
- **Promotional text / description / keywords** (Arabic). Keyword ideas:
  `قدرات,قياس,لفظي,كمي,اختبار القدرات,بطاقات,مراجعة,ثانوي,تحصيلي`
- **Support URL**: `https://taqdir-c88f0.web.app`
- **Privacy Policy URL**: `https://taqdir-c88f0.web.app/privacy.html`
- **Category**: Education · **Age rating**: 4+
- **App Privacy** questionnaire. Data collected and linked to the user:
  *Contact Info* (name, email, phone), *Usage Data* (product interaction), *Purchases*.
  Purpose: *App Functionality*. **Not** used for tracking.
- **Sign-in information for App Review** (required because the app needs an account):
  create a test account in the app, verify its email, and put the email and password here.
  Give it a temporary premium grant so the reviewer can see paid packs, or note that paid packs
  are unlocked via the sandbox subscription.
- Attach both subscriptions to the version (section *In-App Purchases and Subscriptions*).

Then click **Add for Review → Submit**. Review usually takes 1–3 days.

## Common rejection reasons (already handled)

| Guideline | Status |
|---|---|
| 5.1.1(v) Account deletion in app | ✔ Profile → Privacy & Security → Delete account |
| 3.1.1 Restore purchases | ✔ Button on paywall |
| 3.1.2 Subscription terms + privacy/terms links | ✔ Paywall text and links |
| 2.1 Demo account for review | ⚠ You must provide one (step 7) |
| 4.0 / 5.2 Not affiliated with Qiyas | ✔ Stated in the terms. Don't use the official Qiyas logo or name as the app name. |
