import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @highSchoolStudent.
  ///
  /// In ar, this message translates to:
  /// **'طالب ثانوي'**
  String get highSchoolStudent;

  /// No description provided for @graduate.
  ///
  /// In ar, this message translates to:
  /// **'خريج'**
  String get graduate;

  /// No description provided for @universityStudent.
  ///
  /// In ar, this message translates to:
  /// **'طالب جامعي'**
  String get universityStudent;

  /// No description provided for @otherLevel.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get otherLevel;

  /// No description provided for @homePage_title.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get homePage_title;

  /// No description provided for @registerPage_header.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ استعدادك للقدرات اليوم!'**
  String get registerPage_header;

  /// No description provided for @basicText_name.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الأول'**
  String get basicText_name;

  /// No description provided for @basicText_surname.
  ///
  /// In ar, this message translates to:
  /// **'اسم العائلة'**
  String get basicText_surname;

  /// No description provided for @basicText_email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get basicText_email;

  /// No description provided for @basicText_phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال'**
  String get basicText_phoneNumber;

  /// No description provided for @basicText_educationLevel.
  ///
  /// In ar, this message translates to:
  /// **'المستوى الدراسي'**
  String get basicText_educationLevel;

  /// No description provided for @basicText_password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get basicText_password;

  /// No description provided for @basicText_repeatPassword.
  ///
  /// In ar, this message translates to:
  /// **'أعد كتابة كلمة المرور'**
  String get basicText_repeatPassword;

  /// No description provided for @basicText_register.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get basicText_register;

  /// No description provided for @basicText_alreadyAMember.
  ///
  /// In ar, this message translates to:
  /// **'عندك حساب؟'**
  String get basicText_alreadyAMember;

  /// No description provided for @basicText_signInNow.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get basicText_signInNow;

  /// No description provided for @basicText_forgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور'**
  String get basicText_forgotPassword;

  /// No description provided for @basicText_notAMember.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك حساب؟'**
  String get basicText_notAMember;

  /// No description provided for @basicText_sendEmail.
  ///
  /// In ar, this message translates to:
  /// **'إرسال البريد'**
  String get basicText_sendEmail;

  /// No description provided for @basicText_update.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get basicText_update;

  /// No description provided for @basicText_tryAgain.
  ///
  /// In ar, this message translates to:
  /// **'حاول مرة أخرى'**
  String get basicText_tryAgain;

  /// No description provided for @basicText_profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get basicText_profile;

  /// No description provided for @basicText_edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get basicText_edit;

  /// No description provided for @basicText_cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get basicText_cancel;

  /// No description provided for @basicText_save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get basicText_save;

  /// No description provided for @basicText_other.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get basicText_other;

  /// No description provided for @basicText_logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get basicText_logout;

  /// No description provided for @basicText_signOut.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get basicText_signOut;

  /// No description provided for @basicText_goToLogin.
  ///
  /// In ar, this message translates to:
  /// **'الذهاب لتسجيل الدخول'**
  String get basicText_goToLogin;

  /// No description provided for @registerPage_successfulRegister.
  ///
  /// In ar, this message translates to:
  /// **'مبروك {displayName}، تم إنشاء حسابك بنجاح!'**
  String registerPage_successfulRegister(String displayName);

  /// No description provided for @loginPage_welcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بعودتك إلى تقدر، اشتقنا لك'**
  String get loginPage_welcomeBack;

  /// No description provided for @loginPage_welcomeBackMember.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بعودتك {displayName}!'**
  String loginPage_welcomeBackMember(String displayName);

  /// No description provided for @forgotPasswordPage_emailSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رسالة التحقق. تفقّد بريدك الوارد'**
  String get forgotPasswordPage_emailSent;

  /// No description provided for @forgotPasswordPage_enterEmail.
  ///
  /// In ar, this message translates to:
  /// **'أدخل البريد الإلكتروني المرتبط بحسابك.'**
  String get forgotPasswordPage_enterEmail;

  /// No description provided for @verifyEmailPage_success.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رسالة توثيق البريد بنجاح!'**
  String get verifyEmailPage_success;

  /// No description provided for @personalInformationPage_personalInformation.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الشخصية'**
  String get personalInformationPage_personalInformation;

  /// No description provided for @privacySecurityPage_title.
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية والأمان'**
  String get privacySecurityPage_title;

  /// No description provided for @privacySecurityPage_changeEmail.
  ///
  /// In ar, this message translates to:
  /// **'تغيير البريد الإلكتروني'**
  String get privacySecurityPage_changeEmail;

  /// No description provided for @privacySecurityPage_verified.
  ///
  /// In ar, this message translates to:
  /// **'موثّق'**
  String get privacySecurityPage_verified;

  /// No description provided for @privacySecurityPage_changePassword.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get privacySecurityPage_changePassword;

  /// No description provided for @privacySecurityPage_hiddenPassword.
  ///
  /// In ar, this message translates to:
  /// **'••••••••'**
  String get privacySecurityPage_hiddenPassword;

  /// No description provided for @privacySecurityPage_changePhone.
  ///
  /// In ar, this message translates to:
  /// **'تغيير رقم الجوال'**
  String get privacySecurityPage_changePhone;

  /// No description provided for @privacySecurityPage_notVerified.
  ///
  /// In ar, this message translates to:
  /// **'غير موثّق'**
  String get privacySecurityPage_notVerified;

  /// No description provided for @privacySecurityPage_deleteAccount.
  ///
  /// In ar, this message translates to:
  /// **'حذف حسابك'**
  String get privacySecurityPage_deleteAccount;

  /// No description provided for @privacySecurityPage_deleteAccountSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف حسابك نهائياً'**
  String get privacySecurityPage_deleteAccountSubtitle;

  /// No description provided for @privacySecurityPage_pendingVerification.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار التوثيق'**
  String get privacySecurityPage_pendingVerification;

  /// No description provided for @privacySecurityPage_changeEmailText.
  ///
  /// In ar, this message translates to:
  /// **'لتغيير بريدك أكمل العملية من صفحة تغيير البريد. توثيقه من مكان آخر قد يسبب مشاكل. إذا غيّرت رأيك فتجاهل هذا الأمر بأمان.'**
  String get privacySecurityPage_changeEmailText;

  /// No description provided for @profilePage_errorMessage.
  ///
  /// In ar, this message translates to:
  /// **'{errorMessage}'**
  String profilePage_errorMessage(String errorMessage);

  /// No description provided for @deleteAccountSuccessfulPage_message.
  ///
  /// In ar, this message translates to:
  /// **'حزنّا لمغادرتك. تم حذف حسابك وجميع بياناتك بنجاح.'**
  String get deleteAccountSuccessfulPage_message;

  /// No description provided for @deleteAccountSuccessfulPage_button.
  ///
  /// In ar, this message translates to:
  /// **'الذهاب لتسجيل الدخول'**
  String get deleteAccountSuccessfulPage_button;

  /// No description provided for @authErrorContainer_verifyEmailSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم! الآن لنوثّق بريدك الإلكتروني'**
  String get authErrorContainer_verifyEmailSuccess;

  /// No description provided for @reauthSection_securityNotice.
  ///
  /// In ar, this message translates to:
  /// **'لأسباب أمنية، أكّد هويتك من فضلك.'**
  String get reauthSection_securityNotice;

  /// No description provided for @reauthSection_passwordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get reauthSection_passwordLabel;

  /// No description provided for @reauthSection_button.
  ///
  /// In ar, this message translates to:
  /// **'إعادة التحقق'**
  String get reauthSection_button;

  /// No description provided for @reauthSection_success.
  ///
  /// In ar, this message translates to:
  /// **'تم التحقق بنجاح. سيتم إكمال العملية السابقة الآن.'**
  String get reauthSection_success;

  /// No description provided for @reauthSection_info.
  ///
  /// In ar, this message translates to:
  /// **'قد يُطلب منك تأكيد هويتك.'**
  String get reauthSection_info;

  /// No description provided for @loadingProfileData_message.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحميل ملفك الشخصي...'**
  String get loadingProfileData_message;

  /// No description provided for @profileReaderBlocBuilder_neverLoaded.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تحميل الملف الشخصي.'**
  String get profileReaderBlocBuilder_neverLoaded;

  /// No description provided for @readProfileErrorScreen_errorMessage.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء تحميل ملفك الشخصي.'**
  String get readProfileErrorScreen_errorMessage;

  /// No description provided for @personalInfoContent_updateSuccessMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث معلوماتك الشخصية بنجاح!'**
  String get personalInfoContent_updateSuccessMessage;

  /// No description provided for @profileData_accountSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الحساب'**
  String get profileData_accountSettings;

  /// No description provided for @profileData_personalInformation.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الشخصية'**
  String get profileData_personalInformation;

  /// No description provided for @profileData_privacySecurity.
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية والأمان'**
  String get profileData_privacySecurity;

  /// No description provided for @profileData_billingDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الاشتراك'**
  String get profileData_billingDetails;

  /// No description provided for @profileData_flashcards.
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة'**
  String get profileData_flashcards;

  /// No description provided for @profileData_flashcardSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات المذاكرة'**
  String get profileData_flashcardSettings;

  /// No description provided for @profileData_bookmarkedFlashcards.
  ///
  /// In ar, this message translates to:
  /// **'البطاقات المحفوظة'**
  String get profileData_bookmarkedFlashcards;

  /// No description provided for @profileData_privacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get profileData_privacyPolicy;

  /// No description provided for @verifyEmailActionButtons_changeEmail.
  ///
  /// In ar, this message translates to:
  /// **'تغيير البريد'**
  String get verifyEmailActionButtons_changeEmail;

  /// No description provided for @verifyEmailHeadline_sendingVerificationLink.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ إرسال رابط التوثيق...'**
  String get verifyEmailHeadline_sendingVerificationLink;

  /// No description provided for @verifyEmailHeadline_refreshingApplicationState.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحديث حالة التطبيق...'**
  String get verifyEmailHeadline_refreshingApplicationState;

  /// No description provided for @verifyEmailHeadline_errorSendingVerificationLink.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إرسال رابط التوثيق، حاول لاحقاً'**
  String get verifyEmailHeadline_errorSendingVerificationLink;

  /// No description provided for @verifyEmailHeadline_verifyYourEmailAddress.
  ///
  /// In ar, this message translates to:
  /// **'وثّق بريدك الإلكتروني'**
  String get verifyEmailHeadline_verifyYourEmailAddress;

  /// No description provided for @verifyEmailInfoSection_emailSentMessage1.
  ///
  /// In ar, this message translates to:
  /// **'شكراً لتسجيلك! أرسلنا رسالة توثيق إلى بريدك.'**
  String get verifyEmailInfoSection_emailSentMessage1;

  /// No description provided for @verifyEmailInfoSection_emailSentMessage2.
  ///
  /// In ar, this message translates to:
  /// **'افتح بريدك واضغط على رابط التوثيق لتفعيل حسابك.'**
  String get verifyEmailInfoSection_emailSentMessage2;

  /// No description provided for @verifyEmailInfoSection_twoEmailsDetectedMessage.
  ///
  /// In ar, this message translates to:
  /// **'أرسلنا روابط توثيق للبريدين.\nأول رابط تضغط عليه يحدد البريد المحفوظ في ملفك.'**
  String get verifyEmailInfoSection_twoEmailsDetectedMessage;

  /// No description provided for @verifyEmailResendLinkButton_successMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رسالة التوثيق بنجاح!'**
  String get verifyEmailResendLinkButton_successMessage;

  /// No description provided for @verifyEmailResendLinkButton_resendLinkButtonText.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرابط'**
  String get verifyEmailResendLinkButton_resendLinkButtonText;

  /// No description provided for @verifyEmailResendLinkButton_waitButtonText.
  ///
  /// In ar, this message translates to:
  /// **'انتظر...'**
  String get verifyEmailResendLinkButton_waitButtonText;

  /// No description provided for @error_requiresRecentLogin.
  ///
  /// In ar, this message translates to:
  /// **'لأسباب أمنية، أعد تسجيل الدخول لإكمال هذا الإجراء.'**
  String get error_requiresRecentLogin;

  /// No description provided for @error_invalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'صيغة البريد الإلكتروني غير صحيحة.'**
  String get error_invalidEmail;

  /// No description provided for @error_userDisabled.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحساب معطّل.'**
  String get error_userDisabled;

  /// No description provided for @error_userNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد حساب بهذا البريد.'**
  String get error_userNotFound;

  /// No description provided for @error_wrongPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور غير صحيحة. حاول مرة أخرى.'**
  String get error_wrongPassword;

  /// No description provided for @error_tooManyRequests.
  ///
  /// In ar, this message translates to:
  /// **'أرسلت طلبات كثيرة، حاول لاحقاً'**
  String get error_tooManyRequests;

  /// No description provided for @error_tokenExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الجلسة، سجّل الدخول من جديد.'**
  String get error_tokenExpired;

  /// No description provided for @error_networkIssue.
  ///
  /// In ar, this message translates to:
  /// **'مشكلة في الشبكة، تحقق من اتصالك بالإنترنت'**
  String get error_networkIssue;

  /// No description provided for @error_invalidCredential.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الدخول غير صحيحة، حاول مرة أخرى'**
  String get error_invalidCredential;

  /// No description provided for @error_operationNotAllowed.
  ///
  /// In ar, this message translates to:
  /// **'مشكلة في إعدادات المصادقة، تواصل مع المطوّر'**
  String get error_operationNotAllowed;

  /// No description provided for @error_emailAlreadyInUse.
  ///
  /// In ar, this message translates to:
  /// **'هذا البريد مستخدم مسبقاً، جرّب بريداً آخر.'**
  String get error_emailAlreadyInUse;

  /// No description provided for @error_authFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل تسجيل الدخول. حاول مرة أخرى.'**
  String get error_authFailed;

  /// No description provided for @error_unexpected.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع. حاول مرة أخرى.'**
  String get error_unexpected;

  /// No description provided for @error_passwordRequirement.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور لا تحقق شروط الأمان.'**
  String get error_passwordRequirement;

  /// No description provided for @error_passwordNonAlphanumeric.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن تحتوي كلمة المرور على رمز خاص.'**
  String get error_passwordNonAlphanumeric;

  /// No description provided for @error_passwordEightCharacters.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن تحتوي كلمة المرور على 8 خانات على الأقل.'**
  String get error_passwordEightCharacters;

  /// No description provided for @error_passwordUpperCase.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن تحتوي كلمة المرور على حرف إنجليزي كبير.'**
  String get error_passwordUpperCase;

  /// No description provided for @error_passwordNumeric.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن تحتوي كلمة المرور على رقم.'**
  String get error_passwordNumeric;

  /// No description provided for @error_loadingBookmarks.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل البطاقات المحفوظة، حاول مرة أخرى'**
  String get error_loadingBookmarks;

  /// No description provided for @error_loadingPacks.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الحزم 😔'**
  String get error_loadingPacks;

  /// No description provided for @flashcardMainCard_packFinished.
  ///
  /// In ar, this message translates to:
  /// **'أحسنت!'**
  String get flashcardMainCard_packFinished;

  /// No description provided for @flashcardMainButton_reveal.
  ///
  /// In ar, this message translates to:
  /// **'إظهار الإجابة'**
  String get flashcardMainButton_reveal;

  /// No description provided for @flashcardMainButton_skip.
  ///
  /// In ar, this message translates to:
  /// **'تخطّي'**
  String get flashcardMainButton_skip;

  /// No description provided for @flashcardPageDialog_packFinishedForNow.
  ///
  /// In ar, this message translates to:
  /// **'خلصت، الحين'**
  String get flashcardPageDialog_packFinishedForNow;

  /// No description provided for @flashcardPageDialog_packEnded.
  ///
  /// In ar, this message translates to:
  /// **'مبروك! ما فيه بطاقات مستحقة من {subTextForDialog} الحين، ارجع لاحقاً.\n\nاستمر على هذا المستوى.'**
  String flashcardPageDialog_packEnded(String subTextForDialog);

  /// No description provided for @flashcardPageDialog_backHome.
  ///
  /// In ar, this message translates to:
  /// **'العودة للرئيسية'**
  String get flashcardPageDialog_backHome;

  /// No description provided for @flashcardPageDialog_sessionFinishedForNow.
  ///
  /// In ar, this message translates to:
  /// **'انتهت جلسة المذاكرة، الحين'**
  String get flashcardPageDialog_sessionFinishedForNow;

  /// No description provided for @flashcardPageDialog_sessionEnded.
  ///
  /// In ar, this message translates to:
  /// **'مبروك! أنهيت هذه الجلسة.'**
  String get flashcardPageDialog_sessionEnded;

  /// No description provided for @flashcardPageDialog_closeSession.
  ///
  /// In ar, this message translates to:
  /// **'تقدر تقفل الجلسة أو تكمل المذاكرة.'**
  String get flashcardPageDialog_closeSession;

  /// No description provided for @flashcardPageDialog_continueLearning.
  ///
  /// In ar, this message translates to:
  /// **'أكمل المذاكرة'**
  String get flashcardPageDialog_continueLearning;

  /// No description provided for @flashcardPageDialog_endThisSession.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء هذه الجلسة؟'**
  String get flashcardPageDialog_endThisSession;

  /// No description provided for @flashcardPageDialog_updateCardsPerSession.
  ///
  /// In ar, this message translates to:
  /// **'راجعت {cardDifference} بطاقة أكثر من هدفك وهو {userCardsPerSession} بطاقة في الجلسة.\n\nتبي تحدّث هدفك إلى {newCardsPerSession} بطاقة في الجلسة؟\n\nتقدر تغيّره دائماً من الإعدادات.'**
  String flashcardPageDialog_updateCardsPerSession(
    int cardDifference,
    int userCardsPerSession,
    int newCardsPerSession,
  );

  /// No description provided for @flashcardPageDialog_keepCurrent.
  ///
  /// In ar, this message translates to:
  /// **'إبقاء الحالي'**
  String get flashcardPageDialog_keepCurrent;

  /// No description provided for @flashcardPageDialog_updateTarget.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الهدف'**
  String get flashcardPageDialog_updateTarget;

  /// No description provided for @flashcardRatingButtons_easyLabel.
  ///
  /// In ar, this message translates to:
  /// **'سهل'**
  String get flashcardRatingButtons_easyLabel;

  /// No description provided for @flashcardRatingButtons_easyTooltip.
  ///
  /// In ar, this message translates to:
  /// **'عرفتها فوراً وبثقة.'**
  String get flashcardRatingButtons_easyTooltip;

  /// No description provided for @flashcardRatingButtons_goodLabel.
  ///
  /// In ar, this message translates to:
  /// **'جيد'**
  String get flashcardRatingButtons_goodLabel;

  /// No description provided for @flashcardRatingButtons_goodTooltip.
  ///
  /// In ar, this message translates to:
  /// **'تذكرتها لكن احتجت أفكر شوي.'**
  String get flashcardRatingButtons_goodTooltip;

  /// No description provided for @flashcardRatingButtons_hardLabel.
  ///
  /// In ar, this message translates to:
  /// **'صعب'**
  String get flashcardRatingButtons_hardLabel;

  /// No description provided for @flashcardRatingButtons_hardTooltip.
  ///
  /// In ar, this message translates to:
  /// **'بالكاد تذكرتها.'**
  String get flashcardRatingButtons_hardTooltip;

  /// No description provided for @flashcardRatingButtons_againLabel.
  ///
  /// In ar, this message translates to:
  /// **'أعد'**
  String get flashcardRatingButtons_againLabel;

  /// No description provided for @flashcardRatingButtons_againTooltip.
  ///
  /// In ar, this message translates to:
  /// **'نسيتها أو أجبت خطأ.'**
  String get flashcardRatingButtons_againTooltip;

  /// No description provided for @flashcardTimerContainer.
  ///
  /// In ar, this message translates to:
  /// **'الوقت: {time}'**
  String flashcardTimerContainer(String time);

  /// No description provided for @flashcardPage_packTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحزمة'**
  String get flashcardPage_packTitle;

  /// No description provided for @flashcardPage_packSubtext.
  ///
  /// In ar, this message translates to:
  /// **'الحزمة'**
  String get flashcardPage_packSubtext;

  /// No description provided for @flashcardPage_bookmarksTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحفوظة'**
  String get flashcardPage_bookmarksTitle;

  /// No description provided for @flashcardPage_bookmarksSubtext.
  ///
  /// In ar, this message translates to:
  /// **'المحفوظة'**
  String get flashcardPage_bookmarksSubtext;

  /// No description provided for @reviewBookmarkPage_review.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة البطاقات المحفوظة'**
  String get reviewBookmarkPage_review;

  /// No description provided for @reviewBookmarkPage_noBookmarks.
  ///
  /// In ar, this message translates to:
  /// **'ما حفظت أي بطاقة للحين.'**
  String get reviewBookmarkPage_noBookmarks;

  /// No description provided for @reviewBookmarkPage_numberOfBookmarks.
  ///
  /// In ar, this message translates to:
  /// **'عدد البطاقات المحفوظة: {number}'**
  String reviewBookmarkPage_numberOfBookmarks(int number);

  /// No description provided for @reviewBookmarkPage_remove.
  ///
  /// In ar, this message translates to:
  /// **'إزالة من المحفوظة'**
  String get reviewBookmarkPage_remove;

  /// No description provided for @reviewBookmarkPage_swipe.
  ///
  /// In ar, this message translates to:
  /// **'اسحب لليسار لإزالة البطاقة'**
  String get reviewBookmarkPage_swipe;

  /// No description provided for @splashPageText.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تجهيز تجربتك...'**
  String get splashPageText;

  /// No description provided for @packsPage_title.
  ///
  /// In ar, this message translates to:
  /// **'الحزم'**
  String get packsPage_title;

  /// No description provided for @packsPage_fetching.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ جلب الحزم...'**
  String get packsPage_fetching;

  /// No description provided for @packsPage_noPacks.
  ///
  /// In ar, this message translates to:
  /// **'ما فيه حزم متاحة حالياً'**
  String get packsPage_noPacks;

  /// No description provided for @updateEmailSuccessfulPage_text.
  ///
  /// In ar, this message translates to:
  /// **'🎉 تم! تم تحديث بريدك الإلكتروني.\nاستخدم البريد الجديد عند تسجيل الدخول.'**
  String get updateEmailSuccessfulPage_text;

  /// No description provided for @updateEmailSuccessfulPage_button.
  ///
  /// In ar, this message translates to:
  /// **'الذهاب لتسجيل الدخول'**
  String get updateEmailSuccessfulPage_button;

  /// No description provided for @changeEmailDuringVerificationPage_text.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رسالة توثيق جديدة إلى {email}'**
  String changeEmailDuringVerificationPage_text(String email);

  /// No description provided for @changeEmailPage_leaveWithoutVerifying.
  ///
  /// In ar, this message translates to:
  /// **'تغادر بدون توثيق البريد؟'**
  String get changeEmailPage_leaveWithoutVerifying;

  /// No description provided for @changeEmailPage_text.
  ///
  /// In ar, this message translates to:
  /// **'لتغيير بريدك لازم تكمل التوثيق وأنت في هذه الصفحة.\n\nتوثيق البريد من صفحة أخرى قد يسبب سلوكاً غير متوقع.\n\nإذا غيّرت رأيك تقدر تغادر بأمان.'**
  String get changeEmailPage_text;

  /// No description provided for @changeEmailPage_stay.
  ///
  /// In ar, this message translates to:
  /// **'البقاء في الصفحة'**
  String get changeEmailPage_stay;

  /// No description provided for @changeEmailPage_leaveAnyway.
  ///
  /// In ar, this message translates to:
  /// **'المغادرة'**
  String get changeEmailPage_leaveAnyway;

  /// No description provided for @deleteProfilePage_deleteAccount.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get deleteProfilePage_deleteAccount;

  /// No description provided for @deleteProfilePage_areYouSure.
  ///
  /// In ar, this message translates to:
  /// **'متأكد إنك تبي تحذف حسابك نهائياً؟\n\nما يمكن التراجع عن هذا الإجراء وستفقد كل بياناتك.'**
  String get deleteProfilePage_areYouSure;

  /// No description provided for @updatePasswordPage_title.
  ///
  /// In ar, this message translates to:
  /// **'تحديث كلمة المرور'**
  String get updatePasswordPage_title;

  /// No description provided for @updatePasswordPage_update.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get updatePasswordPage_update;

  /// No description provided for @updatePasswordPage_success.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث كلمة المرور بنجاح'**
  String get updatePasswordPage_success;

  /// No description provided for @updatePasswordPage_password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get updatePasswordPage_password;

  /// No description provided for @updatePasswordPage_repeatPassword.
  ///
  /// In ar, this message translates to:
  /// **'أعد كتابة كلمة المرور'**
  String get updatePasswordPage_repeatPassword;

  /// No description provided for @profileData_bookmarks.
  ///
  /// In ar, this message translates to:
  /// **'المحفوظة'**
  String get profileData_bookmarks;

  /// No description provided for @profileData_chooseEngage.
  ///
  /// In ar, this message translates to:
  /// **'اختر كيف تحب تتعامل مع بطاقاتك المحفوظة.'**
  String get profileData_chooseEngage;

  /// No description provided for @profileData_review.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة البطاقات'**
  String get profileData_review;

  /// No description provided for @profileData_startTest.
  ///
  /// In ar, this message translates to:
  /// **'اختبر نفسك'**
  String get profileData_startTest;

  /// No description provided for @assignAdminPage_title.
  ///
  /// In ar, this message translates to:
  /// **'تعيين المشرفين'**
  String get assignAdminPage_title;

  /// No description provided for @flashcardBuilderPage_title.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المحتوى'**
  String get flashcardBuilderPage_title;

  /// No description provided for @reportFlashcardPage_success.
  ///
  /// In ar, this message translates to:
  /// **'تم الإبلاغ عن البطاقة بنجاح'**
  String get reportFlashcardPage_success;

  /// No description provided for @reportFlashcardPage_report.
  ///
  /// In ar, this message translates to:
  /// **'الإبلاغ عن بطاقة'**
  String get reportFlashcardPage_report;

  /// No description provided for @reportFlashcardPage_whyReporting.
  ///
  /// In ar, this message translates to:
  /// **'ما سبب الإبلاغ عن هذه البطاقة؟'**
  String get reportFlashcardPage_whyReporting;

  /// No description provided for @reportFlashcardPage_submitReport.
  ///
  /// In ar, this message translates to:
  /// **'إرسال البلاغ'**
  String get reportFlashcardPage_submitReport;

  /// No description provided for @reportFlashcardPage_additionalDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل إضافية (اختياري)'**
  String get reportFlashcardPage_additionalDetails;

  /// No description provided for @reportFlashcardPage_explain.
  ///
  /// In ar, this message translates to:
  /// **'اشرح بلاغك هنا'**
  String get reportFlashcardPage_explain;

  /// No description provided for @reportReason_inappropriateContent.
  ///
  /// In ar, this message translates to:
  /// **'محتوى غير لائق'**
  String get reportReason_inappropriateContent;

  /// No description provided for @reportReason_incorrectInformation.
  ///
  /// In ar, this message translates to:
  /// **'معلومة خاطئة'**
  String get reportReason_incorrectInformation;

  /// No description provided for @reportReason_poorTranslation.
  ///
  /// In ar, this message translates to:
  /// **'صياغة ضعيفة'**
  String get reportReason_poorTranslation;

  /// No description provided for @reportReason_duplicateFlashcard.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة مكررة'**
  String get reportReason_duplicateFlashcard;

  /// No description provided for @reportReason_other.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get reportReason_other;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
