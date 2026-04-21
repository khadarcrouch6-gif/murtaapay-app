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
  String get searchTransactions => 'Raadi dhaqdhaqaaqyada...';

  @override
  String get noTransactionsFound => 'Dhaqdhaqaaqyo lama helin';

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
  String get vouchers => 'Vouchers';

  @override
  String get seeAll => 'See All';

  @override
  String get spendingAnalysis => 'Spending Analysis';

  @override
  String get walletBalance => 'Wallet Balance';

  @override
  String get getStarted => 'Bilow';

  @override
  String get virtualCard => 'Kaadhka Virtual-ka';

  @override
  String get virtualCardDesc =>
      'Get your secure virtual card and shop globally.';

  @override
  String get enterAmount => 'Geli cadadka';

  @override
  String get transferLimit => 'Limit: \$50,000.00';

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
  String get murtaaxWallet => 'Wallet-ka Murtaax';

  @override
  String get visaMastercard => 'Visa / MasterCard';

  @override
  String get mobileMoney => 'Lacagta Mobilka';

  @override
  String get transactionFee => 'Kharashka dhaqdhaqaaqa';

  @override
  String get totalToPay => 'Wadarta la bixinayo';

  @override
  String get insufficientBalance => 'Haraagaagu kuguma filna';

  @override
  String get receiverDetails => 'Receiver Details';

  @override
  String get enterReceiverPhone => 'Enter Receiver Phone Number';

  @override
  String get phoneNumber => 'Lambarka Taleefanka';

  @override
  String get receiver => 'Receiver';

  @override
  String get recent => 'Recent';

  @override
  String get pleaseEnterDetails => 'Please enter receiver details';

  @override
  String get invalidAmount => 'Invalid amount';

  @override
  String get continueToReview => 'Continue to Review';

  @override
  String get reviewTransfer => 'Review Transfer';

  @override
  String get paymentMethod => 'Habka lacag bixinta';

  @override
  String get fee => 'Fee';

  @override
  String get exchangeRate => 'Heerka sarrifka';

  @override
  String get deliveryNotice => 'Funds will be delivered within minutes';

  @override
  String get confirmAndPay => 'Confirm and Pay';

  @override
  String get choosePaymentMethod => 'Choose Payment Method';

  @override
  String get finalSummary => 'Final Summary';

  @override
  String get amount => 'Cadadka';

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
  String get payNow => 'Hadda bixi';

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
  String get walletId => 'ID-ga Wallet-ka';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get payoutVia => 'Payout Via';

  @override
  String get paidUsing => 'Paid Using';

  @override
  String get cancel => 'Jooji';

  @override
  String get moneyOnWay => 'Your money is on its way.';

  @override
  String get refId => 'Ref ID';

  @override
  String get idCopied => 'ID-ga waa la koobiyey';

  @override
  String get shareReceipt => 'Share Receipt';

  @override
  String get reference => 'Reference';

  @override
  String get backToHome => 'Ku laabo Hoyga';

  @override
  String get addMoney => 'Add Money';

  @override
  String get enterAmountToDeposit => 'Enter Amount to Deposit';

  @override
  String get confirmTopUp => 'Xaqiiji Lacag Shubista';

  @override
  String get expiry => 'Expiry';

  @override
  String get cardholderName => 'Cardholder Name';

  @override
  String get fullNameOnCard => 'Full name on card';

  @override
  String get selectProvider => 'Dooro Shirkadda';

  @override
  String get accountHolderName => 'Account Holder Name';

  @override
  String get fullName => 'Magaca oo dhammaystiran';

  @override
  String get reviewDeposit => 'Review Deposit';

  @override
  String get totalCharged => 'Total Charged';

  @override
  String get confirmAndDeposit => 'Confirm & Deposit';

  @override
  String get depositSuccessful => 'Deposit Successful!';

  @override
  String depositSuccessMessage(Object amount) {
    return '$amount has been added to your wallet.';
  }

  @override
  String get stepAmount => 'Amount';

  @override
  String get stepReceiver => 'Receiver';

  @override
  String get stepPayment => 'Payment';

  @override
  String get stepReview => 'Review';

  @override
  String get refreshed => 'Refreshed';

  @override
  String get ok => 'OK';

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
  String get active => 'Firfircoon';

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
  String get payWithCard => 'Pay with Card';

  @override
  String get securePayment => 'Secure Payment';

  @override
  String get cardDetails => 'Card Details';

  @override
  String get deposit => 'Deposit';

  @override
  String get withdraw => 'Kala bax';

  @override
  String get savings => 'Kaydka';

  @override
  String get invest => 'Invest';

  @override
  String get transactions => 'Dhaqdhaqaaqyada';

  @override
  String get food => 'Food';

  @override
  String get shopping => 'Shopping';

  @override
  String get billsLabel => 'Bills';

  @override
  String get monthlyBudget => 'Miisaaniyadda Bisha';

  @override
  String get cardSettings => 'Card Settings';

  @override
  String get frozen => 'Frozen';

  @override
  String get unfreezeCard => 'Unfreeze Card';

  @override
  String get freezeCard => 'Xir kaadhka';

  @override
  String get temporarilyDisablePayments => 'Temporarily disable payments';

  @override
  String get security => 'Amniga';

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
  String get enterSecurityPin => 'Enter Security PIN';

  @override
  String get cardInformation => 'Xogta Kaadhka';

  @override
  String get visaDetails => 'Faahfaahinta Visa-ha';

  @override
  String get mastercardDetails => 'Faahfaahinta Mastercard-ka';

  @override
  String cardDetailsInfo(Object amount) {
    return 'Geli xogta kaadhkaaga si aad u dhammaystirto xawaaladda $amount';
  }

  @override
  String get cardHolderName => 'Magaca Mulkiilaha Kaadhka';

  @override
  String get expiryDate => 'Taariikhda Dhicitaanka';

  @override
  String get cvv => 'CVV';

  @override
  String get secureProcessing =>
      'Waxaa si ammaan ah loo socodsiinayaa lacag bixintaada...';

  @override
  String get selectBank => 'Dooro Bangiga';

  @override
  String get addBank => 'Add Bank';

  @override
  String get murtaaxWalletDesc => 'Ka bixi hadhaaga app-kaaga';

  @override
  String get visaMastercardDesc => 'Ku bixi adoo isticmaalaya kaadhkaaga';

  @override
  String get bankTransferDesc => 'Xawilaad toos ah oo bangi';

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
  String get emailAddress => 'Email-ka';

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
  String get cardHolder => 'CARD HOLDER';

  @override
  String get yourName => 'MAGACAAGA';

  @override
  String get expires => 'EXPIRES';

  @override
  String get requiredField => 'Waa lagama maarmaan';

  @override
  String get chooseProviderAndEnterPhone =>
      'Dooro shirkadda oo geli lambarka telefoonka';

  @override
  String get enterNumberToCharge => 'Geli lambarka lacagta laga jarayo';

  @override
  String get servicePin => 'PIN-ka Adeegga';

  @override
  String get enterPin => 'Geli PIN-ka';

  @override
  String get ibanHint => 'tusaale: GB29 NWBK 6016 1331 9268 19';

  @override
  String get cardHolderNameLabel => 'Magaca Mulkiilaha Kaadhka';

  @override
  String get johnDoe => 'Maxamed Cali';

  @override
  String get verifyingIdentity => 'Verifying Identity...';

  @override
  String get pleaseFillAllFields => 'Fadlan buuxi dhammaan meelaha banaan';

  @override
  String get virtualCardTopUp => 'Ku Shubista Kaadhka Virtual-ka';

  @override
  String get cardTopUpSuccessful => 'Lacag ku shubista kaadhku waa guul!';

  @override
  String cardTopUpSuccessMessage(String amount) {
    return '$amount ayaa lagu daray kaadhkaaga virtual-ka ah.';
  }

  @override
  String get enterAmountToTopUp => 'Geli cadadka aad ku shubayso';

  @override
  String get topUp => 'Ku Shubo';

  @override
  String topUpInstantlyVia(String method) {
    return 'Si degdeg ah ugu shubo $method';
  }

  @override
  String get walletPin => 'PIN-ka Wallet-ka';

  @override
  String get enterWalletPinMessage =>
      'Geli 4-digit PIN-kaaga wallet-ka si aad u xaqiijiso lacag ku shubista.';

  @override
  String get confirm => 'Xaqiiji';

  @override
  String get submit => 'Gudbi';

  @override
  String get accountName => 'Account Name';

  @override
  String get transferToAccountBelow =>
      'Please transfer the amount to the account below and click continue.';

  @override
  String cardEndingIn(String lastFour) {
    return 'Kaadhka ku dhammaada $lastFour';
  }

  @override
  String get withdrawMoney => 'Withdraw Money';

  @override
  String get withdrawToStripe => 'Kala bax akoonkaaga Stripe';

  @override
  String get withdrawalMethod => 'Withdrawal Method';

  @override
  String get stripeEmail => 'Stripe Email';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get iban => 'IBAN';

  @override
  String get reviewWithdrawal => 'Review Withdrawal';

  @override
  String get details => 'Details';

  @override
  String get free => 'Free';

  @override
  String get totalDeducted => 'Total Deducted';

  @override
  String get confirmWithdraw => 'Confirm & Withdraw';

  @override
  String get confirmAndWithdraw => 'Confirm & Withdraw';

  @override
  String get transactionFailed => 'Transaction Failed';

  @override
  String get transactionFailedMessage =>
      'Something went wrong. Please try again or contact support.';

  @override
  String get tryAgain => 'Mar kale isku day';

  @override
  String newBalance(String balance) {
    return 'New Balance: $balance';
  }

  @override
  String get withdrawalRequested => 'Withdrawal Requested!';

  @override
  String withdrawalSuccessMessage(String amount) {
    return 'Your withdrawal of $amount is being processed.';
  }

  @override
  String get withdrawal => 'Withdrawal';

  @override
  String get feeLabel => 'Fee (0.99%):';

  @override
  String get totalDeduct => 'Total Deduct:';

  @override
  String minAmountError(String amount) {
    return 'Minimum amount is $amount';
  }

  @override
  String maxAmountError(String amount) {
    return 'Maximum amount is $amount';
  }

  @override
  String get insufficientBalanceWithFee => 'Insufficient balance (incl. fee)';

  @override
  String get phoneLengthError => 'Number must be 9 digits';

  @override
  String get payBills => 'Pay Bills';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get recentBills => 'Recent Bills';

  @override
  String get amountToPay => 'Cadadka la bixinayo';

  @override
  String get confirmPayment => 'Xaqiiji Bixinta';

  @override
  String get paymentSuccessful => 'Bixinta way guulaysatay!';

  @override
  String paymentSuccessMessage(String amount, String category) {
    return 'Your payment of $amount for $category has been processed.';
  }

  @override
  String get billDetails => 'Faahfaahinta Biilka';

  @override
  String get serviceProvider => 'Service Provider';

  @override
  String get category => 'Category';

  @override
  String get accountId => 'Account ID';

  @override
  String get amountPaid => 'Amount Paid';

  @override
  String get paymentDate => 'Payment Date';

  @override
  String get status => 'Xaaladda';

  @override
  String get success => 'Guul';

  @override
  String get pending => 'Wuu socdaa';

  @override
  String get completed => 'Guulaystay';

  @override
  String get downloadReceipt => 'Download Receipt';

  @override
  String get downloadPdf => 'Download PDF';

  @override
  String get viewReceipt => 'View Receipt';

  @override
  String get transactionSuccessful => 'Transaction Successful!';

  @override
  String get topUpSuccessful => 'Top-up Successful!';

  @override
  String get withdrawalSuccessful => 'Withdrawal Successful!';

  @override
  String get cardPaymentSuccessful => 'Card Payment Successful!';

  @override
  String get walletTransaction => 'Wallet Transaction';

  @override
  String get merchant => 'Ganacsade';

  @override
  String get sourceReceiver => 'Source/Receiver';

  @override
  String get receiverSource => 'Receiver/Source';

  @override
  String get transactionId => 'ID-ga Dhaqdhaqaaqa';

  @override
  String get date => 'Taariikhda';

  @override
  String get close => 'Close';

  @override
  String get backToBills => 'Back to Bills';

  @override
  String get electricity => 'Korontada';

  @override
  String get water => 'Biyaha';

  @override
  String get internet => 'Internet-ka';

  @override
  String get tvCable => 'TV Cable';

  @override
  String get education => 'Education';

  @override
  String get govServices => 'Gov Services';

  @override
  String get stripe => 'Stripe';

  @override
  String get debitCreditCard => 'Debit / Credit Card';

  @override
  String get justAMoment => 'Just a moment';

  @override
  String get processing => 'Processing...';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get otherBank => 'Other Bank';

  @override
  String get bankName => 'Bank Name';

  @override
  String get enterBankName => 'Enter Bank Name';

  @override
  String get enterAccountNumber => 'Enter Account Number';

  @override
  String get enterAccountName => 'Enter Account Name';

  @override
  String get noActiveCards => 'No active cards';

  @override
  String get orderVirtualCard => 'Order Virtual Card';

  @override
  String get instantlyIssueNewCard => 'Instantly issue a new digital card';

  @override
  String get addToAppleWallet => 'Add to Apple Wallet';

  @override
  String get addToGooglePay => 'Add to Google Pay';

  @override
  String get terminateCardConfirm =>
      'Are you sure you want to permanently delete this card? This action cannot be undone.';

  @override
  String get all => 'Dhammaan';

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get cardTerminated => 'Card Terminated';

  @override
  String get cardTerminatedSuccess =>
      'Your virtual card has been permanently deleted.';

  @override
  String get topUpFromWallet => 'Top-up from Wallet';

  @override
  String get withdrawToWallet => 'U dir Wallet-ka';

  @override
  String get withdrawToWalletDesc => 'U wareeji hadhaaga wallet-kaaga weyn';

  @override
  String get withdrawToBankDesc => 'Kala bax bangi gudaha ama dibadda ah';

  @override
  String get withdrawToStripeDesc => 'Withdraw to your Stripe account';

  @override
  String get enterVirtualCardPin =>
      'Geli 4-digit PIN-kaaga kaadhka virtual-ka ah si aad u xaqiijiso kala bixitaanka.';

  @override
  String get currentCardBalance => 'HADHAAGA KAADHKA EE HADDA';

  @override
  String get welcomeBack => 'Ku soo laabo guul!';

  @override
  String get enterPhoneNumberToContinue =>
      'Enter your phone number to continue';

  @override
  String get dontHaveAccountSignUp => 'Don\'t have an account? Sign Up';

  @override
  String get createAccount => 'Abuur Akoon';

  @override
  String get joinMurtaaxPayToday => 'Ku soo biir MurtaaxPay maanta';

  @override
  String get password => 'Sirta';

  @override
  String get signUp => 'Isku diwaangeli';

  @override
  String get alreadyHaveAccountLogin => 'Horay ma u lahayd akoon? Soo gal';

  @override
  String get confirmYourPin => 'Confirm your PIN';

  @override
  String get toKeepYourMoneySafe => 'To keep your money safe';

  @override
  String get useFaceIdFingerprint => 'Use FaceID / Fingerprint';

  @override
  String get virtualCardBalance => 'HADHAAGA KAADHKA VIRTUAL-KA AH';

  @override
  String get messages => 'Messages';

  @override
  String get startNewConversation => 'Start new conversation';

  @override
  String get searchConversations => 'Search conversations...';

  @override
  String get noMessages => 'No messages';

  @override
  String get now => 'Hadda';

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String daysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get online => 'Online';

  @override
  String get viewInfo => 'View Info';

  @override
  String get helpSupport => 'Caawinaad';

  @override
  String get clearChat => 'Clear Chat';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get nameLabel => 'Name';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get emailLabel => 'Email';

  @override
  String get messageTypes => 'Message Types';

  @override
  String get messageTypesDesc =>
      'Text, SMS, Audio, Images, Documents & Personal Info';

  @override
  String get shareInformation => 'Share Information';

  @override
  String get shareInformationDesc =>
      'Securely share your contact details and address';

  @override
  String get searchChats => 'Search Chats';

  @override
  String get searchChatsDesc => 'Find any conversation quickly';

  @override
  String get chatSettings => 'Chat Settings';

  @override
  String get chatSettingsDesc => 'Clear chat history and manage preferences';

  @override
  String get clearChatConfirm => 'Are you sure you want to clear this chat?';

  @override
  String get clear => 'Tirtir';

  @override
  String get location => 'Location';

  @override
  String get youSentMoney => 'You sent money';

  @override
  String get youReceivedMoney => 'You received money';

  @override
  String get smsMessage => 'SMS Message';

  @override
  String get audioMessage => 'Audio Message';

  @override
  String get downloadingDocument => 'Downloading document...';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get sms => 'SMS';

  @override
  String get gallery => 'Gallery';

  @override
  String get file => 'File';

  @override
  String get contact => 'Contact';

  @override
  String get typeAMessage => 'Type a message...';

  @override
  String get shareContent => 'Share Content';

  @override
  String get smsSentSuccess => 'SMS sent successfully!';

  @override
  String get audioSentSuccess => 'Audio message sent!';

  @override
  String get imageSentSuccess => 'Image sent!';

  @override
  String get documentSentSuccess => 'Document sent!';

  @override
  String get personalInfoSharedSuccess => 'Personal information shared!';

  @override
  String get sharePersonalInfo => 'Share Personal Info';

  @override
  String get reviewInfoToShare => 'Review information to share';

  @override
  String get infoSharedNotice =>
      'This information will be shared with the current conversation.';

  @override
  String get address => 'Address';

  @override
  String get postalCode => 'Postal Code';

  @override
  String get country => 'Country';

  @override
  String get pleaseEnter => 'Please enter';

  @override
  String get help => 'Help';

  @override
  String get returnToHome => 'Return to Home';

  @override
  String get verification => 'Xaqiijinta';

  @override
  String get voucherCopied => 'Voucher code copied! Ready to use.';

  @override
  String get howToUse => 'How to use';

  @override
  String get stepRedeem => 'Tap \'Redeem Now\' to copy the code.';

  @override
  String get stepTransfer => 'Start a new money transfer.';

  @override
  String get stepPaste => 'Paste code in the \'Promo Code\' field.';

  @override
  String get welcomeBonus => 'Welcome Bonus';

  @override
  String get welcomeBonusDesc => 'Get 5% cashback on your next transfer.';

  @override
  String get expires30Dec => 'Expires: 30 Dec';

  @override
  String get familyFriday => 'Family Friday';

  @override
  String get familyFridayDesc => 'Zero fees for any transfer to Somalia today!';

  @override
  String get expiresTomorrow => 'Expires: Tomorrow';

  @override
  String get eidSpecial => 'Eid Special';

  @override
  String get eidSpecialDesc => '\$10 bonus on transfers over \$100.';

  @override
  String get expiresIn5Days => 'Expires: in 5 days';

  @override
  String get reward => 'REWARD';

  @override
  String get copied => 'Copied!';

  @override
  String get redeemNow => 'Redeem Now';

  @override
  String get referAndEarn => 'Refer & Earn';

  @override
  String get referralCodeCopied => 'Referral code copied to clipboard!';

  @override
  String get rewardsWaiting => 'Rewards Waiting';

  @override
  String get inviteFriendsGet10 => 'Invite Friends, Get \$10';

  @override
  String get referralDescription =>
      'Share MurtaaxPay with your friends and you both get \$10 when they make their first transfer of \$50 or more.';

  @override
  String get yourReferralCode => 'Your Referral Code';

  @override
  String get copy => 'COPY';

  @override
  String get whatsApp => 'WhatsApp';

  @override
  String get sadaqahCommunity => 'Sadaqah & Community';

  @override
  String get medicalEmergency => 'Medical Emergency';

  @override
  String get medicalEmergencyDesc =>
      'Help Ahmed cover his heart surgery expenses in Turkey.';

  @override
  String get villageWaterWell => 'Village Water Well';

  @override
  String get villageWaterWellDesc =>
      'Building a permanent water source for a village in Gedo.';

  @override
  String get educationSupport => 'Education Support';

  @override
  String get educationSupportDesc =>
      'Scholarships for 10 orphans in Mogadishu.';

  @override
  String get verified => 'La xaqiijiyay';

  @override
  String get by => 'By';

  @override
  String get raised => 'Raised';

  @override
  String get goal => 'Goal';

  @override
  String get startAFundraiser => 'Start a Fundraiser';

  @override
  String get totalInvestment => 'Total Investment';

  @override
  String get yourPortfolio => 'Your Portfolio';

  @override
  String get bitcoin => 'Bitcoin';

  @override
  String get ethereum => 'Ethereum';

  @override
  String get gold => 'Gold';

  @override
  String get investmentOpportunities => 'Investment Opportunities';

  @override
  String get realEstate => 'Real Estate';

  @override
  String get realEstateDesc => 'Investment in premium property projects.';

  @override
  String get agriculture => 'Agriculture';

  @override
  String get agricultureDesc => 'Support local sustainable farming.';

  @override
  String get savingsAndGoals => 'Savings & Goals';

  @override
  String get activeGoals => 'Active Goals';

  @override
  String get createNewGoal => 'Create New Goal';

  @override
  String get totalSavings => 'Total Savings';

  @override
  String get cardBalanceLabel => 'Card: ';

  @override
  String get chooseWithdrawalMethod => 'Choose Withdrawal Method';

  @override
  String get sendToWallet => 'Send to Wallet';

  @override
  String get payFromSavingBalance => 'Pay from your Saving balance';

  @override
  String get sendToCard => 'Send to Card';

  @override
  String get withdrawToVirtualCard => 'withdraw to your virtual card';

  @override
  String get savingsBalanceLabel => 'SAVINGS BALANCE';

  @override
  String get cardPin => 'Card PIN';

  @override
  String withdrawalSuccessFromSavings(String amount) {
    return 'You have successfully withdrawn $amount from your savings.';
  }

  @override
  String get goalName => 'Goal Name';

  @override
  String get targetAmount => 'Target Amount';

  @override
  String get deadline => 'Deadline';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get selectColor => 'Select Color';

  @override
  String get create => 'Create';

  @override
  String get creating => 'Creating...';

  @override
  String get goalCreated => 'Goal Created!';

  @override
  String goalCreatedSuccess(String title, String amount) {
    return 'Your new goal \'$title\' with a target of $amount has been set up successfully.';
  }

  @override
  String get backToSavings => 'Back to Savings';

  @override
  String get sendFromWallet => 'Send from Wallet';

  @override
  String get payFromWalletBalance => 'Pay from your wallet balance';

  @override
  String get sendFromCard => 'Send from Card';

  @override
  String get payFromVirtualCard => 'Pay from your Virtual Card';

  @override
  String get paused => 'Paused';

  @override
  String get targetWithColon => 'Target: ';

  @override
  String get addFunds => 'Add Funds';

  @override
  String get edit => 'Wax ka beddel';

  @override
  String get resume => 'Resume';

  @override
  String get pause => 'Pause';

  @override
  String get delete => 'Tirtir';

  @override
  String get amountToAdd => 'Amount to add';

  @override
  String get fundsAddedSuccess => 'Successfully added funds!';

  @override
  String get deleteGoal => 'Delete Goal?';

  @override
  String get deleteGoalConfirm => 'Are you sure? This action cannot be undone.';

  @override
  String get editGoal => 'Edit Goal';

  @override
  String get save => 'Keydi';

  @override
  String get pinChangedSuccess => 'PIN-ka waa la beddelay';

  @override
  String get done => 'Done';

  @override
  String get changePin => 'Beddel PIN-ka';

  @override
  String get createNewPin => 'Create New PIN';

  @override
  String get newPinDescription =>
      'Enter your current PIN and choose a new 4-digit security PIN.';

  @override
  String get currentPin => 'Current PIN';

  @override
  String get pleaseEnterCurrentPin => 'Please enter current PIN';

  @override
  String get pinMustBe4Digits => 'PIN must be 4 digits';

  @override
  String get newPin => 'New PIN';

  @override
  String get pleaseEnterNewPin => 'Please enter new PIN';

  @override
  String get cannotBeSameAsOld => 'Cannot be same as old PIN';

  @override
  String get confirmNewPin => 'Confirm New PIN';

  @override
  String get pleaseConfirmNewPin => 'Please confirm new PIN';

  @override
  String get pinsDoNotMatch => 'PINs do not match';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get termsConditions => 'Terms & Conditions';

  @override
  String get lastUpdated => 'Last Updated';

  @override
  String get acceptanceOfTerms => '1. Acceptance of Terms';

  @override
  String get acceptanceOfTermsDesc =>
      'By accessing or using MurtaaxPay, you agree to be bound by these terms. If you do not agree to all of these terms, do not use our services.';

  @override
  String get userVerificationL10n => '2. User Verification';

  @override
  String get userVerificationDescL10n =>
      'To comply with financial regulations, we require identity verification for certain transaction limits. You agree to provide accurate information.';

  @override
  String get transactionFees => '3. Transaction Fees';

  @override
  String get transactionFeesDesc =>
      'Fees are clearly displayed before every transaction. By confirming a transaction, you agree to pay the specified fees.';

  @override
  String get privacyPolicyL10n => '4. Privacy Policy';

  @override
  String get privacyPolicyDescL10n =>
      'Your privacy is important to us. We use bank-grade encryption to protect your data. Please review our full privacy policy for more details.';

  @override
  String get limitationOfLiability => '5. Limitation of Liability';

  @override
  String get limitationOfLiabilityDesc =>
      'MurtaaxPay is not liable for indirect, incidental, or consequential damages resulting from the use or inability to use the service.';

  @override
  String get allRightsReserved => 'Xuquuqda oo dhan waa la dhawray.';

  @override
  String get oct2023 => 'Oct 2023';

  @override
  String get copyrightMurtaaxPay => '© 2026 MurtaaxPay.';

  @override
  String get hagbad => 'Hagbad';

  @override
  String get myGroups => 'Kooxahayga';

  @override
  String get createHagbad => 'Abuur Hagbad';

  @override
  String get totalSavingsPot => 'Total Savings Pot';

  @override
  String get activeGroups => 'Kooxaha firfircoon';

  @override
  String get nextPayout => 'Lacag bixinta xigta';

  @override
  String get days => 'maalmood';

  @override
  String get nextInLine => 'Next in line';

  @override
  String get rotation => 'Rotation';

  @override
  String get groupChat => 'Wada-hadalka Kooxda';

  @override
  String get payContribution => 'Pay Contribution';

  @override
  String get createNewHagbad => 'Create New Hagbad';

  @override
  String get groupName => 'Magaca Kooxda';

  @override
  String get contributionAmount => 'Cadadka qaaraanka';

  @override
  String get frequency => 'Muddada';

  @override
  String get addMembers => 'Add Members (Phone or Name)';

  @override
  String get createGroup => 'Create Group';

  @override
  String get received => 'Waa la helay';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get potWadar => 'Total Fund';

  @override
  String get daily => 'Maalinle';

  @override
  String get weekly => 'Toddobaadle';

  @override
  String get tenDays => '10 Days';

  @override
  String get monthly => 'Bil kasta';

  @override
  String get yearly => 'Yearly';

  @override
  String get hagbadCreatedSuccess =>
      'Kooxda Hagbad-da waa la abuuray si guul leh!';

  @override
  String get drawing => 'Bakhti-nasiibka...';

  @override
  String get qoriTuur => 'Qori-tuur';

  @override
  String get noHagbadGroups =>
      'Weli ma jiraan kooxo. Abuur mid si aad u bilowdo kaydinta!';

  @override
  String get progress => 'Heerka';

  @override
  String get members => 'Xubnaha';

  @override
  String get you => 'You';

  @override
  String get youAdmin => 'You (Admin)';

  @override
  String payoutAfterFee(String fee) {
    return 'Payout after $fee fee';
  }

  @override
  String get receiptDownloaded => 'Receipt downloaded to your gallery';

  @override
  String yourTurnInDays(int days) {
    return 'Your turn in $days days';
  }

  @override
  String dayWithNumber(int number) {
    return 'Day $number';
  }

  @override
  String weekWithNumber(int number) {
    return 'Week $number';
  }

  @override
  String monthWithNumber(int number) {
    return 'Month $number';
  }

  @override
  String turnWithNumber(int number) {
    return 'Turn $number';
  }

  @override
  String get cannotSwapReceived =>
      'Cannot swap with members who already received their payout.';

  @override
  String get swapTurn => 'Swap Turn';

  @override
  String swapWith(String name) {
    return 'Swap with $name';
  }

  @override
  String get trustedMember => 'Trusted Member';

  @override
  String get yourTurnToday => 'It\'s your turn today!';

  @override
  String get yourTurnTomorrow => 'Your turn is tomorrow!';

  @override
  String get serviceFee => 'Service Fee';

  @override
  String get payoutMethod => 'Payout Method';

  @override
  String get payoutReady => 'Payout Ready';

  @override
  String get totalPot => 'Wadarta lacagta';

  @override
  String get hagbadPot => 'Hagbad Pot (Escrow)';

  @override
  String get amountToReceive => 'Amount to Receive';

  @override
  String get claimPayout => 'Claim Payout';

  @override
  String get guarantor => 'Dammaanad-qaade';

  @override
  String get guarantorNameLabel => 'Guarantor Name';

  @override
  String get guarantorIdLabel => 'Guarantor Wallet ID';

  @override
  String get requireGuarantor => 'This member requires a guarantor (Uul)';

  @override
  String get guarantorDetails => 'Guarantor Details';

  @override
  String get debtor => 'Debtor';

  @override
  String get remaining => 'Haray';

  @override
  String get hagbadTerms => '6. Aaminaadda Hagbad';

  @override
  String get hagbadTermsDesc =>
      'Hagbad waxay ku dhisantahay aaminaad. Markaad ku biirto, waxaad ogolaatay inaad qaaraanka bixiso waqtigeeda. Haddii xubni bixin waayo, Uul-ka ayaa mas\'uul ka ah bixinta deynta.';

  @override
  String get iAgreeToHagbadTerms =>
      'Waxaan ogolaaday shuruudaha iyo qawaaniinta Hagbad ee MurtaaxPay.';

  @override
  String get hagbadOath => 'Dhaar diini ah';

  @override
  String get hagbadOathDesc =>
      'Ilaahay ma kugu ogyahay in aad daacad ahaanayso, bixinaysona qaaraanka waqtigiisa?';

  @override
  String get iConfirmOath => 'Ilaahay ayaan ku dhaartay inaan daacad noqonayo.';

  @override
  String get remindAll => 'Xusuusi Dhammaan';

  @override
  String get remindMember => 'Xusuusi Xubinta';

  @override
  String reminderSent(Object name) {
    return 'Xusuusin waxaa loo diray $name';
  }

  @override
  String get allRemindersSent => 'Xusuusin wadajir ah waa la diray';

  @override
  String get replaceMember => 'Beddel Xubinta';

  @override
  String get substituteMember => 'Xubinta Beddelka ah';

  @override
  String get enterNewMemberDetails => 'Gali xogta xubinta cusub';

  @override
  String get memberReplaced => 'Xubinta si guul leh ayaa loo beddelay';

  @override
  String get cannotReplaceReceived =>
      'Lama beddeli karo xubin horay lacag u qaadatay';

  @override
  String get paymentHistory => 'Taariikhda Bixinta';

  @override
  String paidOn(Object date) {
    return 'Waxaa la bixiyay $date';
  }

  @override
  String get noPaymentsYet => 'Weli wax lacag ah lama bixin';

  @override
  String get lateFee => 'Ganaax Dib-u-dhac';

  @override
  String get applyPenalty => 'Saar Ganaax';

  @override
  String get penaltyAmount => 'Cadadka Ganaaxa (\$)';

  @override
  String penaltyApplied(Object amount, Object name) {
    return 'Ganaax dhan \$$amount ayaa la saaray $name';
  }

  @override
  String get invitationReceived => 'Casuumad Cusub';

  @override
  String invitationDesc(String admin, String amount) {
    return '$admin ayaa kugu casuumay kooxda Hagbad ee \$$amount.';
  }

  @override
  String get acceptInvite => 'Aqbal Casuumadda';

  @override
  String get religiousOathRequired => 'Dhaar Diini ah ayaa loo baahan yahay';

  @override
  String get oathRequirementDesc =>
      'Si aad si rasmi ah ugu biirto kooxda, waa inaad saxiixdaa dhaarta (Dhaarta).';

  @override
  String get signOathNow => 'Hadda Dhaaro';

  @override
  String get apr2026 => 'Abriil 2026';

  @override
  String get scanQR => 'Sawirka QR-ka';

  @override
  String get alignQRCode => 'QR Code-ka ku aadi sanduuqa si uu u scan-gareeyo';

  @override
  String get myQrCode => 'Sawirkayga QR-ka';

  @override
  String get shareMyQrCode =>
      'La wadaag sawirkaaga QR-ka si aad lacag u hesho.';

  @override
  String get quickSend => 'Xiriirada Degdega';

  @override
  String get invalidWalletId => 'Nambarka Wallet-ka waa khalad';

  @override
  String get cannotSendToSelf => 'Isku diri kartid lacag';

  @override
  String get evcPlus => 'EVC Plus';

  @override
  String get edahab => 'e-Dahab';

  @override
  String get zaad => 'ZAAD';

  @override
  String get sahal => 'Sahal';

  @override
  String get purposeOfRemittance => 'Sababta Lacag Dirista';

  @override
  String get purpose => 'Ujeedada';

  @override
  String get familySupport => 'Taageerada Qoyska';

  @override
  String get educationTuition => 'Waxbarasho';

  @override
  String get medicalExpenses => 'Caafimaad';

  @override
  String get businessTransaction => 'Ganacsi';

  @override
  String get propertyRent => 'Guri/Kiira';

  @override
  String get gift => 'Hadiyad';

  @override
  String get other => 'Kale';

  @override
  String get contactPermissionRequired =>
      'Fadlan oggolaaw inaan akhrino dadka kugu jira (contacts) si aad u doorto.';

  @override
  String get openSettings => 'Fur Settings';

  @override
  String get dailyLimit => 'Xadka Maalinlaha ah';

  @override
  String get monthlyLimit => 'Xadka Bisha';

  @override
  String get recentSavingsActivity => 'Dhaqdhaqaaqa Kaydka';

  @override
  String get noActivityYet => 'Weli ma jiraan dhaqdhaqaaqyo';
}
