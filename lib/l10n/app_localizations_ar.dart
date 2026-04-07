// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مرتاح باي';

  @override
  String get splashTitle => 'مورتاكس باي';

  @override
  String get splashSubtitle => 'شريك صومالي موثوق';

  @override
  String get welcome => 'أهلاً بك';

  @override
  String get sendMoney => 'إرسال الأموال';

  @override
  String get receiveMoney => 'استلام';

  @override
  String get balance => 'الرصيد';

  @override
  String get recentTransactions => 'المعاملات الأخيرة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get send => 'إرسال';

  @override
  String get add => 'إضافة';

  @override
  String get bills => 'فواتير';

  @override
  String get sadaqah => 'صدقة';

  @override
  String get exchange => 'تبديل';

  @override
  String get vouchers => 'قسائم';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get spendingAnalysis => 'تحليل الإنفاق';

  @override
  String get walletBalance => 'رصيد المحفظة';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get virtualCard => 'بطاقة افتراضية';

  @override
  String get virtualCardDesc =>
      'احصل على بطاقتك الافتراضية الآمنة وتسوق عالمياً.';

  @override
  String get enterAmount => 'أدخل المبلغ';

  @override
  String get transferLimit => 'الحد الأقصى: 5,000.00 دولار';

  @override
  String get feeRate => 'الرسوم: 0.99 دولار لكل 100 دولار';

  @override
  String get youSend => 'أنت ترسل';

  @override
  String get searchCurrency => 'بحث عن عملة';

  @override
  String get receiverGets => 'المستلم يحصل على';

  @override
  String get selectPaymentMethod => 'اختر طريقة الدفع';

  @override
  String get transactionFee => 'رسوم المعاملة';

  @override
  String get totalToPay => 'الإجمالي للدفع';

  @override
  String get insufficientBalance => 'رصيد غير كافٍ';

  @override
  String get receiverDetails => 'تفاصيل المستلم';

  @override
  String get enterReceiverPhone => 'أدخل رقم هاتف المستلم';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get receiver => 'المستلم';

  @override
  String get recent => 'الأخير';

  @override
  String get pleaseEnterDetails => 'يرجى إدخال تفاصيل المستلم';

  @override
  String get continueToReview => 'المتابعة للمراجعة';

  @override
  String get reviewTransfer => 'مراجعة التحويل';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get fee => 'الرسوم';

  @override
  String get exchangeRate => 'سعر الصرف';

  @override
  String get deliveryNotice => 'سيتم تسليم الأموال في غضون دقائق';

  @override
  String get confirmAndPay => 'تأكيد ودفع';

  @override
  String get choosePaymentMethod => 'اختر طريقة الدفع';

  @override
  String get finalSummary => 'الملخص النهائي';

  @override
  String get amount => 'المبلغ';

  @override
  String get instantPaymentFromWallet => 'دفع فوري من المحفظة';

  @override
  String get payViaHormuud => 'دفع عبر هرمز EVC Plus';

  @override
  String get payViaTelesom => 'دفع عبر تليسوم ZAAD';

  @override
  String get payViaSomtel => 'دفع عبر صومتل e-Dahab';

  @override
  String get bankTransfer => 'تحويل بنكي';

  @override
  String get localBankTransfer => 'تحويل بنكي صومالي محلي';

  @override
  String get internationalMethods => 'طرق دولية';

  @override
  String get payWithInternationalCard => 'الدفع ببطاقة دولية';

  @override
  String get payNow => 'ادفع الآن';

  @override
  String get transferSuccessful => 'تم التحويل بنجاح!';

  @override
  String transferSentMessage(Object amount, Object receiver) {
    return 'تم إرسال $amount بأمان إلى $receiver.';
  }

  @override
  String get method => 'الطريقة';

  @override
  String get reference => 'المرجع';

  @override
  String get backToHome => 'العودة للرئيسية';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get murtaaxTransfer => 'تحويل مرتاح';

  @override
  String get enterReceiverWalletId => 'أدخل معرف محفظة المستلم';

  @override
  String get walletIdTransferNotice =>
      'سيتم تحويل الأموال فورا إلى معرف مرتاح المحدد.';

  @override
  String get enterWalletIdHint => 'أدخل معرف المحفظة (مثلاً 102234)';

  @override
  String get verifiedReceiverLabel => 'مستلم موثق';

  @override
  String get recentContacts => 'جهات الاتصال الأخيرة';

  @override
  String get securityVerification => 'التحقق الأمني';

  @override
  String get enterTransactionPin =>
      'يرجى إدخال رمز PIN المكون من 4 أرقام لتفويض هذا الدفع.';

  @override
  String get authorizing => 'جاري التفويض...';

  @override
  String confirmPaymentAmount(Object amount) {
    return 'تأكيد الدفع ($amount)';
  }

  @override
  String get verifyingTransaction => 'تأمين تأكيد المعاملة مع خوادم مرتاح...';

  @override
  String get cancelAndChangeMethod => 'إلغاء وتغيير الطريقة';

  @override
  String get active => 'نشط';

  @override
  String get availableBalance => 'الرصيد المتاح';

  @override
  String get deductFeeFromAmount => 'خصم الرسوم من المبلغ';

  @override
  String get receiverWillReceiveLess => 'المستلم سيحصل على مبلغ أقل';

  @override
  String get payFeeSeparately => 'دفع الرسوم بشكل منفصل';
}
