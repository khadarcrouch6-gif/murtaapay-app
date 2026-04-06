// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Somali (`so`).
class AppLocalizationsSo extends AppLocalizations {
  AppLocalizationsSo([String locale = 'so']) : super(locale);

  @override
  String get appTitle => 'MurtaaxPay';

  @override
  String get splashTitle => 'MURTAAX PAY';

  @override
  String get splashSubtitle => 'Saaxiibka Soomaaliyeed';

  @override
  String get welcome => 'Ku soo dhawaada';

  @override
  String get sendMoney => 'Lacag Dir';

  @override
  String get receiveMoney => 'Lacag Hel';

  @override
  String get balance => 'Haraaga';

  @override
  String get recentTransactions => 'Dhaqdhaqaaqadii u dambeeyay';

  @override
  String get settings => 'Habsamada';

  @override
  String get language => 'Luuqadda';

  @override
  String get theme => 'Muuqaalka';

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
  String get confirmAndPay => 'Xaqiiji oo Bixi';

  @override
  String get choosePaymentMethod => 'Dooro habka lacag bixinta';

  @override
  String get finalSummary => 'Soo koobid';

  @override
  String get amount => 'Lacagta';

  @override
  String get instantPaymentFromWallet => 'Lacag bixin degdeg ah oo ka timid booshkaaga Murtaax';

  @override
  String get payViaHormuud => 'Ku bixi Hormuud EVC Plus';

  @override
  String get payViaTelesom => 'Ku bixi Telesom ZAAD';

  @override
  String get payViaSomtel => 'Ku bixi Somtel e-Dahab';

  @override
  String get bankTransfer => 'Xawaalad Bangi';

  @override
  String get localBankTransfer => 'Xawaalad Bangi Soomaaliyeed oo maxalli ah';

  @override
  String get internationalMethods => 'Hababka caalamiga ah';

  @override
  String get payWithInternationalCard => 'Ku bixi Kaarka Caalamiga ah';

  @override
  String get payNow => 'Bixi hadda';

  @override
  String get transferSuccessful => 'Xawaaladda waa lagu guuleystay!';

  @override
  String transferSentMessage(Object amount, Object receiver) {
    return '$amount ayaa si ammaan ah loogu diray $receiver.';
  }

  @override
  String get method => 'Habka';

  @override
  String get reference => 'Tixraac';

  @override
  String get backToHome => 'Ku laabo bogga hore';

  @override
  String get murtaaxTransfer => 'Xawaaladda Murtaax';

  @override
  String get enterReceiverWalletId => 'Geli aqoonsiga booshka qaataha';

  @override
  String get walletIdTransferNotice => 'Lacagta waxaa isla markiiba loo wareejin doonaa aqoonsiga Murtaax ee la cayimay.';

  @override
  String get enterWalletIdHint => 'Geli aqoonsiga booshka (tusaale 102234)';

  @override
  String get verifiedReceiverLabel => 'QAATAHA LA XAQIIJIYAY';

  @override
  String get recentContacts => 'Xiriirradii u dambeeyay';

  @override
  String get securityVerification => 'Xaqiijinta Amniga';

  @override
  String get enterTransactionPin => 'Fadlan geli 4-god ee PIN-kaaga si aad u oggolaato lacag bixintan.';

  @override
  String get authorizing => 'Oggolaanshaha...';

  @override
  String confirmPaymentAmount(Object amount) {
    return 'Xaqiiji Lacag Bixinta ($amount)';
  }

  @override
  String get verifyingTransaction => 'Si ammaan ah loogu xaqiijinayo wax kala iibsiga adeegayaasha Murtaax...';

  @override
  String get cancelAndChangeMethod => 'Jooji oo beddel habka';

  @override
  String get active => 'Shaqeynaya';

  @override
  String get availableBalance => 'HARAA GA LA HELI KARO';
}
