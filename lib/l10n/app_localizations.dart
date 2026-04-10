import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_et.dart';
import 'app_localizations_so.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('et'),
    Locale('so'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MurtaaxPay'**
  String get appTitle;

  /// No description provided for @splashTitle.
  ///
  /// In en, this message translates to:
  /// **'MURTAAX PAY'**
  String get splashTitle;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trusted Somali Partner'**
  String get splashSubtitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcome;

  /// No description provided for @sendMoney.
  ///
  /// In en, this message translates to:
  /// **'Send Money'**
  String get sendMoney;

  /// No description provided for @receiveMoney.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get receiveMoney;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @bills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get bills;

  /// No description provided for @sadaqah.
  ///
  /// In en, this message translates to:
  /// **'Sadaqah'**
  String get sadaqah;

  /// No description provided for @exchange.
  ///
  /// In en, this message translates to:
  /// **'Exchange'**
  String get exchange;

  /// No description provided for @vouchers.
  ///
  /// In en, this message translates to:
  /// **'Vouchers'**
  String get vouchers;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @spendingAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Spending Analysis'**
  String get spendingAnalysis;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance'**
  String get walletBalance;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @virtualCard.
  ///
  /// In en, this message translates to:
  /// **'Virtual Card'**
  String get virtualCard;

  /// No description provided for @virtualCardDesc.
  ///
  /// In en, this message translates to:
  /// **'Get your secure virtual card and shop globally.'**
  String get virtualCardDesc;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get enterAmount;

  /// No description provided for @transferLimit.
  ///
  /// In en, this message translates to:
  /// **'Limit: \$5,000.00'**
  String get transferLimit;

  /// No description provided for @feeRate.
  ///
  /// In en, this message translates to:
  /// **'Fee: \$0.99 per \$100'**
  String get feeRate;

  /// No description provided for @youSend.
  ///
  /// In en, this message translates to:
  /// **'You Send'**
  String get youSend;

  /// No description provided for @searchCurrency.
  ///
  /// In en, this message translates to:
  /// **'Search currency'**
  String get searchCurrency;

  /// No description provided for @receiverGets.
  ///
  /// In en, this message translates to:
  /// **'Receiver Gets'**
  String get receiverGets;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// No description provided for @murtaaxWallet.
  ///
  /// In en, this message translates to:
  /// **'Murtaax Wallet'**
  String get murtaaxWallet;

  /// No description provided for @visaMastercard.
  ///
  /// In en, this message translates to:
  /// **'Visa / MasterCard'**
  String get visaMastercard;

  /// No description provided for @mobileMoney.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money'**
  String get mobileMoney;

  /// No description provided for @transactionFee.
  ///
  /// In en, this message translates to:
  /// **'Transaction Fee'**
  String get transactionFee;

  /// No description provided for @totalToPay.
  ///
  /// In en, this message translates to:
  /// **'Total to Pay'**
  String get totalToPay;

  /// No description provided for @insufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Balance'**
  String get insufficientBalance;

  /// No description provided for @receiverDetails.
  ///
  /// In en, this message translates to:
  /// **'Receiver Details'**
  String get receiverDetails;

  /// No description provided for @enterReceiverPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter Receiver Phone Number'**
  String get enterReceiverPhone;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @receiver.
  ///
  /// In en, this message translates to:
  /// **'Receiver'**
  String get receiver;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @pleaseEnterDetails.
  ///
  /// In en, this message translates to:
  /// **'Please enter receiver details'**
  String get pleaseEnterDetails;

  /// No description provided for @continueToReview.
  ///
  /// In en, this message translates to:
  /// **'Continue to Review'**
  String get continueToReview;

  /// No description provided for @reviewTransfer.
  ///
  /// In en, this message translates to:
  /// **'Review Transfer'**
  String get reviewTransfer;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @fee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get fee;

  /// No description provided for @exchangeRate.
  ///
  /// In en, this message translates to:
  /// **'Exchange Rate'**
  String get exchangeRate;

  /// No description provided for @deliveryNotice.
  ///
  /// In en, this message translates to:
  /// **'Funds will be delivered within minutes'**
  String get deliveryNotice;

  /// No description provided for @confirmAndPay.
  ///
  /// In en, this message translates to:
  /// **'Confirm and Pay'**
  String get confirmAndPay;

  /// No description provided for @choosePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose Payment Method'**
  String get choosePaymentMethod;

  /// No description provided for @finalSummary.
  ///
  /// In en, this message translates to:
  /// **'Final Summary'**
  String get finalSummary;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @instantPaymentFromWallet.
  ///
  /// In en, this message translates to:
  /// **'Instant payment from wallet'**
  String get instantPaymentFromWallet;

  /// No description provided for @payViaHormuud.
  ///
  /// In en, this message translates to:
  /// **'Pay via Hormuud EVC Plus'**
  String get payViaHormuud;

  /// No description provided for @payViaTelesom.
  ///
  /// In en, this message translates to:
  /// **'Pay via Telesom ZAAD'**
  String get payViaTelesom;

  /// No description provided for @payViaSomtel.
  ///
  /// In en, this message translates to:
  /// **'Pay via Somtel e-Dahab'**
  String get payViaSomtel;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// No description provided for @localBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Local Somali bank transfer'**
  String get localBankTransfer;

  /// No description provided for @internationalMethods.
  ///
  /// In en, this message translates to:
  /// **'International Methods'**
  String get internationalMethods;

  /// No description provided for @payWithInternationalCard.
  ///
  /// In en, this message translates to:
  /// **'Pay with international card'**
  String get payWithInternationalCard;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @transferSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Transfer Successful!'**
  String get transferSuccessful;

  /// No description provided for @transferSentMessage.
  ///
  /// In en, this message translates to:
  /// **'{amount} has been safely sent to {receiver}.'**
  String transferSentMessage(Object amount, Object receiver);

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumber;

  /// No description provided for @walletId.
  ///
  /// In en, this message translates to:
  /// **'Wallet ID'**
  String get walletId;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @payoutVia.
  ///
  /// In en, this message translates to:
  /// **'Payout Via'**
  String get payoutVia;

  /// No description provided for @paidUsing.
  ///
  /// In en, this message translates to:
  /// **'Paid Using'**
  String get paidUsing;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @moneyOnWay.
  ///
  /// In en, this message translates to:
  /// **'Your money is on its way.'**
  String get moneyOnWay;

  /// No description provided for @refId.
  ///
  /// In en, this message translates to:
  /// **'Ref ID'**
  String get refId;

  /// No description provided for @idCopied.
  ///
  /// In en, this message translates to:
  /// **'ID Copied'**
  String get idCopied;

  /// No description provided for @shareReceipt.
  ///
  /// In en, this message translates to:
  /// **'Share Receipt'**
  String get shareReceipt;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @addMoney.
  ///
  /// In en, this message translates to:
  /// **'Add Money'**
  String get addMoney;

  /// No description provided for @enterAmountToDeposit.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount to Deposit'**
  String get enterAmountToDeposit;

  /// No description provided for @confirmDeposit.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deposit'**
  String get confirmDeposit;

  /// No description provided for @expiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get expiry;

  /// No description provided for @cardholderName.
  ///
  /// In en, this message translates to:
  /// **'Cardholder Name'**
  String get cardholderName;

  /// No description provided for @fullNameOnCard.
  ///
  /// In en, this message translates to:
  /// **'Full name on card'**
  String get fullNameOnCard;

  /// No description provided for @selectProvider.
  ///
  /// In en, this message translates to:
  /// **'Select Provider'**
  String get selectProvider;

  /// No description provided for @accountHolderName.
  ///
  /// In en, this message translates to:
  /// **'Account Holder Name'**
  String get accountHolderName;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @reviewDeposit.
  ///
  /// In en, this message translates to:
  /// **'Review Deposit'**
  String get reviewDeposit;

  /// No description provided for @totalCharged.
  ///
  /// In en, this message translates to:
  /// **'Total Charged'**
  String get totalCharged;

  /// No description provided for @confirmAndDeposit.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Deposit'**
  String get confirmAndDeposit;

  /// No description provided for @depositSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Deposit Successful!'**
  String get depositSuccessful;

  /// No description provided for @depositSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'{amount} has been added to your wallet.'**
  String depositSuccessMessage(Object amount);

  /// No description provided for @stepAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get stepAmount;

  /// No description provided for @stepReceiver.
  ///
  /// In en, this message translates to:
  /// **'Receiver'**
  String get stepReceiver;

  /// No description provided for @stepPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get stepPayment;

  /// No description provided for @stepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get stepReview;

  /// No description provided for @feeInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Exchange Fee Info'**
  String get feeInfoTitle;

  /// No description provided for @feeInfoContent.
  ///
  /// In en, this message translates to:
  /// **'The fee is 0.99%. For example: sending \$100 will cost only \$0.99 in fees.'**
  String get feeInfoContent;

  /// No description provided for @maxLabel.
  ///
  /// In en, this message translates to:
  /// **'MAX'**
  String get maxLabel;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @murtaaxTransfer.
  ///
  /// In en, this message translates to:
  /// **'Murtaax Transfer'**
  String get murtaaxTransfer;

  /// No description provided for @enterReceiverWalletId.
  ///
  /// In en, this message translates to:
  /// **'Enter Receiver Wallet ID'**
  String get enterReceiverWalletId;

  /// No description provided for @walletIdTransferNotice.
  ///
  /// In en, this message translates to:
  /// **'Funds will be transferred instantly to the specified Murtaax ID.'**
  String get walletIdTransferNotice;

  /// No description provided for @enterWalletIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Wallet ID (e.g. 102234)'**
  String get enterWalletIdHint;

  /// No description provided for @verifiedReceiverLabel.
  ///
  /// In en, this message translates to:
  /// **'VERIFIED RECEIVER'**
  String get verifiedReceiverLabel;

  /// No description provided for @recentContacts.
  ///
  /// In en, this message translates to:
  /// **'Recent Contacts'**
  String get recentContacts;

  /// No description provided for @securityVerification.
  ///
  /// In en, this message translates to:
  /// **'Security Verification'**
  String get securityVerification;

  /// No description provided for @enterTransactionPin.
  ///
  /// In en, this message translates to:
  /// **'Please enter your 4-digit PIN to authorize this payment.'**
  String get enterTransactionPin;

  /// No description provided for @authorizing.
  ///
  /// In en, this message translates to:
  /// **'Authorizing...'**
  String get authorizing;

  /// No description provided for @confirmPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment ({amount})'**
  String confirmPaymentAmount(Object amount);

  /// No description provided for @verifyingTransaction.
  ///
  /// In en, this message translates to:
  /// **'Securing confirming transaction with Murtaax servers...'**
  String get verifyingTransaction;

  /// No description provided for @cancelAndChangeMethod.
  ///
  /// In en, this message translates to:
  /// **'Cancel and Change Method'**
  String get cancelAndChangeMethod;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE BALANCE'**
  String get availableBalance;

  /// No description provided for @deductFeeFromAmount.
  ///
  /// In en, this message translates to:
  /// **'Deduct fee from amount'**
  String get deductFeeFromAmount;

  /// No description provided for @receiverWillReceiveLess.
  ///
  /// In en, this message translates to:
  /// **'Receiver will receive less'**
  String get receiverWillReceiveLess;

  /// No description provided for @payFeeSeparately.
  ///
  /// In en, this message translates to:
  /// **'Pay fee separately'**
  String get payFeeSeparately;

  /// No description provided for @myCards.
  ///
  /// In en, this message translates to:
  /// **'My Cards'**
  String get myCards;

  /// No description provided for @addNewCard.
  ///
  /// In en, this message translates to:
  /// **'Add New Card'**
  String get addNewCard;

  /// No description provided for @cardNumberCopied.
  ///
  /// In en, this message translates to:
  /// **'Card number copied!'**
  String get cardNumberCopied;

  /// No description provided for @payWithCard.
  ///
  /// In en, this message translates to:
  /// **'Pay with Card'**
  String get payWithCard;

  /// No description provided for @securePayment.
  ///
  /// In en, this message translates to:
  /// **'Secure Payment'**
  String get securePayment;

  /// No description provided for @cardDetails.
  ///
  /// In en, this message translates to:
  /// **'Card Details'**
  String get cardDetails;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @savings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// No description provided for @invest.
  ///
  /// In en, this message translates to:
  /// **'Invest'**
  String get invest;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// No description provided for @billsLabel.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get billsLabel;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget'**
  String get monthlyBudget;

  /// No description provided for @cardSettings.
  ///
  /// In en, this message translates to:
  /// **'Card Settings'**
  String get cardSettings;

  /// No description provided for @frozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get frozen;

  /// No description provided for @unfreezeCard.
  ///
  /// In en, this message translates to:
  /// **'Unfreeze Card'**
  String get unfreezeCard;

  /// No description provided for @freezeCard.
  ///
  /// In en, this message translates to:
  /// **'Freeze Card'**
  String get freezeCard;

  /// No description provided for @temporarilyDisablePayments.
  ///
  /// In en, this message translates to:
  /// **'Temporarily disable payments'**
  String get temporarilyDisablePayments;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @cardControls.
  ///
  /// In en, this message translates to:
  /// **'Card Controls'**
  String get cardControls;

  /// No description provided for @onlinePayments.
  ///
  /// In en, this message translates to:
  /// **'Online Payments'**
  String get onlinePayments;

  /// No description provided for @internationalUsage.
  ///
  /// In en, this message translates to:
  /// **'International Usage'**
  String get internationalUsage;

  /// No description provided for @contactlessPayments.
  ///
  /// In en, this message translates to:
  /// **'Contactless Payments'**
  String get contactlessPayments;

  /// No description provided for @terminateCard.
  ///
  /// In en, this message translates to:
  /// **'Terminate Card'**
  String get terminateCard;

  /// No description provided for @permanentlyDeleteCard.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete this virtual card'**
  String get permanentlyDeleteCard;

  /// No description provided for @enterSecurityPin.
  ///
  /// In en, this message translates to:
  /// **'Please enter your 4-digit security PIN'**
  String get enterSecurityPin;

  /// No description provided for @cardInformation.
  ///
  /// In en, this message translates to:
  /// **'Card Information'**
  String get cardInformation;

  /// No description provided for @visaDetails.
  ///
  /// In en, this message translates to:
  /// **'Visa Details'**
  String get visaDetails;

  /// No description provided for @mastercardDetails.
  ///
  /// In en, this message translates to:
  /// **'Mastercard Details'**
  String get mastercardDetails;

  /// No description provided for @cardDetailsInfo.
  ///
  /// In en, this message translates to:
  /// **'Enter your card details to complete the transfer of {amount}'**
  String cardDetailsInfo(Object amount);

  /// No description provided for @cardHolderName.
  ///
  /// In en, this message translates to:
  /// **'Card Holder Name'**
  String get cardHolderName;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @secureProcessing.
  ///
  /// In en, this message translates to:
  /// **'Securely processing your payment...'**
  String get secureProcessing;

  /// No description provided for @selectBank.
  ///
  /// In en, this message translates to:
  /// **'Select Bank'**
  String get selectBank;

  /// No description provided for @murtaaxWalletDesc.
  ///
  /// In en, this message translates to:
  /// **'Pay from your app balance'**
  String get murtaaxWalletDesc;

  /// No description provided for @visaMastercardDesc.
  ///
  /// In en, this message translates to:
  /// **'Pay using your card'**
  String get visaMastercardDesc;

  /// No description provided for @bankTransferDesc.
  ///
  /// In en, this message translates to:
  /// **'Direct bank transfer'**
  String get bankTransferDesc;

  /// No description provided for @mobileMoneyDesc.
  ///
  /// In en, this message translates to:
  /// **'EVC Plus, Sahal, ZAAD, e-Dahab'**
  String get mobileMoneyDesc;

  /// No description provided for @identityVerification.
  ///
  /// In en, this message translates to:
  /// **'Identity Verification'**
  String get identityVerification;

  /// No description provided for @verifyYourIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Identity'**
  String get verifyYourIdentity;

  /// No description provided for @verifyIdentityDesc.
  ///
  /// In en, this message translates to:
  /// **'We need to verify your identity to keep your account secure. This only takes 2 minutes.'**
  String get verifyIdentityDesc;

  /// No description provided for @prepareIdDoc.
  ///
  /// In en, this message translates to:
  /// **'Prepare your ID document'**
  String get prepareIdDoc;

  /// No description provided for @wellLitArea.
  ///
  /// In en, this message translates to:
  /// **'Make sure you\'re in a well-lit area'**
  String get wellLitArea;

  /// No description provided for @followInstructions.
  ///
  /// In en, this message translates to:
  /// **'Follow the on-screen instructions'**
  String get followInstructions;

  /// No description provided for @letsGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Get Started'**
  String get letsGetStarted;

  /// No description provided for @encryptedConnection.
  ///
  /// In en, this message translates to:
  /// **'ENCRYPTED & SECURE CONNECTION'**
  String get encryptedConnection;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @residentialAddress.
  ///
  /// In en, this message translates to:
  /// **'Residential Address'**
  String get residentialAddress;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @chooseDocumentType.
  ///
  /// In en, this message translates to:
  /// **'Choose Document Type'**
  String get chooseDocumentType;

  /// No description provided for @passport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get passport;

  /// No description provided for @nationalIdCard.
  ///
  /// In en, this message translates to:
  /// **'National ID Card'**
  String get nationalIdCard;

  /// No description provided for @driversLicense.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s License'**
  String get driversLicense;

  /// No description provided for @bankGradeEncryption.
  ///
  /// In en, this message translates to:
  /// **'Bank-grade encryption'**
  String get bankGradeEncryption;

  /// No description provided for @dataDeletedNotice.
  ///
  /// In en, this message translates to:
  /// **'Your data is deleted after verification'**
  String get dataDeletedNotice;

  /// No description provided for @frontOfIdCard.
  ///
  /// In en, this message translates to:
  /// **'Front of ID Card'**
  String get frontOfIdCard;

  /// No description provided for @verifyYourFace.
  ///
  /// In en, this message translates to:
  /// **'Verify your face'**
  String get verifyYourFace;

  /// No description provided for @positionFaceNotice.
  ///
  /// In en, this message translates to:
  /// **'Position your face well-lit and clearly'**
  String get positionFaceNotice;

  /// No description provided for @alignId.
  ///
  /// In en, this message translates to:
  /// **'Align your ID'**
  String get alignId;

  /// No description provided for @capturing.
  ///
  /// In en, this message translates to:
  /// **'Capturing...'**
  String get capturing;

  /// No description provided for @lookStraight.
  ///
  /// In en, this message translates to:
  /// **'Look Straight'**
  String get lookStraight;

  /// No description provided for @lookLeft.
  ///
  /// In en, this message translates to:
  /// **'Look Left'**
  String get lookLeft;

  /// No description provided for @lookRight.
  ///
  /// In en, this message translates to:
  /// **'Look Right'**
  String get lookRight;

  /// No description provided for @verificationPending.
  ///
  /// In en, this message translates to:
  /// **'Verification Pending'**
  String get verificationPending;

  /// No description provided for @verificationPendingDesc.
  ///
  /// In en, this message translates to:
  /// **'Your documents are being reviewed. This usually takes 10-15 minutes. We\'ll notify you once it\'s complete.'**
  String get verificationPendingDesc;

  /// No description provided for @documentCheck.
  ///
  /// In en, this message translates to:
  /// **'Document Check'**
  String get documentCheck;

  /// No description provided for @scanningForClarity.
  ///
  /// In en, this message translates to:
  /// **'Scanning for clarity'**
  String get scanningForClarity;

  /// No description provided for @biometricMatch.
  ///
  /// In en, this message translates to:
  /// **'Biometric Match'**
  String get biometricMatch;

  /// No description provided for @comparingSelfie.
  ///
  /// In en, this message translates to:
  /// **'Comparing selfie with ID'**
  String get comparingSelfie;

  /// No description provided for @cardHolder.
  ///
  /// In en, this message translates to:
  /// **'CARD HOLDER'**
  String get cardHolder;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'YOUR NAME'**
  String get yourName;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'EXPIRES'**
  String get expires;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @chooseProviderAndEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Choose your provider and enter phone number'**
  String get chooseProviderAndEnterPhone;

  /// No description provided for @enterNumberToCharge.
  ///
  /// In en, this message translates to:
  /// **'Enter number to charge'**
  String get enterNumberToCharge;

  /// No description provided for @servicePin.
  ///
  /// In en, this message translates to:
  /// **'Service PIN'**
  String get servicePin;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// No description provided for @ibanHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. GB29 NWBK 6016 1331 9268 19'**
  String get ibanHint;

  /// No description provided for @cardHolderNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Holder Name'**
  String get cardHolderNameLabel;

  /// No description provided for @johnDoe.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get johnDoe;

  /// No description provided for @verifyingIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verifying Identity...'**
  String get verifyingIdentity;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @virtualCardTopUp.
  ///
  /// In en, this message translates to:
  /// **'Virtual Card Top-Up'**
  String get virtualCardTopUp;

  /// No description provided for @topUpInstantlyVia.
  ///
  /// In en, this message translates to:
  /// **'Top up instantly via {method}'**
  String topUpInstantlyVia(String method);

  /// No description provided for @walletPin.
  ///
  /// In en, this message translates to:
  /// **'Wallet PIN'**
  String get walletPin;

  /// No description provided for @enterWalletPinMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your 4-digit wallet PIN to authorize top-up.'**
  String get enterWalletPinMessage;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountName;

  /// No description provided for @cardEndingIn.
  ///
  /// In en, this message translates to:
  /// **'Card ending in {lastFour}'**
  String cardEndingIn(String lastFour);
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
      <String>['ar', 'de', 'en', 'et', 'so'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'et':
      return AppLocalizationsEt();
    case 'so':
      return AppLocalizationsSo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
