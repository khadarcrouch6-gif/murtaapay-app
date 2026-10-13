import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app_analytics.dart';
import 'package:intl/intl.dart';
import 'models/bank_account.dart';
import 'models/transaction.dart';
import 'models/quick_profile.dart';
import 'models/savings_goal.dart';
import '../features/cards/models/card_model.dart';
import 'models/hagbad_model.dart';
import 'models/recurring_payment_model.dart';
import 'models/notification_model.dart';
import '../features/more/models/campaign.dart';
import 'api_service.dart';
import 'dart:math' as math;

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  late final analytics = AppAnalytics();
  late SharedPreferences _prefs;
  final _secureStorage = const FlutterSecureStorage();
  bool _isInitialized = false;

  List<String> _hagbadSearchHistory = [];
  List<String> _sadaqahSearchHistory = [];
  List<String> _contactSearchHistory = [];

  List<String> get hagbadSearchHistory => _hagbadSearchHistory;
  List<String> get sadaqahSearchHistory => _sadaqahSearchHistory;
  List<String> get contactSearchHistory => _contactSearchHistory;

  double _balance = 12450.80;
  double get balance => _balance;

  String _userName = "Mohamed Osman";
  String get userName => _userName;

  String _userEmail = "mohamed.osman@example.com";
  String get userEmail => _userEmail;

  String _userPhone = "+252 615 123 456";
  String get userPhone => _userPhone;

  String _userDob = "1990-01-01";
  String get userDob => _userDob;

  String _userNationality = "Somali";
  String get userNationality => _userNationality;

  String _userIdNumber = "ABC123456";
  String get userIdNumber => _userIdNumber;

  String _userOccupation = "Software Engineer";
  String get userOccupation => _userOccupation;

  String _userStreet = "Maka Al-Mukarama Road";
  String get userStreet => _userStreet;

  String _userCity = "Mogadishu";
  String get userCity => _userCity;

  String _userPostalCode = "10001";
  String get userPostalCode => _userPostalCode;

  String _userCountry = "Somalia";
  String get userCountry => _userCountry;

  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? dob,
    String? nationality,
    String? idNumber,
    String? occupation,
    String? street,
    String? city,
    String? postalCode,
    String? country,
  }) {
    if (name != null) _userName = name;
    if (email != null) _userEmail = email;
    if (phone != null) _userPhone = phone;
    if (dob != null) _userDob = dob;
    if (nationality != null) _userNationality = nationality;
    if (idNumber != null) _userIdNumber = idNumber;
    if (occupation != null) _userOccupation = occupation;
    if (street != null) _userStreet = street;
    if (city != null) _userCity = city;
    if (postalCode != null) _userPostalCode = postalCode;
    if (country != null) _userCountry = country;
    
    // Save to prefs for persistence (simplified for this task)
    _prefs.setString('user_name', _userName);
    _prefs.setString('user_email', _userEmail);
    _prefs.setString('user_phone', _userPhone);
    _prefs.setString('user_dob', _userDob);
    _prefs.setString('user_nationality', _userNationality);
    _prefs.setString('user_id_number', _userIdNumber);
    _prefs.setString('user_occupation', _userOccupation);
    _prefs.setString('user_street', _userStreet);
    _prefs.setString('user_city', _userCity);
    _prefs.setString('user_postal_code', _userPostalCode);
    _prefs.setString('user_country', _userCountry);

    notifyListeners();
  }

  double _savingsBalance = 0.0;
  double get savingsBalance => _savingsBalance;

  List<QuickProfile> _quickProfiles = [];
  List<QuickProfile> get quickProfiles {
    final sorted = List<QuickProfile>.from(_quickProfiles);
    sorted.sort((a, b) {
      // 1. Favorites always first
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;
      
      // 2. Sort by transaction count (most frequent)
      int cmp = b.transactionCount.compareTo(a.transactionCount);
      if (cmp != 0) return cmp;
      
      // 3. Then by last transaction date (most recent)
      if (a.lastTransactionDate == null && b.lastTransactionDate == null) return 0;
      if (a.lastTransactionDate == null) return 1;
      if (b.lastTransactionDate == null) return -1;
      return b.lastTransactionDate!.compareTo(a.lastTransactionDate!);
    });
    return sorted;
  }

  double get cardBalance => _cards.fold(0.0, (sum, card) => sum + card.balance);

  final String _walletId = '102234';
  String get walletId => _walletId;

  String _pin = '0011'; // Default mock PIN
  
  bool verifyPin(String pin) {
    if (pin == "BIOMETRIC_SUCCESS") return true;
    return _pin == pin;
  }

  Future<void> updatePin(String newPin) async {
    _pin = newPin;
    await _secureStorage.write(key: 'user_pin', value: newPin);
    notifyListeners();
  }

  bool _biometricEnabled = true;
  bool get biometricEnabled => _biometricEnabled;

  bool _cardBiometricEnabled = true;
  bool get cardBiometricEnabled => _cardBiometricEnabled;

  Future<void> setBiometricEnabled(bool enabled) async {
    _biometricEnabled = enabled;
    await _prefs.setBool('biometric_enabled', enabled);
    notifyListeners();
  }

  Future<void> setCardBiometricEnabled(bool enabled) async {
    _cardBiometricEnabled = enabled;
    await _prefs.setBool('card_biometric_enabled', enabled);
    notifyListeners();
  }

  bool verifyCardPin(String pin, {String? cardId}) {
    if (pin == "BIOMETRIC_SUCCESS") return true;
    if (_cards.isEmpty) return false;
    
    // If cardId is null, try to use selectedCardIndex, but ensure it's within bounds
    final index = _selectedCardIndex;
    final id = cardId ?? (index >= 0 && index < _cards.length ? _cards[index].id : null);
    
    if (id == null) return false;
    final storedPin = _cardPins[id];
    
    // If no PIN is set, default to '0000' for newly added cards that might have missed initialization
    if (storedPin == null) {
      return pin == '0000';
    }
    
    return storedPin == pin;
  }

  Future<void> updateCardPin(String pin, {String? cardId}) async {
    if (_cards.isEmpty) return;
    final id = cardId ?? _cards[_selectedCardIndex].id;
    _cardPins[id] = pin;
    await _secureStorage.write(key: 'card_pin_$id', value: pin);
    analytics.logEvent('card_pin_updated', parameters: {'card_id': id});
    notifyListeners();
  }

  final String _currencyCode = 'USD';
  String get currencyCode => _currencyCode;

  final List<BankAccount> _linkedBanks = [];
  List<BankAccount> get linkedBanks => _linkedBanks;

  final List<BankAccount> _savedBeneficiaries = [];
  List<BankAccount> get savedBeneficiaries => _savedBeneficiaries;

  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  List<Transaction> getTransactionsForCard(String cardId) {
    return _transactions.where((tx) => tx.cardId == cardId).toList();
  }

  final List<Map<String, String>> _recentWithdrawals = [];
  List<Map<String, String>> get recentWithdrawals => _recentWithdrawals;

  List<VirtualCard> _cards = [];
  List<VirtualCard> get cards => _cards;

  final Map<String, String> _cardPins = {};

  final List<VirtualCard> _terminatedCards = [];
  List<VirtualCard> get terminatedCards => _terminatedCards;

  List<SavingsGoal> _savingsGoals = [];
  List<SavingsGoal> get savingsGoals => _savingsGoals;

  Map<String, double> _cryptoHoldings = {};
  Map<String, double> get cryptoHoldings => _cryptoHoldings;

  List<HagbadGroup> _hagbadGroups = [];
  List<HagbadGroup> get hagbadGroups => _hagbadGroups;

  List<RecurringPayment> _recurringPayments = [];
  List<RecurringPayment> get recurringPayments => _recurringPayments;

  List<Campaign> _campaigns = [];
  List<Campaign> get campaigns => _campaigns;

  final List<NotificationData> _notifications = [];
  List<NotificationData> get notifications => _notifications;

  void addNotification(NotificationData notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  // Market Rates (FX & Commodities)
  Map<String, double> _fxRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'KES': 130.50,
    'SOS': 575.00,
    'AED': 3.67,
    'TRY': 32.20,
    'DJF': 177.72,
    'ETB': 57.15,
    'SAR': 3.75,
    'CAD': 1.35,
    'AUD': 1.52,
    'CNY': 7.23,
    'JPY': 151.80,
    'INR': 83.30,
    'UGX': 3780.00,
    'RWF': 1285.00,
    'TZS': 2580.00,
  };
  Map<String, double> get fxRates => _fxRates;

  double _goldPrice = 74.50;   // USD per gram
  double _silverPrice = 0.95;  // USD per gram
  
  double get goldPrice => _goldPrice;
  double get silverPrice => _silverPrice;

  // Zakat/Nisab State
  double _nisabGold = 6500.0;
  double _nisabSilver = 550.0;
  String _preferredNisab = 'gold'; // 'gold' or 'silver'

  double get nisabGold => _nisabGold;
  double get nisabSilver => _nisabSilver;
  String get preferredNisab => _preferredNisab;
  double get effectiveNisab => _preferredNisab == 'gold' ? _nisabGold : _nisabSilver;

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  void togglePremium([bool? value]) {
    _isPremium = value ?? !_isPremium;
    notifyListeners();
  }

  void setPreferredNisab(String type) {
    if (type == 'gold' || type == 'silver') {
      _preferredNisab = type;
      notifyListeners();
    }
  }

  Future<void> updateMarketRates() async {
    try {
      final newRates = await ApiService.fetchAllRates();
      if (newRates.isNotEmpty) {
        _fxRates = newRates;
        
        // Update commodity prices (simulated or from API if added)
        _goldPrice = 74.0 + (math.Random().nextDouble() * 2);
        _silverPrice = 0.90 + (math.Random().nextDouble() * 0.1);
        
        updateNisabValues();
      }
    } catch (e) {
      debugPrint("Error updating market rates: $e");
    }
  }

  void updateNisabValues() {
    _nisabGold = 87.48 * _goldPrice;
    _nisabSilver = 612.36 * _silverPrice;
    notifyListeners();
  }

  bool get hasUrgentCampaigns => _campaigns.any((c) => c.isUrgent);
  bool get hasNewCampaigns => _campaigns.any((c) => c.status == 'new');

  void _loadCampaigns() {
    final List<String>? campaignsJson = _prefs.getStringList('fundraiser_campaigns') ?? _prefs.getStringList('fundraiser_campaigns_legacy');
    if (campaignsJson != null) {
      _campaigns = campaignsJson.map((e) => Campaign.fromJson(json.decode(e))).toList();
    } else {
      // Mock initial campaigns
      _campaigns = [
        Campaign(
          id: "1",
          title: "Community Center Expansion",
          description: "Help us expand the local community center to provide better facilities for everyone.",
          goalAmount: 50000.0,
          raisedAmount: 32500.0,
          creator: "Community First",
          icon: Icons.business_rounded,
          imageUrl: "https://images.unsplash.com/photo-1542621334-a254cf47733d?q=80&w=2070",
          category: "Community",
          donorCount: 1240,
          lastDonationAgo: "5m",
          isUrgent: true,
          status: 'trending',
          organizerTitle: "Sheikh",
          organizerSubtitle: "Sheikh Maxamed Umal",
          galleryUrls: [
            "https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=2093",
            "https://images.unsplash.com/photo-1542810634-71277d95dcbb?q=80&w=2070",
          ],
          donorAvatars: [
            "https://ui-avatars.com/api/?name=A+M&background=random",
            "https://ui-avatars.com/api/?name=S+A&background=random",
            "https://ui-avatars.com/api/?name=J+D&background=random",
            "https://ui-avatars.com/api/?name=M+O&background=random",
          ],
          partnerLogos: ["GOLIS", "TELESOM", "SOMTEL"],
          endDate: DateTime.now().add(const Duration(days: 45)),
          recentDonors: [
            Donor(name: 'Axmed M.', amount: 50.0, donatedAt: DateTime.now().subtract(const Duration(minutes: 2))),
            Donor(name: 'Sahra A.', amount: 100.0, donatedAt: DateTime.now().subtract(const Duration(minutes: 5))),
          ],
        ),
      ];
      _saveCampaigns();
    }
  }

  void _saveCampaigns() {
    final List<String> campaignsJson = _campaigns.map((e) => json.encode(e.toJson())).toList();
    _prefs.setStringList('fundraiser_campaigns', campaignsJson);
  }

  void addCampaign(Campaign campaign) {
    _campaigns.insert(0, campaign);
    _saveCampaigns();
    notifyListeners();
  }

  Future<void> donateToCampaign(
    String campaignId, 
    double amount, {
    String? cardId, 
    String? paymentMethod, 
    bool isAnonymous = false,
    String? message,
    bool isRecurring = false,
  }) async {
    String method = paymentMethod ?? "Main Wallet";
    if (method == "Savings Account") {
      throw Exception('Savings accounts cannot be used for bill payments');
    }

    final index = _campaigns.indexWhere((c) => c.id == campaignId);
    if (index == -1) {
      throw Exception('campaign_not_found');
    }

    double fee = calculateFeeForSource(amount, method, cardId: cardId);
    double total = amount + fee;

    if (!hasSufficientBalanceForSource(amount, method, cardId: cardId)) {
      throw Exception('insufficient_funds');
    }

    // Process deduction
    if (method == "Main Wallet" || method == "Murtaax Wallet") {
      _balance -= total;
      await _saveBalance();
    } else if (cardId != null) {
      final cardIdx = _cards.indexWhere((c) => c.id == cardId);
      if (cardIdx != -1) {
        _cards[cardIdx] = _cards[cardIdx].copyWith(balance: _cards[cardIdx].balance - total);
        await _saveCards();
      }
    }

    final campaign = _campaigns[index];
    final newDonors = List<Donor>.from(campaign.recentDonors);
    
    final donor = Donor(
      name: isAnonymous ? "Anonymous" : (_userName.split(' ')[0] + '.'),
      amount: amount,
      donatedAt: DateTime.now(),
      isAnonymous: isAnonymous,
      message: message,
    );
    
    newDonors.insert(0, donor);
    if (newDonors.length > 5) {
      newDonors.removeLast();
    }

    _campaigns[index] = campaign.copyWith(
      raisedAmount: campaign.raisedAmount + amount,
      donorCount: campaign.donorCount + 1,
      lastDonationAgo: "Just now",
      recentDonors: newDonors,
    );

    final tx = Transaction(
      id: "TX-SADAQAH-${DateTime.now().millisecondsSinceEpoch}",
      title: "Fundraiser: ${campaign.title}",
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: "-${NumberFormat.simpleCurrency(name: _currencyCode).format(total)}",
      numericAmount: amount,
      fee: fee,
      isNegative: true,
      category: campaign.category == "Zakat / Agoomo" ? "Zakat" : "Sadaqah",
      status: "Success",
      type: "transfer_out",
      method: "Wallet",
      paymentMethod: method,
      cardId: cardId,
      referenceId: campaignId,
      purpose: message,
    );
    _transactions.insert(0, tx);
    analytics.logTransaction(tx.type, tx.numericAmount, _currencyCode);
    analytics.logEvent('donation_completed', parameters: {
      'campaign_id': campaignId,
      'amount': amount,
      'is_anonymous': isAnonymous,
      'is_recurring': isRecurring,
      'payment_method': method,
    });

    if (isRecurring) {
      final recurring = RecurringPayment(
        id: "REC-FUND-${DateTime.now().millisecondsSinceEpoch}",
        title: "Fundraiser: ${campaign.title}",
        receiverId: campaignId,
        receiverName: campaign.title,
        amount: amount,
        frequency: RecurringFrequency.monthly,
        startDate: DateTime.now(),
        nextPaymentDate: DateTime.now().add(const Duration(days: 30)),
        status: RecurringStatus.active,
        category: "Donation",
        cardId: cardId,
        lastExecution: DateTime.now(),
      );
      _recurringPayments.add(recurring);
      await _saveRecurringPayments();
    }

    await _saveTransactions();
    _saveCampaigns();
    notifyListeners();
  }

  void _loadRecurringPayments() {
    final List<String>? paymentsJson = _prefs.getStringList('recurring_payments');
    if (paymentsJson != null) {
      _recurringPayments = paymentsJson.map((e) => RecurringPayment.fromJson(json.decode(e))).toList();
    }
  }

  Future<void> _saveRecurringPayments() async {
    final List<String> paymentsJson = _recurringPayments.map((e) => json.encode(e.toJson())).toList();
    await _prefs.setStringList('recurring_payments', paymentsJson);
  }

  void addRecurringPayment(RecurringPayment payment) {
    _recurringPayments.add(payment);
    _saveRecurringPayments();
    notifyListeners();
  }

  void _loadHagbadGroups() {
    final List<String>? groupsJson = _prefs.getStringList('hagbad_groups');
    if (groupsJson != null) {
      _hagbadGroups = groupsJson.map((e) => HagbadGroup.fromJson(json.decode(e))).toList();
    }
  }

  Future<void> _saveHagbadGroups() async {
    final List<String> groupsJson = _hagbadGroups.map((e) => json.encode(e.toJson())).toList();
    await _prefs.setStringList('hagbad_groups', groupsJson);
  }

  Future<void> updateHagbadGroup(HagbadGroup group) async {
    final index = _hagbadGroups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      _hagbadGroups[index] = group;
      await _saveHagbadGroups();
      notifyListeners();
    }
  }

  Future<void> createHagbadGroup(HagbadGroup group) async {
    _hagbadGroups.add(group);
    await _saveHagbadGroups();
    notifyListeners();
  }

  Future<void> deleteHagbadGroup(String groupId) async {
    _hagbadGroups.removeWhere((g) => g.id == groupId);
    await _saveHagbadGroups();
    notifyListeners();
  }

  Future<void> addHagbadMember(String groupId, HagbadMember member, {bool isSms = false, double catchUpAmount = 0}) async {
    final index = _hagbadGroups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      final group = _hagbadGroups[index];
      
      // If catching up, deduct from balance
      if (catchUpAmount > 0) {
        if (_balance < catchUpAmount) {
          throw Exception('insufficient_funds');
        }
        _balance -= catchUpAmount;
        await _saveBalance();
        
        final tx = Transaction(
          id: "HAG-ADD-${DateTime.now().millisecondsSinceEpoch}",
          title: "Hagbad Catch-up: ${group.name}",
          date: DateFormat('MMM dd').format(DateTime.now()),
          amount: "-${NumberFormat.simpleCurrency(name: _currencyCode).format(catchUpAmount)}",
          numericAmount: catchUpAmount,
          isNegative: true,
          category: "Hagbad",
          status: "Success",
          type: "send",
          timestamp: DateTime.now(),
        );
        _transactions.insert(0, tx);
        analytics.logTransaction(tx.type, tx.numericAmount, _currencyCode);
        await _saveTransactions();
      }

      final newMembers = List<HagbadMember>.from(group.members)..add(member);
      _hagbadGroups[index] = group.copyWith(members: newMembers);
      await _saveHagbadGroups();
      notifyListeners();
    }
  }

  Future<void> updateHagbadMember(String groupId, dynamic indexOrMember, [HagbadMember? member]) async {
    final groupIdx = _hagbadGroups.indexWhere((g) => g.id == groupId);
    if (groupIdx != -1) {
      final group = _hagbadGroups[groupIdx];
      final newMembers = List<HagbadMember>.from(group.members);
      
      if (indexOrMember is int && member != null) {
        if (indexOrMember >= 0 && indexOrMember < newMembers.length) {
          newMembers[indexOrMember] = member;
        }
      } else if (indexOrMember is HagbadMember) {
        final mIdx = newMembers.indexWhere((m) => m.name == indexOrMember.name);
        if (mIdx != -1) {
          newMembers[mIdx] = indexOrMember;
        }
      }
      
      _hagbadGroups[groupIdx] = group.copyWith(members: newMembers);
      await _saveHagbadGroups();
      notifyListeners();
    }
  }

  Future<void> removeHagbadMember(String groupId, dynamic nameOrIndex) async {
    final index = _hagbadGroups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      final group = _hagbadGroups[index];
      final newMembers = List<HagbadMember>.from(group.members);
      if (nameOrIndex is int) {
        if (nameOrIndex >= 0 && nameOrIndex < newMembers.length) {
          newMembers.removeAt(nameOrIndex);
        }
      } else if (nameOrIndex is String) {
        newMembers.removeWhere((m) => m.name == nameOrIndex);
      }
      _hagbadGroups[index] = group.copyWith(members: newMembers);
      await _saveHagbadGroups();
      notifyListeners();
    }
  }

  Future<void> payHagbad(String groupId, dynamic amountOrIndex, [double? amount]) async {
    final index = _hagbadGroups.indexWhere((g) => g.id == groupId);
    if (index == -1) {
      return;
    }
    
    final group = _hagbadGroups[index];
    double payAmount = 0;
    int memberIdx = -1;

    if (amountOrIndex is double) {
      payAmount = amountOrIndex;
    } else if (amountOrIndex is int && amount != null) {
      memberIdx = amountOrIndex;
      payAmount = amount;
    } else if (amountOrIndex is num) {
      payAmount = amountOrIndex.toDouble();
    }

    if (_balance < payAmount) {
      throw Exception('insufficient_funds');
    }

    _balance -= payAmount;
    final updatedMembers = List<HagbadMember>.from(group.members);
    if (memberIdx != -1 && memberIdx < updatedMembers.length) {
       updatedMembers[memberIdx] = updatedMembers[memberIdx].copyWith(
         paidAmount: updatedMembers[memberIdx].paidAmount + payAmount
       );
    }
    
    _hagbadGroups[index] = group.copyWith(
      paidAmount: group.paidAmount + payAmount,
      members: updatedMembers,
    );
    
    await _saveBalance();
    await _saveHagbadGroups();
    
    final tx = Transaction(
      id: "HAG-PAY-${DateTime.now().millisecondsSinceEpoch}",
      title: "Hagbad Payment: ${group.name}",
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: "-${NumberFormat.simpleCurrency(name: _currencyCode).format(payAmount)}",
      numericAmount: payAmount,
      isNegative: true,
      category: "Hagbad",
      status: "Success",
      type: "send",
      timestamp: DateTime.now(),
    );
    _transactions.insert(0, tx);
    analytics.logTransaction(tx.type, tx.numericAmount, _currencyCode);
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> randomizeHagbadTurns(String groupId) async {
    final index = _hagbadGroups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      final group = _hagbadGroups[index];
      final members = List<HagbadMember>.from(group.members)..shuffle();
      final newMembers = List.generate(members.length, (i) => members[i].copyWith(payoutOrder: i + 1));
      _hagbadGroups[index] = group.copyWith(members: newMembers);
      await _saveHagbadGroups();
      notifyListeners();
    }
  }

  Future<void> swapHagbadTurns(String groupId, int order1, int order2) async {
    final index = _hagbadGroups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      final group = _hagbadGroups[index];
      final m1Idx = group.members.indexWhere((m) => m.payoutOrder == order1);
      final m2Idx = group.members.indexWhere((m) => m.payoutOrder == order2);
      if (m1Idx != -1 && m2Idx != -1) {
        final newMembers = List<HagbadMember>.from(group.members);
        final m1 = newMembers[m1Idx];
        final m2 = newMembers[m2Idx];
        newMembers[m1Idx] = m1.copyWith(payoutOrder: order2);
        newMembers[m2Idx] = m2.copyWith(payoutOrder: order1);
        _hagbadGroups[index] = group.copyWith(members: newMembers);
        await _saveHagbadGroups();
        notifyListeners();
      }
    }
  }

  Future<void> processHagbadPayout(String groupId, [dynamic memberNameOrIndex]) async {
    final index = _hagbadGroups.indexWhere((g) => g.id == groupId);
    if (index == -1) {
      return;
    }

    final group = _hagbadGroups[index];
    int memberIdx = -1;

    if (memberNameOrIndex is int) {
      memberIdx = memberNameOrIndex;
    } else if (memberNameOrIndex is String) {
      memberIdx = group.members.indexWhere((m) => m.name == memberNameOrIndex);
    } else {
      // Default to the next person who hasn't received
      memberIdx = group.members.indexWhere((m) => !m.hasReceived);
    }

    if (memberIdx != -1) {
      final member = group.members[memberIdx];
      final payoutAmount = group.totalPayout;
      
      if (member.name == "Me" || member.walletId == _walletId) {
        _balance += payoutAmount;
        await _saveBalance();
      }

      final newMembers = List<HagbadMember>.from(group.members);
      newMembers[memberIdx] = member.copyWith(hasReceived: true);
      _hagbadGroups[index] = group.copyWith(
        members: newMembers,
        currentCycle: group.currentCycle + 1,
      );
      
      final tx = Transaction(
        id: "HAG-PAYOUT-${DateTime.now().millisecondsSinceEpoch}",
        title: "Hagbad Payout: ${group.name}",
        date: DateFormat('MMM dd').format(DateTime.now()),
        amount: "+${NumberFormat.simpleCurrency(name: _currencyCode).format(payoutAmount)}",
        numericAmount: payoutAmount,
        isNegative: false,
        category: "Hagbad",
        status: "Success",
        type: "receive",
        timestamp: DateTime.now(),
      );
      _transactions.insert(0, tx);
      analytics.logTransaction(tx.type, tx.numericAmount, _currencyCode);
      await _saveTransactions();
      await _saveHagbadGroups();
      notifyListeners();
    }
  }

  void logHagbadEvent(String groupId, String message) {
    debugPrint("Hagbad Event [$groupId]: $message");
  }

  void sendHagbadNotification(String targetId, String message, {bool isSms = false}) {
    if (targetId == _walletId || targetId == "Me") {
      addNotification(NotificationData(
        id: "HAG-NOT-${DateTime.now().millisecondsSinceEpoch}",
        title: isSms ? "SMS: Hagbad Update" : "Hagbad Update",
        subtitle: message,
        time: "Just now",
        message: message,
        timestamp: DateTime.now(),
        type: 4, // 4 for Hagbad
      ));
    }
    if (isSms) {
      debugPrint("Simulating SMS to $targetId: $message");
    }
  }

  Future<void> addBank(BankAccount bank) async {
    _linkedBanks.add(bank);
    await _saveLinkedBanks();
    notifyListeners();
  }

  Future<void> removeBank(String bankId) async {
    _linkedBanks.removeWhere((b) => b.id == bankId);
    await _saveLinkedBanks();
    notifyListeners();
  }

  Future<void> _saveLinkedBanks() async {
    final List<String> banksJson = _linkedBanks.map((e) => json.encode(e.toJson())).toList();
    await _prefs.setStringList('linked_banks', banksJson);
  }

  Future<void> saveBeneficiary(BankAccount beneficiary) async {
    final index = _savedBeneficiaries.indexWhere((b) => b.accountNumber == beneficiary.accountNumber);
    if (index != -1) {
      _savedBeneficiaries[index] = beneficiary;
    } else {
      _savedBeneficiaries.add(beneficiary);
    }
    await _saveBeneficiaries();

    // Also add to Quick Profiles for the home screen if it doesn't exist
    final profileIndex = _quickProfiles.indexWhere((p) => p.walletId == beneficiary.accountNumber);
    if (profileIndex == -1) {
      final newProfile = QuickProfile(
        id: "BEN-${DateTime.now().millisecondsSinceEpoch}",
        name: beneficiary.accountHolder ?? "Beneficiary",
        walletId: beneficiary.accountNumber,
        payoutMethod: "Bank",
        bankName: beneficiary.bankName,
        initials: (beneficiary.accountHolder ?? "B").split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
      );
      _quickProfiles.add(newProfile);
      await _saveQuickProfiles();
    }

    notifyListeners();
  }

  Future<void> _saveBeneficiaries() async {
    final List<String> bensJson = _savedBeneficiaries.map((e) => json.encode(e.toJson())).toList();
    await _prefs.setStringList('saved_beneficiaries', bensJson);
  }

  Future<void> contributeToHagbad(String groupId, double amount) async {
    if (_balance < amount) {
      throw Exception('insufficient_funds');
    }
    
    final index = _hagbadGroups.indexWhere((g) => g.id == groupId);
    if (index == -1) {
      throw Exception('group_not_found');
    }
    
    _balance -= amount;
    final group = _hagbadGroups[index];
    
    // Logic for contribution
    _hagbadGroups[index] = group.copyWith(
      paidAmount: group.paidAmount + amount,
    );
    
    final tx = Transaction(
      id: "HAG-${DateTime.now().millisecondsSinceEpoch}",
      title: "Hagbad: ${group.name}",
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: "-${NumberFormat.simpleCurrency(name: _currencyCode).format(amount)}",
      numericAmount: amount,
      isNegative: true,
      category: "Hagbad",
      status: "Success",
      type: "payment",
      referenceId: groupId,
    );
    
    _transactions.insert(0, tx);
    analytics.logTransaction(tx.type, tx.numericAmount, _currencyCode);
    await _saveBalance();
    await _saveTransactions();
    _saveHagbadGroups();
    notifyListeners();
  }

  Future<void> _loadCryptoHoldings() async {
    final String? cryptoJson = _prefs.getString('crypto_holdings');
    if (cryptoJson != null) {
      final Map<String, dynamic> decoded = json.decode(cryptoJson);
      _cryptoHoldings = decoded.map((key, value) => MapEntry(key, value.toDouble()));
    }
  }

  Future<void> _saveCryptoHoldings() async {
    await _prefs.setString('crypto_holdings', json.encode(_cryptoHoldings));
  }

  Future<void> _loadCards() async {
    final List<String>? cardsJson = _prefs.getStringList('virtual_cards');
    if (cardsJson != null) {
      _cards = cardsJson.map((e) => VirtualCard.fromJson(json.decode(e))).toList();
    } else {
      // Mock initial cards
      _cards = [
        VirtualCard(
          id: '1',
          cardNumber: '**** **** **** 4589',
          cardHolder: 'MOHAMED OSMAN',
          expiryDate: '09/26',
          cvv: '123',
          theme: CardThemeType.obsidian,
          network: CardNetwork.visa,
          balance: 2450.80,
        ),
        VirtualCard(
          id: '2',
          cardNumber: '**** **** **** 1122',
          cardHolder: 'MOHAMED OSMAN',
          expiryDate: '12/25',
          cvv: '987',
          theme: CardThemeType.gold,
          network: CardNetwork.mastercard,
          balance: 1500.00,
        ),
      ];
    }
    // Load associated card PINs from secure storage
    for (final card in _cards) {
      final pin = await _secureStorage.read(key: 'card_pin_${card.id}');
      if (pin != null) {
        _cardPins[card.id] = pin;
      } else {
        // Default pin if none is set yet for the mock cards
        _cardPins[card.id] = card.id == '1' ? '1122' : '2233';
      }
    }
  }

  Future<void> _saveCards() async {
    final List<String> cardsJson = _cards.map((e) => json.encode(e.toJson())).toList();
    await _prefs.setStringList('virtual_cards', cardsJson);
    
    final List<String> terminatedJson = _terminatedCards.map((e) => json.encode(e.toJson())).toList();
    await _prefs.setStringList('terminated_cards', terminatedJson);
  }

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  String get languageName {
    switch (_locale.languageCode) {
      case 'en': return 'English';
      case 'so': return 'Af-Soomaali';
      case 'ar': return 'Ø§Ù„Ø¹Ø±Ø¨ÙŠØ©';
      case 'de': return 'Deutsch';
      case 'et': return 'Eesti';
      default: return 'English';
    }
  }

  bool get isRtl => _locale.languageCode == 'ar'; 

  int _selectedNavIndex = 0;
  int get selectedNavIndex => _selectedNavIndex;

  int _selectedCardIndex = 0;
  int get selectedCardIndex => _selectedCardIndex;

  void setSelectedCardIndex(int index) {
    _selectedCardIndex = index;
    notifyListeners();
  }

  final Map<String, String> _mockUsers = {
    '102234': 'Ayaanle Rayaale',
    '102235': 'Fartun Ali',
    '102236': 'Abdirahman Said',
    '102237': 'Zamzam Abdi',
    '102238': 'Mustaf Khalil',
    '615123456': 'Mohamed Osman',
    '612888777': 'Sahra Hassan',
    '634111222': 'Axmed Cali',
    '659000111': 'Deeqa Jaamac',
    '770555444': 'Cabdi Salaad',
  };

  final Map<String, Map<String, String>> _mockBankAccounts = {
    'IBS Bank': {
      '123456789012': 'Faarax Axmed',
      '987654321098': 'Deeqa Jaamac',
      '112233445566': 'Maxamed Ibraahim',
      '556677889900': 'Khadra Cali',
      '101020203030': 'Yoonis Cabdi',
    },
    'Salaam Bank': {
      '1020304050': 'Cali Geedi',
      '1020304060': 'Xaliimo Cali',
      '1055667788': 'Cabdiraxmaan Geelle',
      '1099887766': 'Hibaaq Jaamac',
      '1044332211': 'Ismaaciil Cumar',
    },
    'Premier Bank': {
      '5060708090': 'Sahra Maxamed',
      '5060708091': 'Warsame Abtidoon',
      '5011223344': 'Hodan Ciise',
      '5088776655': 'Yuusuf Xasan',
      '5033445566': 'Maryan Cabdi',
    },
  };

  Map<String, String> get mockUsers => _mockUsers;

  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    
    final savedTheme = _prefs.getString('theme_mode') ?? 'light';
    _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;

    final savedLocale = _prefs.getString('language_code') ?? 'en';
    _locale = Locale(savedLocale);

    _balance = _prefs.getDouble('balance') ?? 12450.80;
    _savingsBalance = _prefs.getDouble('savings_balance') ?? 520.50;

    await _loadCards();
    _loadTransactions();
    await _loadCryptoHoldings();
    _loadSavingsGoals();
    _loadHagbadGroups();
    _loadRecurringPayments();
    _loadCampaigns();
    _loadSearchHistories();
    
    updateMarketRates();

    _biometricEnabled = _prefs.getBool('biometric_enabled') ?? true;
    _cardBiometricEnabled = _prefs.getBool('card_biometric_enabled') ?? true;
    
    _userDailyLimit = _prefs.getDouble('daily_limit') ?? 5000.0;
    _userMonthlyLimit = _prefs.getDouble('monthly_limit') ?? 20000.0;

    _isInitialized = true;
    notifyListeners();
  }

  void _loadTransactions() {
    final List<String>? txJson = _prefs.getStringList('transactions');
    if (txJson != null) {
      _transactions = txJson.map((e) => Transaction.fromJson(json.decode(e))).toList();
    }
  }

  Future<void> addTransaction(Transaction tx) async {
    _transactions.insert(0, tx);
    analytics.logTransaction(tx.type, tx.numericAmount, _currencyCode);
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> _saveTransactions() async {
    final List<String> txJson = _transactions.map((e) => json.encode(e.toJson())).toList();
    await _prefs.setStringList('transactions', txJson);
  }

  Future<void> _saveBalance() async {
    await _prefs.setDouble('balance', _balance);
  }

  Future<void> _saveSavingsBalance() async {
    await _prefs.setDouble('savings_balance', _savingsBalance);
  }

  Future<void> _loadSavingsGoals() async {
    final List<String>? goalsJson = _prefs.getStringList('savings_goals');
    if (goalsJson != null) {
      _savingsGoals = goalsJson.map((e) => SavingsGoal.fromJson(json.decode(e))).toList();
    }
  }

  Future<void> _saveSavingsGoals() async {
    final List<String> goalsJson = _savingsGoals.map((e) => json.encode(e.toJson())).toList();
    await _prefs.setStringList('savings_goals', goalsJson);
  }

  void _loadSearchHistories() {
    _hagbadSearchHistory = _prefs.getStringList('hagbad_search_history') ?? [];
    _sadaqahSearchHistory = _prefs.getStringList('sadaqah_search_history') ?? [];
    _contactSearchHistory = _prefs.getStringList('contact_search_history') ?? [];
  }

  Future<void> addToSearchHistory(String query, String module) async {
    if (query.trim().isEmpty) {
      return;
    }
    
    List<String> history;
    String key;
    
    switch (module.toLowerCase()) {
      case 'hagbad':
        history = _hagbadSearchHistory;
        key = 'hagbad_search_history';
        break;
      case 'sadaqah':
      case 'zakat':
      case 'fundraiser':
        history = _sadaqahSearchHistory;
        key = 'sadaqah_search_history';
        break;
      case 'contact':
      case 'p2p':
        history = _contactSearchHistory;
        key = 'contact_search_history';
        break;
      default:
        return;
    }

    // Remove if exists and add to top
    history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    history.insert(0, query);
    
    // Limit history to 10 items
    if (history.length > 10) {
      history = history.sublist(0, 10);
    }

    if (module.toLowerCase() == 'hagbad') {
      _hagbadSearchHistory = history;
    } else if (module.toLowerCase() == 'contact' || module.toLowerCase() == 'p2p') {
      _contactSearchHistory = history;
    } else {
      _sadaqahSearchHistory = history;
    }

    await _prefs.setStringList(key, history);
    notifyListeners();
  }

  Future<void> clearSearchHistory(String module) async {
    String key;
    switch (module.toLowerCase()) {
      case 'hagbad':
        _hagbadSearchHistory = [];
        key = 'hagbad_search_history';
        break;
      case 'sadaqah':
      case 'zakat':
      case 'fundraiser':
        _sadaqahSearchHistory = [];
        key = 'sadaqah_search_history';
        break;
      case 'contact':
      case 'p2p':
        _contactSearchHistory = [];
        key = 'contact_search_history';
        break;
      default:
        return;
    }
    await _prefs.setStringList(key, []);
    notifyListeners();
  }

  Future<void> removeFromSearchHistory(String query, String module) async {
    List<String> history;
    String key;
    
    switch (module.toLowerCase()) {
      case 'hagbad':
        history = _hagbadSearchHistory;
        key = 'hagbad_search_history';
        break;
      case 'sadaqah':
      case 'zakat':
      case 'fundraiser':
        history = _sadaqahSearchHistory;
        key = 'sadaqah_search_history';
        break;
      case 'contact':
      case 'p2p':
        history = _contactSearchHistory;
        key = 'contact_search_history';
        break;
      default:
        return;
    }

    history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    await _prefs.setStringList(key, history);
    notifyListeners();
  }

  Future<void> addSavingsGoal(SavingsGoal goal) async {
    _savingsGoals.add(goal);
    await _saveSavingsGoals();
    notifyListeners();
  }

  Future<void> updateSavingsGoal(dynamic indexOrGoal, [SavingsGoal? goal]) async {
    if (indexOrGoal is int && goal != null) {
      if (indexOrGoal >= 0 && indexOrGoal < _savingsGoals.length) {
        _savingsGoals[indexOrGoal] = goal;
      }
    } else if (indexOrGoal is SavingsGoal) {
      final index = _savingsGoals.indexWhere((g) => g.id == indexOrGoal.id);
      if (index != -1) {
        _savingsGoals[index] = indexOrGoal;
      }
    }
    await _saveSavingsGoals();
    notifyListeners();
  }

  Future<void> removeSavingsGoal(dynamic idOrIndex) async {
    if (idOrIndex is int) {
      if (idOrIndex >= 0 && idOrIndex < _savingsGoals.length) {
        _savingsGoals.removeAt(idOrIndex);
      }
    } else if (idOrIndex is String) {
      _savingsGoals.removeWhere((g) => g.id == idOrIndex);
    }
    await _saveSavingsGoals();
    notifyListeners();
  }

  Future<void> transferToSavings(double amount, {String? goalId, String? goalName, String? fromCardId}) async {
    if (fromCardId != null) {
      final cardIdx = _cards.indexWhere((c) => c.id == fromCardId);
      if (cardIdx != -1) {
        if (_cards[cardIdx].balance < amount) {
          throw Exception('insufficient_card_funds');
        }
        _cards[cardIdx] = _cards[cardIdx].copyWith(balance: _cards[cardIdx].balance - amount);
        await _saveCards();
      } else {
        throw Exception('card_not_found');
      }
    } else {
      if (_balance < amount) {
        throw Exception('insufficient_funds');
      }
      _balance -= amount;
      await _saveBalance();
    }

    _savingsBalance += amount;
    
    if (goalId != null || goalName != null) {
      final index = _savingsGoals.indexWhere((g) => g.id == goalId || g.name == goalName);
      if (index != -1) {
        final goal = _savingsGoals[index];
        _savingsGoals[index] = goal.copyWith(
          currentAmount: goal.currentAmount + amount,
        );
      }
    }
    
    final tx = Transaction(
      id: "SAV-IN-${DateTime.now().millisecondsSinceEpoch}",
      title: "Transfer to Savings",
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: "-${NumberFormat.simpleCurrency(name: _currencyCode).format(amount)}",
      numericAmount: amount,
      isNegative: true,
      category: "Savings",
      status: "Success",
      type: "transfer_out",
      timestamp: DateTime.now(),
    );
    
    _transactions.insert(0, tx);
    analytics.logTransaction(tx.type, tx.numericAmount, _currencyCode);
    await _saveTransactions();
    await _saveSavingsGoals();
    await _saveSavingsBalance();
    notifyListeners();
  }

  Future<void> withdrawFromSavings(double amount, {String? goalId, String? toCardId}) async {
    if (_savingsBalance < amount) {
      throw Exception('insufficient_savings');
    }
    
    _savingsBalance -= amount;
    
    if (toCardId != null) {
      final cardIdx = _cards.indexWhere((c) => c.id == toCardId);
      if (cardIdx != -1) {
        _cards[cardIdx] = _cards[cardIdx].copyWith(balance: _cards[cardIdx].balance + amount);
        await _saveCards();
      } else {
        throw Exception('card_not_found');
      }
    } else {
      _balance += amount;
      await _saveBalance();
    }
    
    if (goalId != null) {
      final index = _savingsGoals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        final goal = _savingsGoals[index];
        _savingsGoals[index] = goal.copyWith(
          currentAmount: math.max(0.0, goal.currentAmount - amount),
        );
      }
    }
    
    final tx = Transaction(
      id: "SAV-OUT-${DateTime.now().millisecondsSinceEpoch}",
      title: "Withdraw from Savings",
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: NumberFormat.simpleCurrency(name: _currencyCode).format(amount),
      numericAmount: amount,
      isNegative: false,
      category: "Savings",
      status: "Success",
      type: "transfer_in",
      timestamp: DateTime.now(),
    );
    
    _transactions.insert(0, tx);
    analytics.logTransaction(tx.type, tx.numericAmount, _currencyCode);
    await _saveTransactions();
    await _saveSavingsGoals();
    await _saveSavingsBalance();
    notifyListeners();
  }

  Future<void> contributeToGoal(String goalId, double amount) async {
    await transferToSavings(amount, goalId: goalId);
  }

  void _loadQuickProfiles() {
    final List<String>? profilesJson = _prefs.getStringList('quick_profiles');
    if (profilesJson != null) {
      _quickProfiles = profilesJson.map((e) => QuickProfile.fromJson(e)).toList();
    }
  }

  Future<void> _saveQuickProfiles() async {
    final List<String> profilesJson = _quickProfiles.map((e) => e.toJson()).toList();
    await _prefs.setStringList('quick_profiles', profilesJson);
  }

  Future<void> saveQuickProfile(QuickProfile profile) async {
    final index = _quickProfiles.indexWhere((p) => p.walletId == profile.walletId);
    if (index != -1) {
      _quickProfiles[index] = profile;
    } else {
      if (!_isPremium && _quickProfiles.length >= 10) { // Increased limit for all
        throw Exception('profile_limit_reached');
      }
      _quickProfiles.add(profile);
    }
    await _saveQuickProfiles();
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final index = _quickProfiles.indexWhere((p) => p.id == id);
    if (index != -1) {
      _quickProfiles[index] = _quickProfiles[index].copyWith(
        isFavorite: !_quickProfiles[index].isFavorite,
      );
      await _saveQuickProfiles();
      notifyListeners();
    }
  }

  Future<void> _updateQuickProfileStats(String walletId, double amount, String method, {String? name}) async {
    final index = _quickProfiles.indexWhere((p) => p.walletId == walletId);
    if (index != -1) {
      final p = _quickProfiles[index];
      _quickProfiles[index] = p.copyWith(
        transactionCount: p.transactionCount + 1,
        lastTransactionDate: DateTime.now(),
        lastAmount: amount,
        lastReceiverMethod: method,
        name: name ?? p.name,
      );
    } else {
      // Auto-save new frequent recipients if they aren't in the list
      final newProfile = QuickProfile(
        id: "AUTO-${DateTime.now().millisecondsSinceEpoch}",
        name: name ?? walletId,
        walletId: walletId,
        payoutMethod: method,
        transactionCount: 1,
        lastTransactionDate: DateTime.now(),
        lastAmount: amount,
        lastReceiverMethod: method,
        initials: (name ?? "U").split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
      );
      
      if (_quickProfiles.length < 20) { // Reasonable auto-save limit
        _quickProfiles.add(newProfile);
      }
    }
    await _saveQuickProfiles();
  }

  Future<void> updateQuickProfileStatus(String id, String status) async {
    final index = _quickProfiles.indexWhere((p) => p.id == id);
    if (index != -1) {
      _quickProfiles[index] = _quickProfiles[index].copyWith(
        verificationStatus: status,
        verifiedAt: status == 'verified' ? DateTime.now() : null,
      );
      await _saveQuickProfiles();
      notifyListeners();
    }
  }

  Future<void> deleteQuickProfile(String id) async {
    _quickProfiles.removeWhere((p) => p.id == id);
    await _saveQuickProfiles();
    notifyListeners();
  }

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _prefs.setString('theme_mode', isDark ? 'dark' : 'light');
    notifyListeners();
  }

  void setLanguage(String langCode) {
    _locale = Locale(langCode);
    _prefs.setString('language_code', langCode);
    notifyListeners();
  }

  Future<void> simulateTransactionCompletion(String transactionId) async {
    final index = _transactions.indexWhere((tx) => tx.id == transactionId);
    if (index != -1) {
      final tx = _transactions[index];
      if (tx.status == "Pending") {
        _transactions[index] = tx.copyWith(status: "Success");
        
        addNotification(NotificationData(
          id: "NOTIF-${DateTime.now().millisecondsSinceEpoch}",
          title: "Transaction Successful",
          subtitle: "Bank Transfer",
          message: "Your withdrawal of ${tx.amount} to ${tx.title} has been completed.",
          time: "Just now",
          timestamp: DateTime.now(),
          isRead: false,
        ));
        
        await _saveTransactions();
        notifyListeners();
      }
    }
  }

  double calculateFeeForSource(double amount, String source, {String? payoutMethod, String? cardId}) {
    // Fee rates per $100: 
    // Mobile Money: $2.5 (2.5%) - Min $0.10 (e.g. EVC Plus, Sahal, ZAAD, E-Dahab)
    // Bank Transfer: $1.5 (1.5%) - Min $0.50
    // Debit/Virtual Card: $2.0 (2.0%)
    // Main Wallet: $1.0 (1.0%)
    
    double rate = 0.01; // Default Wallet (1%)
    double minFee = 0.0;
    
    // Check for Mobile Money providers or explicit "Mobile" string
    final mobileProviders = ["EVC Plus", "Sahal", "ZAAD Service", "E-Dahab", "Mobile"];
    bool isMobile = mobileProviders.any((p) => source.contains(p)) || 
                   (payoutMethod != null && mobileProviders.any((p) => payoutMethod.contains(p)));

    if (isMobile) {
      rate = 0.025; // 2.5%
      minFee = 0.10;
    } else if (source.contains("Bank") || (payoutMethod?.contains("Bank") ?? false)) {
      rate = 0.015; // 1.5%
      minFee = 0.50;
    } else if (source.contains("Card") || source.contains("Debit") || cardId != null) {
      rate = 0.020; // 2.0% (Updated from 1.5% to 2.0%)
    }
    
    double calculated = amount * rate;
    return calculated < minFee ? minFee : calculated;
  }

  double calculateTotal(double amount, {String? payoutMethod, String? cardId, String? paymentMethod}) {
    final method = paymentMethod ?? (cardId != null ? "Virtual Card" : "Main Wallet");
    return amount + calculateFeeForSource(amount, method, payoutMethod: payoutMethod, cardId: cardId);
  }

  double convertAmount(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return amount;
    
    double amountInUsd;
    if (fromCurrency == 'USD') {
      amountInUsd = amount;
    } else {
      double fromRate = _fxRates[fromCurrency] ?? 1.0;
      amountInUsd = amount / fromRate;
    }
    
    if (toCurrency == 'USD') {
      return amountInUsd;
    } else {
      double toRate = _fxRates[toCurrency] ?? 1.0;
      return amountInUsd * toRate;
    }
  }

  Future<void> autoTopUpMainFromSavings(double amount) async {
    if (_savingsBalance < amount) {
      throw Exception('insufficient_savings');
    }
    
    _savingsBalance -= amount;
    _balance += amount;
    
    final tx = Transaction(
      id: "AUTO-TOP-${DateTime.now().millisecondsSinceEpoch}",
      title: "Auto Top-up from Savings",
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: NumberFormat.simpleCurrency(name: _currencyCode).format(amount),
      numericAmount: amount,
      isNegative: false,
      category: "Savings",
      status: "Success",
      type: "transfer_in",
      purpose: "Auto Top-up for transaction",
    );
    
    _transactions.insert(0, tx);
    await _saveBalance();
    await _saveSavingsGoals(); // Update savings related state
    await _saveTransactions();
    notifyListeners();
  }

  bool hasSufficientBalanceForSource(double amount, String source, {String? cardId, String? payoutMethod}) {
    double total = amount + calculateFeeForSource(amount, source, payoutMethod: payoutMethod, cardId: cardId);
    if (source == "Main Wallet" || source == "Murtaax Wallet") {
      return _balance >= total;
    }
    return true;
  }

  double _userDailyLimit = 5000.0;
  double _userMonthlyLimit = 20000.0;
  
  double get dailyLimit => _userDailyLimit;
  double get monthlyLimit => _userMonthlyLimit;

  double getDailyRemaining() {
    final now = DateTime.now();
    double spentToday = _transactions
      .where((tx) => tx.isNegative && 
                     tx.timestamp != null &&
                     tx.timestamp.day == now.day &&
                     tx.timestamp.month == now.month &&
                     tx.timestamp.year == now.year)
      .fold(0.0, (sum, tx) => sum + tx.numericAmount);
    return math.max(0.0, _userDailyLimit - spentToday);
  }

  double getMonthlyRemaining() {
    final now = DateTime.now();
    double spentThisMonth = _transactions
      .where((tx) => tx.isNegative && 
                     tx.timestamp != null &&
                     tx.timestamp.month == now.month &&
                     tx.timestamp.year == now.year)
      .fold(0.0, (sum, tx) => sum + tx.numericAmount);
    return math.max(0.0, _userMonthlyLimit - spentThisMonth);
  }

  void updateLimits({double? daily, double? monthly}) {
    if (daily != null) _userDailyLimit = daily;
    if (monthly != null) _userMonthlyLimit = monthly;
    _prefs.setDouble('daily_limit', _userDailyLimit);
    _prefs.setDouble('monthly_limit', _userMonthlyLimit);
    notifyListeners();
  }

  String translate(String en, String so, {String ar = '', String et = '', String de = ''}) {
    switch (_locale.languageCode) {
      case 'so': return so.isNotEmpty ? so : en;
      case 'ar': return ar.isNotEmpty ? ar : en;
      case 'et': return et.isNotEmpty ? et : en;
      case 'de': return de.isNotEmpty ? de : en;
      default:   return en;
    }
  }

  Future<void> _saveTerminatedCards() async {
    final List<String> terminatedJson = _terminatedCards.map((e) => json.encode(e.toJson())).toList();
    await _prefs.setStringList('terminated_cards', terminatedJson);
  }

  Future<Map<String, String>?> resolveAccountDetails(String id, {String? type, String? bankName}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));

    // 1. Check for Bank Resolution
    if (type == 'bank' || (bankName != null && bankName.isNotEmpty)) {
      final searchBank = bankName ?? '';
      if (_mockBankAccounts.containsKey(searchBank) && _mockBankAccounts[searchBank]!.containsKey(id)) {
        return {
          'name': _mockBankAccounts[searchBank]![id]!,
          'bank': searchBank,
          'type': 'bank'
        };
      }
    }

    // 2. Fallback search across all banks
    for (var bName in _mockBankAccounts.keys) {
      if (_mockBankAccounts[bName]!.containsKey(id)) {
        return {
          'name': _mockBankAccounts[bName]![id]!,
          'bank': bName,
          'type': 'bank'
        };
      }
    }

    // 3. Check for Wallet/Mobile resolution in _mockUsers
    if (_mockUsers.containsKey(id)) {
      String resolvedType = 'wallet';
      String? provider;
      if (id.length == 9 || id.startsWith('61') || id.startsWith('252')) {
        resolvedType = 'mobile';
        if (id.startsWith('61')) {
          provider = 'Hormuud (EVC Plus)';
        } else if (id.startsWith('62')) {
          provider = 'Somnet';
        } else if (id.startsWith('63')) {
          provider = 'Telesom (Zaad)';
        } else if (id.startsWith('65')) {
          provider = 'Golis (Sahal)';
        } else if (id.startsWith('77')) {
          provider = 'Somtel (e-Dahab)';
        }
      }
      return {
        'name': _mockUsers[id]!,
        'type': type ?? resolvedType,
        if (provider != null) ...{
          'bank': provider,
        },
      };
    }

    // 4. Heuristic resolution for demo purposes
    if (type == 'bank' && id.length >= 8) {
      final List<String> mockNames = ["Abshir Duale", "Leyla Ahmed", "Xasan Kaafi", "Muna Omar", "Khadra Jaamac", "Axmed Cali"];
      return {
        'name': mockNames[id.hashCode % mockNames.length],
        'bank': bankName ?? 'Bank',
        'type': 'bank'
      };
    }

    if (type == 'mobile' && (id.length >= 7)) {
      final List<String> mockNames = ["Farah Saney", "Hawa Abdi", "Bile Raage", "Ubax Cali", "Ayaanle Mahad"];
      return {
        'name': mockNames[id.hashCode % mockNames.length],
        'bank': bankName ?? 'Mobile Provider',
        'type': 'mobile'
      };
    }

    return null;
  }

  Future<String?> resolveAccountName(String id, {String? type, String? bankName}) async {
    final details = await resolveAccountDetails(id, type: type, bankName: bankName);
    if (details != null) {
      return details['name'];
    }
    return null;
  }

  Future<String?> verifyWalletId(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockUsers[id];
  }

  Future<Transaction?> processP2PTransfer({
    required String receiverId,
    required double amount,
    required String currencyCode,
    required String purpose,
    String paymentMethod = "Main Wallet",
    String? payoutMethod,
    String? receiverName,
    String? cardId,
    bool isFeeIncluded = false,
  }) async {
    final fee = calculateFeeForSource(amount, paymentMethod, payoutMethod: payoutMethod);
    final total = isFeeIncluded ? amount : (amount + fee);
    final netAmount = isFeeIncluded ? (amount - fee) : amount;
    
    // Limit Enforcement
    if (getDailySpent() + amount > dailyLimit) {
      throw Exception('daily_limit_exceeded');
    }
    if (getMonthlySpent() + amount > monthlyLimit) {
      throw Exception('monthly_limit_exceeded');
    }

    if (!hasSufficientBalanceForSource(amount, paymentMethod, cardId: cardId, payoutMethod: payoutMethod)) {
      throw Exception('insufficient_funds');
    }

    // Deduction logic based on sender source
    if (paymentMethod == "Main Wallet" || paymentMethod == "Murtaax Wallet") {
      _balance -= total;
      await _saveBalance();
    } else if (cardId != null || paymentMethod.startsWith("Card ")) {
      final id = cardId ?? (paymentMethod.startsWith("Card ") ? paymentMethod.substring(5) : null);
      if (id != null) {
        final cardIdx = _cards.indexWhere((c) => c.id == id);
        if (cardIdx != -1) {
          if (_cards[cardIdx].balance < total) {
            throw Exception('insufficient_funds');
          }
          _cards[cardIdx] = _cards[cardIdx].copyWith(balance: _cards[cardIdx].balance - total);
          await _saveCards();
        }
      }
    }
    // Note: Mobile Money and Bank Transfer as paymentMethods (sources) are external, 
    // so they don't deduct from the app's internal balances in this simulation.

    final tx = Transaction(
      id: "TX${DateTime.now().millisecondsSinceEpoch}",
      title: receiverName ?? _mockUsers[receiverId] ?? "User",
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: "-${NumberFormat.simpleCurrency(name: currencyCode).format(total)}",
      numericAmount: netAmount,
      fee: fee,
      isNegative: true,
      category: "Transfer",
      status: (payoutMethod != null && payoutMethod.contains("Bank")) ? "Pending" : "Success",
      type: "send",
      method: payoutMethod ?? "Wallet",
      paymentMethod: paymentMethod,
      purpose: purpose,
      referenceId: receiverId,
      cardId: cardId,
      timestamp: DateTime.now(),
      receiverVerificationStatus: _quickProfiles.where((p) => p.walletId == receiverId).isNotEmpty
          ? _quickProfiles.firstWhere((p) => p.walletId == receiverId).verificationStatus
          : null,
    );
    
    _transactions.insert(0, tx);
    analytics.logTransaction(tx.type, tx.numericAmount, currencyCode);
    
    // Update QuickProfile stats for the recipient
    await _updateQuickProfileStats(
      receiverId, 
      netAmount, 
      payoutMethod ?? "Wallet",
      name: receiverName ?? _mockUsers[receiverId]
    );

    await _saveTransactions();
    await _saveBalance();
    notifyListeners();
    return tx;
  }

  Future<Transaction> processWalletWithdrawal({
    required double amount,
    required double fee,
    required String method,
    required String detail,
    required String provider,
    required String name,
    required String type,
    String? status,
    String? purpose,
  }) async {
    // Security check: Daily limit enforcement
    if (getDailySpent() + amount > dailyLimit) {
      throw Exception('daily_limit_exceeded');
    }

    final total = amount + fee;
    if (_balance < total) {
      throw Exception('insufficient_funds');
    }

    _balance -= total;

    final tx = Transaction(
      id: "TX${DateTime.now().millisecondsSinceEpoch}",
      title: name,
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: "-${NumberFormat.simpleCurrency(name: _currencyCode).format(total)}",
      numericAmount: amount,
      fee: fee,
      isNegative: true,
      category: "Transfer",
      status: status ?? "Success",
      type: "withdraw",
      method: method,
      purpose: purpose,
      referenceId: detail,
    );

    _transactions.insert(0, tx);
    analytics.logTransaction(tx.type, tx.numericAmount, _currencyCode);
    
    // Update QuickProfile stats
    await _updateQuickProfileStats(
      detail, 
      amount, 
      method,
      name: name
    );

    await _saveBalance();
    await _saveTransactions();
    notifyListeners();
    return tx;
  }

  Future<Transaction> processCardWithdrawal({
    required String cardId,
    required double amount,
    required double fee,
    required String method,
    required String detail,
    required String provider,
    required String name,
    required String type,
    String? status,
    String? purpose,
  }) async {
    final total = amount + fee;
    final cardIdx = _cards.indexWhere((c) => c.id == cardId);
    if (cardIdx == -1) {
      throw Exception('card_not_found');
    }
    if (_cards[cardIdx].balance < total) {
      throw Exception('insufficient_funds');
    }

    _cards[cardIdx] = _cards[cardIdx].copyWith(balance: _cards[cardIdx].balance - total);

    final tx = Transaction(
      id: "TX-CARD-${DateTime.now().millisecondsSinceEpoch}",
      title: name,
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: "-${NumberFormat.simpleCurrency(name: _currencyCode).format(total)}",
      numericAmount: total,
      fee: fee,
      isNegative: true,
      category: "Withdraw",
      status: status ?? "Success",
      type: "withdraw",
      method: "Virtual Card",
      purpose: purpose ?? "Withdrawal",
      cardId: cardId,
      referenceId: detail,
    );
    
    _transactions.insert(0, tx);
    analytics.logTransaction(tx.type, tx.numericAmount, _currencyCode);
    await _saveTransactions();
    await _saveCards();
    notifyListeners();
    return tx;
  }

  Future<void> createMoneyRequest({
    required double amount,
    required String receiverName,
    required String receiverId,
    String? note,
    bool isSplit = false,
    int? splitCount,
  }) async {
    final tx = Transaction(
      id: "REQ-${DateTime.now().millisecondsSinceEpoch}",
      title: isSplit ? "Split Request ($splitCount people)" : "Request to $receiverName",
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: NumberFormat.simpleCurrency(name: _currencyCode).format(amount),
      numericAmount: amount,
      isNegative: false,
      category: "Request",
      status: "Pending",
      type: "request_out",
      purpose: note,
      referenceId: receiverId,
      timestamp: DateTime.now(),
    );

    _transactions.insert(0, tx);
    analytics.logTransaction(tx.type, tx.numericAmount, _currencyCode);
    await _saveTransactions();
    notifyListeners();
  }

  Future<Transaction> processBillPayment({
    required String category,
    required String accountId,
    required double amount,
    required String l10nKey,
    String? paymentMethod,
    String? cardId,
  }) async {
    final method = paymentMethod ?? "Main Wallet";
    if (method == "Savings Account") {
      throw Exception('Savings accounts cannot be used for bill payments');
    }
    final fee = calculateFeeForSource(amount, method, cardId: cardId);
    final total = amount + fee;
    
    if (!hasSufficientBalanceForSource(amount, method, cardId: cardId)) {
      throw Exception('insufficient_funds');
    }

    if (method == "Main Wallet" || method == "Murtaax Wallet") {
      _balance -= total;
      await _saveBalance();
    } else if (cardId != null) {
      final cardIdx = _cards.indexWhere((c) => c.id == cardId);
      if (cardIdx != -1) {
        _cards[cardIdx] = _cards[cardIdx].copyWith(balance: _cards[cardIdx].balance - total);
        await _saveCards();
      }
    }
      
    final tx = Transaction(
      id: "TX-BILL-${DateTime.now().millisecondsSinceEpoch}",
      title: category,
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: "-${NumberFormat.simpleCurrency(name: _currencyCode).format(total)}",
      numericAmount: amount,
      fee: fee,
      isNegative: true,
      category: "Bills",
      status: "Success",
      type: "payment",
      method: method,
      referenceId: "BILL-$accountId",
    );
    
    _transactions.insert(0, tx);
    analytics.logTransaction(tx.type, tx.numericAmount, _currencyCode);
    await _saveTransactions();
    notifyListeners();
    return tx;
  }

  void addBalance(double amount) {
    _balance += amount;
    _saveBalance();
    notifyListeners();
  }

  Future<void> addCard(VirtualCard card) async {
    _cards.add(card);
    // Initialize default PIN for the new card
    const defaultPin = '0000';
    _cardPins[card.id] = defaultPin;
    await _secureStorage.write(key: 'card_pin_${card.id}', value: defaultPin);
    analytics.logEvent('card_created', parameters: {
      'card_id': card.id,
      'network': card.network.toString(),
      'theme': card.theme.toString(),
    });
    await _saveCards();
    notifyListeners();
  }

  Future<void> updateCard(dynamic indexOrCard, [VirtualCard? card]) async {
    if (indexOrCard is int && card != null) {
      if (indexOrCard >= 0 && indexOrCard < _cards.length) {
        _cards[indexOrCard] = card;
      }
    } else if (indexOrCard is VirtualCard) {
      final index = _cards.indexWhere((c) => c.id == indexOrCard.id);
      if (index != -1) {
        _cards[index] = indexOrCard;
      }
    }
    await _saveCards();
    notifyListeners();
  }

  Future<void> removeCard(dynamic idOrIndex) async {
    VirtualCard? cardToRemove;
    if (idOrIndex is int) {
      if (idOrIndex >= 0 && idOrIndex < _cards.length) {
        cardToRemove = _cards.removeAt(idOrIndex);
      }
    } else if (idOrIndex is String) {
      final idx = _cards.indexWhere((c) => c.id == idOrIndex);
      if (idx != -1) {
        cardToRemove = _cards.removeAt(idx);
      }
    }

    if (cardToRemove != null) {
      _terminatedCards.add(cardToRemove);
      analytics.logEvent('card_terminated', parameters: {'card_id': cardToRemove.id});
      await _saveCards();
      await _saveTerminatedCards();
      notifyListeners();
    }
  }

  Future<void> restoreCard(String cardId) async {
    final index = _terminatedCards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      final card = _terminatedCards.removeAt(index);
      _cards.add(card);
      analytics.logEvent('card_restored', parameters: {'card_id': cardId});
      await _saveCards();
      notifyListeners();
    }
  }

  Future<void> addCardBalance(String cardId, double amount) async {
    if (_balance < amount) {
      throw Exception('insufficient_funds');
    }
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      _balance -= amount;
      _cards[index] = _cards[index].copyWith(balance: _cards[index].balance + amount);
      analytics.logEvent('card_balance_added', parameters: {
        'card_id': cardId,
        'amount': amount,
      });
      await _saveBalance();
      await _saveCards();
      notifyListeners();
    }
  }

  Future<void> deductCardBalance(String cardId, double amount) async {
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      if (_cards[index].balance < amount) {
        throw Exception('insufficient_card_funds');
      }
      _cards[index] = _cards[index].copyWith(balance: _cards[index].balance - amount);
      _balance += amount;
      analytics.logEvent('card_balance_deducted', parameters: {
        'card_id': cardId,
        'amount': amount,
      });
      await _saveBalance();
      await _saveCards();
      notifyListeners();
    }
  }

  Future<void> toggleCardFreeze(String cardId) async {
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      final isFrozen = !_cards[index].isFrozen;
      _cards[index] = _cards[index].copyWith(isFrozen: isFrozen);
      analytics.logEvent('card_freeze_toggled', parameters: {
        'card_id': cardId,
        'is_frozen': isFrozen,
      });
      await _saveCards();
      notifyListeners();
    }
  }

  Future<void> updateCardSettings(String cardId, {
    bool? allowOnline,
    bool? allowInternational,
    bool? allowContactless,
    double? dailyLimit,
  }) async {
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      _cards[index] = _cards[index].copyWith(
        allowOnline: allowOnline,
        allowInternational: allowInternational,
        allowContactless: allowContactless,
        dailyLimit: dailyLimit,
      );
      await _saveCards();
      notifyListeners();
    }
  }

  Future<void> buyCrypto(dynamic assetOrSymbol, double amount, double price) async {
    final String symbol = assetOrSymbol is String ? assetOrSymbol : (assetOrSymbol as dynamic).symbol;
    final total = amount * price;
    if (_balance < total) {
      throw Exception('insufficient_funds');
    }

    _balance -= total;
    _cryptoHoldings[symbol] = (_cryptoHoldings[symbol] ?? 0.0) + amount;
    
    final tx = Transaction(
      id: "CRYPTO-BUY-${DateTime.now().millisecondsSinceEpoch}",
      title: "Buy $symbol",
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: "-${NumberFormat.simpleCurrency(name: _currencyCode).format(total)}",
      numericAmount: total,
      isNegative: true,
      category: "Crypto",
      status: "Success",
      type: "payment",
      purpose: "Bought $amount $symbol @ $price",
    );

    _transactions.insert(0, tx);
    await _saveBalance();
    await _saveCryptoHoldings();
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> sellCrypto(dynamic assetOrSymbol, double amount, double price) async {
    final String symbol = assetOrSymbol is String ? assetOrSymbol : (assetOrSymbol as dynamic).symbol;
    final holding = _cryptoHoldings[symbol] ?? 0.0;
    if (holding < amount) {
      throw Exception('insufficient_crypto_balance');
    }

    final total = amount * price;
    _balance += total;
    _cryptoHoldings[symbol] = holding - amount;
    
    final tx = Transaction(
      id: "CRYPTO-SELL-${DateTime.now().millisecondsSinceEpoch}",
      title: "Sell $symbol",
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: NumberFormat.simpleCurrency(name: _currencyCode).format(total),
      numericAmount: total,
      isNegative: false,
      category: "Crypto",
      status: "Success",
      type: "transfer_in",
      purpose: "Sold $amount $symbol @ $price",
    );

    _transactions.insert(0, tx);
    await _saveBalance();
    await _saveCryptoHoldings();
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> updateRecurringPayment(RecurringPayment payment) async {
    final index = _recurringPayments.indexWhere((p) => p.id == payment.id);
    if (index != -1) {
      _recurringPayments[index] = payment;
      await _saveRecurringPayments();
      notifyListeners();
    }
  }

  Future<void> deleteRecurringPayment(String id) async {
    _recurringPayments.removeWhere((p) => p.id == id);
    await _saveRecurringPayments();
    notifyListeners();
  }

  Future<void> toggleRecurringPayment(String id) async {
    final index = _recurringPayments.indexWhere((p) => p.id == id);
    if (index != -1) {
      _recurringPayments[index] = _recurringPayments[index].copyWith(
        isActive: !_recurringPayments[index].isActive,
      );
      await _saveRecurringPayments();
      notifyListeners();
    }
  }

  Future<void> processRecurringPayment(String id) async {
    final index = _recurringPayments.indexWhere((p) => p.id == id);
    if (index == -1) {
      return;
    }

    final payment = _recurringPayments[index];
    if (!payment.isActive || payment.status != RecurringStatus.active) {
      return;
    }

    // Deduct from card balance if cardId is present, otherwise main balance
    if (payment.cardId != null) {
      final cardIndex = _cards.indexWhere((c) => c.id == payment.cardId);
      if (cardIndex != -1) {
        final card = _cards[cardIndex];
        if (card.isFrozen) {
          throw Exception('Card is frozen');
        }
        if (card.balance < payment.amount) {
          throw Exception('Insufficient card funds');
        }
        
        _cards[cardIndex] = card.copyWith(balance: card.balance - payment.amount);
        await _saveCards();
      } else {
        throw Exception('Linked card not found');
      }
    } else {
      if (_balance < payment.amount) {
        throw Exception('insufficient_funds');
      }
      _balance -= payment.amount;
      await _saveBalance();
    }

    // Create Transaction
    final tx = Transaction(
      id: "TX-REC-${DateTime.now().millisecondsSinceEpoch}",
      title: "Recurring: ${payment.title}",
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: "-${NumberFormat.simpleCurrency(name: _currencyCode).format(payment.amount)}",
      numericAmount: payment.amount,
      isNegative: true,
      category: payment.category,
      status: "Success",
      type: "transfer_out",
      cardId: payment.cardId,
      purpose: "Automatic payment to ${payment.receiverName}",
    );

    _transactions.insert(0, tx);
    analytics.logTransaction(tx.type, tx.numericAmount, _currencyCode);
    await _saveTransactions();

    // Update next payment date based on frequency
    DateTime nextDate = payment.nextPaymentDate ?? DateTime.now();
    if (payment.frequency == RecurringFrequency.weekly) {
      nextDate = nextDate.add(const Duration(days: 7));
    } else if (payment.frequency == RecurringFrequency.monthly) {
      nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
    } else if (payment.frequency == RecurringFrequency.quarterly) {
      nextDate = DateTime(nextDate.year, nextDate.month + 3, nextDate.day);
    }

    _recurringPayments[index] = payment.copyWith(
      lastExecution: DateTime.now(),
      nextPaymentDate: nextDate,
    );
    
    await _saveRecurringPayments();
    notifyListeners();
  }

  Future<void> approveMoneyRequest(String requestId) async {
    final index = _transactions.indexWhere((tx) => tx.id == requestId);
    if (index != -1) {
      final request = _transactions[index];
      if (_balance < request.numericAmount) {
        throw Exception('insufficient_funds');
      }

      _balance -= request.numericAmount;
      _transactions[index] = request.copyWith(status: "Success");
      
      final tx = Transaction(
        id: "TX-REQ-APP-${DateTime.now().millisecondsSinceEpoch}",
        title: "Paid Request: ${request.title}",
        date: DateFormat('MMM dd').format(DateTime.now()),
        amount: "-${NumberFormat.simpleCurrency(name: _currencyCode).format(request.numericAmount)}",
        numericAmount: request.numericAmount,
        isNegative: true,
        category: "Transfer",
        status: "Success",
        type: "send",
      );
      _transactions.insert(0, tx);
      analytics.logTransaction(tx.type, tx.numericAmount, _currencyCode);
      
      await _saveBalance();
      await _saveTransactions();
      notifyListeners();
    }
  }

  Future<Transaction?> sendMoney(dynamic dataOrAmount, [String? receiverId, String? name, String? paymentMethod, String? cardId, String? payoutMethod, String? purpose]) async {
    if (dataOrAmount is Map<String, dynamic>) {
      return await processP2PTransfer(
        receiverId: dataOrAmount['receiverId'] ?? dataOrAmount['walletId'] ?? '',
        amount: (dataOrAmount['amount'] as num).toDouble(),
        currencyCode: dataOrAmount['currency'] ?? _currencyCode,
        purpose: dataOrAmount['purpose'] ?? 'Transfer',
        paymentMethod: dataOrAmount['paymentMethod'] ?? 'Main Wallet',
        payoutMethod: dataOrAmount['payoutMethod'],
        receiverName: dataOrAmount['receiverName'],
        cardId: dataOrAmount['cardId'],
      );
    } else if (dataOrAmount is num && receiverId != null) {
      return await processP2PTransfer(
        receiverId: receiverId,
        amount: dataOrAmount.toDouble(),
        currencyCode: _currencyCode,
        purpose: purpose ?? 'Transfer',
        paymentMethod: paymentMethod ?? 'Main Wallet',
        receiverName: name,
        cardId: cardId,
        payoutMethod: payoutMethod,
      );
    }
    return null;
  }

  Future<void> updateDailyLimit(double limit) async {
    _userDailyLimit = limit;
    await _prefs.setDouble('daily_limit', limit);
    notifyListeners();
  }

  Future<void> updateMonthlyLimit(double limit) async {
    _userMonthlyLimit = limit;
    await _prefs.setDouble('monthly_limit', limit);
    notifyListeners();
  }

  double getDailySpent() {
    return _transactions
        .where((tx) =>
            tx.isNegative &&
            tx.timestamp.day == DateTime.now().day &&
            tx.timestamp.month == DateTime.now().month &&
            tx.timestamp.year == DateTime.now().year)
        .fold(0.0, (sum, tx) => sum + tx.numericAmount);
  }

  double getMonthlySpent() {
    return _transactions
        .where((tx) =>
            tx.isNegative &&
            tx.timestamp.month == DateTime.now().month &&
            tx.timestamp.year == DateTime.now().year)
        .fold(0.0, (sum, tx) => sum + tx.numericAmount);
  }

  double getExchangeRate(String from, String to) {
    return convertAmount(1.0, from, to);
  }

  double getFeeRate(String method) {
    return calculateFeeForSource(100.0, method) / 100.0;
  }

  bool hasSufficientBalance(double amount, [String source = 'Main Wallet']) {
    return hasSufficientBalanceForSource(amount, source);
  }

  double calculateTotalForSource(double amount, String source, {String? payoutMethod}) {
    return calculateTotal(amount, paymentMethod: source, payoutMethod: payoutMethod);
  }

  void deductBalance(double amount) {
    _balance -= amount;
    _saveBalance();
    notifyListeners();
  }
}
