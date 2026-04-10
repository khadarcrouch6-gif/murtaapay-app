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
  String get murtaaxWallet => 'Murtaax Wallet';

  @override
  String get visaMastercard => 'Visa / MasterCard';

  @override
  String get mobileMoney => 'Mobile Money';

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
  String get accountNumber => 'Kontonummer';

  @override
  String get walletId => 'Wallet-ID';

  @override
  String get cardNumber => 'Kartennummer';

  @override
  String get payoutVia => 'Auszahlung über';

  @override
  String get paidUsing => 'Bezahlt mit';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get moneyOnWay => 'Ihr Geld ist unterwegs.';

  @override
  String get refId => 'Referenz-ID';

  @override
  String get idCopied => 'ID kopiert';

  @override
  String get shareReceipt => 'Beleg teilen';

  @override
  String get reference => 'Referenz';

  @override
  String get backToHome => 'Zurück zum Start';

  @override
  String get addMoney => 'Add Money';

  @override
  String get enterAmountToDeposit => 'Enter Amount to Deposit';

  @override
  String get confirmDeposit => 'Confirm Deposit';

  @override
  String get expiry => 'Expiry';

  @override
  String get cardholderName => 'Cardholder Name';

  @override
  String get fullNameOnCard => 'Full name on card';

  @override
  String get selectProvider => 'Select Provider';

  @override
  String get accountHolderName => 'Account Holder Name';

  @override
  String get fullName => 'Full Name';

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
  String get stepAmount => 'Betrag';

  @override
  String get stepReceiver => 'Empfänger';

  @override
  String get stepPayment => 'Zahlung';

  @override
  String get stepReview => 'Prüfung';

  @override
  String get feeInfoTitle => 'Info zu Wechselgebühren';

  @override
  String get feeInfoContent =>
      'Die Gebühr beträgt 0,99%. Beispiel: Das Senden von 100 \$ kostet nur 0,99 \$ an Gebühren.';

  @override
  String get maxLabel => 'MAX';

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

  @override
  String get myCards => 'Meine Karten';

  @override
  String get addNewCard => 'Neue Karte hinzufügen';

  @override
  String get cardNumberCopied => 'Kartennummer kopiert!';

  @override
  String get deposit => 'Einzahlung';

  @override
  String get withdraw => 'Auszahlung';

  @override
  String get savings => 'Sparen';

  @override
  String get invest => 'Investieren';

  @override
  String get transactions => 'Transaktionen';

  @override
  String get food => 'Essen';

  @override
  String get shopping => 'Shopping';

  @override
  String get billsLabel => 'Rechnungen';

  @override
  String get monthlyBudget => 'Monatliches Budget';

  @override
  String get cardSettings => 'Karteneinstellungen';

  @override
  String get frozen => 'Gefroren';

  @override
  String get unfreezeCard => 'Karte entsperren';

  @override
  String get freezeCard => 'Karte sperren';

  @override
  String get temporarilyDisablePayments =>
      'Zahlungen vorübergehend deaktivieren';

  @override
  String get security => 'Sicherheit';

  @override
  String get cardControls => 'Kartensteuerung';

  @override
  String get onlinePayments => 'Online-Zahlungen';

  @override
  String get internationalUsage => 'Internationale Nutzung';

  @override
  String get contactlessPayments => 'Kontaktloses Bezahlen';

  @override
  String get terminateCard => 'Karte kündigen';

  @override
  String get permanentlyDeleteCard => 'Diese virtuelle Karte dauerhaft löschen';

  @override
  String get enterSecurityPin =>
      'Bitte geben Sie Ihre 4-stellige Sicherheits-PIN ein';

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
  String get cardHolder => 'CARD HOLDER';

  @override
  String get yourName => 'YOUR NAME';

  @override
  String get expires => 'EXPIRES';

  @override
  String get requiredField => 'Required';

  @override
  String get chooseProviderAndEnterPhone =>
      'Choose your provider and enter phone number';

  @override
  String get enterNumberToCharge => 'Enter number to charge';

  @override
  String get servicePin => 'Service PIN';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get ibanHint => 'e.g. GB29 NWBK 6016 1331 9268 19';

  @override
  String get cardHolderNameLabel => 'Card Holder Name';

  @override
  String get johnDoe => 'John Doe';

  @override
  String get verifyingIdentity => 'Verifying Identity...';

  @override
  String get pleaseFillAllFields => 'Please fill in all fields';

  @override
  String cardEndingIn(String lastFour) {
    return 'Card ending in $lastFour';
  }
}
