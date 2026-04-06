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
