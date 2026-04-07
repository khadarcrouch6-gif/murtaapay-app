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
  String get send => 'Senden';

  @override
  String get add => 'Hinzufügen';

  @override
  String get bills => 'Rechnungen';

  @override
  String get sadaqah => 'Sadaqah';

  @override
  String get exchange => 'Umtausch';

  @override
  String get vouchers => 'Gutscheine';

  @override
  String get seeAll => 'Alle ansehen';

  @override
  String get spendingAnalysis => 'Ausgabenanalyse';

  @override
  String get walletBalance => 'Guthaben';

  @override
  String get getStarted => 'Jetzt loslegen';

  @override
  String get virtualCard => 'Virtuelle Karte';

  @override
  String get virtualCardDesc =>
      'Holst du sich deine sichere virtuelle Karte und shoppe weltweit.';

  @override
  String get enterAmount => 'Betrag eingeben';

  @override
  String get transferLimit => 'Limit: 5.000,00 \$';

  @override
  String get feeRate => 'Gebühr: 0,99 \$ pro 100 \$';

  @override
  String get youSend => 'Sie senden';

  @override
  String get searchCurrency => 'Währung suchen';

  @override
  String get receiverGets => 'Empfänger erhält';

  @override
  String get selectPaymentMethod => 'Zahlungsmethode wählen';

  @override
  String get transactionFee => 'Transaktionsgebühr';

  @override
  String get totalToPay => 'Gesamtbetrag';

  @override
  String get insufficientBalance => 'Unzureichendes Guthaben';

  @override
  String get receiverDetails => 'Empfängerdetails';

  @override
  String get enterReceiverPhone => 'Telefonnummer des Empfängers eingeben';

  @override
  String get phoneNumber => 'Telefonnummer';

  @override
  String get receiver => 'Empfänger';

  @override
  String get recent => 'Zuletzt';

  @override
  String get pleaseEnterDetails => 'Bitte Empfängerdetails eingeben';

  @override
  String get continueToReview => 'Weiter zur Überprüfung';

  @override
  String get reviewTransfer => 'Überweisung prüfen';

  @override
  String get paymentMethod => 'Zahlungsmethode';

  @override
  String get fee => 'Gebühr';

  @override
  String get exchangeRate => 'Wechselkurs';

  @override
  String get deliveryNotice => 'Das Geld wird innerhalb von Minuten zugestellt';

  @override
  String get confirmAndPay => 'Bestätigen und Bezahlen';

  @override
  String get choosePaymentMethod => 'Zahlungsmethode wählen';

  @override
  String get finalSummary => 'Zusammenfassung';

  @override
  String get amount => 'Betrag';

  @override
  String get instantPaymentFromWallet => 'Sofortzahlung aus der Wallet';

  @override
  String get payViaHormuud => 'Mit Hormuud EVC Plus bezahlen';

  @override
  String get payViaTelesom => 'Mit Telesom ZAAD bezahlen';

  @override
  String get payViaSomtel => 'Mit Somtel e-Dahab bezahlen';

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
  String get backToHome => 'Zurück zum Start';

  @override
  String get continueLabel => 'Weiter';

  @override
  String get murtaaxTransfer => 'Murtaax Überweisung';

  @override
  String get enterReceiverWalletId => 'Empfänger-Wallet-ID eingeben';

  @override
  String get walletIdTransferNotice =>
      'Das Geld wird sofort an die angegebene Murtaax-ID überwiesen.';

  @override
  String get enterWalletIdHint => 'Wallet-ID eingeben (z. B. 102234)';

  @override
  String get verifiedReceiverLabel => 'VERIFIZIERTER EMPFÄNGER';

  @override
  String get recentContacts => 'Letzte Kontakte';

  @override
  String get securityVerification => 'Sicherheitsüberprüfung';

  @override
  String get enterTransactionPin =>
      'Bitte geben Sie Ihre 4-stellige PIN ein, um diese Zahlung zu autorisieren.';

  @override
  String get authorizing => 'Autorisiere...';

  @override
  String confirmPaymentAmount(Object amount) {
    return 'Zahlung bestätigen ($amount)';
  }

  @override
  String get verifyingTransaction =>
      'Sichere Bestätigung der Transaktion mit Murtaax-Servern...';

  @override
  String get cancelAndChangeMethod => 'Abbrechen und Methode ändern';

  @override
  String get active => 'Aktiv';

  @override
  String get availableBalance => 'VERFÜGBARES GUTHABEN';

  @override
  String get deductFeeFromAmount => 'Gebühr vom Betrag abziehen';

  @override
  String get receiverWillReceiveLess => 'Empfänger erhält weniger';

  @override
  String get payFeeSeparately => 'Gebühr separat bezahlen';
}
