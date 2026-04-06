// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'MurtaaxPay';

  @override
  String get splashTitle => 'MURTAAX PAY';

  @override
  String get splashSubtitle => 'Vertrauenswürdiger Partner';

  @override
  String get welcome => 'Willkommen zurück';

  @override
  String get sendMoney => 'Geld senden';

  @override
  String get receiveMoney => 'Erhalten';

  @override
  String get balance => 'Kontostand';

  @override
  String get recentTransactions => 'Letzte Transaktionen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get theme => 'Thema';

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
  String get confirmAndPay => 'Bestätigen und Bezahlen';

  @override
  String get choosePaymentMethod => 'Zahlungsmethode wählen';

  @override
  String get finalSummary => 'Zusammenfassung';

  @override
  String get amount => 'Betrag';

  @override
  String get instantPaymentFromWallet => 'Sofortzahlung aus Ihrem Murtaax-Wallet';

  @override
  String get payViaHormuud => 'Bezahlen über Hormuud EVC Plus';

  @override
  String get payViaTelesom => 'Bezahlen über Telesom ZAAD';

  @override
  String get payViaSomtel => 'Bezahlen über Somtel e-Dahab';

  @override
  String get bankTransfer => 'Banküberweisung';

  @override
  String get localBankTransfer => 'Lokale somalische Banküberweisung';

  @override
  String get internationalMethods => 'Internationale Methoden';

  @override
  String get payWithInternationalCard => 'Mit internationaler Karte bezahlen';

  @override
  String get payNow => 'Jetzt bezahlen';

  @override
  String get transferSuccessful => 'Überweisung erfolgreich!';

  @override
  String transferSentMessage(Object amount, Object receiver) {
    return '$amount wurde sicher an $receiver gesendet.';
  }

  @override
  String get method => 'Methode';

  @override
  String get reference => 'Referenz';

  @override
  String get backToHome => 'Zurück zur Startseite';

  @override
  String get murtaaxTransfer => 'Murtaax-Überweisung';

  @override
  String get enterReceiverWalletId => 'Wallet-ID des Empfängers eingeben';

  @override
  String get walletIdTransferNotice => 'Das Guthaben wird sofort auf die angegebene Murtaax-ID übertragen.';

  @override
  String get enterWalletIdHint => 'Wallet-ID eingeben (z. B. 102234)';

  @override
  String get verifiedReceiverLabel => 'VERIFIZIERTER EMPFÄNGER';

  @override
  String get recentContacts => 'Letzte Kontakte';

  @override
  String get securityVerification => 'Sicherheitsüberprüfung';

  @override
  String get enterTransactionPin => 'Bitte geben Sie Ihre 4-stellige PIN ein, um diese Zahlung zu autorisieren.';

  @override
  String get authorizing => 'Autorisierung...';

  @override
  String confirmPaymentAmount(Object amount) {
    return 'Zahlung bestätigen ($amount)';
  }

  @override
  String get verifyingTransaction => 'Transaktion wird sicher mit Murtaax-Servern überprüft...';

  @override
  String get cancelAndChangeMethod => 'Abbrechen und Methode ändern';

  @override
  String get active => 'Aktiv';

  @override
  String get availableBalance => 'VERFÜGBARES GUTHABEN';
}
