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

  /// No description provided for @searchTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search transactions...'**
  String get searchTransactions;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

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

  /// No description provided for @confirmTopUp.
  ///
  /// In en, this message translates to:
  /// **'Confirm Top-Up'**
  String get confirmTopUp;

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

  /// No description provided for @refreshed.
  ///
  /// In en, this message translates to:
  /// **'Refreshed'**
  String get refreshed;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

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
  /// **'Enter Security PIN'**
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

  /// No description provided for @addBank.
  ///
  /// In en, this message translates to:
  /// **'Add Bank'**
  String get addBank;

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

  /// No description provided for @cardTopUpSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Card Top-Up Successful!'**
  String get cardTopUpSuccessful;

  /// No description provided for @cardTopUpSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'{amount} has been added to your virtual card.'**
  String cardTopUpSuccessMessage(String amount);

  /// No description provided for @enterAmountToTopUp.
  ///
  /// In en, this message translates to:
  /// **'Enter amount to top up'**
  String get enterAmountToTopUp;

  /// No description provided for @topUp.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get topUp;

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

  /// No description provided for @transferToAccountBelow.
  ///
  /// In en, this message translates to:
  /// **'Please transfer the amount to the account below and click continue.'**
  String get transferToAccountBelow;

  /// No description provided for @cardEndingIn.
  ///
  /// In en, this message translates to:
  /// **'Card ending in {lastFour}'**
  String cardEndingIn(String lastFour);

  /// No description provided for @withdrawMoney.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Money'**
  String get withdrawMoney;

  /// No description provided for @withdrawToStripe.
  ///
  /// In en, this message translates to:
  /// **'Withdraw to your Stripe account'**
  String get withdrawToStripe;

  /// No description provided for @withdrawalMethod.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Method'**
  String get withdrawalMethod;

  /// No description provided for @stripeEmail.
  ///
  /// In en, this message translates to:
  /// **'Stripe Email'**
  String get stripeEmail;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @iban.
  ///
  /// In en, this message translates to:
  /// **'IBAN'**
  String get iban;

  /// No description provided for @reviewWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Review Withdrawal'**
  String get reviewWithdrawal;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @totalDeducted.
  ///
  /// In en, this message translates to:
  /// **'Total Deducted'**
  String get totalDeducted;

  /// No description provided for @confirmWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Withdraw'**
  String get confirmWithdraw;

  /// No description provided for @withdrawalRequested.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Requested!'**
  String get withdrawalRequested;

  /// No description provided for @withdrawalSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your withdrawal of {amount} is being processed.'**
  String withdrawalSuccessMessage(String amount);

  /// No description provided for @payBills.
  ///
  /// In en, this message translates to:
  /// **'Pay Bills'**
  String get payBills;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @recentBills.
  ///
  /// In en, this message translates to:
  /// **'Recent Bills'**
  String get recentBills;

  /// No description provided for @amountToPay.
  ///
  /// In en, this message translates to:
  /// **'Amount to Pay (\$)'**
  String get amountToPay;

  /// No description provided for @confirmPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get confirmPayment;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccessful;

  /// No description provided for @paymentSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your payment of {amount} for {category} has been processed.'**
  String paymentSuccessMessage(String amount, String category);

  /// No description provided for @billDetails.
  ///
  /// In en, this message translates to:
  /// **'Bill Details'**
  String get billDetails;

  /// No description provided for @serviceProvider.
  ///
  /// In en, this message translates to:
  /// **'Service Provider'**
  String get serviceProvider;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @accountId.
  ///
  /// In en, this message translates to:
  /// **'Account ID'**
  String get accountId;

  /// No description provided for @amountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount Paid'**
  String get amountPaid;

  /// No description provided for @paymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment Date'**
  String get paymentDate;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @downloadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Download Receipt'**
  String get downloadReceipt;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @transactionSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Transaction Successful!'**
  String get transactionSuccessful;

  /// No description provided for @topUpSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Top-up Successful!'**
  String get topUpSuccessful;

  /// No description provided for @withdrawalSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Successful!'**
  String get withdrawalSuccessful;

  /// No description provided for @cardPaymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Card Payment Successful!'**
  String get cardPaymentSuccessful;

  /// No description provided for @walletTransaction.
  ///
  /// In en, this message translates to:
  /// **'Wallet Transaction'**
  String get walletTransaction;

  /// No description provided for @merchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get merchant;

  /// No description provided for @sourceReceiver.
  ///
  /// In en, this message translates to:
  /// **'Source/Receiver'**
  String get sourceReceiver;

  /// No description provided for @receiverSource.
  ///
  /// In en, this message translates to:
  /// **'Receiver/Source'**
  String get receiverSource;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @backToBills.
  ///
  /// In en, this message translates to:
  /// **'Back to Bills'**
  String get backToBills;

  /// No description provided for @electricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get electricity;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @internet.
  ///
  /// In en, this message translates to:
  /// **'Internet'**
  String get internet;

  /// No description provided for @tvCable.
  ///
  /// In en, this message translates to:
  /// **'TV Cable'**
  String get tvCable;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @govServices.
  ///
  /// In en, this message translates to:
  /// **'Gov Services'**
  String get govServices;

  /// No description provided for @stripe.
  ///
  /// In en, this message translates to:
  /// **'Stripe'**
  String get stripe;

  /// No description provided for @debitCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Debit / Credit Card'**
  String get debitCreditCard;

  /// No description provided for @justAMoment.
  ///
  /// In en, this message translates to:
  /// **'Just a moment'**
  String get justAMoment;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @otherBank.
  ///
  /// In en, this message translates to:
  /// **'Other Bank'**
  String get otherBank;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankName;

  /// No description provided for @enterBankName.
  ///
  /// In en, this message translates to:
  /// **'Enter Bank Name'**
  String get enterBankName;

  /// No description provided for @enterAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Account Number'**
  String get enterAccountNumber;

  /// No description provided for @enterAccountName.
  ///
  /// In en, this message translates to:
  /// **'Enter Account Name'**
  String get enterAccountName;

  /// No description provided for @noActiveCards.
  ///
  /// In en, this message translates to:
  /// **'No active cards'**
  String get noActiveCards;

  /// No description provided for @orderVirtualCard.
  ///
  /// In en, this message translates to:
  /// **'Order Virtual Card'**
  String get orderVirtualCard;

  /// No description provided for @instantlyIssueNewCard.
  ///
  /// In en, this message translates to:
  /// **'Instantly issue a new digital card'**
  String get instantlyIssueNewCard;

  /// No description provided for @addToAppleWallet.
  ///
  /// In en, this message translates to:
  /// **'Add to Apple Wallet'**
  String get addToAppleWallet;

  /// No description provided for @addToGooglePay.
  ///
  /// In en, this message translates to:
  /// **'Add to Google Pay'**
  String get addToGooglePay;

  /// No description provided for @terminateCardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this card? This action cannot be undone.'**
  String get terminateCardConfirm;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @cardTerminated.
  ///
  /// In en, this message translates to:
  /// **'Card Terminated'**
  String get cardTerminated;

  /// No description provided for @cardTerminatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your virtual card has been permanently deleted.'**
  String get cardTerminatedSuccess;

  /// No description provided for @topUpFromWallet.
  ///
  /// In en, this message translates to:
  /// **'Top-up from Wallet'**
  String get topUpFromWallet;

  /// No description provided for @withdrawToWallet.
  ///
  /// In en, this message translates to:
  /// **'Send to Wallet'**
  String get withdrawToWallet;

  /// No description provided for @withdrawToWalletDesc.
  ///
  /// In en, this message translates to:
  /// **'Transfer to your main wallet balance'**
  String get withdrawToWalletDesc;

  /// No description provided for @withdrawToBankDesc.
  ///
  /// In en, this message translates to:
  /// **'Withdraw to local or international bank'**
  String get withdrawToBankDesc;

  /// No description provided for @withdrawToStripeDesc.
  ///
  /// In en, this message translates to:
  /// **'Withdraw to your Stripe account'**
  String get withdrawToStripeDesc;

  /// No description provided for @enterVirtualCardPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your 4-digit virtual card PIN to authorize withdrawal.'**
  String get enterVirtualCardPin;

  /// No description provided for @currentCardBalance.
  ///
  /// In en, this message translates to:
  /// **'CURRENT CARD BALANCE'**
  String get currentCardBalance;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @enterPhoneNumberToContinue.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to continue'**
  String get enterPhoneNumberToContinue;

  /// No description provided for @dontHaveAccountSignUp.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get dontHaveAccountSignUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinMurtaaxPayToday.
  ///
  /// In en, this message translates to:
  /// **'Join MurtaaxPay today and start sending money safely.'**
  String get joinMurtaaxPayToday;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @alreadyHaveAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccountLogin;

  /// No description provided for @confirmYourPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get confirmYourPin;

  /// No description provided for @toKeepYourMoneySafe.
  ///
  /// In en, this message translates to:
  /// **'To keep your money safe'**
  String get toKeepYourMoneySafe;

  /// No description provided for @useFaceIdFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Use FaceID / Fingerprint'**
  String get useFaceIdFingerprint;

  /// No description provided for @virtualCardBalance.
  ///
  /// In en, this message translates to:
  /// **'VIRTUAL CARD BALANCE'**
  String get virtualCardBalance;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @startNewConversation.
  ///
  /// In en, this message translates to:
  /// **'Start new conversation'**
  String get startNewConversation;

  /// No description provided for @searchConversations.
  ///
  /// In en, this message translates to:
  /// **'Search conversations...'**
  String get searchConversations;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages'**
  String get noMessages;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get now;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(int hours);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgo(int days);

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @viewInfo.
  ///
  /// In en, this message translates to:
  /// **'View Info'**
  String get viewInfo;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get clearChat;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @messageTypes.
  ///
  /// In en, this message translates to:
  /// **'Message Types'**
  String get messageTypes;

  /// No description provided for @messageTypesDesc.
  ///
  /// In en, this message translates to:
  /// **'Text, SMS, Audio, Images, Documents & Personal Info'**
  String get messageTypesDesc;

  /// No description provided for @shareInformation.
  ///
  /// In en, this message translates to:
  /// **'Share Information'**
  String get shareInformation;

  /// No description provided for @shareInformationDesc.
  ///
  /// In en, this message translates to:
  /// **'Securely share your contact details and address'**
  String get shareInformationDesc;

  /// No description provided for @searchChats.
  ///
  /// In en, this message translates to:
  /// **'Search Chats'**
  String get searchChats;

  /// No description provided for @searchChatsDesc.
  ///
  /// In en, this message translates to:
  /// **'Find any conversation quickly'**
  String get searchChatsDesc;

  /// No description provided for @chatSettings.
  ///
  /// In en, this message translates to:
  /// **'Chat Settings'**
  String get chatSettings;

  /// No description provided for @chatSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear chat history and manage preferences'**
  String get chatSettingsDesc;

  /// No description provided for @clearChatConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear this chat?'**
  String get clearChatConfirm;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @youSentMoney.
  ///
  /// In en, this message translates to:
  /// **'You sent money'**
  String get youSentMoney;

  /// No description provided for @youReceivedMoney.
  ///
  /// In en, this message translates to:
  /// **'You received money'**
  String get youReceivedMoney;

  /// No description provided for @smsMessage.
  ///
  /// In en, this message translates to:
  /// **'SMS Message'**
  String get smsMessage;

  /// No description provided for @audioMessage.
  ///
  /// In en, this message translates to:
  /// **'Audio Message'**
  String get audioMessage;

  /// No description provided for @downloadingDocument.
  ///
  /// In en, this message translates to:
  /// **'Downloading document...'**
  String get downloadingDocument;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @sms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get sms;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// No description provided for @shareContent.
  ///
  /// In en, this message translates to:
  /// **'Share Content'**
  String get shareContent;

  /// No description provided for @smsSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'SMS sent successfully!'**
  String get smsSentSuccess;

  /// No description provided for @audioSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Audio message sent!'**
  String get audioSentSuccess;

  /// No description provided for @imageSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Image sent!'**
  String get imageSentSuccess;

  /// No description provided for @documentSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Document sent!'**
  String get documentSentSuccess;

  /// No description provided for @personalInfoSharedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Personal information shared!'**
  String get personalInfoSharedSuccess;

  /// No description provided for @sharePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Share Personal Info'**
  String get sharePersonalInfo;

  /// No description provided for @reviewInfoToShare.
  ///
  /// In en, this message translates to:
  /// **'Review information to share'**
  String get reviewInfoToShare;

  /// No description provided for @infoSharedNotice.
  ///
  /// In en, this message translates to:
  /// **'This information will be shared with the current conversation.'**
  String get infoSharedNotice;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal Code'**
  String get postalCode;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @pleaseEnter.
  ///
  /// In en, this message translates to:
  /// **'Please enter'**
  String get pleaseEnter;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @returnToHome.
  ///
  /// In en, this message translates to:
  /// **'Return to Home'**
  String get returnToHome;

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// No description provided for @voucherCopied.
  ///
  /// In en, this message translates to:
  /// **'Voucher code copied! Ready to use.'**
  String get voucherCopied;

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How to use'**
  String get howToUse;

  /// No description provided for @stepRedeem.
  ///
  /// In en, this message translates to:
  /// **'Tap \'Redeem Now\' to copy the code.'**
  String get stepRedeem;

  /// No description provided for @stepTransfer.
  ///
  /// In en, this message translates to:
  /// **'Start a new money transfer.'**
  String get stepTransfer;

  /// No description provided for @stepPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste code in the \'Promo Code\' field.'**
  String get stepPaste;

  /// No description provided for @welcomeBonus.
  ///
  /// In en, this message translates to:
  /// **'Welcome Bonus'**
  String get welcomeBonus;

  /// No description provided for @welcomeBonusDesc.
  ///
  /// In en, this message translates to:
  /// **'Get 5% cashback on your next transfer.'**
  String get welcomeBonusDesc;

  /// No description provided for @expires30Dec.
  ///
  /// In en, this message translates to:
  /// **'Expires: 30 Dec'**
  String get expires30Dec;

  /// No description provided for @familyFriday.
  ///
  /// In en, this message translates to:
  /// **'Family Friday'**
  String get familyFriday;

  /// No description provided for @familyFridayDesc.
  ///
  /// In en, this message translates to:
  /// **'Zero fees for any transfer to Somalia today!'**
  String get familyFridayDesc;

  /// No description provided for @expiresTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Expires: Tomorrow'**
  String get expiresTomorrow;

  /// No description provided for @eidSpecial.
  ///
  /// In en, this message translates to:
  /// **'Eid Special'**
  String get eidSpecial;

  /// No description provided for @eidSpecialDesc.
  ///
  /// In en, this message translates to:
  /// **'\$10 bonus on transfers over \$100.'**
  String get eidSpecialDesc;

  /// No description provided for @expiresIn5Days.
  ///
  /// In en, this message translates to:
  /// **'Expires: in 5 days'**
  String get expiresIn5Days;

  /// No description provided for @reward.
  ///
  /// In en, this message translates to:
  /// **'REWARD'**
  String get reward;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get copied;

  /// No description provided for @redeemNow.
  ///
  /// In en, this message translates to:
  /// **'Redeem Now'**
  String get redeemNow;

  /// No description provided for @referAndEarn.
  ///
  /// In en, this message translates to:
  /// **'Refer & Earn'**
  String get referAndEarn;

  /// No description provided for @referralCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Referral code copied to clipboard!'**
  String get referralCodeCopied;

  /// No description provided for @rewardsWaiting.
  ///
  /// In en, this message translates to:
  /// **'Rewards Waiting'**
  String get rewardsWaiting;

  /// No description provided for @inviteFriendsGet10.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends, Get \$10'**
  String get inviteFriendsGet10;

  /// No description provided for @referralDescription.
  ///
  /// In en, this message translates to:
  /// **'Share MurtaaxPay with your friends and you both get \$10 when they make their first transfer of \$50 or more.'**
  String get referralDescription;

  /// No description provided for @yourReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Your Referral Code'**
  String get yourReferralCode;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'COPY'**
  String get copy;

  /// No description provided for @whatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsApp;

  /// No description provided for @sadaqahCommunity.
  ///
  /// In en, this message translates to:
  /// **'Sadaqah & Community'**
  String get sadaqahCommunity;

  /// No description provided for @medicalEmergency.
  ///
  /// In en, this message translates to:
  /// **'Medical Emergency'**
  String get medicalEmergency;

  /// No description provided for @medicalEmergencyDesc.
  ///
  /// In en, this message translates to:
  /// **'Help Ahmed cover his heart surgery expenses in Turkey.'**
  String get medicalEmergencyDesc;

  /// No description provided for @villageWaterWell.
  ///
  /// In en, this message translates to:
  /// **'Village Water Well'**
  String get villageWaterWell;

  /// No description provided for @villageWaterWellDesc.
  ///
  /// In en, this message translates to:
  /// **'Building a permanent water source for a village in Gedo.'**
  String get villageWaterWellDesc;

  /// No description provided for @educationSupport.
  ///
  /// In en, this message translates to:
  /// **'Education Support'**
  String get educationSupport;

  /// No description provided for @educationSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'Scholarships for 10 orphans in Mogadishu.'**
  String get educationSupportDesc;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @by.
  ///
  /// In en, this message translates to:
  /// **'By'**
  String get by;

  /// No description provided for @raised.
  ///
  /// In en, this message translates to:
  /// **'Raised'**
  String get raised;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @startAFundraiser.
  ///
  /// In en, this message translates to:
  /// **'Start a Fundraiser'**
  String get startAFundraiser;

  /// No description provided for @totalInvestment.
  ///
  /// In en, this message translates to:
  /// **'Total Investment'**
  String get totalInvestment;

  /// No description provided for @yourPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Your Portfolio'**
  String get yourPortfolio;

  /// No description provided for @bitcoin.
  ///
  /// In en, this message translates to:
  /// **'Bitcoin'**
  String get bitcoin;

  /// No description provided for @ethereum.
  ///
  /// In en, this message translates to:
  /// **'Ethereum'**
  String get ethereum;

  /// No description provided for @gold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get gold;

  /// No description provided for @investmentOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Investment Opportunities'**
  String get investmentOpportunities;

  /// No description provided for @realEstate.
  ///
  /// In en, this message translates to:
  /// **'Real Estate'**
  String get realEstate;

  /// No description provided for @realEstateDesc.
  ///
  /// In en, this message translates to:
  /// **'Investment in premium property projects.'**
  String get realEstateDesc;

  /// No description provided for @agriculture.
  ///
  /// In en, this message translates to:
  /// **'Agriculture'**
  String get agriculture;

  /// No description provided for @agricultureDesc.
  ///
  /// In en, this message translates to:
  /// **'Support local sustainable farming.'**
  String get agricultureDesc;

  /// No description provided for @savingsAndGoals.
  ///
  /// In en, this message translates to:
  /// **'Savings & Goals'**
  String get savingsAndGoals;

  /// No description provided for @activeGoals.
  ///
  /// In en, this message translates to:
  /// **'Active Goals'**
  String get activeGoals;

  /// No description provided for @createNewGoal.
  ///
  /// In en, this message translates to:
  /// **'Create New Goal'**
  String get createNewGoal;

  /// No description provided for @totalSavings.
  ///
  /// In en, this message translates to:
  /// **'Total Savings'**
  String get totalSavings;

  /// No description provided for @chooseWithdrawalMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose Withdrawal Method'**
  String get chooseWithdrawalMethod;

  /// No description provided for @sendToWallet.
  ///
  /// In en, this message translates to:
  /// **'Send to Wallet'**
  String get sendToWallet;

  /// No description provided for @payFromSavingBalance.
  ///
  /// In en, this message translates to:
  /// **'Pay from your Saving balance'**
  String get payFromSavingBalance;

  /// No description provided for @sendToCard.
  ///
  /// In en, this message translates to:
  /// **'Send to Card'**
  String get sendToCard;

  /// No description provided for @withdrawToVirtualCard.
  ///
  /// In en, this message translates to:
  /// **'withdraw to your virtual card'**
  String get withdrawToVirtualCard;

  /// No description provided for @savingsBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'SAVINGS BALANCE'**
  String get savingsBalanceLabel;

  /// No description provided for @cardPin.
  ///
  /// In en, this message translates to:
  /// **'Card PIN'**
  String get cardPin;

  /// No description provided for @withdrawalSuccessFromSavings.
  ///
  /// In en, this message translates to:
  /// **'You have successfully withdrawn {amount} from your savings.'**
  String withdrawalSuccessFromSavings(String amount);

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal Name'**
  String get goalName;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get targetAmount;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadline;

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creating;

  /// No description provided for @goalCreated.
  ///
  /// In en, this message translates to:
  /// **'Goal Created!'**
  String get goalCreated;

  /// No description provided for @goalCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your new goal \'{title}\' with a target of {amount} has been set up successfully.'**
  String goalCreatedSuccess(String title, String amount);

  /// No description provided for @backToSavings.
  ///
  /// In en, this message translates to:
  /// **'Back to Savings'**
  String get backToSavings;

  /// No description provided for @sendFromWallet.
  ///
  /// In en, this message translates to:
  /// **'Send from Wallet'**
  String get sendFromWallet;

  /// No description provided for @payFromWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'Pay from your wallet balance'**
  String get payFromWalletBalance;

  /// No description provided for @sendFromCard.
  ///
  /// In en, this message translates to:
  /// **'Send from Card'**
  String get sendFromCard;

  /// No description provided for @payFromVirtualCard.
  ///
  /// In en, this message translates to:
  /// **'Pay from your Virtual Card'**
  String get payFromVirtualCard;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @targetWithColon.
  ///
  /// In en, this message translates to:
  /// **'Target: '**
  String get targetWithColon;

  /// No description provided for @addFunds.
  ///
  /// In en, this message translates to:
  /// **'Add Funds'**
  String get addFunds;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @amountToAdd.
  ///
  /// In en, this message translates to:
  /// **'Amount to add'**
  String get amountToAdd;

  /// No description provided for @fundsAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully added funds!'**
  String get fundsAddedSuccess;

  /// No description provided for @deleteGoal.
  ///
  /// In en, this message translates to:
  /// **'Delete Goal?'**
  String get deleteGoal;

  /// No description provided for @deleteGoalConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? This action cannot be undone.'**
  String get deleteGoalConfirm;

  /// No description provided for @editGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit Goal'**
  String get editGoal;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @pinChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your PIN has been updated successfully. Use your new PIN for future transactions.'**
  String get pinChangedSuccess;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// No description provided for @createNewPin.
  ///
  /// In en, this message translates to:
  /// **'Create New PIN'**
  String get createNewPin;

  /// No description provided for @newPinDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your current PIN and choose a new 4-digit security PIN.'**
  String get newPinDescription;

  /// No description provided for @currentPin.
  ///
  /// In en, this message translates to:
  /// **'Current PIN'**
  String get currentPin;

  /// No description provided for @pleaseEnterCurrentPin.
  ///
  /// In en, this message translates to:
  /// **'Please enter current PIN'**
  String get pleaseEnterCurrentPin;

  /// No description provided for @pinMustBe4Digits.
  ///
  /// In en, this message translates to:
  /// **'PIN must be 4 digits'**
  String get pinMustBe4Digits;

  /// No description provided for @newPin.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get newPin;

  /// No description provided for @pleaseEnterNewPin.
  ///
  /// In en, this message translates to:
  /// **'Please enter new PIN'**
  String get pleaseEnterNewPin;

  /// No description provided for @cannotBeSameAsOld.
  ///
  /// In en, this message translates to:
  /// **'Cannot be same as old PIN'**
  String get cannotBeSameAsOld;

  /// No description provided for @confirmNewPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm New PIN'**
  String get confirmNewPin;

  /// No description provided for @pleaseConfirmNewPin.
  ///
  /// In en, this message translates to:
  /// **'Please confirm new PIN'**
  String get pleaseConfirmNewPin;

  /// No description provided for @pinsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get pinsDoNotMatch;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdated;

  /// No description provided for @acceptanceOfTerms.
  ///
  /// In en, this message translates to:
  /// **'1. Acceptance of Terms'**
  String get acceptanceOfTerms;

  /// No description provided for @acceptanceOfTermsDesc.
  ///
  /// In en, this message translates to:
  /// **'By accessing or using MurtaaxPay, you agree to be bound by these terms. If you do not agree to all of these terms, do not use our services.'**
  String get acceptanceOfTermsDesc;

  /// No description provided for @userVerificationL10n.
  ///
  /// In en, this message translates to:
  /// **'2. User Verification'**
  String get userVerificationL10n;

  /// No description provided for @userVerificationDescL10n.
  ///
  /// In en, this message translates to:
  /// **'To comply with financial regulations, we require identity verification for certain transaction limits. You agree to provide accurate information.'**
  String get userVerificationDescL10n;

  /// No description provided for @transactionFees.
  ///
  /// In en, this message translates to:
  /// **'3. Transaction Fees'**
  String get transactionFees;

  /// No description provided for @transactionFeesDesc.
  ///
  /// In en, this message translates to:
  /// **'Fees are clearly displayed before every transaction. By confirming a transaction, you agree to pay the specified fees.'**
  String get transactionFeesDesc;

  /// No description provided for @privacyPolicyL10n.
  ///
  /// In en, this message translates to:
  /// **'4. Privacy Policy'**
  String get privacyPolicyL10n;

  /// No description provided for @privacyPolicyDescL10n.
  ///
  /// In en, this message translates to:
  /// **'Your privacy is important to us. We use bank-grade encryption to protect your data. Please review our full privacy policy for more details.'**
  String get privacyPolicyDescL10n;

  /// No description provided for @limitationOfLiability.
  ///
  /// In en, this message translates to:
  /// **'5. Limitation of Liability'**
  String get limitationOfLiability;

  /// No description provided for @limitationOfLiabilityDesc.
  ///
  /// In en, this message translates to:
  /// **'MurtaaxPay is not liable for indirect, incidental, or consequential damages resulting from the use or inability to use the service.'**
  String get limitationOfLiabilityDesc;

  /// No description provided for @allRightsReserved.
  ///
  /// In en, this message translates to:
  /// **'All Rights Reserved'**
  String get allRightsReserved;

  /// No description provided for @oct2023.
  ///
  /// In en, this message translates to:
  /// **'Oct 2023'**
  String get oct2023;

  /// No description provided for @copyrightMurtaaxPay.
  ///
  /// In en, this message translates to:
  /// **'© 2026 MurtaaxPay.'**
  String get copyrightMurtaaxPay;

  /// No description provided for @hagbad.
  ///
  /// In en, this message translates to:
  /// **'Hagbad'**
  String get hagbad;

  /// No description provided for @myGroups.
  ///
  /// In en, this message translates to:
  /// **'My Groups'**
  String get myGroups;

  /// No description provided for @createHagbad.
  ///
  /// In en, this message translates to:
  /// **'Create Hagbad'**
  String get createHagbad;

  /// No description provided for @totalSavingsPot.
  ///
  /// In en, this message translates to:
  /// **'Total Savings Pot'**
  String get totalSavingsPot;

  /// No description provided for @activeGroups.
  ///
  /// In en, this message translates to:
  /// **'Active Groups'**
  String get activeGroups;

  /// No description provided for @nextPayout.
  ///
  /// In en, this message translates to:
  /// **'Next Payout'**
  String get nextPayout;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @nextInLine.
  ///
  /// In en, this message translates to:
  /// **'Next in line'**
  String get nextInLine;

  /// No description provided for @rotation.
  ///
  /// In en, this message translates to:
  /// **'Rotation'**
  String get rotation;

  /// No description provided for @groupChat.
  ///
  /// In en, this message translates to:
  /// **'Group Chat'**
  String get groupChat;

  /// No description provided for @payContribution.
  ///
  /// In en, this message translates to:
  /// **'Pay Contribution'**
  String get payContribution;

  /// No description provided for @createNewHagbad.
  ///
  /// In en, this message translates to:
  /// **'Create New Hagbad'**
  String get createNewHagbad;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupName;

  /// No description provided for @contributionAmount.
  ///
  /// In en, this message translates to:
  /// **'Contribution Amount'**
  String get contributionAmount;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @addMembers.
  ///
  /// In en, this message translates to:
  /// **'Add Members (Phone or Name)'**
  String get addMembers;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get createGroup;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @potWadar.
  ///
  /// In en, this message translates to:
  /// **'Total Fund'**
  String get potWadar;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @tenDays.
  ///
  /// In en, this message translates to:
  /// **'10 Days'**
  String get tenDays;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @hagbadCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Hagbad Group Created Successfully!'**
  String get hagbadCreatedSuccess;

  /// No description provided for @drawing.
  ///
  /// In en, this message translates to:
  /// **'Drawing...'**
  String get drawing;

  /// No description provided for @qoriTuur.
  ///
  /// In en, this message translates to:
  /// **'Qori-tuur'**
  String get qoriTuur;

  /// No description provided for @noHagbadGroups.
  ///
  /// In en, this message translates to:
  /// **'No groups yet. Create one to start saving!'**
  String get noHagbadGroups;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @youAdmin.
  ///
  /// In en, this message translates to:
  /// **'You (Admin)'**
  String get youAdmin;

  /// No description provided for @payoutAfterFee.
  ///
  /// In en, this message translates to:
  /// **'Payout after {fee} fee'**
  String payoutAfterFee(String fee);

  /// No description provided for @receiptDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Receipt downloaded to your gallery'**
  String get receiptDownloaded;

  /// No description provided for @yourTurnInDays.
  ///
  /// In en, this message translates to:
  /// **'Your turn in {days} days'**
  String yourTurnInDays(int days);

  /// No description provided for @dayWithNumber.
  ///
  /// In en, this message translates to:
  /// **'Day {number}'**
  String dayWithNumber(int number);

  /// No description provided for @weekWithNumber.
  ///
  /// In en, this message translates to:
  /// **'Week {number}'**
  String weekWithNumber(int number);

  /// No description provided for @monthWithNumber.
  ///
  /// In en, this message translates to:
  /// **'Month {number}'**
  String monthWithNumber(int number);

  /// No description provided for @turnWithNumber.
  ///
  /// In en, this message translates to:
  /// **'Turn {number}'**
  String turnWithNumber(int number);

  /// No description provided for @cannotSwapReceived.
  ///
  /// In en, this message translates to:
  /// **'Cannot swap with members who already received their payout.'**
  String get cannotSwapReceived;

  /// No description provided for @swapTurn.
  ///
  /// In en, this message translates to:
  /// **'Swap Turn'**
  String get swapTurn;

  /// No description provided for @swapWith.
  ///
  /// In en, this message translates to:
  /// **'Swap with {name}'**
  String swapWith(String name);

  /// No description provided for @trustedMember.
  ///
  /// In en, this message translates to:
  /// **'Trusted Member'**
  String get trustedMember;

  /// No description provided for @yourTurnToday.
  ///
  /// In en, this message translates to:
  /// **'It\'s your turn today!'**
  String get yourTurnToday;

  /// No description provided for @yourTurnTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Your turn is tomorrow!'**
  String get yourTurnTomorrow;

  /// No description provided for @serviceFee.
  ///
  /// In en, this message translates to:
  /// **'Service Fee'**
  String get serviceFee;

  /// No description provided for @payoutMethod.
  ///
  /// In en, this message translates to:
  /// **'Payout Method'**
  String get payoutMethod;

  /// No description provided for @payoutReady.
  ///
  /// In en, this message translates to:
  /// **'Payout Ready'**
  String get payoutReady;

  /// No description provided for @totalPot.
  ///
  /// In en, this message translates to:
  /// **'Total Fund'**
  String get totalPot;

  /// No description provided for @hagbadPot.
  ///
  /// In en, this message translates to:
  /// **'Hagbad Pot (Escrow)'**
  String get hagbadPot;

  /// No description provided for @amountToReceive.
  ///
  /// In en, this message translates to:
  /// **'Amount to Receive'**
  String get amountToReceive;

  /// No description provided for @claimPayout.
  ///
  /// In en, this message translates to:
  /// **'Claim Payout'**
  String get claimPayout;

  /// No description provided for @guarantor.
  ///
  /// In en, this message translates to:
  /// **'Guarantor (Uul)'**
  String get guarantor;

  /// No description provided for @guarantorNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Guarantor Name'**
  String get guarantorNameLabel;

  /// No description provided for @guarantorIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Guarantor Wallet ID'**
  String get guarantorIdLabel;

  /// No description provided for @requireGuarantor.
  ///
  /// In en, this message translates to:
  /// **'This member requires a guarantor (Uul)'**
  String get requireGuarantor;

  /// No description provided for @guarantorDetails.
  ///
  /// In en, this message translates to:
  /// **'Guarantor Details'**
  String get guarantorDetails;

  /// No description provided for @debtor.
  ///
  /// In en, this message translates to:
  /// **'Debtor'**
  String get debtor;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @hagbadTerms.
  ///
  /// In en, this message translates to:
  /// **'6. Hagbad Social Trust'**
  String get hagbadTerms;

  /// No description provided for @hagbadTermsDesc.
  ///
  /// In en, this message translates to:
  /// **'Hagbad is based on mutual trust (Aaminaad). By joining, you agree to make timely contributions. If a member fails to pay, the Guarantor (Uul) is responsible for covering the debt.'**
  String get hagbadTermsDesc;

  /// No description provided for @iAgreeToHagbadTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Hagbad Social Trust terms and conditions.'**
  String get iAgreeToHagbadTerms;

  /// No description provided for @hagbadOath.
  ///
  /// In en, this message translates to:
  /// **'Religious Oath (Dhaar)'**
  String get hagbadOath;

  /// No description provided for @hagbadOathDesc.
  ///
  /// In en, this message translates to:
  /// **'Do you swear by Allah that you will be honest and fulfill your contributions on time?'**
  String get hagbadOathDesc;

  /// No description provided for @iConfirmOath.
  ///
  /// In en, this message translates to:
  /// **'I swear by Allah to be honest.'**
  String get iConfirmOath;

  /// No description provided for @remindAll.
  ///
  /// In en, this message translates to:
  /// **'Remind All'**
  String get remindAll;

  /// No description provided for @remindMember.
  ///
  /// In en, this message translates to:
  /// **'Remind Member'**
  String get remindMember;

  /// No description provided for @reminderSent.
  ///
  /// In en, this message translates to:
  /// **'Reminder sent to {name}'**
  String reminderSent(Object name);

  /// No description provided for @allRemindersSent.
  ///
  /// In en, this message translates to:
  /// **'Reminders sent to all pending members'**
  String get allRemindersSent;

  /// No description provided for @replaceMember.
  ///
  /// In en, this message translates to:
  /// **'Replace Member'**
  String get replaceMember;

  /// No description provided for @substituteMember.
  ///
  /// In en, this message translates to:
  /// **'Substitute Member'**
  String get substituteMember;

  /// No description provided for @enterNewMemberDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter new member details'**
  String get enterNewMemberDetails;

  /// No description provided for @memberReplaced.
  ///
  /// In en, this message translates to:
  /// **'Member has been successfully replaced'**
  String get memberReplaced;

  /// No description provided for @cannotReplaceReceived.
  ///
  /// In en, this message translates to:
  /// **'Cannot replace a member who has already received a payout'**
  String get cannotReplaceReceived;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// No description provided for @paidOn.
  ///
  /// In en, this message translates to:
  /// **'Paid on {date}'**
  String paidOn(Object date);

  /// No description provided for @noPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments recorded yet'**
  String get noPaymentsYet;

  /// No description provided for @lateFee.
  ///
  /// In en, this message translates to:
  /// **'Late Fee'**
  String get lateFee;

  /// No description provided for @applyPenalty.
  ///
  /// In en, this message translates to:
  /// **'Apply Penalty'**
  String get applyPenalty;

  /// No description provided for @penaltyAmount.
  ///
  /// In en, this message translates to:
  /// **'Penalty Amount (\$)'**
  String get penaltyAmount;

  /// No description provided for @penaltyApplied.
  ///
  /// In en, this message translates to:
  /// **'Penalty of \${amount} applied to {name}'**
  String penaltyApplied(Object amount, Object name);

  /// No description provided for @invitationReceived.
  ///
  /// In en, this message translates to:
  /// **'Invitation Received'**
  String get invitationReceived;

  /// No description provided for @invitationDesc.
  ///
  /// In en, this message translates to:
  /// **'{admin} invited you to join a \${amount} Hagbad group.'**
  String invitationDesc(String admin, String amount);

  /// No description provided for @acceptInvite.
  ///
  /// In en, this message translates to:
  /// **'Accept Invitation'**
  String get acceptInvite;

  /// No description provided for @religiousOathRequired.
  ///
  /// In en, this message translates to:
  /// **'Religious Oath Required'**
  String get religiousOathRequired;

  /// No description provided for @oathRequirementDesc.
  ///
  /// In en, this message translates to:
  /// **'To join the group officially, you must sign the religious oath (Dhaar).'**
  String get oathRequirementDesc;

  /// No description provided for @signOathNow.
  ///
  /// In en, this message translates to:
  /// **'Sign Oath Now'**
  String get signOathNow;

  /// No description provided for @apr2026.
  ///
  /// In en, this message translates to:
  /// **'Apr 2026'**
  String get apr2026;
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
