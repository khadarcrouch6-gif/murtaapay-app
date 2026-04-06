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
  String get receiverGets => 'Saaja saab';

  @override
  String get selectPaymentMethod => 'Vali makseviis';

  @override
  String get transactionFee => 'Tehingutasu';

  @override
  String get totalToPay => 'Kokku maksta';

  @override
  String get insufficientBalance => 'Ebapiisav jääk';

  @override
  String get searchCurrency => 'Otsi valuutat...';

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
  String get reference => 'Viide';

  @override
  String get backToHome => 'Tagasi avalehele';

  @override
  String get murtaaxTransfer => 'Murtaax ülekanne';

  @override
  String get enterReceiverWalletId => 'Sisesta saaja rahakoti ID';

  @override
  String get walletIdTransferNotice => 'Raha kantakse kohe üle määratud Murtaaxi ID-le.';

  @override
  String get enterWalletIdHint => 'Sisesta rahakoti ID (nt 102234)';

  @override
  String get verifiedReceiverLabel => 'KINNITATUD SAAJA';

  @override
  String get recentContacts => 'Viimased kontaktid';

  @override
  String get securityVerification => 'Turvakontroll';

  @override
  String get enterTransactionPin => 'Makse autoriseerimiseks sisesta oma 4-kohaline PIN-kood.';

  @override
  String get authorizing => 'Autoriseerimine...';

  @override
  String confirmPaymentAmount(Object amount) {
    return 'Kinnita makse ($amount)';
  }

  @override
  String get verifyingTransaction => 'Tehingu turvaline kinnitamine Murtaaxi serveriga...';

  @override
  String get cancelAndChangeMethod => 'Tühista ja muuda meetodit';

  @override
  String get active => 'Aktiivne';

  @override
  String get availableBalance => 'SAADAVAL JÄÄK';
}
