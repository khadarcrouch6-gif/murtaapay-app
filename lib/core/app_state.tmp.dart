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
import 'models/crypto_asset.dart';
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

  double _balance = 12450.80;
  double get balance => _balance;

  String _userName = "Mohamed Osman";
  String get userName => _userName;

  String _userEmail = "mohamed.osman@example.com";
  String get userEmail => _userEmail;

  String _userPhone = "+252 615 123 456";
  String get userPhone => _userPhone;

  void updateProfile({String? name, String? email, String? phone}) {
    if (name != null) _userName = name;
    if (email != null) _userEmail = email;
    if (phone != null) _userPhone = phone;
    notifyListeners();
}

  double _savingsBalance = 0.0;
  double get savingsBalance => _savingsBalance;

  List<QuickProfile> _quickProfiles = [];
  List<QuickProfile> get quickProfiles {
    final sorted = List<QuickProfile>.from(_quickProfiles);
    sorted.sort((a, b) {
      // Sort by transaction count (most frequent)
      int cmp = b.transactionCount.compareTo(a.transactionCount);
      if (cmp != 0) return cmp;
      // Then by last transaction date (most recent)
      if (a.lastTransactionDate == null) return 1;
      if (b.lastTransactionDate == null) return -1;
      return b.lastTransactionDate!.compareTo(a.lastTransactionDate!);
    return sorted;
}

  double get cardBalance => _cards.fold(0.0, (sum, card) => sum + card.balance);

  final String _walletId = '102234';
  String get walletId => _walletId;

  String _pin = '0011'; // Default mock PIN
  
  bool verifyPin(String pin) {
    return _pin == pin;
}

  Future<void> updatePin(String newPin) async {
    _pin = newPin;
    await _secureStorage.write(key: 'user_pin', value: newPin);
    notifyListeners();
}

  bool _biometricEnabled = true;
  bool get biometricEnabled => _biometricEnabled;

  Future<void> setBiometricEnabled(bool enabled) async {
    _biometricEnabled = enabled;
    await _prefs.setBool('biometric_enabled', enabled);
    notifyListeners();
}

  bool verifyCardPin(String pin, {String? cardId}) {
    if (_cards.isEmpty) return false;
    final id = cardId ?? _cards[_selectedCardIndex].id;
    return _cardPins[id] == pin;
}

  Future<void> updateCardPin(String pin, {String? cardId}) async {
    if (_cards.isEmpty) return;
    final id = cardId ?? _cards[_selectedCardIndex].id;
    _cardPins[id] = pin;
    await _secureStorage.write(key: 'card_pin_$id', value: pin);
    notifyListeners();
}

  final String _currencyCode = 'USD';
  String get currencyCode => _currencyCode;

  List<BankAccount> _linkedBanks = [];
  List<BankAccount> get linkedBanks => _linkedBanks;

  List<BankAccount> _savedBeneficiaries = [];
  List<BankAccount> get savedBeneficiaries => _savedBeneficiaries;

  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  List<Transaction> getTransactionsForCard(String cardId) {
    return _transactions.where((tx) => tx.cardId == cardId).toList();
}

  List<Map<String, String>> _recentWithdrawals = [];
  List<Map<String, String>> get recentWithdrawals => _recentWithdrawals;

  List<VirtualCard> _cards = [];
  List<VirtualCard> get cards => _cards;

  Map<String, String> _cardPins = {};

  List<VirtualCard> _terminatedCards = [];
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

  List<NotificationData> _notifications = [];
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
        // In a real scenario, these would also come from the API
        _goldPrice = 74.0 + (math.Random().nextDouble() * 2);
        _silverPrice = 0.90 + (math.Random().nextDouble() * 0.1);
        
        updateNisabValues();
}
      debugPrint("Error updating market rates: $e");
}
}

  void updateNisabValues() {
    // Gold Nisab: 87.48g of Gold
    // Silver Nisab: 612.36g of Silver
    _nisabGold = 87.48 * _goldPrice;
    _nisabSilver = 612.36 * _silverPrice;
    notifyListeners();
}

  bool get hasUrgentCampaigns => _campaigns.any((c) => c.isUrgent);
  bool get hasNewCampaigns => _campaigns.any((c) => c.status == 'new');

  void _loadCampaigns() {
    final List<String>? campaignsJson = _prefs.getStringList('fundraiser_campaigns') ?? _prefs.getStringList('sadaqah_campaigns');
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
          donorAvatars: [
            "https://i.pravatar.cc/150?u=1",
            "https://i.pravatar.cc/150?u=2",
            "https://i.pravatar.cc/150?u=3",
            "https://i.pravatar.cc/150?u=4",
          ],
          partnerLogos: ["GOLIS", "TELESOM", "SOMTEL"],
          recentDonors: [
            Donor(name: 'Axmed M.', amount: 50.0, donatedAt: DateTime.now().subtract(const Duration(minutes: 2))),
            Donor(name: 'Sahra A.', amount: 100.0, donatedAt: DateTime.now().subtract(const Duration(minutes: 5))),
          ],
        ),
        Campaign(
          id: "2",
          title: "Education for All",
          description: "Providing quality education and school supplies to children in need.",
          goalAmount: 15000.0,
          raisedAmount: 13800.0,
          creator: "Charity Foundation",
          icon: Icons.school_rounded,
          imageUrl: "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=2070",
          category: "Education",
          donorCount: 456,
          lastDonationAgo: "15m",
          status: 'ending_soon',
          donorAvatars: [
            "https://i.pravatar.cc/150?u=5",
            "https://i.pravatar.cc/150?u=6",
          ],
          partnerLogos: ["DARASALAM", "OOMAAR"],
          recentDonors: [
            Donor(name: 'Jaamac K.', amount: 20.0, donatedAt: DateTime.now().subtract(const Duration(minutes: 15))),
          ],
        ),
        Campaign(
          id: "3",
          title: "Clean Water Initiative",
          description: "Building sustainable wells to provide clean drinking water to remote villages.",
          goalAmount: 25000.0,
          raisedAmount: 12000.0,
          creator: "Biyo Deeq",
          icon: Icons.water_drop_rounded,
          imageUrl: "https://images.unsplash.com/photo-1519074063912-ad25b57b9d17?q=80&w=1974",
          category: "Health",
          donorCount: 256,
          lastDonationAgo: "2m",
          status: 'new',
          donorAvatars: [
            "https://i.pravatar.cc/150?u=8",
            "https://i.pravatar.cc/150?u=9",
            "https://i.pravatar.cc/150?u=10",
          ],
          partnerLogos: ["INDHA DEERO", "UNICEF"],
          recentDonors: [
            Donor(name: 'Muna H.', amount: 25.0, donatedAt: DateTime.now().subtract(const Duration(minutes: 2))),
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
    String method = paymentMethod ?? "Main Wallet";
    if (method == "Savings Account") {
      throw Exception('Savings accounts cannot be used for bill payments');
}

    // Normalize mobile money methods
    final mobileProviders = ["EVC Plus", "Sahal", "ZAAD Service", "E-Dahab"];
    if (mobileProviders.contains(method)) {
      // Simulation: no internal deduction for external mobile money
      final fee = calculateFeeForSource(amount, method, cardId: cardId);
      final total = amount + fee;
      
      if (!hasSufficientBalanceForSource(amount, method, cardId: cardId)) {
        throw Exception('insufficient_funds');
}
}

    final index = _campaigns.indexWhere((c) => c.id == campaignId);
    if (index == -1) throw Exception('campaign_not_found');

    // Capture state for rollback
    final double originalBalance = _balance;
    final double originalSavingsBalance = _savingsBalance;
    final List<Campaign> originalCampaigns = List.from(_campaigns.map((e) => e.copyWith()));
    final List<Transaction> originalTransactions = List.from(_transactions);
    final List<VirtualCard> originalCards = List.from(_cards.map((e) => e.copyWith()));

    try {
      double fee = 0;
      double total = amount;

      // Deduct from source
      if (method == "Main Wallet" || method == "Murtaax Wallet") {
        fee = calculateFeeForSource(amount, method);
        total = amount + fee;
        _balance -= total;
        await _prefs.setDouble('balance', _balance);
        fee = calculateFeeForSource(amount, "Debit Card", cardId: cardId);
        total = amount + fee;
        final cardIdx = _cards.indexWhere((c) => c.id == cardId);
        if (cardIdx != -1) {
          _cards[cardIdx] = _cards[cardIdx].copyWith(balance: _cards[cardIdx].balance - total);
          await _saveCards();
}
        // External methods like Mobile Money
        fee = calculateFeeForSource(amount, method);
        total = amount + fee;
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
      if (newDonors.length > 5) newDonors.removeLast();

      _campaigns[index] = campaign.copyWith(
        raisedAmount: campaign.raisedAmount + amount,
        donorCount: campaign.donorCount + 1,
        lastDonationAgo: "Just now",
        recentDonors: newDonors,
      );

      if (isRecurring) {
        final recurringPayment = RecurringPayment(
          id: "REC-DON-${DateTime.now().millisecondsSinceEpoch}",
          title: "Recurring Contribution: ${campaign.title}",
          receiverId: campaignId,
          receiverName: campaign.title,
          amount: amount,
          frequency: RecurringFrequency.monthly,
          startDate: DateTime.now(),
          nextPaymentDate: DateTime.now().add(const Duration(days: 30)),
          status: RecurringStatus.active,
          category: "Fundraiser",
          cardId: cardId,
        );
        addRecurringPayment(recurringPayment);
}

      final tx = Transaction(
        id: "TX-FUND-${DateTime.now().millisecondsSinceEpoch}",
        title: "Fundraiser: ${campaign.title}",
        date: DateFormat('MMM dd').format(DateTime.now()),
        amount: "-${NumberFormat.simpleCurrency(name: _currencyCode).format(total)}",
        numericAmount: amount,
        fee: fee,
        isNegative: true,
        category: "Fundraiser",
        status: "Success",
        type: "transfer_out",
        method: "Wallet",
        paymentMethod: method,
        cardId: cardId,
        referenceId: campaignId,
        purpose: message,
      );
      _transactions.insert(0, tx);

      await _saveTransactions();
      _saveCampaigns();
      notifyListeners();
      // Rollback
      _balance = originalBalance;
      _savingsBalance = originalSavingsBalance;
      _campaigns = originalCampaigns;
      _transactions = originalTransactions;
      _cards = originalCards;
      notifyListeners();
      rethrow;
}
}

  void _loadRecurringPayments() {
    final List<String>? paymentsJson = _prefs.getStringList('recurring_payments');
    if (paymentsJson != null) {
      _recurringPayments = paymentsJson.map((e) => RecurringPayment.fromJson(json.decode(e))).toList();
      // Mock initial recurring payments
      _recurringPayments = [
        RecurringPayment(
          id: '1',
          title: "Netflix Subscription",
          receiverId: "netflix.com",
          receiverName: "Netflix",
          amount: 15.99,
          frequency: RecurringFrequency.monthly,
          startDate: DateTime.now().subtract(const Duration(days: 15)),
          nextPaymentDate: DateTime.now().add(const Duration(days: 15)),
          status: RecurringStatus.active,
          category: "Subscriptions",
          cardId: "1",
        ),
        RecurringPayment(
          id: '2',
          title: "Amazon Prime",
          receiverId: "amazon.com",
          receiverName: "Amazon",
          amount: 12.99,
          frequency: RecurringFrequency.monthly,
          startDate: DateTime.now().subtract(const Duration(days: 5)),
          nextPaymentDate: DateTime.now().add(const Duration(days: 25)),
          status: RecurringStatus.active,
          category: "Subscriptions",
          cardId: "1",
        ),
        RecurringPayment(
          id: '3',
          title: "Family Support (Hooyo)",
          receiverId: "615123456",
          receiverName: "Hooyo",
          amount: 200.0,
          frequency: RecurringFrequency.monthly,
          startDate: DateTime.now().subtract(const Duration(days: 15)),
          nextPaymentDate: DateTime.now().add(const Duration(days: 15)),
          status: RecurringStatus.active,
          category: "Transfer",
        ),
      ];
      _saveRecurringPayments();
}
}

  void _saveRecurringPayments() {
    final List<String> paymentsJson = _recurringPayments.map((e) => json.encode(e.toJson())).toList();
    _prefs.setStringList('recurring_payments', paymentsJson);
}

  void addRecurringPayment(RecurringPayment payment) {
    _recurringPayments.add(payment);
    _saveRecurringPayments();
    notifyListeners();
}

  void updateRecurringPayment(int index, RecurringPayment payment) {
    _recurringPayments[index] = payment;
    _saveRecurringPayments();
    notifyListeners();
}

  void deleteRecurringPayment(int index) {
    _recurringPayments.removeAt(index);
    _saveRecurringPayments();
    notifyListeners();
}

  Future<void> processRecurringPayment(String paymentId) async {
    final index = _recurringPayments.indexWhere((p) => p.id == paymentId);
    if (index == -1) throw Exception('payment_not_found');

    final payment = _recurringPayments[index];
    if (_balance < payment.amount) throw Exception('insufficient_funds');

    // Capture state for rollback
    final double originalBalance = _balance;
    final List<Transaction> originalTransactions = List.from(_transactions);
    final List<RecurringPayment> originalPayments = List.from(_recurringPayments.map((e) => e.copyWith()));

    try {
      _balance -= payment.amount;
      
      // Update next payment date (simplified: add 30 days)
      final updatedPayment = payment.copyWith(
        nextPaymentDate: payment.nextPaymentDate?.add(const Duration(days: 30)),
      );
      _recurringPayments[index] = updatedPayment;

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
        method: "Wallet",
        referenceId: paymentId,
      );
      _transactions.insert(0, tx);

      await _prefs.setDouble('balance', _balance);
      await _saveTransactions();
      _saveRecurringPayments();
      notifyListeners();
      // Rollback
      _balance = originalBalance;
      _transactions = originalTransactions;
      _recurringPayments = originalPayments;
      notifyListeners();
      rethrow;
}
}

  void _loadHagbadGroups() {
    final List<String>? groupsJson = _prefs.getStringList('hagbad_groups');
    if (groupsJson != null) {
      _hagbadGroups = groupsJson.map((e) => HagbadGroup.fromJson(json.decode(e))).toList();
      // Mock initial group
      _hagbadGroups = [
        HagbadGroup(
          id: '1',
          name: "Qoyska & Asxaabta",
          adminName: "Khadar Abdi",
          amount: 50.0,
          frequency: HagbadFrequency.monthly,
          status: HagbadStatus.active,
          startDate: DateTime.now().subtract(const Duration(days: 45)),
          totalCycles: 12,
          currentCycle: 3,
          members: [
            HagbadMember(name: "Khadar", paidAmount: 150.0, hasReceived: true, isTrusted: true, avatar: "K", payoutOrder: 1, isConfirmed: true, hasSignedOath: true),
            HagbadMember(name: "Ahmed", paidAmount: 150.0, hasReceived: false, isTrusted: true, avatar: "A", payoutOrder: 2, isConfirmed: true, hasSignedOath: true),
            HagbadMember(name: "Fardowsa", paidAmount: 100.0, hasReceived: false, isTrusted: false, avatar: "F", payoutOrder: 3, guarantorName: "Khadar Abdi", isConfirmed: true),
            HagbadMember(name: "Mustafe", paidAmount: 100.0, hasReceived: false, isTrusted: true, avatar: "M", payoutOrder: 4, isConfirmed: false),
          ],
        ),
      ];
      _saveHagbadGroups();
}
}

  void _saveHagbadGroups() {
    final List<String> groupsJson = _hagbadGroups.map((e) => json.encode(e.toJson())).toList();
    _prefs.setStringList('hagbad_groups', groupsJson);
}

  void createHagbadGroup(HagbadGroup group) {
    _hagbadGroups.add(group);
    _saveHagbadGroups();
    
    // Notify all invited members via simulated SMS
    for (var member in group.members) {
      if (member.name != "Me" && member.walletId != null) {
        sendHagbadNotification(
          member.walletId!, 
          "You have been invited to join the new Hagbad group '${group.name}' by ${group.adminName}.",
          isSms: true,
        );
}
}

    notifyListeners();
}

  void deleteHagbadGroup(String groupId) {
    _hagbadGroups.removeWhere((g) => g.id == groupId);
    _saveHagbadGroups();
    logHagbadEvent(groupId, "Group deleted by admin");
    notifyListeners();
}

  void removeHagbadMember(String groupId, int memberIndex) {
    final gIdx = _hagbadGroups.indexWhere((g) => g.id == groupId);
    if (gIdx != -1) {
      final group = _hagbadGroups[gIdx];
      final member = group.members[memberIndex];
      
      final updatedMembers = List<HagbadMember>.from(group.members);
      updatedMembers.removeAt(memberIndex);
      
      // Update order for remaining members if needed
      for (int i = 0; i < updatedMembers.length; i++) {
        updatedMembers[i] = updatedMembers[i].copyWith(payoutOrder: i + 1);
}

      _hagbadGroups[gIdx] = group.copyWith(
        members: updatedMembers,
        totalCycles: updatedMembers.length,
      );
      
      _saveHagbadGroups();
      logHagbadEvent(groupId, "Member removed: ${member.name}");
      notifyListeners();
}
}

  void updateHagbadMember(String groupId, int memberIndex, HagbadMember member) {
    final gIdx = _hagbadGroups.indexWhere((g) => g.id == groupId);
    if (gIdx != -1) {
      final updatedMembers = List<HagbadMember>.from(_hagbadGroups[gIdx].members);
      updatedMembers[memberIndex] = member;
      _hagbadGroups[gIdx] = _hagbadGroups[gIdx].copyWith(members: updatedMembers);
      _saveHagbadGroups();
      notifyListeners();
}
}

  Future<void> addHagbadMember(String groupId, HagbadMember member, {double catchUpAmount = 0}) async {
    final gIdx = _hagbadGroups.indexWhere((g) => g.id == groupId);
    if (gIdx == -1) return;

    final group = _hagbadGroups[gIdx];
    
    // Capture state for rollback
    final double originalBalance = _balance;
    final List<HagbadGroup> originalGroups = List.from(_hagbadGroups.map((e) => e.copyWith()));
    final List<Transaction> originalTransactions = List.from(_transactions);

    try {
      if (catchUpAmount > 0) {
        if (_balance < catchUpAmount) throw Exception('insufficient_funds');
        _balance -= catchUpAmount;
        await _prefs.setDouble('balance', _balance);
        
      final tx = Transaction(
          id: "TX-HAG-CATCHUP-${DateTime.now().millisecondsSinceEpoch}",
          title: "Hagbad Catch-up: ${group.name}",
          purpose: "For ${member.name}",
          date: DateFormat('MMM dd').format(DateTime.now()),
          amount: "-${NumberFormat.simpleCurrency(name: _currencyCode).format(catchUpAmount)}",
          numericAmount: catchUpAmount,
          isNegative: true,
          category: "Hagbad",
          status: "Success",
          type: "transfer_out",
          method: "Wallet",
          referenceId: groupId,
        );
        _transactions.insert(0, tx);
        await _saveTransactions();
}

      final updatedMembers = List<HagbadMember>.from(group.members)..add(member);
      _hagbadGroups[gIdx] = group.copyWith(
        members: updatedMembers,
        totalCycles: updatedMembers.length,
      );
      _saveHagbadGroups();
      logHagbadEvent(groupId, "New member added: ${member.name}${catchUpAmount > 0 ? ' with catch-up payment of \$$catchUpAmount' : ''}");
      
      if (member.walletId != null) {
        sendHagbadNotification(
          member.walletId!, 
          "You have been invited to join the '${group.name}' Hagbad group by ${group.adminName}.",
          isSms: true,
        );
}

      notifyListeners();
      _balance = originalBalance;
      _hagbadGroups = originalGroups;
      _transactions = originalTransactions;
      notifyListeners();
      rethrow;
}
}

  Future<void> logHagbadEvent(String groupId, String event) async {
    final tx = Transaction(
      id: "TX-EVENT-${DateTime.now().millisecondsSinceEpoch}",
      title: event,
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: "EVENT",
      numericAmount: 0,
      isNegative: false,
      category: "Hagbad",
      status: "Info",
      type: "event",
      method: "System",
      referenceId: groupId,
    );
    _transactions.insert(0, tx);

    await _saveTransactions();
    notifyListeners();
}

  Future<void> sendHagbadNotification(String walletId, String message, {bool isSms = false}) async {
    // In a real app, this would call an API or Firebase Cloud Functions
    // For this simulation, we log it and could potentially add to a notification list
    debugPrint("Hagbad Notification [${isSms ? 'SMS' : 'App'}]: To $walletId - $message");
    
    // Simulate system message if the user exists in our mock system
    final tx = Transaction(
      id: "TX-NOTIF-${DateTime.now().millisecondsSinceEpoch}",
      title: isSms ? "SMS Sent to $walletId" : "Notification Sent",
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: "NOTIF",
      numericAmount: 0,
      isNegative: false,
      category: "System",
      status: "Success",
      type: "notification",
      method: isSms ? "SMS" : "Push",
      purpose: message,
    );
    _transactions.insert(0, tx);

    await _saveTransactions();
    notifyListeners();
}

  void randomizeHagbadTurns(String groupId) {
    final gIdx = _hagbadGroups.indexWhere((g) => g.id == groupId);
    if (gIdx != -1) {
      final group = _hagbadGroups[gIdx];
      final members = List<HagbadMember>.from(group.members);
      
      // Filter out members who have already received their payout
      final received = members.where((m) => m.hasReceived).toList();
      final remaining = members.where((m) => !m.hasReceived).toList();
      
      // Ensure all members are confirmed before allowing Qori-tuur for group start
      if (group.status == HagbadStatus.pending && members.any((m) => !m.isConfirmed)) {
         return; // Safety check
}

      remaining.shuffle();
      
      for (int i = 0; i < remaining.length; i++) {
        int mIdx = members.indexWhere((m) => m.name == remaining[i].name && m.walletId == remaining[i].walletId);
        if (mIdx != -1) {
          members[mIdx] = members[mIdx].copyWith(payoutOrder: received.length + i + 1);
}
}
      
      members.sort((a, b) => a.payoutOrder.compareTo(b.payoutOrder));
      _hagbadGroups[gIdx] = group.copyWith(
        members: members,
        status: group.status == HagbadStatus.pending ? HagbadStatus.active : group.status,
      );
      _saveHagbadGroups();
      logHagbadEvent(groupId, "Qori-tuur: Randomized remaining ${remaining.length} turns.");
      notifyListeners();
}
}

  void swapHagbadTurns(String groupId, int index1, int index2) {
    final gIdx = _hagbadGroups.indexWhere((g) => g.id == groupId);
    if (gIdx != -1) {
      final members = List<HagbadMember>.from(_hagbadGroups[gIdx].members);
      if (index1 >= 0 && index1 < members.length && index2 >= 0 && index2 < members.length) {
        final order1 = members[index1].payoutOrder;
        final order2 = members[index2].payoutOrder;

        members[index1] = members[index1].copyWith(payoutOrder: order2);
        members[index2] = members[index2].copyWith(payoutOrder: order1);

        members.sort((a, b) => a.payoutOrder.compareTo(b.payoutOrder));
        _hagbadGroups[gIdx] = _hagbadGroups[gIdx].copyWith(members: members);
        _saveHagbadGroups();
        logHagbadEvent(groupId, "Turns swapped between ${members.firstWhere((m) => m.payoutOrder == order2).name} and ${members.firstWhere((m) => m.payoutOrder == order1).name}");
        notifyListeners();
}
}
}

  Future<void> payHagbad(String groupId, int memberIndex, double amount) async {
    final gIdx = _hagbadGroups.indexWhere((g) => g.id == groupId);
    if (gIdx == -1) return;

    if (_balance < amount) throw Exception('insufficient_funds');

    // Capture state for rollback
    final double originalBalance = _balance;
    final List<HagbadGroup> originalGroups = List.from(_hagbadGroups.map((e) => e.copyWith()));
    final List<Transaction> originalTransactions = List.from(_transactions);

    try {
      _balance -= amount;
      final group = _hagbadGroups[gIdx];
      final updatedMembers = List<HagbadMember>.from(group.members);
      final member = updatedMembers[memberIndex];
      
      updatedMembers[memberIndex] = member.copyWith(
        paidAmount: member.paidAmount + amount,
        lastPaymentDate: DateTime.now(),
      );
      
      _hagbadGroups[gIdx] = group.copyWith(members: updatedMembers);

      final tx = Transaction(
        id: "TX-HAG-${DateTime.now().millisecondsSinceEpoch}",
        title: "Hagbad: ${group.name}",
        date: DateFormat('MMM dd').format(DateTime.now()),
        amount: "-${NumberFormat.simpleCurrency(name: _currencyCode).format(amount)}",
        numericAmount: amount,
        isNegative: true,
        category: "Hagbad",
        status: "Success",
        type: "transfer_out",
        method: "Wallet",
        paymentMethod: "Main Wallet",
        referenceId: groupId,
        purpose: "Contribution by ${member.name}",
      );
      _transactions.insert(0, tx);

      await _prefs.setDouble('balance', _balance);
      await _saveTransactions();
      _saveHagbadGroups();
      
      logHagbadEvent(groupId, "Payment of \$${amount.toStringAsFixed(2)} by ${member.name}");
      notifyListeners();
      // Rollback
      _balance = originalBalance;
      _hagbadGroups = originalGroups;
      _transactions = originalTransactions;
      notifyListeners();
      rethrow;
}
}

  Future<void> processHagbadPayout(String groupId) async {
    final gIdx = _hagbadGroups.indexWhere((g) => g.id == groupId);
    if (gIdx == -1) return;

    final group = _hagbadGroups[gIdx];
    final currentOrder = group.currentCycle;
    final mIdx = group.members.indexWhere((m) => m.payoutOrder == currentOrder);

    if (mIdx == -1) throw Exception('Member for current turn not found');

    final member = group.members[mIdx];
    if (member.hasReceived) throw Exception('Payout already received for this turn');

    // Ensure the pool has enough funds (currentBalance must cover all payouts including this one)
    // For simplicity, we check if the current balance is at least the payout amount 
    // In a real Hagbad, everyone in the current cycle must have paid.
    if (group.currentBalance < group.totalPayout * group.currentCycle / group.totalCycles && group.currentBalance < group.totalPayout) {
       // This is a bit complex due to cumulative paidAmount. 
       // Simpler check: Does the pool have enough for at least one payout?
       // Let's use: Available = currentBalance - (already paid out)
       double alreadyPaidOut = (group.currentCycle - 1) * group.totalPayout;
       double available = group.currentBalance - alreadyPaidOut;
       if (available < group.totalPayout) {
         throw Exception('Insufficient funds in Hagbad pool. All members must contribute for this cycle first.');
}
}

    // Calculate total payout (amount * members)
    // We add any extra funds in the pool (penalties) to the payout for this cycle
    final totalPool = group.currentBalance;
    final alreadyPaidOut = (group.currentCycle - 1) * group.totalPayout;
    
    // Recipient gets the standard amount + any surplus in the pool (penalties)
    // If it's the last cycle, they get everything left.
    double payoutAmount;
    double surplus = 0;
    
    if (group.currentCycle == group.totalCycles) {
      payoutAmount = totalPool - alreadyPaidOut;
      surplus = payoutAmount - group.totalPayout;
      payoutAmount = group.totalPayout;
      // In this system, penalties stay in the pool until the final cycle 
      // or can be distributed. Let's stick to final cycle distribution for simplicity
      // and fairness, unless we want to distribute "Baraka" (blessings/surplus) early.
}
    
    payoutAmount -= group.serviceFee;

    // Start Transaction
    final double originalBalance = _balance;
    final List<HagbadGroup> originalGroups = List.from(_hagbadGroups.map((e) => e.copyWith()));
    final List<Transaction> originalTransactions = List.from(_transactions);

    try {
      final updatedMembers = List<HagbadMember>.from(group.members);
      updatedMembers[mIdx] = member.copyWith(hasReceived: true);

      // If it's "Me", update balance
      if (member.name == "Me" || member.name == "Khadar" || (member.walletId != null && member.walletId == _walletId)) {
        _balance += payoutAmount;
        await _prefs.setDouble('balance', _balance);
}

      final tx = Transaction(
        id: "TX-PAYOUT-${DateTime.now().millisecondsSinceEpoch}",
        title: "Hagbad Payout: ${group.name}",
        date: DateFormat('MMM dd').format(DateTime.now()),
        amount: "+${NumberFormat.simpleCurrency(name: _currencyCode).format(payoutAmount)}",
        numericAmount: payoutAmount,
        fee: group.serviceFee,
        isNegative: false,
        category: "Hagbad",
        status: "Success",
        type: "payout",
        method: "Wallet",
        paymentMethod: "Hagbad Pool",
        referenceId: groupId,
        purpose: "Recipient: ${member.name}${surplus > 0 ? ' (Includes \$${surplus.toStringAsFixed(2)} surplus)' : ''}",
      );
      _transactions.insert(0, tx);

      // Progress cycle if not last
      int nextCycle = group.currentCycle;
      HagbadStatus nextStatus = group.status;
      if (group.currentCycle < group.totalCycles) {
        nextCycle++;
        nextStatus = HagbadStatus.completed;
}

      _hagbadGroups[gIdx] = group.copyWith(
        members: updatedMembers,
        currentCycle: nextCycle,
        status: nextStatus,
      );

      await _saveTransactions();
      _saveHagbadGroups();
      
      logHagbadEvent(groupId, "Payout of \$${payoutAmount.toStringAsFixed(2)} to ${member.name}${surplus > 0 ? ' (incl. surplus)' : ''}");
      
      if (member.walletId != null) {
        sendHagbadNotification(
          member.walletId!, 
          "Your Hagbad payout of \$${payoutAmount.toStringAsFixed(2)} for '${group.name}' has been processed.",
          isSms: true,
        );
}

      notifyListeners();
      _balance = originalBalance;
      _hagbadGroups = originalGroups;
      _transactions = originalTransactions;
      notifyListeners();
      rethrow;
}
}

  Future<void> _loadCryptoHoldings() async {
    final String? cryptoJson = _prefs.getString('crypto_holdings');
    if (cryptoJson != null) {
      final Map<String, dynamic> decoded = json.decode(cryptoJson);
      _cryptoHoldings = decoded.map((key, value) => MapEntry(key, value.toDouble()));
      // Mock initial holdings
      _cryptoHoldings = {
        'BTC': 0.45,
        'ETH': 2.5,
      await _saveCryptoHoldings();
}
}

  Future<void> _saveCryptoHoldings() async {
    await _prefs.setString('crypto_holdings', json.encode(_cryptoHoldings));
}

  Future<void> _loadCards() async {
    final List<String>? cardsJson = _prefs.getStringList('virtual_cards');
    if (cardsJson != null) {
      _cards = cardsJson.map((e) => VirtualCard.fromJson(json.decode(e))).toList();
      // Enforce limit of 2 cards
      if (_cards.length > 2) {
        _cards = _cards.sublist(0, 2);
        await _saveCards();
}
      _cards = [
        VirtualCard(
          id: "1",
          cardNumber: "4580123456789012",
          cardHolder: "KHADAR RAYAALE",
          expiryDate: "12/28",
          cvv: "455",
          theme: CardThemeType.obsidian,
          network: CardNetwork.visa,
          balance: 850.50,
        ),
        VirtualCard(
          id: "2",
          cardNumber: "5241987654321098",
          cardHolder: "KHADAR RAYAALE",
          expiryDate: "05/30",
          cvv: "822",
          theme: CardThemeType.gold,
          network: CardNetwork.mastercard,
          balance: 150.0,
        ),
      ];
      await _saveCards();
}
    
    final List<String>? terminatedJson = _prefs.getStringList('terminated_cards');
    if (terminatedJson != null) {
      _terminatedCards = terminatedJson.map((e) => VirtualCard.fromJson(json.decode(e))).toList();
}
}

  Future<void> _saveCards() async {
    final List<String> cardsJson = _cards.map((e) => json.encode(e.toJson())).toList();
    await _prefs.setStringList('virtual_cards', cardsJson);
    
    final List<String> terminatedJson = _terminatedCards.map((e) => json.encode(e.toJson())).toList();
    await _prefs.setStringList('terminated_cards', terminatedJson);
}

  Future<void> updateCard(int index, VirtualCard card) async {
    _cards[index] = card;
    await _saveCards();
    notifyListeners();
}

  Future<void> removeCard(int index) async {
    final card = _cards.removeAt(index);
    // Add to terminated cards with a timestamp (stored in metadata/id if needed, or we just track here)
    // For simplicity, we add it to the grace period list
    _terminatedCards.add(card);
    await _saveCards();
    notifyListeners();
}

  Future<void> restoreCard(String cardId) async {
    final index = _terminatedCards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      final card = _terminatedCards.removeAt(index);
      _cards.add(card);
      await _saveCards();
      notifyListeners();
}
}

  Future<void> addCard(VirtualCard card) async {
    if (_cards.length >= 2) return;
    _cards.add(card);
    await _saveCards();
    notifyListeners();
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

  // Estonian is not RTL, so we can remove or update this check.
  // Arabic was RTL.
  bool get isRtl => _locale.languageCode == 'ar'; 

  int _selectedNavIndex = 0;
  int get selectedNavIndex => _selectedNavIndex;

  int _selectedCardIndex = 0;
  int get selectedCardIndex => _selectedCardIndex;

  void setSelectedCardIndex(int index) {
    _selectedCardIndex = index;
    notifyListeners();
}

  bool _showHomePromo = false;
  bool get showHomePromo => _showHomePromo;

  // Mock users for Wallet ID verification
  final Map<String, String> _mockUsers = {
    '102234': 'Ayaanle Rayaale',
    '102235': 'Fartun Ali',
    '102236': 'Abdirahman Said',
    '102237': 'Hodan Muse',
    '102238': 'Mustafe Gedi',
    '102239': 'Deqa Warsame',
    '102240': 'Guled Omar',
    '102241': 'Nimo Farah',
    '102242': 'Ismail Jibril',
    '102243': 'Zahra Barre',
    '102244': 'Bashir Adan',
    '102245': 'Khadra Ismail',
    '102246': 'Yusuf Duale',
    '102247': 'Hamdi Hassan',
    '102248': 'Idris Salad',
    '102249': 'Maryan Hussein',
    '102250': 'Ali Samatar',
    '204456': 'Mohamed Abdi Ali',
    '309987': 'Sahra Hassan Duale',
    '401122': 'Hassan Mohamud',
    '505566': 'Aminat Yusuf',
    '606677': 'Jama Ahmed',
    '615123456': 'Mohamed Hassan Ali', // EVC Plus mock
    '634987654': 'Ahmed Ismail Hersi', // ZAAD mock
    '615112233': 'Aisha Farah',
    '615445566': 'Omar Dheere',
    // Merchant / Till Numbers
    '889900': 'Somali Electronics Store',
    '776655': 'Bakara Market Wholesale',
    '554433': 'Murtaax Supermarket',
    '221100': 'Hormuud Coffee Shop',

  final Map<String, Map<String, String>> _mockBankAccounts = {
    'IBS Bank': {
      '11223344': 'Mohamed Ali',
      '22334455': 'Fatima Yusuf',
      '33445566': 'Ahmed Salad',
    'Salaam Bank': {
      '1002003004': 'Ayaan Geedi',
      '2003004005': 'Omar Warsame',
      '3004005006': 'Zahra Farah',
    'Premier Bank': {
      '111222333444': 'Mustafe Hassan',
      '222333444555': 'Deqa Omar',
      '333444555666': 'Guled Isse',
    'Dahabshil Bank': {
      '123456789': 'Hassan Ali',
      '987654321': 'Fardowsa Ahmed',
      '456789123': 'Jamac Said',
    'Amal Bank': {
      '5566778899': 'Khadar Abdi',
      '9988776655': 'Muna Ibrahim',
      '1122998877': 'Bile Salad',

  Map<String, String> get mockUsers => _mockUsers;

  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    
    // Load saved theme
    final savedTheme = _prefs.getString('theme_mode') ?? 'light';
    _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;

    // Load saved locale
    final savedLocale = _prefs.getString('language_code') ?? 'en';
    _locale = Locale(savedLocale);

    // Load balance (mock)
    _balance = _prefs.getDouble('balance') ?? 12450.80;
    _savingsBalance = _prefs.getDouble('savings_balance') ?? 520.50;

    // Load all local data in parallel where possible
    _loadRecentWithdrawals();
    _loadQuickProfiles();
    _loadBanks();
    _loadSavedBeneficiaries();
    _loadCards();
    _loadTransactions();
    _loadCryptoHoldings();
    _loadSavingsGoals();
    _loadHagbadGroups();
    _loadRecurringPayments();
    _loadCampaigns();
    
    // Trigger market rates update in background to not block startup
    updateMarketRates();

    // Load secure data
    try {
      final savedPin = await _secureStorage.read(key: 'user_pin');
      if (savedPin != null) {
        _pin = savedPin;
        await _secureStorage.write(key: 'user_pin', value: _pin);
}
      debugPrint("Secure storage not available: $e");
}
    
    _biometricEnabled = _prefs.getBool('biometric_enabled') ?? true;

    // Load card pins
    for (var card in _cards) {
      try {
        final cardPin = await _secureStorage.read(key: 'card_pin_${card.id}');
        if (cardPin != null) {
          _cardPins[card.id] = cardPin;
          // Default pin if not found, and save it
          _cardPins[card.id] = "1122";
          await _secureStorage.write(key: 'card_pin_${card.id}', value: "1122");
}
        _cardPins[card.id] = "1122";
}
}
    
    _userDailyLimit = _prefs.getDouble('daily_limit') ?? 5000.0;
    _userMonthlyLimit = _prefs.getDouble('monthly_limit') ?? 20000.0;

    _isInitialized = true;
    notifyListeners();
}

  void _loadTransactions() {
    final List<String>? txJson = _prefs.getStringList('transactions');
    if (txJson != null) {
      _transactions = txJson.map((e) => Transaction.fromJson(json.decode(e))).toList();
      // Mock initial transactions
      _transactions = [
        Transaction(
          id: "1", 
          title: "Netflix", 
          date: "Oct 24", 
          amount: r"-$15.99", 
          numericAmount: 15.99,
          isNegative: true, 
          category: "Subscriptions", 
          status: "Success", 
          type: "payment",
          cardId: "1"
        ),
        Transaction(
          id: "2", 
          title: "Amazon", 
          date: "Oct 22", 
          amount: r"-$124.50", 
          numericAmount: 124.50,
          isNegative: true, 
          category: "Shopping", 
          status: "Success", 
          type: "payment",
          cardId: "1"
        ),
        Transaction(
          id: "3", 
          title: "Topup", 
          date: "Oct 20", 
          amount: r"+$500.00", 
          numericAmount: 500.0,
          isNegative: false, 
          category: "General", 
          status: "Success", 
          type: "deposit", 
          method: "Wallet"
        ),
        Transaction(
          id: "4", 
          title: "Starbucks", 
          date: "Oct 19", 
          amount: r"-$5.50", 
          numericAmount: 5.50,
          isNegative: true, 
          category: "Food", 
          status: "Success", 
          type: "payment",
          cardId: "2"
        ),
        Transaction(
          id: "5", 
          title: "Apple Music", 
          date: "Oct 18", 
          amount: r"-$9.99", 
          numericAmount: 9.99,
          isNegative: true, 
          category: "Subscriptions", 
          status: "Success", 
          type: "payment",
          cardId: "2"
        ),
        Transaction(
          id: "6", 
          title: "Uber", 
          date: "Oct 17", 
          amount: r"-$25.00", 
          numericAmount: 25.0,
          isNegative: true, 
          category: "Transport", 
          status: "Success", 
          type: "payment",
          cardId: "3"
        ),
        Transaction(
          id: "7", 
          title: "Salary", 
          date: "Oct 15", 
          amount: r"+$2500.00", 
          numericAmount: 2500.0,
          isNegative: false, 
          category: "Income", 
          status: "Success", 
          type: "deposit", 
          method: "Bank"
        ),
        Transaction(
          id: "8", 
          title: "Bank Transfer", 
          date: "Oct 14", 
          amount: r"-$100.00", 
          numericAmount: 100.0,
          isNegative: true, 
          category: "Transfer", 
          status: "Success", 
          type: "withdraw"
        ),
      ];
}
}

  Future<void> addTransaction(Transaction tx) async {
    _transactions.insert(0, tx);

    await _saveTransactions();
    notifyListeners();
}

  void toggleRecurringPayment(String id) {
    final index = _recurringPayments.indexWhere((p) => p.id == id);
    if (index != -1) {
      final payment = _recurringPayments[index];
      _recurringPayments[index] = payment.copyWith(
        status: payment.status == RecurringStatus.active 
            ? RecurringStatus.paused 
            : RecurringStatus.active
      );
      _saveRecurringPayments();
      notifyListeners();
}
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
      // Mock initial goals
      _savingsGoals = [
        SavingsGoal(
          id: "1",
          title: "Hajj Fund",
          soTitle: "Sanduuqa Xajka",
          arTitle: "ØµÙ†Ø¯ÙˆÙ‚ Ø§Ù„Ø­Ø¬",
          deTitle: "Hajj-Fonds",
          saved: 1200.0,
          target: 5000.0,
          deadline: "Dec 2025",
          icon: Icons.mosque_rounded,
          color: const Color(0xFF009688),
          delay: 100,
        ),
        SavingsGoal(
          id: "2",
          title: "New Car",
          soTitle: "Gaadhi Cusub",
          arTitle: "Ø³ÙŠØ§Ø±Ø© Ø¬Ø¯ÙŠØ¯Ø©",
          deTitle: "Neues Auto",
          saved: 4500.0,
          target: 15000.0,
          deadline: "Jun 2026",
          icon: Icons.directions_car_rounded,
          color: const Color(0xFF6366F1),
          delay: 200,
        ),
        SavingsGoal(
          id: "3",
          title: "Emergency Fund",
          soTitle: "Sanduuqa Degdegga",
          arTitle: "ØµÙ†Ø¯ÙˆÙ‚ Ø§Ù„Ø·ÙˆØ§Ø±Ø¦",
          deTitle: "Notfallfonds",
          saved: 850.0,
          target: 2000.0,
          deadline: "Ongoing",
          icon: Icons.health_and_safety_rounded,
          color: const Color(0xFFF43F5E),
          delay: 300,
          isPaused: true,
        ),
      ];
      await _saveSavingsGoals();
}
}

  Future<void> _saveSavingsGoals() async {
    final List<String> goalsJson = _savingsGoals.map((e) => json.encode(e.toJson())).toList();
    await _prefs.setStringList('savings_goals', goalsJson);
}

  Future<void> addSavingsGoal(SavingsGoal goal) async {
    _savingsGoals.add(goal);
    await _saveSavingsGoals();
    notifyListeners();
}

  Future<void> updateSavingsGoal(int index, SavingsGoal goal) async {
    _savingsGoals[index] = goal;
    await _saveSavingsGoals();
    notifyListeners();
}

  Future<void> removeSavingsGoal(int index) async {
    _savingsGoals.removeAt(index);
    await _saveSavingsGoals();
    notifyListeners();
}

  void _loadBanks() {
    final List<String>? banksJson = _prefs.getStringList('linked_banks');
    if (banksJson != null) {
      _linkedBanks = banksJson.map((e) => BankAccount.fromJson(e)).toList();
      // Mock initial banks
      _linkedBanks = [
        BankAccount(id: '1', bankName: 'LHV Pank', accountNumber: '**** 8829'),
        BankAccount(id: '2', bankName: 'Swedbank', accountNumber: '**** 1120'),
      ];
}
}

  void addBank(BankAccount bank) {
    // Prevent duplicates
    if (_linkedBanks.any((b) => b.accountNumber == bank.accountNumber && b.bankName == bank.bankName)) {
      return;
}
    _linkedBanks.add(bank);
    _saveBanks();
    analytics.logEvent('add_bank', parameters: {'bank': bank.bankName});
    notifyListeners();
}

  void removeBank(String id) {
    _linkedBanks.removeWhere((bank) => bank.id == id);
    _saveBanks();
    analytics.logEvent('remove_bank', parameters: {'id': id});
    notifyListeners();
}

  void _saveBanks() {
    final List<String> banksJson = _linkedBanks.map((e) => e.toJson()).toList();
    _prefs.setStringList('linked_banks', banksJson);
}

  void _loadSavedBeneficiaries() {
    final List<String>? beneficiariesJson = _prefs.getStringList('saved_beneficiaries');
    if (beneficiariesJson != null) {
      _savedBeneficiaries = beneficiariesJson.map((e) => BankAccount.fromJson(e)).toList();
      // Mock initial beneficiaries if none saved
      _savedBeneficiaries = [
        BankAccount(id: 'b1', bankName: 'IBS Bank', accountNumber: '10223499', accountHolder: 'Ahmed Ali'),
        BankAccount(id: 'b2', bankName: 'Premier Bank', accountNumber: '55678902', accountHolder: 'Fartun Omar'),
      ];
}
}

  void saveBeneficiary(BankAccount beneficiary) {
    final index = _savedBeneficiaries.indexWhere((b) => b.accountNumber == beneficiary.accountNumber && b.bankName == beneficiary.bankName);
    if (index != -1) {
      _savedBeneficiaries[index] = beneficiary;
      _savedBeneficiaries.insert(0, beneficiary);
}
    
    // Keep a reasonable limit for recents
    if (_savedBeneficiaries.length > 10) _savedBeneficiaries.removeLast();

    _saveBeneficiaries();
    notifyListeners();
}

  void _saveBeneficiaries() {
    final List<String> beneficiariesJson = _savedBeneficiaries.map((e) => e.toJson()).toList();
    _prefs.setStringList('saved_beneficiaries', beneficiariesJson);
}

  void _loadRecentWithdrawals() {
    final List<String>? recents = _prefs.getStringList('recent_withdrawals');
    if (recents != null) {
      _recentWithdrawals = recents.map((e) {
        final parts = e.split('|');
        return {
          'id': parts[0],
          'type': parts[1],
          'name': parts[2],
          'detail': parts[3],
          'provider': parts[4],
      // Mock initial recents
      _recentWithdrawals = [
        {'id': '1', 'type': 'mobile', 'name': 'Hooyo', 'detail': '615123456', 'provider': 'EVC Plus'},
        {'id': '2', 'type': 'bank', 'name': 'Ahmed Cali', 'detail': '102234556', 'provider': 'IBS Bank'},
      ];
}
}

  void addRecentWithdrawal(Map<String, String> entry) {
    // Check if duplicate
    _recentWithdrawals.removeWhere((e) => e['detail'] == entry['detail']);
    _recentWithdrawals.insert(0, entry);
    if (_recentWithdrawals.length > 5) _recentWithdrawals.removeLast();
    
    final List<String> recents = _recentWithdrawals.map((e) => 
      "${e['id']}|${e['type']}|${e['name']}|${e['detail']}|${e['provider']}"
    ).toList();
    _prefs.setStringList('recent_withdrawals', recents);
    notifyListeners();
}

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  void togglePremium(bool value) {
    _isPremium = value;
    _prefs.setBool('is_premium', value);
    notifyListeners();
}

  void _loadQuickProfiles() {
    final List<String>? profilesJson = _prefs.getStringList('quick_profiles');
    _isPremium = _prefs.getBool('is_premium') ?? false;
    if (profilesJson != null) {
      _quickProfiles = profilesJson.map((e) => QuickProfile.fromJson(e)).toList();
      // Mock initial profiles with Somali numbers
      _quickProfiles = [
        QuickProfile(id: '1', name: 'Ayaanle', walletId: '252615123456', avatarUrl: 'https://i.pravatar.cc/150?u=ayaanle'),
        QuickProfile(id: '2', name: 'Fartun', walletId: '252615654321', avatarUrl: 'https://i.pravatar.cc/150?u=fartun'),
        QuickProfile(id: '3', name: 'Abdirahman', walletId: '252617788990', avatarUrl: 'https://i.pravatar.cc/150?u=abdirahman'),
        QuickProfile(id: '4', name: 'Hodan', walletId: '252618877665', avatarUrl: 'https://i.pravatar.cc/150?u=hodan'),
        QuickProfile(id: '5', name: 'Mustafe', walletId: '252619922334', avatarUrl: 'https://i.pravatar.cc/150?u=mustafe'),
      ];
}
}

  void saveQuickProfile(QuickProfile profile) {
    // Enforcement of limits
    if (!_isPremium && _quickProfiles.length >= 5 && !_quickProfiles.any((p) => p.walletId == profile.walletId)) {
      throw Exception('profile_limit_reached');
}

    // Check if exists
    final index = _quickProfiles.indexWhere((p) => p.walletId == profile.walletId);
    if (index != -1) {
      _quickProfiles[index] = profile;
      _quickProfiles.add(profile);
}
    
    // Hard cap at 20 even for premium in this mock
    if (_quickProfiles.length > 20) _quickProfiles.removeAt(0);

    _saveQuickProfiles();
    notifyListeners();
}

  void deleteQuickProfile(String id) {
    _quickProfiles.removeWhere((p) => p.id == id);
    _saveQuickProfiles();
    notifyListeners();
}

  void _saveQuickProfiles() {
    final List<String> profilesJson = _quickProfiles.map((e) => e.toJson()).toList();
    _prefs.setStringList('quick_profiles', profilesJson);
}

  void setShowHomePromo(bool show) {
    _showHomePromo = show;
    notifyListeners();
}

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    analytics.logEvent('bottom_nav_click', parameters: {'index': index});
    notifyListeners();
}

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _prefs.setString('theme_mode', isDark ? 'dark' : 'light');
    analytics.logEvent('toggle_theme', parameters: {'is_dark': isDark});
    notifyListeners();
}

  void setLanguage(String langCode) {
    _locale = Locale(langCode);
    _prefs.setString('language_code', langCode);
    analytics.logEvent('set_language', parameters: {'lang': langCode});
    notifyListeners();
}

  double getExchangeRate(String from, String to) {
    if (from == to) return 1.0;
    
    // Convert through USD base
    double fromRate = _fxRates[from] ?? 1.0;
    double toRate = _fxRates[to] ?? 1.0;
    
    // If our rates are USD-based (1 USD = X EUR), then fromRate is EUR/USD
    // This depends on how the map is structured. 
    // Usually, 1 USD = _fxRates['EUR'] EUR.
    // So to convert X FROM to TO:
    // X / fromRate = amount in USD
    // (X / fromRate) * toRate = amount in TO
    
    return toRate / fromRate;
}

  double convertAmount(double amount, String from, String to) {
    double rate = getExchangeRate(from, to);
    // Use 4 decimal places for SOS (high nominal value), 2 for others
    int decimals = to == 'SOS' ? 0 : 2;
    return double.parse((amount * rate).toStringAsFixed(decimals));
}

  final double walletFlatFee = 1.0; // $1.0 per $100
  final double bankFlatFee = 1.5;   // $1.5 per $100
  final double mobileMoneyFlatFee = 2.5; // $2.5 per $100
  final double cardFlatFee = 2.5;
  final double savingsFlatFee = 0.5;

  double getFeeRate(String method) {
    if (method.contains("Bank") || method == "Bank Transfer") {
      return bankFlatFee;
      return walletFlatFee;
        method == "EVC Plus" || method == "ZAAD Service" || 
        method == "e-Dahab" || method == "Sahal" || method == "Waafi" ||
        method.toUpperCase().contains("EVC") || 
        method.toUpperCase().contains("ZAAD") || 
        method.toUpperCase().contains("SAHAL") || 
        method.toUpperCase().contains("DAHAB")) {
      return mobileMoneyFlatFee;
      return cardFlatFee;
      return savingsFlatFee;
      return walletFlatFee; // Default
}
}

  double calculateFeeForSource(double amount, String source, {String? payoutMethod, String? cardId}) {
    if (amount <= 0) return 0.0;
    
    // Determine the fee rate based on payoutMethod or source
    String effectiveMethod = payoutMethod ?? source;
    double feeRate = getFeeRate(effectiveMethod);

    // Calculate fee: $feeRate per $100 (e.g., $2.5 per $100 = 2.5% fee)
    return (amount / 100) * feeRate;
}

  double calculateTotalForSource(double amount, String source, {String? payoutMethod, String? cardId}) {
    return amount + calculateFeeForSource(amount, source, payoutMethod: payoutMethod, cardId: cardId);
}

  // Validation: Check if balance is sufficient
  bool hasSufficientBalanceForSource(double amount, String source, {String? cardId, String? payoutMethod}) {
    double total = calculateTotalForSource(amount, source, payoutMethod: payoutMethod, cardId: cardId);
    if (source == "Main Wallet" || source == "Murtaax Wallet") {
      return _balance >= total;
      return _savingsBalance >= total;
      final card = _cards.firstWhere((c) => c.id == cardId, orElse: () => throw Exception('card_not_found'));
      return card.balance >= total;
}
    return true; // For external sources like Bank Transfer/Mobile Money
}

  // Security Limits
  double _userDailyLimit = 5000.0;
  double _userMonthlyLimit = 20000.0;
  
  double get dailyLimit => _userDailyLimit;
  double get monthlyLimit => _userMonthlyLimit;

  Future<void> updateDailyLimit(double newLimit) async {
    _userDailyLimit = newLimit;
    await _prefs.setDouble('daily_limit', newLimit);
    notifyListeners();
}

  Future<void> updateMonthlyLimit(double newLimit) async {
    _userMonthlyLimit = newLimit;
    await _prefs.setDouble('monthly_limit', newLimit);
    notifyListeners();
}

  double getDailySpent() {
    final now = DateTime.now();
    final todayTransactions = _transactions.where((tx) => 
      tx.isNegative && 
      tx.timestamp.year == now.year &&
      tx.timestamp.month == now.month &&
      tx.timestamp.day == now.day
    );
    return todayTransactions.fold(0.0, (sum, tx) => sum + (tx.numericAmount + tx.fee));
}

  double getDailyRemaining() {
    double spentToday = getDailySpent();
    return (dailyLimit - spentToday).clamp(0.0, dailyLimit);
}

  double getMonthlyRemaining() {
    final now = DateTime.now();
    final monthlyTransactions = _transactions.where((tx) => 
      tx.isNegative && 
      tx.timestamp.year == now.year &&
      tx.timestamp.month == now.month
    );
    double spentMonth = monthlyTransactions.fold(0.0, (sum, tx) => sum + (tx.numericAmount + tx.fee));
    return (monthlyLimit - spentMonth).clamp(0.0, monthlyLimit);
}

  void _checkTransactionLimits(double totalAmount) {
    if (totalAmount > getDailyRemaining()) {
      throw Exception('daily_limit_exceeded');
}
    if (totalAmount > getMonthlyRemaining()) {
      throw Exception('monthly_limit_exceeded');
}
}

  void deductBalance(double amount) {
    _balance -= amount;
    _prefs.setDouble('balance', _balance);
    notifyListeners();
}

  void deductSavings(double amount) {
    _savingsBalance -= amount;
    _prefs.setDouble('savings_balance', _savingsBalance);
    notifyListeners();
}

  Future<void> autoTopUpMainFromSavings(double neededAmount) async {
    if (_savingsBalance < neededAmount) {
      throw Exception('insufficient_savings');
}
    
    _savingsBalance -= neededAmount;
    _balance += neededAmount;
    
    // Log internal transfer
    final tx = Transaction(
      id: "TOPUP${DateTime.now().millisecondsSinceEpoch}",
      title: "Auto Top-up from Savings",
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: "+${NumberFormat.simpleCurrency(name: _currencyCode).format(neededAmount)}",
      numericAmount: neededAmount,
      fee: 0,
      isNegative: false,
      category: "Transfer",
      status: "Success",
      type: "transfer_in",
      timestamp: DateTime.now(),
    );
    
    _transactions.insert(0, tx);
    await _saveBalance();
    await _saveSavingsBalance();
    await _saveTransactions();
    notifyListeners();
}

  void addBalance(double amount) {
    _balance += amount;
    _prefs.setDouble('balance', _balance);
    notifyListeners();
}

  double calculateFee(double amount, {String? payoutMethod}) {
    return calculateFeeForSource(amount, "Main Wallet", payoutMethod: payoutMethod);
}
  
  double calculateTotal(double amount, {String? payoutMethod}) => amount + calculateFee(amount, payoutMethod: payoutMethod);

  bool hasSufficientBalance(double amount, {String? payoutMethod}) {
    return _balance >= calculateTotal(amount, payoutMethod: payoutMethod);
}

  Future<void> deductCardBalance(String cardId, double amount) async {
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      _cards[index] = _cards[index].copyWith(balance: _cards[index].balance - amount);
      await _saveCards();
      notifyListeners();
}
}

  Future<void> addCardBalance(String cardId, double amount) async {
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      _cards[index] = _cards[index].copyWith(balance: _cards[index].balance + amount);
      await _saveCards();
      notifyListeners();
}
}

  // Helper for translations
  String translate(String en, String so, {String ar = '', String et = '', String de = ''}) {
    switch (_locale.languageCode) {
      case 'so': return so.isNotEmpty ? so : en;
      case 'ar': return ar.isNotEmpty ? ar : en;
      case 'et': return et.isNotEmpty ? et : en;
      case 'de': return de.isNotEmpty ? de : en;
      default:   return en;
}
}

  // Savings Logic
  Future<void> transferToSavings(double amount, {String? fromCardId, bool? fromCard, String? goalName, String? goalId}) async {
    final bool isFromCard = fromCardId != null || (fromCard ?? false);
    String? effectiveFromCardId = fromCardId;
    
    if (isFromCard && effectiveFromCardId == null) {
      if (_cards.isNotEmpty) {
        effectiveFromCardId = _cards[_selectedCardIndex < _cards.length ? _selectedCardIndex : 0].id;
        throw Exception('no_cards_available');
}
}

    VirtualCard? sourceCard;
    if (isFromCard) {
      sourceCard = _cards.firstWhere((c) => c.id == effectiveFromCardId, orElse: () => throw Exception('card_not_found'));
}

    final double sourceBalance = isFromCard ? sourceCard!.balance : _balance;

    if (sourceBalance < amount) {
      throw Exception(isFromCard ? 'insufficient_card_funds' : 'insufficient_funds');
}

    if (!isFromCard) {
      _checkTransactionLimits(amount);
}

    // Capture state for rollback
    final double originalBalance = _balance;
    final List<VirtualCard> originalCards = List.from(_cards.map((e) => e.copyWith()));
    final double originalSavingsBalance = _savingsBalance;
    final List<Transaction> originalTransactions = List.from(_transactions);
    final List<SavingsGoal> originalGoals = List.from(_savingsGoals.map((e) => e.copyWith()));

    try {
      if (isFromCard) {
        final index = _cards.indexWhere((c) => c.id == effectiveFromCardId);
        _cards[index] = _cards[index].copyWith(balance: _cards[index].balance - amount);
        _balance -= amount;
}
      _savingsBalance += amount;

      if (goalId != null) {
        final goalIndex = _savingsGoals.indexWhere((g) => g.id == goalId);
        if (goalIndex != -1) {
          _savingsGoals[goalIndex] = _savingsGoals[goalIndex].copyWith(
            saved: _savingsGoals[goalIndex].saved + amount,
          );
}
}

      String txTitle = "";
      if (goalName != null) {
        txTitle = "Deposit to $goalName";
        txTitle = "Card Deposit (**** ${sourceCard.cardNumber.substring(sourceCard.cardNumber.length - 4)})";
        txTitle = "Deposit to Savings";
}

      final tx = Transaction(
        id: "TX${DateTime.now().millisecondsSinceEpoch}",
        title: txTitle,
        date: DateFormat('MMM dd').format(DateTime.now()),
        numericAmount: amount,
        amount: "-${NumberFormat.simpleCurrency(name: _currencyCode).format(amount)}",
        isNegative: true,
        category: "Savings",
        status: "Success",
        type: "transfer_out",
        method: isFromCard ? "Virtual Card" : "Wallet",
        cardId: effectiveFromCardId,
      );

      _transactions.insert(0, tx);

      // Persist changes
      await _prefs.setDouble('balance', _balance);
      await _prefs.setDouble('savings_balance', _savingsBalance);
      await _saveCards();
      await _saveTransactions();
      await _saveSavingsGoals();

      notifyListeners();
      analytics.logEvent('savings_deposit_success', parameters: {'amount': amount, 'from_card': isFromCard, 'goal': goalName});
      // Rollback
      _balance = originalBalance;
      _cards = originalCards;
      _savingsBalance = originalSavingsBalance;
      _transactions = originalTransactions;
      _savingsGoals = originalGoals;
      notifyListeners();
      rethrow;
}
}

  Future<void> withdrawFromSavings(double amount, {String? toCardId, bool? toCard, String? goalName, String? goalId}) async {
    if (_savingsBalance < amount) {
      throw Exception('insufficient_savings');
}

    final bool isToCard = toCardId != null || (toCard ?? false);
    String? effectiveToCardId = toCardId;
    
    if (isToCard && effectiveToCardId == null) {
       if (_cards.isNotEmpty) {
        effectiveToCardId = _cards[_selectedCardIndex < _cards.length ? _selectedCardIndex : 0].id;
        throw Exception('no_cards_available');
}
}

    VirtualCard? targetCard;
    if (isToCard) {
      targetCard = _cards.firstWhere((c) => c.id == effectiveToCardId, orElse: () => throw Exception('card_not_found'));
}

    // Capture state for rollback
    final double originalBalance = _balance;
    final List<VirtualCard> originalCards = List.from(_cards.map((e) => e.copyWith()));
    final double originalSavingsBalance = _savingsBalance;
    final List<Transaction> originalTransactions = List.from(_transactions);
    final List<SavingsGoal> originalGoals = List.from(_savingsGoals.map((e) => e.copyWith()));

    try {
      _savingsBalance -= amount;
      if (isToCard) {
        final index = _cards.indexWhere((c) => c.id == effectiveToCardId);
        _cards[index] = _cards[index].copyWith(balance: _cards[index].balance + amount);
        _balance += amount;
}

      if (goalId != null) {
        final goalIndex = _savingsGoals.indexWhere((g) => g.id == goalId);
        if (goalIndex != -1) {
          _savingsGoals[goalIndex] = _savingsGoals[goalIndex].copyWith(
            saved: (_savingsGoals[goalIndex].saved - amount).clamp(0, double.infinity),
          );
}
}

      String txTitle = "";
      if (goalName != null) {
        txTitle = "Withdraw from $goalName";
        txTitle = "Withdraw to Card (**** ${targetCard.cardNumber.substring(targetCard.cardNumber.length - 4)})";
        txTitle = "Withdraw from Savings";
}

      final tx = Transaction(
        id: "TX${DateTime.now().millisecondsSinceEpoch}",
        title: txTitle,
        date: DateFormat('MMM dd').format(DateTime.now()),
        numericAmount: amount,
        amount: "+${NumberFormat.simpleCurrency(name: _currencyCode).format(amount)}",
        isNegative: false,
        category: "Savings",
        status: "Success",
        type: "transfer_in",
        method: isToCard ? "Virtual Card" : "Wallet",
        cardId: effectiveToCardId,
      );

      _transactions.insert(0, tx);

      // Persist changes
      await _prefs.setDouble('balance', _balance);
      await _prefs.setDouble('savings_balance', _savingsBalance);
      await _saveCards();
      await _saveTransactions();
      await _saveSavingsGoals();

      notifyListeners();
      analytics.logEvent('savings_withdraw_success', parameters: {'amount': amount, 'to_card': isToCard});
      // Rollback
      _balance = originalBalance;
      _cards = originalCards;
      _savingsBalance = originalSavingsBalance;
      _transactions = originalTransactions;
      _savingsGoals = originalGoals;
      notifyListeners();
      rethrow;
}
}


  // Wallet ID / Account Inquiry Logic
  Future<String?> resolveAccountName(String id, {String? type, String? bankName}) async {
    // Simulate network delay for professional feel
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // Check mock users (covers Wallet IDs and some phone numbers)
    if (_mockUsers.containsKey(id)) {
      return _mockUsers[id];
}

    // New specific bank validation
    if (type == 'bank' && bankName != null) {
      if (_mockBankAccounts.containsKey(bankName)) {
        return _mockBankAccounts[bankName]![id];
}
}

    // Additional mock logic for Bank Accounts if needed
    if (type == 'bank' && id.length >= 8) {
      final List<String> mockNames = ["Abshir Duale", "Leyla Ahmed", "Xasan Kaafi", "Muna Omar"];
      return mockNames[id.length % mockNames.length];
}

    if (type == 'mobile' && id.length == 9) {
      final List<String> mockNames = ["Farah Saney", "Hawa Abdi", "Bile Raage", "Ubax Cali"];
      return mockNames[int.parse(id.substring(id.length - 1)) % mockNames.length];
}

    if (type == 'merchant' || (id.length >= 5 && id.length <= 7)) {
       // Mock resolution for any 5-7 digit number if not in _mockUsers
       if (_mockUsers.containsKey(id)) return _mockUsers[id];
       final List<String> merchantNames = ["Global Trade Ltd", "Local Retailer", "Premium Services", "East Africa Hub"];
       return merchantNames[int.parse(id.substring(id.length - 1)) % merchantNames.length];
}
    
    return null;
}

  // Legacy helper
  Future<String?> verifyWalletId(String id) => resolveAccountName(id);

  /// Atomically process a P2P transfer between Murtaax Wallets.
  /// This simulates a transactional backend operation.
  Future<void> processP2PTransfer({
    required String receiverId,
    required double amount,
    required String currencyCode,
    required String purpose,
    String paymentMethod = "Main Wallet",
    String? payoutMethod,
    String? receiverName,
    String? cardId,
    // 1. Validation
    final fee = calculateFeeForSource(amount, paymentMethod, payoutMethod: payoutMethod);
    final total = amount + fee;
    
    if (!hasSufficientBalanceForSource(amount, paymentMethod, cardId: cardId, payoutMethod: payoutMethod)) {
      throw Exception('insufficient_funds');
}

    _checkTransactionLimits(total);

    // Capture state for rollback
    final double originalBalance = _balance;
    final double originalSavingsBalance = _savingsBalance;
    final List<Transaction> originalTransactions = List.from(_transactions);
    final List<VirtualCard> originalCards = _cards.map((c) => c.copyWith()).toList();

    // 2. Start Simulation (Atomic Block)
    try {
      // Update in-memory state
      if (paymentMethod == "Savings Account") {
        _savingsBalance = double.parse((_savingsBalance - total).toStringAsFixed(2));
        final index = _cards.indexWhere((c) => c.id == cardId);
        if (index != -1) {
          _cards[index] = _cards[index].copyWith(
            balance: double.parse((_cards[index].balance - total).toStringAsFixed(2))
          );
          await _saveCards();
}
        _balance = double.parse((_balance - total).toStringAsFixed(2));
}
      // For external sources like Bank Transfer or Mobile Money, we don't deduct from internal wallet balance
      // in this mock simulation.
      
      String status = "Success";
      if (payoutMethod != null && payoutMethod.contains("Bank")) {
        status = "Pending";
}

      // Record Transaction
      final tx = Transaction(
        id: "TX${DateTime.now().millisecondsSinceEpoch}",
        title: receiverName ?? _mockUsers[receiverId] ?? "Murtaax User",
        date: DateFormat('MMM dd').format(DateTime.now()),
        amount: "-${NumberFormat.simpleCurrency(name: currencyCode).format(total)}",
        numericAmount: amount,
        fee: fee,
        isNegative: true,
        category: "Transfer",
        status: status,
        type: "send",
        method: payoutMethod ?? "Murtaax Wallet",
        paymentMethod: paymentMethod,
        purpose: purpose,
        referenceId: receiverId,
        cardId: cardId,
      );
      
      _transactions.insert(0, tx);
      
      // 3. Persist changes (Critical Section)
      if (paymentMethod == "Savings Account") {
        await _prefs.setDouble('savings_balance', _savingsBalance);
        await _prefs.setDouble('balance', _balance);
}
      await _saveTransactions();
      
      notifyListeners();
      analytics.logEvent('p2p_transfer_success', parameters: {
        'amount': amount,
        'receiver': receiverId,
        'source': paymentMethod,
        'payout_method': payoutMethod ?? "Murtaax Wallet",
        'status': status,
      // 4. Rollback Logic
      _balance = originalBalance;
      _savingsBalance = originalSavingsBalance;
      _transactions = originalTransactions;
      _cards = originalCards;
      notifyListeners();
      rethrow;
}
}

  /// Atomically process a withdrawal from Wallet to Bank/Mobile.
  Future<Transaction> processWalletWithdrawal({
    required double amount,
    required double fee,
    required String method,
    required String detail,
    required String provider,
    required String name,
    required String type,
    String status = "Success",
    String? purpose,
    final total = amount + fee;
    if (_balance < total) {
      throw Exception('insufficient_funds');
}

    _checkTransactionLimits(total);

    final double originalBalance = _balance;
    final List<Transaction> originalTransactions = List.from(_transactions);

    try {
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
        status: status,
        type: "withdraw",
        method: method,
        purpose: purpose,
        referenceId: detail,
      );

      _transactions.insert(0, tx);

      final bool saved = await _prefs.setDouble('balance', _balance);
      await _saveTransactions();

      if (!saved) {
        throw Exception('persistence_error');
}

      // Add to recent withdrawals
      addRecentWithdrawal({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': type,
        'name': name,
        'detail': detail,
        'provider': provider,

      notifyListeners();
      analytics.logEvent('withdraw_success', parameters: {'amount': amount, 'method': method});
      return tx;
      _balance = originalBalance;
      _transactions = originalTransactions;
      rethrow;
}
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
    String status = "Success",
    String? purpose,
    final total = amount + fee;
    final card = _cards.firstWhere((c) => c.id == cardId, orElse: () => throw Exception('card_not_found'));
    
    if (card.balance < total) {
      throw Exception('insufficient_funds');
}

    _checkTransactionLimits(total);

    // Atomic state capture
    final List<VirtualCard> originalCards = _cards.map((c) => c.copyWith()).toList();
    final double originalBalance = _balance;
    final List<Transaction> originalTransactions = List.from(_transactions);

    try {
      // 1. Deduct from Card
      final cardIndex = _cards.indexWhere((c) => c.id == cardId);
      _cards[cardIndex] = card.copyWith(balance: card.balance - total);

      final now = DateTime.now();
      final dateStr = DateFormat('MMM dd').format(now);
      
      // 2. Log withdrawal from card
      final cardTx = Transaction(
        id: "TX-CARD-${now.millisecondsSinceEpoch}",
        title: name,
        date: dateStr,
        amount: "-${NumberFormat.simpleCurrency(name: _currencyCode).format(total)}",
        numericAmount: total,
        fee: fee,
        isNegative: true,
        category: "Withdraw",
        status: status,
        type: "withdraw",
        method: "Virtual Card",
        purpose: purpose ?? "Withdrawal",
        cardId: cardId,
        referenceId: detail,
      );
      _transactions.insert(0, cardTx);

      // 3. If withdrawing to Murtaax Wallet, increment wallet balance and log deposit
      if (type == "wallet") {
        _balance += amount;
        final walletTx = Transaction(
          id: "TX-WALLET-${now.millisecondsSinceEpoch}",
          title: "Card Topup",
          date: dateStr,
          amount: "+${NumberFormat.simpleCurrency(name: _currencyCode).format(amount)}",
          numericAmount: amount,
          isNegative: false,
          category: "Transfer",
          status: "Success",
          type: "deposit",
          method: "Virtual Card",
          purpose: "Transfer",
          cardId: null,
        );
        _transactions.insert(0, walletTx);
}

      await _saveTransactions();
      await _saveCards();
      await _prefs.setDouble('balance', _balance);

      addRecentWithdrawal({
        'id': now.millisecondsSinceEpoch.toString(),
        'type': type,
        'name': name,
        'detail': detail,
        'provider': provider,

      notifyListeners();
      analytics.logEvent('card_withdraw_success', parameters: {'amount': amount, 'method': method, 'type': type});
      return cardTx;
      _cards = originalCards;
      _balance = originalBalance;
      _transactions = originalTransactions;
      rethrow;
}
}


  /// Send money to a contact or phone number with support for multiple sources
  Future<void> sendMoney(
    double amount, 
    String contactInfo, {
    String? name,
    String paymentMethod = "Main Wallet",
    String? cardId,
    String? payoutMethod,
    final fee = calculateFeeForSource(amount, paymentMethod, cardId: cardId, payoutMethod: payoutMethod);
    final total = amount + fee;
    
    if (!hasSufficientBalanceForSource(amount, paymentMethod, cardId: cardId, payoutMethod: payoutMethod)) {
      throw Exception('insufficient_funds');
}

    _checkTransactionLimits(total);

    final double originalBalance = _balance;
    final double originalSavingsBalance = _savingsBalance;
    final List<Transaction> originalTransactions = List.from(_transactions);
    final List<VirtualCard> originalCards = _cards.map((c) => c.copyWith()).toList();

    try {
      // Deduct from source
      if (paymentMethod == "Main Wallet" || paymentMethod == "Murtaax Wallet") {
        _balance -= total;
        await _prefs.setDouble('balance', _balance);
        _savingsBalance -= total;
        await _prefs.setDouble('savings_balance', _savingsBalance);
        final index = _cards.indexWhere((c) => c.id == cardId);
        if (index != -1) {
          _cards[index] = _cards[index].copyWith(
            balance: double.parse((_cards[index].balance - total).toStringAsFixed(2))
          );
          await _saveCards();
}
}
      
      final tx = Transaction(
        id: "TX${DateTime.now().millisecondsSinceEpoch}",
        title: name ?? contactInfo,
        date: DateFormat('MMM dd').format(DateTime.now()),
        amount: "-${NumberFormat.simpleCurrency(name: _currencyCode).format(total)}",
        numericAmount: amount,
        fee: fee,
        isNegative: true,
        category: "Transfer",
        status: (payoutMethod == "Bank" || payoutMethod == "Bank Transfer") ? "Pending" : "Success",
        type: "send",
        method: paymentMethod,
        paymentMethod: paymentMethod,
        referenceId: contactInfo,
        cardId: cardId,
        purpose: (payoutMethod == "Bank" || payoutMethod == "Bank Transfer") ? "Bank Transfer (Processing)" : null,
      );
      
      _transactions.insert(0, tx);

      // Simulation of Push Notification and Live Balance update
      _showTransferNotification(tx);
      
      // Update Quick Profile lastAmount and usage stats
      final profileIndex = _quickProfiles.indexWhere((p) => p.walletId == contactInfo);
      if (profileIndex != -1) {
        _quickProfiles[profileIndex] = _quickProfiles[profileIndex].copyWith(
          lastAmount: amount,
          lastReceiverMethod: payoutMethod ?? 'Wallet',
          lastSenderMethod: paymentMethod,
          transactionCount: _quickProfiles[profileIndex].transactionCount + 1,
          lastTransactionDate: DateTime.now(),
        );
        // Automatically save new profiles if they aren't there
        _quickProfiles.add(QuickProfile(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name ?? contactInfo,
          walletId: contactInfo,
          lastAmount: amount,
          lastReceiverMethod: payoutMethod ?? 'Wallet',
          lastSenderMethod: paymentMethod,
          transactionCount: 1,
          lastTransactionDate: DateTime.now(),
        ));
}
      _saveQuickProfiles();
      
      await _saveTransactions();
      
      notifyListeners();
      analytics.logEvent('send_money_success', parameters: {
        'amount': amount,
        'recipient': contactInfo,
        'source': paymentMethod,
        'payout': payoutMethod,
      _balance = originalBalance;
      _savingsBalance = originalSavingsBalance;
      _transactions = originalTransactions;
      _cards = originalCards;
      notifyListeners();
      rethrow;
}
}

  Future<void> createMoneyRequest({
    required double amount,
    required String receiverName,
    required String receiverId,
    String? note,
    bool isSplit = false,
    int? splitCount,
    final tx = Transaction(
      id: "REQ-${DateTime.now().millisecondsSinceEpoch}",
      title: isSplit ? "Split Request ($splitCount people)" : "Request to $receiverName",
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: NumberFormat.simpleCurrency(name: _currencyCode).format(amount),
      numericAmount: amount,
      isNegative: false, // Requests don't deduct until paid
      category: "Request",
      status: "Pending",
      type: "request_out",
      purpose: note,
      referenceId: receiverId,
      timestamp: DateTime.now(),
    );

    _transactions.insert(0, tx);

    await _saveTransactions();
    notifyListeners();
    analytics.logEvent('money_request_created', parameters: {
      'amount': amount,
      'is_split': isSplit,
}

  /// Atomically process a bill payment.
  Future<Transaction> processBillPayment({
    required String category,
    required String accountId,
    required double amount,
    required String l10nKey,
    String? paymentMethod,
    String? cardId,
    final method = paymentMethod ?? "Main Wallet";
    if (method == "Savings Account") {
      throw Exception('Savings accounts cannot be used for bill payments');
}

    final fee = calculateFeeForSource(amount, method, cardId: cardId);
    final total = amount + fee;
    
    if (!hasSufficientBalanceForSource(amount, method, cardId: cardId)) {
      throw Exception('insufficient_funds');
}

    _checkTransactionLimits(total);

    final double originalBalance = _balance;
    final double originalSavingsBalance = _savingsBalance;
    final List<VirtualCard> originalCards = List.from(_cards.map((e) => e.copyWith()));
    final List<Transaction> originalTransactions = List.from(_transactions);

    try {
      // Deduct from source
      if (method == "Main Wallet" || method == "Murtaax Wallet") {
        _balance -= total;
        _savingsBalance -= total;
        final cardIdx = _cards.indexWhere((c) => c.id == cardId);
        if (cardIdx != -1) {
          final updatedCard = _cards[cardIdx].copyWith(balance: _cards[cardIdx].balance - total);
          _cards[cardIdx] = updatedCard;
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
        referenceId: "BILL-${accountId.substring(0, math.min(4, accountId.length))}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
      );
      
      _transactions.insert(0, tx);
      notifyListeners();
      _saveTransactions();
      _saveCards();
      return tx;
      _balance = originalBalance;
      _savingsBalance = originalSavingsBalance;
      _cards = originalCards;
      _transactions = originalTransactions;
      notifyListeners();
      rethrow;
}
}

  int min(int a, int b) => a < b ? a : b;

  // Crypto Logic
  Future<void> buyCrypto(CryptoAsset asset, double fiatAmount, double cryptoAmount) async {
    if (_balance < fiatAmount) {
      throw Exception('insufficient_funds');
}

    _checkTransactionLimits(fiatAmount);

    final double originalBalance = _balance;
    final Map<String, double> originalHoldings = Map.from(_cryptoHoldings);
    final List<Transaction> originalTransactions = List.from(_transactions);

    try {
      _balance -= fiatAmount;
      _cryptoHoldings[asset.symbol] = (_cryptoHoldings[asset.symbol] ?? 0.0) + cryptoAmount;

      final tx = Transaction(
        id: "TX${DateTime.now().millisecondsSinceEpoch}",
        title: "Bought ${asset.name}",
        date: DateFormat('MMM dd').format(DateTime.now()),
        amount: "-${NumberFormat.simpleCurrency(name: _currencyCode).format(fiatAmount)}",
        numericAmount: fiatAmount,
        isNegative: true,
        category: "Investment",
        status: "Success",
        type: "crypto_buy",
        method: "Wallet",
        referenceId: asset.symbol,
      );

      _transactions.insert(0, tx);

      await _prefs.setDouble('balance', _balance);
      await _saveCryptoHoldings();
      await _saveTransactions();

      notifyListeners();
      analytics.logEvent('crypto_buy_success', parameters: {
        'symbol': asset.symbol,
        'fiat_amount': fiatAmount,
        'crypto_amount': cryptoAmount,
      _balance = originalBalance;
      _cryptoHoldings = originalHoldings;
      _transactions = originalTransactions;
      notifyListeners();
      rethrow;
}
}

  Future<void> sellCrypto(CryptoAsset asset, double cryptoAmount, double fiatAmount) async {
    final currentHoldings = _cryptoHoldings[asset.symbol] ?? 0.0;
    if (currentHoldings < cryptoAmount) {
      throw Exception('insufficient_holdings');
}

    final double originalBalance = _balance;
    final Map<String, double> originalHoldings = Map.from(_cryptoHoldings);
    final List<Transaction> originalTransactions = List.from(_transactions);

    try {
      _cryptoHoldings[asset.symbol] = currentHoldings - cryptoAmount;
      _balance += fiatAmount;

      final tx = Transaction(
        id: "TX${DateTime.now().millisecondsSinceEpoch}",
        title: "Sold ${asset.name}",
        date: DateFormat('MMM dd').format(DateTime.now()),
        amount: "+${NumberFormat.simpleCurrency(name: _currencyCode).format(fiatAmount)}",
        numericAmount: fiatAmount,
        isNegative: false,
        category: "Investment",
        status: "Success",
        type: "crypto_sell",
        method: "Wallet",
        referenceId: asset.symbol,
      );

      _transactions.insert(0, tx);

      await _prefs.setDouble('balance', _balance);
      await _saveCryptoHoldings();
      await _saveTransactions();

      notifyListeners();
      analytics.logEvent('crypto_sell_success', parameters: {
        'symbol': asset.symbol,
        'fiat_amount': fiatAmount,
        'crypto_amount': cryptoAmount,
      _balance = originalBalance;
      _cryptoHoldings = originalHoldings;
      _transactions = originalTransactions;
      notifyListeners();
      rethrow;
}
}

}
