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
  String get send => 'Send';

  @override
  String get add => 'Add';

  @override
  String get bills => 'Bills';

  @override
  String get sadaqah => 'Sadaqah';

  @override
  String get exchange => 'Exchange';

  @override
  String get vouchers => 'Vouchers';

  @override
  String get seeAll => 'See All';

  @override
  String get spendingAnalysis => 'Spending Analysis';

  @override
  String get walletBalance => 'Wallet Balance';

  @override
  String get getStarted => 'Get Started';

  @override
  String get virtualCard => 'Virtual Card';

  @override
  String get virtualCardDesc =>
      'Get your secure virtual card and shop globally.';

  @override
  String get enterAmount => 'Enter Amount';

  @override
  String get transferLimit => 'Limit: \$5,000.00';

  @override
  String get feeRate => 'Fee: \$0.99 per \$100';

  @override
  String get youSend => 'You Send';

  @override
  String get searchCurrency => 'Search currency';

  @override
  String get receiverGets => 'Receiver Gets';

  @override
  String get selectPaymentMethod => 'Select Payment Method';

  @override
  String get transactionFee => 'Transaction Fee';

  @override
  String get totalToPay => 'Total to Pay';

  @override
  String get insufficientBalance => 'Insufficient Balance';

  @override
  String get receiverDetails => 'Receiver Details';

  @override
  String get enterReceiverPhone => 'Enter Receiver Phone Number';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get receiver => 'Receiver';

  @override
  String get recent => 'Recent';

  @override
  String get pleaseEnterDetails => 'Please enter receiver details';

  @override
  String get continueToReview => 'Continue to Review';

  @override
  String get reviewTransfer => 'Review Transfer';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get fee => 'Fee';

  @override
  String get exchangeRate => 'Exchange Rate';

  @override
  String get deliveryNotice => 'Funds will be delivered within minutes';

  @override
  String get confirmAndPay => 'Confirm and Pay';

  @override
  String get choosePaymentMethod => 'اختر طريقة الدفع';

  @override
  String get finalSummary => 'الملخص النهائي';

  @override
  String get amount => 'المبلغ';

  @override
  String get instantPaymentFromWallet => 'دفع فوري من محفظة مرتاح الخاصة بك';

  @override
  String get payViaHormuud => 'الدفع عبر Hormuud EVC Plus';

  @override
  String get payViaTelesom => 'الدفع عبر Telesom ZAAD';

  @override
  String get payViaSomtel => 'الدفع عبر Somtel e-Dahab';

  @override
  String get bankTransfer => 'تحويل بنكي';

  @override
  String get localBankTransfer => 'تحويل بنكي صومالي محلي';

  @override
  String get internationalMethods => 'الطرق الدولية';

  @override
  String get payWithInternationalCard => 'الدفع ببطاقة دولية';

  @override
  String get payNow => 'ادفع الآن';

  @override
  String get transferSuccessful => 'تم التحويل بنجاح!';

  @override
  String transferSentMessage(Object amount, Object receiver) {
    return 'تم إرسال $amount بشكل آمن إلى $receiver.';
  }

  @override
  String get method => 'الطريقة';

  @override
  String get reference => 'المرجع';

  @override
  String get backToHome => 'العودة إلى الرئيسية';

  @override
  String get murtaaxTransfer => 'تحويل مرتاح';

  @override
  String get enterReceiverWalletId => 'أدخل معرف محفظة المستلم';

  @override
  String get walletIdTransferNotice => 'سيتم تحويل الأموال فوراً إلى معرف مرتاح المحدد.';

  @override
  String get enterWalletIdHint => 'أدخل معرف المحفظة (مثلاً 102234)';

  @override
  String get verifiedReceiverLabel => 'مستلم موثق';

  @override
  String get recentContacts => 'جهات الاتصال الأخيرة';

  @override
  String get securityVerification => 'التحقق الأمني';

  @override
  String get enterTransactionPin => 'يرجى إدخال رمز PIN المكون من 4 أرقام للمصادقة على هذا الدفع.';

  @override
  String get authorizing => 'جاري المصادقة...';

  @override
  String confirmPaymentAmount(Object amount) {
    return 'تأكيد الدفع ($amount)';
  }

  @override
  String get verifyingTransaction => 'جاري التحقق من المعاملة بأمان مع خوادم مرتاح...';

  @override
  String get cancelAndChangeMethod => 'إلغاء وتغيير الطريقة';

  @override
  String get active => 'نشط';

  @override
  String get availableBalance => 'الرصيد المتاح';
}
