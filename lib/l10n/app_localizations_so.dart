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
  String get confirmAndPay => 'Confirm and Pay';

  @override
  String get choosePaymentMethod => 'Choose Payment Method';

  @override
  String get finalSummary => 'Final Summary';

  @override
  String get amount => 'Amount';

  @override
  String get instantPaymentFromWallet => 'Instant payment from wallet';

  @override
  String get payViaHormuud => 'Pay via Hormuud EVC Plus';

  @override
  String get payViaTelesom => 'Pay via Telesom ZAAD';

  @override
  String get payViaSomtel => 'Pay via Somtel e-Dahab';

  @override
  String get bankTransfer => 'Bank Transfer';

  @override
  String get localBankTransfer => 'Local Somali bank transfer';

  @override
  String get internationalMethods => 'International Methods';

  @override
  String get payWithInternationalCard => 'Pay with international card';

  @override
  String get payNow => 'Pay Now';

  @override
  String get transferSuccessful => 'Transfer Successful!';

  @override
  String transferSentMessage(Object amount, Object receiver) {
    return '$amount has been safely sent to $receiver.';
  }

  @override
  String get method => 'Method';

  @override
  String get reference => 'Reference';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get continueLabel => 'Sii Soco';

  @override
  String get murtaaxTransfer => 'Murtaax Transfer';

  @override
  String get enterReceiverWalletId => 'Enter Receiver Wallet ID';

  @override
  String get walletIdTransferNotice =>
      'Funds will be transferred instantly to the specified Murtaax ID.';

  @override
  String get enterWalletIdHint => 'Enter Wallet ID (e.g. 102234)';

  @override
  String get verifiedReceiverLabel => 'VERIFIED RECEIVER';

  @override
  String get recentContacts => 'Recent Contacts';

  @override
  String get securityVerification => 'Security Verification';

  @override
  String get enterTransactionPin =>
      'Please enter your 4-digit PIN to authorize this payment.';

  @override
  String get authorizing => 'Authorizing...';

  @override
  String confirmPaymentAmount(Object amount) {
    return 'Confirm Payment ($amount)';
  }

  @override
  String get verifyingTransaction =>
      'Securing confirming transaction with Murtaax servers...';

  @override
  String get cancelAndChangeMethod => 'Cancel and Change Method';

  @override
  String get active => 'Active';

  @override
  String get availableBalance => 'AVAILABLE BALANCE';
}
