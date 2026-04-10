// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Estonian (`et`).
class AppLocalizationsEt extends AppLocalizations {
  AppLocalizationsEt([String locale = 'et']) : super(locale);

  @override
  String get appTitle => 'MurtaaxPay';

  @override
  String get splashTitle => 'MURTAAX PAY';

  @override
  String get splashSubtitle => 'Usaldusväärne partner';

  @override
  String get welcome => 'Tere tulemast tagasi,';

  @override
  String get sendMoney => 'Saada raha';

  @override
  String get receiveMoney => 'Võta vastu';

  @override
  String get balance => 'Saldo';

  @override
  String get recentTransactions => 'Viimased tehingud';

  @override
  String get settings => 'Seaded';

  @override
  String get language => 'Keel';

  @override
  String get theme => 'Teema';

  @override
  String get send => 'Saada';

  @override
  String get add => 'Lisa';

  @override
  String get bills => 'Arved';

  @override
  String get sadaqah => 'Annetus';

  @override
  String get exchange => 'Vahetus';

  @override
  String get vouchers => 'Vautšerid';

  @override
  String get seeAll => 'Vaata kõiki';

  @override
  String get spendingAnalysis => 'Kulude analüüs';

  @override
  String get walletBalance => 'Rahakoti saldo';

  @override
  String get getStarted => 'Alusta';

  @override
  String get virtualCard => 'Virtuaalkaart';

  @override
  String get virtualCardDesc =>
      'Hankige oma turvaline virtuaalkaart ja ostke globaalselt.';

  @override
  String get enterAmount => 'Sisesta summa';

  @override
  String get transferLimit => 'Min: \$10 • Max: \$5,000';

  @override
  String get feeRate => '\$0.99 tasu iga \$100 kohta';

  @override
  String get youSend => 'Sina saadad';

  @override
  String get searchCurrency => 'Otsi valuutat...';

  @override
  String get receiverGets => 'Saaja saab';

  @override
  String get selectPaymentMethod => 'Vali makseviis';

  @override
  String get murtaaxWallet => 'Murtaax rahakott';

  @override
  String get visaMastercard => 'Visa / MasterCard';

  @override
  String get mobileMoney => 'Mobiilimakse';

  @override
  String get transactionFee => 'Tehingutasu';

  @override
  String get totalToPay => 'Kokku maksta';

  @override
  String get insufficientBalance => 'Ebapiisav jääk';

  @override
  String get receiverDetails => 'Saaja andmed';

  @override
  String get enterReceiverPhone => 'Sisesta saaja telefoninumber';

  @override
  String get phoneNumber => 'Telefoninumber';

  @override
  String get receiver => 'Saaja';

  @override
  String get recent => 'Viimased';

  @override
  String get pleaseEnterDetails => 'Palun sisesta saaja andmed';

  @override
  String get continueToReview => 'Jätka ülevaatamisega';

  @override
  String get reviewTransfer => 'Vaata üle';

  @override
  String get paymentMethod => 'Makseviis';

  @override
  String get fee => 'Tasu';

  @override
  String get exchangeRate => 'Vahetuskurss';

  @override
  String get deliveryNotice => 'Raha jõuab kohale mõne minutiga';

  @override
  String get confirmAndPay => 'Kinnita ja maksa';

  @override
  String get choosePaymentMethod => 'Vali makseviis';

  @override
  String get finalSummary => 'Kokkuvõte';

  @override
  String get amount => 'Summa';

  @override
  String get instantPaymentFromWallet => 'Kiire makse rahakotist';

  @override
  String get payViaHormuud => 'Maksa Hormuud EVC Plus kaudu';

  @override
  String get payViaTelesom => 'Maksa Telesom ZAAD kaudu';

  @override
  String get payViaSomtel => 'Maksa Somtel e-Dahab kaudu';

  @override
  String get bankTransfer => 'Pangaülekanne';

  @override
  String get localBankTransfer => 'Kohalik Somaalia pangaülekanne';

  @override
  String get internationalMethods => 'Rahvusvahelised meetodid';

  @override
  String get payWithInternationalCard => 'Maksa rahvusvahelise kaardiga';

  @override
  String get payNow => 'Maksa kohe';

  @override
  String get transferSuccessful => 'Ülekanne õnnestus!';

  @override
  String transferSentMessage(Object amount, Object receiver) {
    return '$amount on turvaliselt saadetud adressaadile $receiver.';
  }

  @override
  String get method => 'Meetod';

  @override
  String get accountNumber => 'Kontonumber';

  @override
  String get walletId => 'Rahakoti ID';

  @override
  String get cardNumber => 'Kaardi number';

  @override
  String get payoutVia => 'Väljamakse kaudu';

  @override
  String get paidUsing => 'Makstud kasutades';

  @override
  String get cancel => 'Tühista';

  @override
  String get moneyOnWay => 'Teie raha on teel.';

  @override
  String get refId => 'Viite ID';

  @override
  String get idCopied => 'ID kopeeritud';

  @override
  String get shareReceipt => 'Jaga kviitungit';

  @override
  String get reference => 'Viide';

  @override
  String get backToHome => 'Tagasi avalehele';

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
  String get fullName => 'Täisnimi';

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
  String get stepAmount => 'Summa';

  @override
  String get stepReceiver => 'Saaja';

  @override
  String get stepPayment => 'Makse';

  @override
  String get stepReview => 'Ülevaade';

  @override
  String get feeInfoTitle => 'Vahetustasu teave';

  @override
  String get feeInfoContent =>
      'Tasu on 0,99%. Näiteks: 100 dollari saatmine maksab vaid 0,99 dollarit tasusid.';

  @override
  String get maxLabel => 'MAX';

  @override
  String get continueLabel => 'Jätka';

  @override
  String get murtaaxTransfer => 'Murtaax ülekanne';

  @override
  String get enterReceiverWalletId => 'Sisesta saaja rahakoti ID';

  @override
  String get walletIdTransferNotice =>
      'Raha kantakse kohe üle määratud Murtaaxi ID-le.';

  @override
  String get enterWalletIdHint => 'Sisesta rahakoti ID (nt 102234)';

  @override
  String get verifiedReceiverLabel => 'KINNITATUD SAAJA';

  @override
  String get recentContacts => 'Viimased kontaktid';

  @override
  String get securityVerification => 'Turvakontroll';

  @override
  String get enterTransactionPin =>
      'Makse autoriseerimiseks sisesta oma 4-kohaline PIN-kood.';

  @override
  String get authorizing => 'Autoriseerimine...';

  @override
  String confirmPaymentAmount(Object amount) {
    return 'Kinnita makse ($amount)';
  }

  @override
  String get verifyingTransaction =>
      'Tehingu turvaline kinnitamine Murtaaxi serveriga...';

  @override
  String get cancelAndChangeMethod => 'Tühista ja muuda meetodit';

  @override
  String get active => 'Aktiivne';

  @override
  String get availableBalance => 'SAADAVAL JÄÄK';

  @override
  String get deductFeeFromAmount => 'Arva tasu summast maha';

  @override
  String get receiverWillReceiveLess => 'Saaja saab vähem raha';

  @override
  String get payFeeSeparately => 'Maksa tasu eraldi';

  @override
  String get myCards => 'Minu kaardid';

  @override
  String get addNewCard => 'Lisa uus kaart';

  @override
  String get cardNumberCopied => 'Kaardi number kopeeritud!';

  @override
  String get payWithCard => 'Maksa kaardiga';

  @override
  String get securePayment => 'Turvaline makse';

  @override
  String get cardDetails => 'Kaardi andmed';

  @override
  String get deposit => 'Hoiustamine';

  @override
  String get withdraw => 'Väljamakse';

  @override
  String get savings => 'Säästud';

  @override
  String get invest => 'Investeerimine';

  @override
  String get transactions => 'Tehingud';

  @override
  String get food => 'Toit';

  @override
  String get shopping => 'Ostlemine';

  @override
  String get billsLabel => 'Arved';

  @override
  String get monthlyBudget => 'Kuu eelarve';

  @override
  String get cardSettings => 'Kaardi seaded';

  @override
  String get frozen => 'Külmutatud';

  @override
  String get unfreezeCard => 'Sulata kaart';

  @override
  String get freezeCard => 'Külmuta kaart';

  @override
  String get temporarilyDisablePayments => 'Peata maksed ajutiselt';

  @override
  String get security => 'Turvalisus';

  @override
  String get cardControls => 'Kaardi kontroll';

  @override
  String get onlinePayments => 'Online-maksed';

  @override
  String get internationalUsage => 'Rahvusvaheline kasutus';

  @override
  String get contactlessPayments => 'Viipemaksed';

  @override
  String get terminateCard => 'Lõpeta kaart';

  @override
  String get permanentlyDeleteCard => 'Kustuta see virtuaalkaart jäädavalt';

  @override
  String get enterSecurityPin => 'Palun sisesta oma 4-kohaline turva-PIN';

  @override
  String get cardInformation => 'Kaardi andmed';

  @override
  String get visaDetails => 'Visa andmed';

  @override
  String get mastercardDetails => 'Mastercardi andmed';

  @override
  String cardDetailsInfo(Object amount) {
    return 'Sisestage oma kaardi andmed, et viia lõpule $amount ülekanne';
  }

  @override
  String get cardHolderName => 'Kaardi valdaja nimi';

  @override
  String get expiryDate => 'Aegumiskuupäev';

  @override
  String get cvv => 'CVV';

  @override
  String get secureProcessing => 'Teie makse turvaline töötlemine...';

  @override
  String get selectBank => 'Vali pank';

  @override
  String get murtaaxWalletDesc => 'Maksa oma rakenduse saldost';

  @override
  String get visaMastercardDesc => 'Maksa oma kaardiga';

  @override
  String get bankTransferDesc => 'Otsene pangaülekanne';

  @override
  String get mobileMoneyDesc => 'EVC Plus, Sahal, ZAAD, e-Dahab';

  @override
  String get identityVerification => 'Isikutuvastus';

  @override
  String get verifyYourIdentity => 'Kinnitage oma isik';

  @override
  String get verifyIdentityDesc =>
      'Peame teie isiku kinnitama, et hoida teie konto turvalisena. See võtab vaid 2 minutit.';

  @override
  String get prepareIdDoc => 'Valmistage ette oma isikut tõendav dokument';

  @override
  String get wellLitArea => 'Veenduge, et olete hästi valgustatud kohas';

  @override
  String get followInstructions => 'Järgige ekraanil olevaid juhiseid';

  @override
  String get letsGetStarted => 'Alustame';

  @override
  String get encryptedConnection => 'KRÜPTEERITUD JA TURVALINE ÜHENDUS';

  @override
  String get personalDetails => 'Isikuandmed';

  @override
  String get emailAddress => 'E-posti aadress';

  @override
  String get city => 'Linn';

  @override
  String get residentialAddress => 'Elukoha aadress';

  @override
  String get required => 'Kohustuslik';

  @override
  String get chooseDocumentType => 'Valige dokumendi tüüp';

  @override
  String get passport => 'Pass';

  @override
  String get nationalIdCard => 'ID-kaart';

  @override
  String get driversLicense => 'Juhiluba';

  @override
  String get bankGradeEncryption => 'Pangataseme krüpteerimine';

  @override
  String get dataDeletedNotice => 'Teie andmed kustutatakse pärast kinnitamist';

  @override
  String get frontOfIdCard => 'ID-kaardi esikülg';

  @override
  String get verifyYourFace => 'Kinnitage oma nägu';

  @override
  String get positionFaceNotice =>
      'Asetage oma nägu hästi valgustatud ja selgelt';

  @override
  String get alignId => 'Joondage oma ID';

  @override
  String get capturing => 'Pildistamine...';

  @override
  String get lookStraight => 'Vaata otse';

  @override
  String get lookLeft => 'Vaata vasakule';

  @override
  String get lookRight => 'Vaata paremale';

  @override
  String get verificationPending => 'Kinnitamine ootel';

  @override
  String get verificationPendingDesc =>
      'Teie dokumente vaadatakse üle. See võtab tavaliselt 10-15 minutit. Teavitame teid, kui see on valmis.';

  @override
  String get documentCheck => 'Dokumendikontroll';

  @override
  String get scanningForClarity => 'Selguse kontrollimine';

  @override
  String get biometricMatch => 'Biomeetriline vastavus';

  @override
  String get comparingSelfie => 'Selfi võrdlemine ID-ga';

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
  String get verifyingIdentity => 'Isiku kinnitamine...';

  @override
  String get pleaseFillAllFields => 'Please fill in all fields';

  @override
  String get virtualCardTopUp => 'Virtual Card Top-Up';

  @override
  String topUpInstantlyVia(String method) {
    return 'Top up instantly via $method';
  }

  @override
  String get walletPin => 'Wallet PIN';

  @override
  String get enterWalletPinMessage =>
      'Enter your 4-digit wallet PIN to authorize top-up.';

  @override
  String get confirm => 'Confirm';

  @override
  String get submit => 'Submit';

  @override
  String get accountName => 'Account Name';

  @override
  String cardEndingIn(String lastFour) {
    return 'Card ending in $lastFour';
  }
}
