// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MurtaaxPay';

  @override
  String get splashTitle => 'MURTAAX PAY';

  @override
  String get splashSubtitle => 'Trusted Somali Partner';

  @override
  String get welcome => 'Welcome back,';

  @override
  String get sendMoney => 'Send Money';

  @override
  String get receiveMoney => 'Receive';

  @override
  String get balance => 'Balance';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

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
  String get murtaaxWallet => 'Murtaax Wallet';

  @override
  String get visaMastercard => 'Visa / MasterCard';

  @override
  String get mobileMoney => 'Mobile Money';

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
  String get accountNumber => 'Account Number';

  @override
  String get walletId => 'Wallet ID';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get payoutVia => 'Payout Via';

  @override
  String get paidUsing => 'Paid Using';

  @override
  String get cancel => 'Cancel';

  @override
  String get moneyOnWay => 'Your money is on its way.';

  @override
  String get refId => 'Ref ID';

  @override
  String get idCopied => 'ID Copied';

  @override
  String get shareReceipt => 'Share Receipt';

  @override
  String get reference => 'Reference';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get stepAmount => 'Amount';

  @override
  String get stepReceiver => 'Receiver';

  @override
  String get stepPayment => 'Payment';

  @override
  String get stepReview => 'Review';

  @override
  String get feeInfoTitle => 'Exchange Fee Info';

  @override
  String get feeInfoContent =>
      'The fee is 0.99%. For example: sending \$100 will cost only \$0.99 in fees.';

  @override
  String get maxLabel => 'MAX';

  @override
  String get continueLabel => 'Continue';

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

  @override
  String get deductFeeFromAmount => 'Deduct fee from amount';

  @override
  String get receiverWillReceiveLess => 'Receiver will receive less';

  @override
  String get payFeeSeparately => 'Pay fee separately';

  @override
  String get myCards => 'My Cards';

  @override
  String get addNewCard => 'Add New Card';

  @override
  String get cardNumberCopied => 'Card number copied!';

  @override
  String get deposit => 'Deposit';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get savings => 'Savings';

  @override
  String get invest => 'Invest';

  @override
  String get transactions => 'Transactions';

  @override
  String get food => 'Food';

  @override
  String get shopping => 'Shopping';

  @override
  String get billsLabel => 'Bills';

  @override
  String get monthlyBudget => 'Monthly Budget';

  @override
  String get cardSettings => 'Card Settings';

  @override
  String get frozen => 'Frozen';

  @override
  String get unfreezeCard => 'Unfreeze Card';

  @override
  String get freezeCard => 'Freeze Card';

  @override
  String get temporarilyDisablePayments => 'Temporarily disable payments';

  @override
  String get security => 'Security';

  @override
  String get cardControls => 'Card Controls';

  @override
  String get onlinePayments => 'Online Payments';

  @override
  String get internationalUsage => 'International Usage';

  @override
  String get contactlessPayments => 'Contactless Payments';

  @override
  String get terminateCard => 'Terminate Card';

  @override
  String get permanentlyDeleteCard => 'Permanently delete this virtual card';

  @override
  String get enterSecurityPin => 'Please enter your 4-digit security PIN';

  @override
  String get cardInformation => 'Card Information';

  @override
  String get visaDetails => 'Visa Details';

  @override
  String get mastercardDetails => 'Mastercard Details';

  @override
  String cardDetailsInfo(Object amount) {
    return 'Enter your card details to complete the transfer of $amount';
  }

  @override
  String get cardHolderName => 'Card Holder Name';

  @override
  String get expiryDate => 'Expiry Date';

  @override
  String get cvv => 'CVV';

  @override
  String get secureProcessing => 'Securely processing your payment...';

  @override
  String get selectBank => 'Select Bank';

  @override
  String get murtaaxWalletDesc => 'Pay from your app balance';

  @override
  String get visaMastercardDesc => 'Pay using your card';

  @override
  String get bankTransferDesc => 'Direct bank transfer';

  @override
  String get mobileMoneyDesc => 'EVC Plus, Sahal, ZAAD, e-Dahab';

  @override
  String get identityVerification => 'Identity Verification';

  @override
  String get verifyYourIdentity => 'Verify Your Identity';

  @override
  String get verifyIdentityDesc =>
      'We need to verify your identity to keep your account secure. This only takes 2 minutes.';

  @override
  String get prepareIdDoc => 'Prepare your ID document';

  @override
  String get wellLitArea => 'Make sure you\'re in a well-lit area';

  @override
  String get followInstructions => 'Follow the on-screen instructions';

  @override
  String get letsGetStarted => 'Let\'s Get Started';

  @override
  String get encryptedConnection => 'ENCRYPTED & SECURE CONNECTION';

  @override
  String get personalDetails => 'Personal Details';

  @override
  String get fullName => 'Full Name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get city => 'City';

  @override
  String get residentialAddress => 'Residential Address';

  @override
  String get required => 'Required';

  @override
  String get chooseDocumentType => 'Choose Document Type';

  @override
  String get passport => 'Passport';

  @override
  String get nationalIdCard => 'National ID Card';

  @override
  String get driversLicense => 'Driver\'s License';

  @override
  String get bankGradeEncryption => 'Bank-grade encryption';

  @override
  String get dataDeletedNotice => 'Your data is deleted after verification';

  @override
  String get frontOfIdCard => 'Front of ID Card';

  @override
  String get verifyYourFace => 'Verify your face';

  @override
  String get positionFaceNotice => 'Position your face well-lit and clearly';

  @override
  String get alignId => 'Align your ID';

  @override
  String get capturing => 'Capturing...';

  @override
  String get lookStraight => 'Look Straight';

  @override
  String get lookLeft => 'Look Left';

  @override
  String get lookRight => 'Look Right';

  @override
  String get verificationPending => 'Verification Pending';

  @override
  String get verificationPendingDesc =>
      'Your documents are being reviewed. This usually takes 10-15 minutes. We\'ll notify you once it\'s complete.';

  @override
  String get documentCheck => 'Document Check';

  @override
  String get scanningForClarity => 'Scanning for clarity';

  @override
  String get biometricMatch => 'Biometric Match';

  @override
  String get comparingSelfie => 'Comparing selfie with ID';

  @override
  String get verifyingIdentity => 'Verifying Identity...';
}
