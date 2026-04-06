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
  String get send => 'Dir';

  @override
  String get add => 'Ku dar';

  @override
  String get bills => 'Biilasha';

  @override
  String get sadaqah => 'Sadaqo';

  @override
  String get exchange => 'Sarif';

  @override
  String get vouchers => 'Boonooyin';

  @override
  String get seeAll => 'Arag dhammaan';

  @override
  String get spendingAnalysis => 'Falanqaynta kharashka';

  @override
  String get walletBalance => 'Haraaga boorsada';

  @override
  String get getStarted => 'Bilow hadda';

  @override
  String get virtualCard => 'Kaarka Virtual-ka';

  @override
  String get virtualCardDesc =>
      'Hel kaar virtual ah oo aamin ah oo caalamka wax kaga iibso.';

  @override
  String get enterAmount => 'Geli cadadka';

  @override
  String get transferLimit => 'Xadadka: \$5,000.00';

  @override
  String get feeRate => 'Kharashka: \$0.99 halkii \$100';

  @override
  String get youSend => 'Waxaad diraysaa';

  @override
  String get searchCurrency => 'Raadi lacagta';

  @override
  String get receiverGets => 'Waxa helaya qofka';

  @override
  String get selectPaymentMethod => 'Dooro habka lacag bixinta';

  @override
  String get transactionFee => 'Kharashka dirista';

  @override
  String get totalToPay => 'Wadarta guud';

  @override
  String get insufficientBalance => 'Haraagu kuguma filna';

  @override
  String get receiverDetails => 'Faahfaahinta qaataha';

  @override
  String get enterReceiverPhone => 'Geli lambarka taleefanka qaataha';

  @override
  String get phoneNumber => 'Lambarka Taleefanka';

  @override
  String get receiver => 'Qaataha';

  @override
  String get recent => 'Dhowaan';

  @override
  String get pleaseEnterDetails => 'Fadlan geli faahfaahinta qaataha';

  @override
  String get continueToReview => 'Sii soco si aad u eegto';

  @override
  String get reviewTransfer => 'Dib u eegista xawaaladda';

  @override
  String get paymentMethod => 'Habka lacag bixinta';

  @override
  String get fee => 'Kharashka';

  @override
  String get exchangeRate => 'Qiimaha sarrifka';

  @override
  String get deliveryNotice => 'Lacagta waxay gaari doontaa daqiiqado gudahood';

  @override
  String get confirmAndPay => 'Hubi oo bixi';

  @override
  String get choosePaymentMethod => 'Dooro habka lacag bixinta';

  @override
  String get finalSummary => 'Koobitaanka u dambeeya';

  @override
  String get amount => 'Cadadka';

  @override
  String get instantPaymentFromWallet =>
      'Lacag bixin degdeg ah oo boorsada ka socota';

  @override
  String get payViaHormuud => 'Ku bixi Hormuud EVC Plus';

  @override
  String get payViaTelesom => 'Ku bixi Telesom ZAAD';

  @override
  String get payViaSomtel => 'Ku bixi Somtel e-Dahab';

  @override
  String get bankTransfer => 'Xawaalad bangi';

  @override
  String get localBankTransfer => 'Xawaalad bangi oo maxalli ah';

  @override
  String get internationalMethods => 'Hababka caalamiga ah';

  @override
  String get payWithInternationalCard => 'Ku bixi kaar caalami ah';

  @override
  String get payNow => 'Bixi hadda';

  @override
  String get transferSuccessful => 'Diristii way guulaysatay!';

  @override
  String transferSentMessage(Object amount, Object receiver) {
    return '$amount ayaa si aamin ah loogu diray $receiver.';
  }

  @override
  String get method => 'Habka';

  @override
  String get reference => 'Tixraaca';

  @override
  String get backToHome => 'Ku laabo hoyga';

  @override
  String get continueLabel => 'Sii soco';

  @override
  String get murtaaxTransfer => 'Xawaaladda Murtaax';

  @override
  String get enterReceiverWalletId => 'Geli ID-ga boorsada qaataha';

  @override
  String get walletIdTransferNotice =>
      'Lacagta si degdeg ah ayaa loogu wareejin doonaa ID-ga Murtaax ee la cayimay.';

  @override
  String get enterWalletIdHint => 'Geli ID-ga boorsada (tusaale 102234)';

  @override
  String get verifiedReceiverLabel => 'QAATAHA LA HUUBIYAY';

  @override
  String get recentContacts => 'Dadkii u dambeeyay';

  @override
  String get securityVerification => 'Xaqiijinta amniga';

  @override
  String get enterTransactionPin =>
      'Fadlan geli 4-ta god ee PIN-kaaga si aad u oggolaato lacag bixintan.';

  @override
  String get authorizing => 'Oggolaansho...';

  @override
  String confirmPaymentAmount(Object amount) {
    return 'Xaqiiji lacag bixinta ($amount)';
  }

  @override
  String get verifyingTransaction =>
      'Xaqiijinta amniga xawaaladda iyo xiriirka server-yada Murtaax...';

  @override
  String get cancelAndChangeMethod => 'Jooji oo beddel habka';

  @override
  String get active => 'Firfircoon';

  @override
  String get availableBalance => 'HARAAGA LA HELI KARO';
}
