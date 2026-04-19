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
  String get searchTransactions => 'Otsi tehinguid...';

  @override
  String get noTransactionsFound => 'Tehinguid ei leitud';

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
  String get invalidAmount => 'Invalid amount';

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
  String get addMoney => 'Lisa raha';

  @override
  String get enterAmountToDeposit => 'Sisesta hoiustatav summa';

  @override
  String get confirmTopUp => 'Confirm Top-Up';

  @override
  String get expiry => 'Kehtivusaeg';

  @override
  String get cardholderName => 'Kaardiomaniku nimi';

  @override
  String get fullNameOnCard => 'Täisnimi kaardil';

  @override
  String get selectProvider => 'Vali pakkuja';

  @override
  String get accountHolderName => 'Konto valdaja nimi';

  @override
  String get fullName => 'Täisnimi';

  @override
  String get reviewDeposit => 'Vaata hoius üle';

  @override
  String get totalCharged => 'Kokku debiteeritakse';

  @override
  String get confirmAndDeposit => 'Kinnita ja hoiusta';

  @override
  String get depositSuccessful => 'Hoiustamine õnnestus!';

  @override
  String depositSuccessMessage(Object amount) {
    return '$amount on lisatud teie rahakotti.';
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
  String get refreshed => 'Refreshed';

  @override
  String get ok => 'OK';

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
  String get addBank => 'Lisa pank';

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
  String get verifyYourFace => 'Kinnita oma nägu';

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
  String get virtualCardTopUp => 'Virtuaalkaardi laadimine';

  @override
  String get cardTopUpSuccessful => 'Card Top-Up Successful!';

  @override
  String cardTopUpSuccessMessage(String amount) {
    return '$amount has been added to your virtual card.';
  }

  @override
  String get enterAmountToTopUp => 'Enter amount to top up';

  @override
  String get topUp => 'Top Up';

  @override
  String topUpInstantlyVia(String method) {
    return 'Laadi kohe $method kaudu';
  }

  @override
  String get walletPin => 'Rahakoti PIN';

  @override
  String get enterWalletPinMessage =>
      'Laadimise autoriseerimiseks sisesta oma 4-kohaline rahakoti PIN.';

  @override
  String get confirm => 'Kinnita';

  @override
  String get submit => 'Saada';

  @override
  String get accountName => 'Konto nimi';

  @override
  String get transferToAccountBelow =>
      'Palun kanda summa allolevale kontole ja klõpsake jätka.';

  @override
  String cardEndingIn(String lastFour) {
    return 'Card ending in $lastFour';
  }

  @override
  String get withdrawMoney => 'Võta raha välja';

  @override
  String get withdrawToStripe => 'Väljamakse Stripe\'i kontole';

  @override
  String get withdrawalMethod => 'Väljamakse meetod';

  @override
  String get stripeEmail => 'Stripe\'i e-post';

  @override
  String get mobileNumber => 'Mobiilinumber';

  @override
  String get iban => 'IBAN';

  @override
  String get reviewWithdrawal => 'Vaata väljamakse üle';

  @override
  String get details => 'Andmed';

  @override
  String get free => 'Tasuta';

  @override
  String get totalDeducted => 'Kokku maha arvatud';

  @override
  String get confirmWithdraw => 'Kinnita ja võta välja';

  @override
  String get confirmAndWithdraw => 'Confirm & Withdraw';

  @override
  String get transactionFailed => 'Transaction Failed';

  @override
  String get transactionFailedMessage =>
      'Something went wrong. Please try again or contact support.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String newBalance(String balance) {
    return 'New Balance: $balance';
  }

  @override
  String get withdrawalRequested => 'Väljamakse taotletud!';

  @override
  String withdrawalSuccessMessage(String amount) {
    return 'Teie väljamakset summas $amount töödeldakse.';
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
  String get payBills => 'Maksa arveid';

  @override
  String get selectCategory => 'Vali kategooria';

  @override
  String get recentBills => 'Viimased arved';

  @override
  String get amountToPay => 'Makstav summa (\$)';

  @override
  String get confirmPayment => 'Kinnita makse';

  @override
  String get paymentSuccessful => 'Makse õnnestus!';

  @override
  String paymentSuccessMessage(String amount, String category) {
    return 'Teie makse summas $amount kategoorias $category on töödeldud.';
  }

  @override
  String get billDetails => 'Arve andmed';

  @override
  String get serviceProvider => 'Teenusepakkuja';

  @override
  String get category => 'Kategooria';

  @override
  String get accountId => 'Konto ID';

  @override
  String get amountPaid => 'Makstud summa';

  @override
  String get paymentDate => 'Makse kuupäev';

  @override
  String get status => 'Olek';

  @override
  String get success => 'Success';

  @override
  String get pending => 'Pending';

  @override
  String get completed => 'Lõpetatud';

  @override
  String get downloadReceipt => 'Laadi kviitung alla';

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
  String get merchant => 'Merchant';

  @override
  String get sourceReceiver => 'Source/Receiver';

  @override
  String get receiverSource => 'Receiver/Source';

  @override
  String get transactionId => 'Transaction ID';

  @override
  String get date => 'Date';

  @override
  String get close => 'Sulge';

  @override
  String get backToBills => 'Tagasi arvete juurde';

  @override
  String get electricity => 'Elekter';

  @override
  String get water => 'Vesi';

  @override
  String get internet => 'Internet';

  @override
  String get tvCable => 'TV ja kaabel';

  @override
  String get education => 'Haridus';

  @override
  String get govServices => 'Riigiteenused';

  @override
  String get stripe => 'Stripe';

  @override
  String get debitCreditCard => 'Deebet- / krediitkaart';

  @override
  String get justAMoment => 'Üks hetk';

  @override
  String get processing => 'Töötlemine...';

  @override
  String get copiedToClipboard => 'Kopeeritud lõikelauale';

  @override
  String get otherBank => 'Muu pank';

  @override
  String get bankName => 'Panga nimi';

  @override
  String get enterBankName => 'Sisesta panga nimi';

  @override
  String get enterAccountNumber => 'Sisesta kontonumber';

  @override
  String get enterAccountName => 'Sisesta konto nimi';

  @override
  String get noActiveCards => 'Aktiivseid kaarte pole';

  @override
  String get orderVirtualCard => 'Telli virtuaalkaart';

  @override
  String get instantlyIssueNewCard => 'Väljasta kohe uus digitaalne kaart';

  @override
  String get addToAppleWallet => 'Lisa Apple Walletisse';

  @override
  String get addToGooglePay => 'Lisa Google Pay\'sse';

  @override
  String get terminateCardConfirm =>
      'Kas olete kindel, et soovite selle kaardi jäädavalt kustutada? Seda toimingut ei saa tühistada.';

  @override
  String get all => 'Kõik';

  @override
  String get subscriptions => 'Tellimused';

  @override
  String get cardTerminated => 'Kaart suletud';

  @override
  String get cardTerminatedSuccess =>
      'Teie virtuaalkaart on jäädavalt kustutatud.';

  @override
  String get topUpFromWallet => 'Laadi rahakotist';

  @override
  String get withdrawToWallet => 'Saada rahakotti';

  @override
  String get withdrawToWalletDesc => 'Kanna üle oma põhirahakoti saldosse';

  @override
  String get withdrawToBankDesc =>
      'Võta välja kohalikku või rahvusvahelisse panka';

  @override
  String get withdrawToStripeDesc => 'Väljamakse teie Stripe\'i kontole';

  @override
  String get enterVirtualCardPin =>
      'Väljamakse autoriseerimiseks sisesta oma 4-kohaline virtuaalkaardi PIN.';

  @override
  String get currentCardBalance => 'KAARDI PRAEGUNE SALDO';

  @override
  String get welcomeBack => 'Tere tulemast tagasi';

  @override
  String get enterPhoneNumberToContinue =>
      'Jätkamiseks sisesta oma telefoninumber';

  @override
  String get dontHaveAccountSignUp => 'Sul pole kontot? Registreeru';

  @override
  String get createAccount => 'Loo konto';

  @override
  String get joinMurtaaxPayToday =>
      'Liitu MurtaaxPayga juba täna ja alusta raha turvalist saatmist.';

  @override
  String get password => 'Parool';

  @override
  String get signUp => 'Registreeru';

  @override
  String get alreadyHaveAccountLogin => 'Sul on juba konto? Logi sisse';

  @override
  String get confirmYourPin => 'Kinnita oma PIN';

  @override
  String get toKeepYourMoneySafe => 'Raha turvalisuse tagamiseks';

  @override
  String get useFaceIdFingerprint => 'Kasuta FaceID-d / sõrmejälge';

  @override
  String get virtualCardBalance => 'VIRTUAALKAARDI SALDO';

  @override
  String get messages => 'Sõnumid';

  @override
  String get startNewConversation => 'Alusta uut vestlust';

  @override
  String get searchConversations => 'Otsi vestlusi...';

  @override
  String get noMessages => 'Sõnumeid pole';

  @override
  String get now => 'nüüd';

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m tagasi';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h tagasi';
  }

  @override
  String daysAgo(int days) {
    return '${days}p tagasi';
  }

  @override
  String get online => 'Sees';

  @override
  String get viewInfo => 'Vaata infot';

  @override
  String get helpSupport => 'Abi ja tugi';

  @override
  String get clearChat => 'Tühjenda vestlus';

  @override
  String get contactInformation => 'Kontaktandmed';

  @override
  String get nameLabel => 'Nimi';

  @override
  String get phoneLabel => 'Telefon';

  @override
  String get emailLabel => 'E-post';

  @override
  String get messageTypes => 'Sõnumite tüübid';

  @override
  String get messageTypesDesc =>
      'Tekst, SMS, audio, pildid, dokumendid ja isikuandmed';

  @override
  String get shareInformation => 'Jaga teavet';

  @override
  String get shareInformationDesc =>
      'Jaga turvaliselt oma kontaktandmeid ja aadressi';

  @override
  String get searchChats => 'Otsi vestlusi';

  @override
  String get searchChatsDesc => 'Leia mis tahes vestlus kiiresti';

  @override
  String get chatSettings => 'Vestluse seaded';

  @override
  String get chatSettingsDesc =>
      'Tühjenda vestluse ajalugu ja hallata eelistusi';

  @override
  String get clearChatConfirm =>
      'Kas olete kindel, et soovite selle vestluse tühjendada?';

  @override
  String get clear => 'Tühjenda';

  @override
  String get location => 'Asukoht';

  @override
  String get youSentMoney => 'Saatsid raha';

  @override
  String get youReceivedMoney => 'Sait raha';

  @override
  String get smsMessage => 'SMS-sõnum';

  @override
  String get audioMessage => 'Audiosõnum';

  @override
  String get downloadingDocument => 'Dokumendi allalaadimine...';

  @override
  String get personalInformation => 'Isikuandmed';

  @override
  String get sms => 'SMS';

  @override
  String get gallery => 'Galerii';

  @override
  String get file => 'Fail';

  @override
  String get contact => 'Kontakt';

  @override
  String get typeAMessage => 'Kirjuta sõnum...';

  @override
  String get shareContent => 'Jaga sisu';

  @override
  String get smsSentSuccess => 'SMS edukalt saadetud!';

  @override
  String get audioSentSuccess => 'Audiosõnum saadetud!';

  @override
  String get imageSentSuccess => 'Pilt saadetud!';

  @override
  String get documentSentSuccess => 'Dokument saadetud!';

  @override
  String get personalInfoSharedSuccess => 'Isikuandmed jagatud!';

  @override
  String get sharePersonalInfo => 'Jaga isikuandmeid';

  @override
  String get reviewInfoToShare => 'Vaata jagatavad andmed üle';

  @override
  String get infoSharedNotice => 'Seda teavet jagatakse praeguse vestlusega.';

  @override
  String get address => 'Aadress';

  @override
  String get postalCode => 'Postiindeks';

  @override
  String get country => 'Riik';

  @override
  String get pleaseEnter => 'Palun sisesta';

  @override
  String get help => 'Abi';

  @override
  String get returnToHome => 'Tagasi avalehele';

  @override
  String get verification => 'Kinnitamine';

  @override
  String get voucherCopied => 'Vautšeri kood kopeeritud! Kasutamiseks valmis.';

  @override
  String get howToUse => 'Kuidas kasutada';

  @override
  String get stepRedeem => 'Koodi kopeerimiseks puudutage \'Lunasta kohe\'.';

  @override
  String get stepTransfer => 'Alusta uut rahaülekannet.';

  @override
  String get stepPaste => 'Kleebi kood väljale \'Sooduskood\'.';

  @override
  String get welcomeBonus => 'Tervitusboonus';

  @override
  String get welcomeBonusDesc =>
      'Saa 5% raha tagasi oma järgmiselt ülekandelt.';

  @override
  String get expires30Dec => 'Aegub: 30. dets';

  @override
  String get familyFriday => 'Pere reede';

  @override
  String get familyFridayDesc =>
      'Täna Somaaliasse tehtavatele ülekannetele tasu ei lisandu!';

  @override
  String get expiresTomorrow => 'Aegub: homme';

  @override
  String get eidSpecial => 'Eid-i eripakkumine';

  @override
  String get eidSpecialDesc => '\$10 boonus ülekannetele üle \$100.';

  @override
  String get expiresIn5Days => 'Aegub: 5 päeva pärast';

  @override
  String get reward => 'PREEMIA';

  @override
  String get copied => 'Kopeeritud!';

  @override
  String get redeemNow => 'Lunasta kohe';

  @override
  String get referAndEarn => 'Soovita ja teeni';

  @override
  String get referralCodeCopied => 'Soovituskood kopeeritud lõikelauale!';

  @override
  String get rewardsWaiting => 'Preemiad ootavad';

  @override
  String get inviteFriendsGet10 => 'Kutsu sõpru, saa \$10';

  @override
  String get referralDescription =>
      'Jaga MurtaaxPayd oma sõpradega ja te mõlemad saate \$10, kui nad teevad oma esimese ülekande summas \$50 või rohkem.';

  @override
  String get yourReferralCode => 'Sinu soovituskood';

  @override
  String get copy => 'KOPEERI';

  @override
  String get whatsApp => 'WhatsApp';

  @override
  String get sadaqahCommunity => 'Annetused ja kogukond';

  @override
  String get medicalEmergency => 'Meditsiiniline hädaabi';

  @override
  String get medicalEmergencyDesc =>
      'Aita Ahmedil katta südameoperatsiooni kulud Türgis.';

  @override
  String get villageWaterWell => 'Küla veekaev';

  @override
  String get villageWaterWellDesc => 'Püsiva veeallika ehitamine Gedo külla.';

  @override
  String get educationSupport => 'Haridustoetus';

  @override
  String get educationSupportDesc => 'Stipendiumid 10-le orvule Mogadishus.';

  @override
  String get verified => 'Kinnitatud';

  @override
  String get by => 'Autor:';

  @override
  String get raised => 'Kogutud';

  @override
  String get goal => 'Eesmärk';

  @override
  String get startAFundraiser => 'Alusta korjandust';

  @override
  String get totalInvestment => 'Kogu investeering';

  @override
  String get yourPortfolio => 'Sinu portfell';

  @override
  String get bitcoin => 'Bitcoin';

  @override
  String get ethereum => 'Ethereum';

  @override
  String get gold => 'Kuld';

  @override
  String get investmentOpportunities => 'Investeerimisvõimalused';

  @override
  String get realEstate => 'Kinnisvara';

  @override
  String get realEstateDesc =>
      'Investeerimine kvaliteetsetesse kinnisvaraprojektidesse.';

  @override
  String get agriculture => 'Põllumajandus';

  @override
  String get agricultureDesc => 'Toeta kohalikku säästvat põllumajandust.';

  @override
  String get savingsAndGoals => 'Säästmine ja eesmärgid';

  @override
  String get activeGoals => 'Aktiivsed eesmärgid';

  @override
  String get createNewGoal => 'Loo uus eesmärk';

  @override
  String get totalSavings => 'Kogu säästud';

  @override
  String get cardBalanceLabel => 'Card: ';

  @override
  String get chooseWithdrawalMethod => 'Vali väljamakse meetod';

  @override
  String get sendToWallet => 'Saada rahakotti';

  @override
  String get payFromSavingBalance => 'Maksa oma säästuarve saldost';

  @override
  String get sendToCard => 'Saada kaardile';

  @override
  String get withdrawToVirtualCard => 'väljamakse oma virtuaalkaardile';

  @override
  String get savingsBalanceLabel => 'SÄÄSTUDE SALDO';

  @override
  String get cardPin => 'Kaardi PIN';

  @override
  String withdrawalSuccessFromSavings(String amount) {
    return 'Olete edukalt võtnud oma säästudest välja $amount.';
  }

  @override
  String get goalName => 'Eesmärgi nimi';

  @override
  String get targetAmount => 'Sihtsumma';

  @override
  String get deadline => 'Tähtaeg';

  @override
  String get selectIcon => 'Vali ikoon';

  @override
  String get selectColor => 'Vali värv';

  @override
  String get create => 'Loo';

  @override
  String get creating => 'Loomine...';

  @override
  String get goalCreated => 'Eesmärk loodud!';

  @override
  String goalCreatedSuccess(String title, String amount) {
    return 'Teie uus eesmärk \'$title\' sihtsummas $amount on edukalt seadistatud.';
  }

  @override
  String get backToSavings => 'Tagasi säästmise juurde';

  @override
  String get sendFromWallet => 'Saada rahakotist';

  @override
  String get payFromWalletBalance => 'Maksa oma rahakoti saldost';

  @override
  String get sendFromCard => 'Saada kaardilt';

  @override
  String get payFromVirtualCard => 'Maksa oma virtuaalkaardiga';

  @override
  String get paused => 'Peatatud';

  @override
  String get targetWithColon => 'Eesmärk: ';

  @override
  String get addFunds => 'Lisa raha';

  @override
  String get edit => 'Muuda';

  @override
  String get resume => 'Jätka';

  @override
  String get pause => 'Peata';

  @override
  String get delete => 'Kustuta';

  @override
  String get amountToAdd => 'Lisatav summa';

  @override
  String get fundsAddedSuccess => 'Raha lisamine õnnestus!';

  @override
  String get deleteGoal => 'Kustuta eesmärk?';

  @override
  String get deleteGoalConfirm =>
      'Kas olete kindel? Seda toimingut ei saa tühistada.';

  @override
  String get editGoal => 'Muuda eesmärki';

  @override
  String get save => 'Salvesta';

  @override
  String get pinChangedSuccess =>
      'Teie PIN on edukalt uuendatud. Kasutage oma uut PIN-i edasiste tehingute jaoks.';

  @override
  String get done => 'Valmis';

  @override
  String get changePin => 'Muuda PIN-i';

  @override
  String get createNewPin => 'Loo uus PIN';

  @override
  String get newPinDescription =>
      'Sisesta oma praegune PIN ja vali uus 4-kohaline turva-PIN.';

  @override
  String get currentPin => 'Praegune PIN';

  @override
  String get pleaseEnterCurrentPin => 'Palun sisesta praegune PIN';

  @override
  String get pinMustBe4Digits => 'PIN peab olema 4-kohaline';

  @override
  String get newPin => 'Uus PIN';

  @override
  String get pleaseEnterNewPin => 'Palun sisesta uus PIN';

  @override
  String get cannotBeSameAsOld => 'Ei tohi olla sama mis vana PIN';

  @override
  String get confirmNewPin => 'Kinnita uus PIN';

  @override
  String get pleaseConfirmNewPin => 'Palun kinnita uus PIN';

  @override
  String get pinsDoNotMatch => 'PIN-koodid ei ühti';

  @override
  String get saveChanges => 'Salvesta muudatused';

  @override
  String get termsConditions => 'Kasutustingimused';

  @override
  String get lastUpdated => 'Viimati uuendatud';

  @override
  String get acceptanceOfTerms => '1. Tingimustega nõustumine';

  @override
  String get acceptanceOfTermsDesc =>
      'MurtaaxPayle juurde pääsedes või seda kasutades nõustute end nende tingimustega siduma. Kui te ei nõustu kõigi nende tingimustega, ärge kasutage meie teenuseid.';

  @override
  String get userVerificationL10n => '2. Kasutaja kinnitamine';

  @override
  String get userVerificationDescL10n =>
      'Finantseeskirjade täitmiseks nõuame teatud tehingulimiitide puhul isikutuvastust. Nõustute esitama täpset teavet.';

  @override
  String get transactionFees => '3. Tehingutasud';

  @override
  String get transactionFeesDesc =>
      'Tasud kuvatakse selgelt enne iga tehingut. Tehingu kinnitamisega nõustute maksma määratud tasusid.';

  @override
  String get privacyPolicyL10n => '4. Privaatsuspoliitika';

  @override
  String get privacyPolicyDescL10n =>
      'Teie privaatsus on meile oluline. Kasutame teie andmete kaitsmiseks pangataseme krüpteerimist. Lisateabe saamiseks vaadake meie täielikku privaatsuspoliitikat.';

  @override
  String get limitationOfLiability => '5. Vastutuse piiramine';

  @override
  String get limitationOfLiabilityDesc =>
      'MurtaaxPay ei vastuta kaudsete, juhuslike või põhjuslike kahjude eest, mis tulenevad teenuse kasutamisest või suutmatusest seda kasutada.';

  @override
  String get allRightsReserved => 'Kõik õigused kaitstud';

  @override
  String get oct2023 => 'Okt 2023';

  @override
  String get copyrightMurtaaxPay => '© 2026 MurtaaxPay.';

  @override
  String get hagbad => 'Hagbad';

  @override
  String get myGroups => 'Minu grupid';

  @override
  String get createHagbad => 'Loo Hagbad';

  @override
  String get totalSavingsPot => 'Kogu säästupott';

  @override
  String get activeGroups => 'Aktiivsed grupid';

  @override
  String get nextPayout => 'Järgmine väljamakse';

  @override
  String get days => 'Päevad';

  @override
  String get nextInLine => 'Järgmine järjekorras';

  @override
  String get rotation => 'Rotatsioon';

  @override
  String get groupChat => 'Grupi vestlus';

  @override
  String get payContribution => 'Maksa osaluspanus';

  @override
  String get createNewHagbad => 'Loo uus Hagbad';

  @override
  String get groupName => 'Grupi nimi';

  @override
  String get contributionAmount => 'Osalustasu suurus';

  @override
  String get frequency => 'Sagedus';

  @override
  String get addMembers => 'Lisa liikmeid (telefon või nimi)';

  @override
  String get createGroup => 'Loo grupp';

  @override
  String get received => 'Saadud';

  @override
  String get currentBalance => 'Praegune jääk';

  @override
  String get potWadar => 'Kogupott';

  @override
  String get daily => 'Igapäevane';

  @override
  String get weekly => 'Iganädalane';

  @override
  String get tenDays => '10 päeva';

  @override
  String get monthly => 'Igakuine';

  @override
  String get yearly => 'Iga-aastane';

  @override
  String get hagbadCreatedSuccess => 'Hagbad Group Created Successfully!';

  @override
  String get drawing => 'Drawing...';

  @override
  String get qoriTuur => 'Qori-tuur';

  @override
  String get noHagbadGroups => 'No groups yet. Create one to start saving!';

  @override
  String get progress => 'Progress';

  @override
  String get members => 'Members';

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
  String get totalPot => 'Total Fund';

  @override
  String get hagbadPot => 'Hagbad Pot (Escrow)';

  @override
  String get amountToReceive => 'Amount to Receive';

  @override
  String get claimPayout => 'Claim Payout';

  @override
  String get guarantor => 'Guarantor (Uul)';

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
  String get remaining => 'Remaining';

  @override
  String get hagbadTerms => '6. Hagbad Social Trust';

  @override
  String get hagbadTermsDesc =>
      'Hagbad is based on mutual trust (Aaminaad). By joining, you agree to make timely contributions. If a member fails to pay, the Guarantor (Uul) is responsible for covering the debt.';

  @override
  String get iAgreeToHagbadTerms =>
      'I agree to the Hagbad Social Trust terms and conditions.';

  @override
  String get hagbadOath => 'Religious Oath (Dhaar)';

  @override
  String get hagbadOathDesc =>
      'Do you swear by Allah that you will be honest and fulfill your contributions on time?';

  @override
  String get iConfirmOath => 'I swear by Allah to be honest.';

  @override
  String get remindAll => 'Remind All';

  @override
  String get remindMember => 'Remind Member';

  @override
  String reminderSent(Object name) {
    return 'Reminder sent to $name';
  }

  @override
  String get allRemindersSent => 'Reminders sent to all pending members';

  @override
  String get replaceMember => 'Replace Member';

  @override
  String get substituteMember => 'Substitute Member';

  @override
  String get enterNewMemberDetails => 'Enter new member details';

  @override
  String get memberReplaced => 'Member has been successfully replaced';

  @override
  String get cannotReplaceReceived =>
      'Cannot replace a member who has already received a payout';

  @override
  String get paymentHistory => 'Payment History';

  @override
  String paidOn(Object date) {
    return 'Paid on $date';
  }

  @override
  String get noPaymentsYet => 'No payments recorded yet';

  @override
  String get lateFee => 'Late Fee';

  @override
  String get applyPenalty => 'Apply Penalty';

  @override
  String get penaltyAmount => 'Penalty Amount (\$)';

  @override
  String penaltyApplied(Object amount, Object name) {
    return 'Penalty of \$$amount applied to $name';
  }

  @override
  String get invitationReceived => 'Invitation Received';

  @override
  String invitationDesc(String admin, String amount) {
    return '$admin invited you to join a \$$amount Hagbad group.';
  }

  @override
  String get acceptInvite => 'Accept Invitation';

  @override
  String get religiousOathRequired => 'Religious Oath Required';

  @override
  String get oathRequirementDesc =>
      'To join the group officially, you must sign the religious oath (Dhaar).';

  @override
  String get signOathNow => 'Sign Oath Now';

  @override
  String get apr2026 => 'Apr 2026';

  @override
  String get scanQR => 'Scan QR Code';

  @override
  String get alignQRCode => 'Align the QR code within the frame to scan';

  @override
  String get myQrCode => 'My QR Code';

  @override
  String get shareMyQrCode => 'Share my QR code to receive payments instantly.';

  @override
  String get quickSend => 'Quick Send';

  @override
  String get invalidWalletId => 'Invalid Wallet ID';

  @override
  String get cannotSendToSelf => 'You cannot send money to yourself';

  @override
  String get evcPlus => 'EVC Plus';

  @override
  String get edahab => 'e-Dahab';

  @override
  String get zaad => 'ZAAD';

  @override
  String get sahal => 'Sahal';

  @override
  String get purposeOfRemittance => 'Purpose of Remittance';

  @override
  String get purpose => 'Purpose';

  @override
  String get familySupport => 'Family Support';

  @override
  String get educationTuition => 'Education/Tuition';

  @override
  String get medicalExpenses => 'Medical Expenses';

  @override
  String get businessTransaction => 'Business Transaction';

  @override
  String get propertyRent => 'Property/Rent';

  @override
  String get gift => 'Gift';

  @override
  String get other => 'Other';

  @override
  String get contactPermissionRequired =>
      'Contact permission is required to pick a contact.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get dailyLimit => 'Daily Limit';

  @override
  String get monthlyLimit => 'Monthly Limit';

  @override
  String get recentSavingsActivity => 'Viimased säästutegevused';

  @override
  String get noActivityYet => 'Tegevusi veel pole';
}
