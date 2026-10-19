// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get highSchoolStudent => 'طالب ثانوي';

  @override
  String get graduate => 'خريج';

  @override
  String get universityStudent => 'طالب جامعي';

  @override
  String get otherLevel => 'أخرى';

  @override
  String get homePage_title => 'الرئيسية';

  @override
  String get registerPage_header => 'ابدأ استعدادك للقدرات اليوم!';

  @override
  String get basicText_name => 'الاسم الأول';

  @override
  String get basicText_surname => 'اسم العائلة';

  @override
  String get basicText_email => 'البريد الإلكتروني';

  @override
  String get basicText_phoneNumber => 'رقم الجوال';

  @override
  String get basicText_educationLevel => 'المستوى الدراسي';

  @override
  String get basicText_password => 'كلمة المرور';

  @override
  String get basicText_repeatPassword => 'أعد كتابة كلمة المرور';

  @override
  String get basicText_register => 'إنشاء حساب';

  @override
  String get basicText_alreadyAMember => 'عندك حساب؟';

  @override
  String get basicText_signInNow => 'تسجيل الدخول';

  @override
  String get basicText_forgotPassword => 'نسيت كلمة المرور';

  @override
  String get basicText_notAMember => 'ما عندك حساب؟';

  @override
  String get basicText_sendEmail => 'إرسال البريد';

  @override
  String get basicText_update => 'تحديث';

  @override
  String get basicText_tryAgain => 'حاول مرة أخرى';

  @override
  String get basicText_profile => 'الملف الشخصي';

  @override
  String get basicText_edit => 'تعديل';

  @override
  String get basicText_cancel => 'إلغاء';

  @override
  String get basicText_save => 'حفظ';

  @override
  String get basicText_other => 'أخرى';

  @override
  String get basicText_logout => 'تسجيل الخروج';

  @override
  String get basicText_signOut => 'تسجيل الخروج';

  @override
  String get basicText_goToLogin => 'الذهاب لتسجيل الدخول';

  @override
  String registerPage_successfulRegister(String displayName) {
    return 'مبروك $displayName، تم إنشاء حسابك بنجاح!';
  }

  @override
  String get loginPage_welcomeBack => 'أهلاً بعودتك إلى تقدر، اشتقنا لك';

  @override
  String loginPage_welcomeBackMember(String displayName) {
    return 'أهلاً بعودتك $displayName!';
  }

  @override
  String get forgotPasswordPage_emailSent =>
      'تم إرسال رسالة التحقق. تفقّد بريدك الوارد';

  @override
  String get forgotPasswordPage_enterEmail =>
      'أدخل البريد الإلكتروني المرتبط بحسابك.';

  @override
  String get verifyEmailPage_success => 'تم إرسال رسالة توثيق البريد بنجاح!';

  @override
  String get personalInformationPage_personalInformation => 'المعلومات الشخصية';

  @override
  String get privacySecurityPage_title => 'الخصوصية والأمان';

  @override
  String get privacySecurityPage_changeEmail => 'تغيير البريد الإلكتروني';

  @override
  String get privacySecurityPage_verified => 'موثّق';

  @override
  String get privacySecurityPage_changePassword => 'تغيير كلمة المرور';

  @override
  String get privacySecurityPage_hiddenPassword => '••••••••';

  @override
  String get privacySecurityPage_changePhone => 'تغيير رقم الجوال';

  @override
  String get privacySecurityPage_notVerified => 'غير موثّق';

  @override
  String get privacySecurityPage_deleteAccount => 'حذف حسابك';

  @override
  String get privacySecurityPage_deleteAccountSubtitle => 'حذف حسابك نهائياً';

  @override
  String get privacySecurityPage_pendingVerification => 'بانتظار التوثيق';

  @override
  String get privacySecurityPage_changeEmailText =>
      'لتغيير بريدك أكمل العملية من صفحة تغيير البريد. توثيقه من مكان آخر قد يسبب مشاكل. إذا غيّرت رأيك فتجاهل هذا الأمر بأمان.';

  @override
  String profilePage_errorMessage(String errorMessage) {
    return '$errorMessage';
  }

  @override
  String get deleteAccountSuccessfulPage_message =>
      'حزنّا لمغادرتك. تم حذف حسابك وجميع بياناتك بنجاح.';

  @override
  String get deleteAccountSuccessfulPage_button => 'الذهاب لتسجيل الدخول';

  @override
  String get authErrorContainer_verifyEmailSuccess =>
      'تم! الآن لنوثّق بريدك الإلكتروني';

  @override
  String get reauthSection_securityNotice =>
      'لأسباب أمنية، أكّد هويتك من فضلك.';

  @override
  String get reauthSection_passwordLabel => 'كلمة المرور';

  @override
  String get reauthSection_button => 'إعادة التحقق';

  @override
  String get reauthSection_success =>
      'تم التحقق بنجاح. سيتم إكمال العملية السابقة الآن.';

  @override
  String get reauthSection_info => 'قد يُطلب منك تأكيد هويتك.';

  @override
  String get loadingProfileData_message => 'جارٍ تحميل ملفك الشخصي...';

  @override
  String get profileReaderBlocBuilder_neverLoaded =>
      'لم يتم تحميل الملف الشخصي.';

  @override
  String get readProfileErrorScreen_errorMessage =>
      'حدث خطأ أثناء تحميل ملفك الشخصي.';

  @override
  String get personalInfoContent_updateSuccessMessage =>
      'تم تحديث معلوماتك الشخصية بنجاح!';

  @override
  String get profileData_accountSettings => 'إعدادات الحساب';

  @override
  String get profileData_personalInformation => 'المعلومات الشخصية';

  @override
  String get profileData_privacySecurity => 'الخصوصية والأمان';

  @override
  String get profileData_billingDetails => 'تفاصيل الاشتراك';

  @override
  String get profileData_flashcards => 'الأسئلة';

  @override
  String get profileData_flashcardSettings => 'إعدادات المذاكرة';

  @override
  String get profileData_bookmarkedFlashcards => 'البطاقات المحفوظة';

  @override
  String get profileData_privacyPolicy => 'سياسة الخصوصية';

  @override
  String get verifyEmailActionButtons_changeEmail => 'تغيير البريد';

  @override
  String get verifyEmailHeadline_sendingVerificationLink =>
      'جارٍ إرسال رابط التوثيق...';

  @override
  String get verifyEmailHeadline_refreshingApplicationState =>
      'جارٍ تحديث حالة التطبيق...';

  @override
  String get verifyEmailHeadline_errorSendingVerificationLink =>
      'تعذّر إرسال رابط التوثيق، حاول لاحقاً';

  @override
  String get verifyEmailHeadline_verifyYourEmailAddress =>
      'وثّق بريدك الإلكتروني';

  @override
  String get verifyEmailInfoSection_emailSentMessage1 =>
      'شكراً لتسجيلك! أرسلنا رسالة توثيق إلى بريدك.';

  @override
  String get verifyEmailInfoSection_emailSentMessage2 =>
      'افتح بريدك واضغط على رابط التوثيق لتفعيل حسابك.';

  @override
  String get verifyEmailInfoSection_twoEmailsDetectedMessage =>
      'أرسلنا روابط توثيق للبريدين.\nأول رابط تضغط عليه يحدد البريد المحفوظ في ملفك.';

  @override
  String get verifyEmailResendLinkButton_successMessage =>
      'تم إرسال رسالة التوثيق بنجاح!';

  @override
  String get verifyEmailResendLinkButton_resendLinkButtonText =>
      'إعادة إرسال الرابط';

  @override
  String get verifyEmailResendLinkButton_waitButtonText => 'انتظر...';

  @override
  String get error_requiresRecentLogin =>
      'لأسباب أمنية، أعد تسجيل الدخول لإكمال هذا الإجراء.';

  @override
  String get error_invalidEmail => 'صيغة البريد الإلكتروني غير صحيحة.';

  @override
  String get error_userDisabled => 'هذا الحساب معطّل.';

  @override
  String get error_userNotFound => 'لا يوجد حساب بهذا البريد.';

  @override
  String get error_wrongPassword => 'كلمة المرور غير صحيحة. حاول مرة أخرى.';

  @override
  String get error_tooManyRequests => 'أرسلت طلبات كثيرة، حاول لاحقاً';

  @override
  String get error_tokenExpired => 'انتهت الجلسة، سجّل الدخول من جديد.';

  @override
  String get error_networkIssue => 'مشكلة في الشبكة، تحقق من اتصالك بالإنترنت';

  @override
  String get error_invalidCredential =>
      'بيانات الدخول غير صحيحة، حاول مرة أخرى';

  @override
  String get error_operationNotAllowed =>
      'مشكلة في إعدادات المصادقة، تواصل مع المطوّر';

  @override
  String get error_emailAlreadyInUse =>
      'هذا البريد مستخدم مسبقاً، جرّب بريداً آخر.';

  @override
  String get error_authFailed => 'فشل تسجيل الدخول. حاول مرة أخرى.';

  @override
  String get error_unexpected => 'حدث خطأ غير متوقع. حاول مرة أخرى.';

  @override
  String get error_passwordRequirement => 'كلمة المرور لا تحقق شروط الأمان.';

  @override
  String get error_passwordNonAlphanumeric =>
      'يجب أن تحتوي كلمة المرور على رمز خاص.';

  @override
  String get error_passwordEightCharacters =>
      'يجب أن تحتوي كلمة المرور على 8 خانات على الأقل.';

  @override
  String get error_passwordUpperCase =>
      'يجب أن تحتوي كلمة المرور على حرف إنجليزي كبير.';

  @override
  String get error_passwordNumeric => 'يجب أن تحتوي كلمة المرور على رقم.';

  @override
  String get error_loadingBookmarks =>
      'تعذّر تحميل البطاقات المحفوظة، حاول مرة أخرى';

  @override
  String get error_loadingPacks => 'تعذّر تحميل الحزم 😔';

  @override
  String get flashcardMainCard_packFinished => 'أحسنت!';

  @override
  String get flashcardMainButton_reveal => 'إظهار الإجابة';

  @override
  String get flashcardMainButton_skip => 'تخطّي';

  @override
  String get flashcardPageDialog_packFinishedForNow => 'خلصت، الحين';

  @override
  String flashcardPageDialog_packEnded(String subTextForDialog) {
    return 'مبروك! ما فيه بطاقات مستحقة من $subTextForDialog الحين، ارجع لاحقاً.\n\nاستمر على هذا المستوى.';
  }

  @override
  String get flashcardPageDialog_backHome => 'العودة للرئيسية';

  @override
  String get flashcardPageDialog_sessionFinishedForNow =>
      'انتهت جلسة المذاكرة، الحين';

  @override
  String get flashcardPageDialog_sessionEnded => 'مبروك! أنهيت هذه الجلسة.';

  @override
  String get flashcardPageDialog_closeSession =>
      'تقدر تقفل الجلسة أو تكمل المذاكرة.';

  @override
  String get flashcardPageDialog_continueLearning => 'أكمل المذاكرة';

  @override
  String get flashcardPageDialog_endThisSession => 'إنهاء هذه الجلسة؟';

  @override
  String flashcardPageDialog_updateCardsPerSession(
    int cardDifference,
    int userCardsPerSession,
    int newCardsPerSession,
  ) {
    return 'راجعت $cardDifference بطاقة أكثر من هدفك وهو $userCardsPerSession بطاقة في الجلسة.\n\nتبي تحدّث هدفك إلى $newCardsPerSession بطاقة في الجلسة؟\n\nتقدر تغيّره دائماً من الإعدادات.';
  }

  @override
  String get flashcardPageDialog_keepCurrent => 'إبقاء الحالي';

  @override
  String get flashcardPageDialog_updateTarget => 'تحديث الهدف';

  @override
  String get flashcardRatingButtons_easyLabel => 'سهل';

  @override
  String get flashcardRatingButtons_easyTooltip => 'عرفتها فوراً وبثقة.';

  @override
  String get flashcardRatingButtons_goodLabel => 'جيد';

  @override
  String get flashcardRatingButtons_goodTooltip =>
      'تذكرتها لكن احتجت أفكر شوي.';

  @override
  String get flashcardRatingButtons_hardLabel => 'صعب';

  @override
  String get flashcardRatingButtons_hardTooltip => 'بالكاد تذكرتها.';

  @override
  String get flashcardRatingButtons_againLabel => 'أعد';

  @override
  String get flashcardRatingButtons_againTooltip => 'نسيتها أو أجبت خطأ.';

  @override
  String flashcardTimerContainer(String time) {
    return 'الوقت: $time';
  }

  @override
  String get flashcardPage_packTitle => 'الحزمة';

  @override
  String get flashcardPage_packSubtext => 'الحزمة';

  @override
  String get flashcardPage_bookmarksTitle => 'المحفوظة';

  @override
  String get flashcardPage_bookmarksSubtext => 'المحفوظة';

  @override
  String get reviewBookmarkPage_review => 'مراجعة البطاقات المحفوظة';

  @override
  String get reviewBookmarkPage_noBookmarks => 'ما حفظت أي بطاقة للحين.';

  @override
  String reviewBookmarkPage_numberOfBookmarks(int number) {
    return 'عدد البطاقات المحفوظة: $number';
  }

  @override
  String get reviewBookmarkPage_remove => 'إزالة من المحفوظة';

  @override
  String get reviewBookmarkPage_swipe => 'اسحب لليسار لإزالة البطاقة';

  @override
  String get splashPageText => 'جارٍ تجهيز تجربتك...';

  @override
  String get packsPage_title => 'الحزم';

  @override
  String get packsPage_fetching => 'جارٍ جلب الحزم...';

  @override
  String get packsPage_noPacks => 'ما فيه حزم متاحة حالياً';

  @override
  String get updateEmailSuccessfulPage_text =>
      '🎉 تم! تم تحديث بريدك الإلكتروني.\nاستخدم البريد الجديد عند تسجيل الدخول.';

  @override
  String get updateEmailSuccessfulPage_button => 'الذهاب لتسجيل الدخول';

  @override
  String changeEmailDuringVerificationPage_text(String email) {
    return 'تم إرسال رسالة توثيق جديدة إلى $email';
  }

  @override
  String get changeEmailPage_leaveWithoutVerifying =>
      'تغادر بدون توثيق البريد؟';

  @override
  String get changeEmailPage_text =>
      'لتغيير بريدك لازم تكمل التوثيق وأنت في هذه الصفحة.\n\nتوثيق البريد من صفحة أخرى قد يسبب سلوكاً غير متوقع.\n\nإذا غيّرت رأيك تقدر تغادر بأمان.';

  @override
  String get changeEmailPage_stay => 'البقاء في الصفحة';

  @override
  String get changeEmailPage_leaveAnyway => 'المغادرة';

  @override
  String get deleteProfilePage_deleteAccount => 'حذف الحساب';

  @override
  String get deleteProfilePage_areYouSure =>
      'متأكد إنك تبي تحذف حسابك نهائياً؟\n\nما يمكن التراجع عن هذا الإجراء وستفقد كل بياناتك.';

  @override
  String get updatePasswordPage_title => 'تحديث كلمة المرور';

  @override
  String get updatePasswordPage_update => 'تحديث';

  @override
  String get updatePasswordPage_success => 'تم تحديث كلمة المرور بنجاح';

  @override
  String get updatePasswordPage_password => 'كلمة المرور';

  @override
  String get updatePasswordPage_repeatPassword => 'أعد كتابة كلمة المرور';

  @override
  String get profileData_bookmarks => 'المحفوظة';

  @override
  String get profileData_chooseEngage =>
      'اختر كيف تحب تتعامل مع بطاقاتك المحفوظة.';

  @override
  String get profileData_review => 'مراجعة البطاقات';

  @override
  String get profileData_startTest => 'اختبر نفسك';

  @override
  String get assignAdminPage_title => 'تعيين المشرفين';

  @override
  String get flashcardBuilderPage_title => 'إدارة المحتوى';

  @override
  String get reportFlashcardPage_success => 'تم الإبلاغ عن البطاقة بنجاح';

  @override
  String get reportFlashcardPage_report => 'الإبلاغ عن بطاقة';

  @override
  String get reportFlashcardPage_whyReporting =>
      'ما سبب الإبلاغ عن هذه البطاقة؟';

  @override
  String get reportFlashcardPage_submitReport => 'إرسال البلاغ';

  @override
  String get reportFlashcardPage_additionalDetails => 'تفاصيل إضافية (اختياري)';

  @override
  String get reportFlashcardPage_explain => 'اشرح بلاغك هنا';

  @override
  String get reportReason_inappropriateContent => 'محتوى غير لائق';

  @override
  String get reportReason_incorrectInformation => 'معلومة خاطئة';

  @override
  String get reportReason_poorTranslation => 'صياغة ضعيفة';

  @override
  String get reportReason_duplicateFlashcard => 'بطاقة مكررة';

  @override
  String get reportReason_other => 'أخرى';
}
