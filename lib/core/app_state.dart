import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  late final analytics = AppAnalytics();
  late SharedPreferences _prefs;
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
  List<QuickProfile> get quickProfiles => _quickProfiles;

  double get cardBalance => _cards.fold(0.0, (sum, card) => sum + card.balance);

  String _walletId = '102234';
  String get walletId => _walletId;

  String _pin = '1234'; // Default mock PIN
  String _cardPin = '1122'; // Virtual Card PIN
  
  bool verifyPin(String pin) {
    return _pin == pin;
  }

  bool verifyCardPin(String pin) {
    return _cardPin == pin;
  }

  void updateCardPin(String pin) {
    _cardPin = pin;
    _prefs.setString('card_pin', pin);
    notifyListeners();
  }

  String _currencyCode = 'USD';
  String get currencyCode => _currencyCode;

  List<BankAccount> _linkedBanks = [];
  List<BankAccount> get linkedBanks => _linkedBanks;

  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  List<Map<String, String>> _recentWithdrawals = [];
  List<Map<String, String>> get recentWithdrawals => _recentWithdrawals;

  List<VirtualCard> _cards = [];
  List<VirtualCard> get cards => _cards;

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

  void _loadRecurringPayments() {
    final List<String>? paymentsJson = _prefs.getStringList('recurring_payments');
    if (paymentsJson != null) {
      _recurringPayments = paymentsJson.map((e) => RecurringPayment.fromJson(json.decode(e))).toList();
    } else {
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

  void _loadHagbadGroups() {
    final List<String>? groupsJson = _prefs.getStringList('hagbad_groups');
    if (groupsJson != null) {
      _hagbadGroups = groupsJson.map((e) => HagbadGroup.fromJson(json.decode(e))).toList();
    } else {
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
    notifyListeners();
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

  void addHagbadMember(String groupId, HagbadMember member, {double catchUpAmount = 0}) {
    final gIdx = _hagbadGroups.indexWhere((g) => g.id == groupId);
    if (gIdx != -1) {
      final group = _hagbadGroups[gIdx];
      
      if (catchUpAmount > 0) {
        if (_balance < catchUpAmount) throw Exception('insufficient_funds');
        _balance -= catchUpAmount;
        _prefs.setDouble('balance', _balance);
        
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
        _saveTransactions();
      }

      final updatedMembers = List<HagbadMember>.from(group.members)..add(member);
      _hagbadGroups[gIdx] = group.copyWith(
        members: updatedMembers,
        totalCycles: updatedMembers.length,
      );
      _saveHagbadGroups();
      logHagbadEvent(groupId, "New member added: ${member.name}${catchUpAmount > 0 ? ' with catch-up payment of \$$catchUpAmount' : ''}");
      notifyListeners();
    }
  }

  void logHagbadEvent(String groupId, String event) {
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
    _saveTransactions();
    notifyListeners();
  }

  void sendHagbadNotification(String walletId, String message, {bool isSms = false}) {
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
    _saveTransactions();
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
    if (_balance < amount) throw Exception('insufficient_funds');

    final gIdx = _hagbadGroups.indexWhere((g) => g.id == groupId);
    if (gIdx != -1) {
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
        referenceId: groupId,
      );
      _transactions.insert(0, tx);

      await _prefs.setDouble('balance', _balance);
      _saveTransactions();
      _saveHagbadGroups();
      notifyListeners();
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
    final expectedPoolForCurrentCycle = group.amount * group.members.length;
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
    final expectedBalanceForCurrentCycle = group.amount * group.members.length * group.currentCycle;
    final totalPool = group.currentBalance;
    final alreadyPaidOut = (group.currentCycle - 1) * group.totalPayout;
    
    // Recipient gets the standard amount + any surplus in the pool (penalties)
    // If it's the last cycle, they get everything left.
    double payoutAmount;
    if (group.currentCycle == group.totalCycles) {
      payoutAmount = totalPool - alreadyPaidOut;
    } else {
      payoutAmount = group.totalPayout;
      // Add a portion of penalties if we want, or just the standard amount.
      // For this logic, let's say they get the standard amount, and penalties accumulate.
    }
    
    payoutAmount -= group.serviceFee;

    // Start Transaction
    final double originalBalance = _balance;
    final List<Transaction> originalTransactions = List.from(_transactions);

    try {
      final updatedMembers = List<HagbadMember>.from(group.members);
      updatedMembers[mIdx] = member.copyWith(hasReceived: true);

      // If it's "Me", update balance
      if (member.name == "Me" || member.name == "Khadar") {
        _balance += payoutAmount;
        await _prefs.setDouble('balance', _balance);
      }

      final tx = Transaction(
        id: "TX-PAYOUT-${DateTime.now().millisecondsSinceEpoch}",
        title: "Hagbad Payout: ${group.name}",
        date: DateFormat('MMM dd').format(DateTime.now()),
        amount: "+${NumberFormat.simpleCurrency(name: _currencyCode).format(payoutAmount)}",
        numericAmount: payoutAmount,
        isNegative: false,
        category: "Hagbad",
        status: "Success",
        type: "payout",
        method: "Wallet",
        referenceId: groupId,
      );
      _transactions.insert(0, tx);

      // Progress cycle if not last
      int nextCycle = group.currentCycle;
      HagbadStatus nextStatus = group.status;
      if (group.currentCycle < group.totalCycles) {
        nextCycle++;
      } else {
        nextStatus = HagbadStatus.completed;
      }

      _hagbadGroups[gIdx] = group.copyWith(
        members: updatedMembers,
        currentCycle: nextCycle,
        status: nextStatus,
      );

      _saveTransactions();
      _saveHagbadGroups();
      notifyListeners();
    } catch (e) {
      _balance = originalBalance;
      _transactions = originalTransactions;
      notifyListeners();
      rethrow;
    }
  }

  void _loadCryptoHoldings() {
    final String? cryptoJson = _prefs.getString('crypto_holdings');
    if (cryptoJson != null) {
      final Map<String, dynamic> decoded = json.decode(cryptoJson);
      _cryptoHoldings = decoded.map((key, value) => MapEntry(key, value.toDouble()));
    } else {
      // Mock initial holdings
      _cryptoHoldings = {
        'BTC': 0.45,
        'ETH': 2.5,
      };
      _saveCryptoHoldings();
    }
  }

  void _saveCryptoHoldings() {
    _prefs.setString('crypto_holdings', json.encode(_cryptoHoldings));
  }

  void _loadCards() {
    final List<String>? cardsJson = _prefs.getStringList('virtual_cards');
    if (cardsJson != null) {
      _cards = cardsJson.map((e) => VirtualCard.fromJson(json.decode(e))).toList();
      // Enforce limit of 2 cards
      if (_cards.length > 2) {
        _cards = _cards.sublist(0, 2);
        _saveCards();
      }
    } else {
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
      _saveCards();
    }
    
    final List<String>? terminatedJson = _prefs.getStringList('terminated_cards');
    if (terminatedJson != null) {
      _terminatedCards = terminatedJson.map((e) => VirtualCard.fromJson(json.decode(e))).toList();
    }
  }

  void _saveCards() {
    final List<String> cardsJson = _cards.map((e) => json.encode(e.toJson())).toList();
    _prefs.setStringList('virtual_cards', cardsJson);
    
    final List<String> terminatedJson = _terminatedCards.map((e) => json.encode(e.toJson())).toList();
    _prefs.setStringList('terminated_cards', terminatedJson);
  }

  void updateCard(int index, VirtualCard card) {
    _cards[index] = card;
    _saveCards();
    notifyListeners();
  }

  void removeCard(int index) {
    final card = _cards.removeAt(index);
    // Add to terminated cards with a timestamp (stored in metadata/id if needed, or we just track here)
    // For simplicity, we add it to the grace period list
    _terminatedCards.add(card);
    _saveCards();
    notifyListeners();
  }

  void restoreCard(String cardId) {
    final index = _terminatedCards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      final card = _terminatedCards.removeAt(index);
      _cards.add(card);
      _saveCards();
      notifyListeners();
    }
  }

  void addCard(VirtualCard card) {
    if (_cards.length >= 2) return;
    _cards.add(card);
    _saveCards();
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
      case 'ar': return 'العربية';
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
  };

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

    _loadRecentWithdrawals();
    _loadQuickProfiles();
    _loadBanks();
    _loadCards();
    _loadTransactions();
    _loadCryptoHoldings();
    _loadSavingsGoals();
    _loadHagbadGroups();
    _loadRecurringPayments();
    
    _cardPin = _prefs.getString('card_pin') ?? '1122';
    
    _userDailyLimit = _prefs.getDouble('daily_limit') ?? 5000.0;
    _userMonthlyLimit = _prefs.getDouble('monthly_limit') ?? 20000.0;

    _isInitialized = true;
    notifyListeners();
  }

  void _loadTransactions() {
    final List<String>? txJson = _prefs.getStringList('transactions');
    if (txJson != null) {
      _transactions = txJson.map((e) => Transaction.fromJson(json.decode(e))).toList();
    } else {
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

  void addTransaction(Transaction tx) {
    _transactions.insert(0, tx);
    _saveTransactions();
    notifyListeners();
  }

  void _saveTransactions() {
    final List<String> txJson = _transactions.map((e) => json.encode(e.toJson())).toList();
    _prefs.setStringList('transactions', txJson);
  }

  void _loadSavingsGoals() {
    final List<String>? goalsJson = _prefs.getStringList('savings_goals');
    if (goalsJson != null) {
      _savingsGoals = goalsJson.map((e) => SavingsGoal.fromJson(json.decode(e))).toList();
    } else {
      // Mock initial goals
      _savingsGoals = [
        SavingsGoal(
          id: "1",
          title: "Hajj Fund",
          soTitle: "Sanduuqa Xajka",
          arTitle: "صندوق الحج",
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
          arTitle: "سيارة جديدة",
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
          arTitle: "صندوق الطوارئ",
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
      _saveSavingsGoals();
    }
  }

  void _saveSavingsGoals() {
    final List<String> goalsJson = _savingsGoals.map((e) => json.encode(e.toJson())).toList();
    _prefs.setStringList('savings_goals', goalsJson);
  }

  void addSavingsGoal(SavingsGoal goal) {
    _savingsGoals.add(goal);
    _saveSavingsGoals();
    notifyListeners();
  }

  void updateSavingsGoal(int index, SavingsGoal goal) {
    _savingsGoals[index] = goal;
    _saveSavingsGoals();
    notifyListeners();
  }

  void removeSavingsGoal(int index) {
    _savingsGoals.removeAt(index);
    _saveSavingsGoals();
    notifyListeners();
  }

  void _loadBanks() {
    final List<String>? banksJson = _prefs.getStringList('linked_banks');
    if (banksJson != null) {
      _linkedBanks = banksJson.map((e) => BankAccount.fromJson(e)).toList();
    } else {
      // Mock initial banks
      _linkedBanks = [
        BankAccount(id: '1', bankName: 'LHV Pank', accountNumber: '**** 8829'),
        BankAccount(id: '2', bankName: 'Swedbank', accountNumber: '**** 1120'),
      ];
    }
  }

  void addBank(BankAccount bank) {
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
        };
      }).toList();
    } else {
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

  void _loadQuickProfiles() {
    final List<String>? profilesJson = _prefs.getStringList('quick_profiles');
    if (profilesJson != null) {
      _quickProfiles = profilesJson.map((e) => QuickProfile.fromJson(e)).toList();
    } else {
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
    // Check if exists
    final index = _quickProfiles.indexWhere((p) => p.walletId == profile.walletId);
    if (index != -1) {
      _quickProfiles[index] = profile;
    } else {
      _quickProfiles.add(profile);
    }
    
    // Keep max 10
    if (_quickProfiles.length > 10) _quickProfiles.removeAt(0);

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

  static const double transactionFeeRate = 0.0099;

  double calculateFee(double amount) {
    return amount * transactionFeeRate;
  }

  double calculateTotal(double amount) {
    return amount + calculateFee(amount);
  }

  // Validation: Check if balance is sufficient
  bool hasSufficientBalance(double amount) {
    return _balance >= calculateTotal(amount);
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

  double getDailyRemaining() {
    final now = DateTime.now();
    final todayTransactions = _transactions.where((tx) => 
      tx.isNegative && 
      tx.timestamp.year == now.year &&
      tx.timestamp.month == now.month &&
      tx.timestamp.day == now.day
    );
    double spentToday = todayTransactions.fold(0.0, (sum, tx) => sum + (tx.numericAmount + tx.fee));
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

  void addBalance(double amount) {
    _balance += amount;
    _prefs.setDouble('balance', _balance);
    notifyListeners();
  }

  void deductCardBalance(String cardId, double amount) {
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      _cards[index] = _cards[index].copyWith(balance: _cards[index].balance - amount);
      _saveCards();
      notifyListeners();
    }
  }

  void addCardBalance(String cardId, double amount) {
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index != -1) {
      _cards[index] = _cards[index].copyWith(balance: _cards[index].balance + amount);
      _saveCards();
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
      } else {
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
      } else {
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
      } else if (isFromCard && sourceCard != null) {
        txTitle = "Card Deposit (**** ${sourceCard.cardNumber.substring(sourceCard.cardNumber.length - 4)})";
      } else {
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
      _saveCards();
      _saveTransactions();
      _saveSavingsGoals();

      notifyListeners();
      analytics.logEvent('savings_deposit_success', parameters: {'amount': amount, 'from_card': isFromCard, 'goal': goalName});
    } catch (e) {
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
      } else {
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
      } else {
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
      } else if (isToCard && targetCard != null) {
        txTitle = "Withdraw to Card (**** ${targetCard.cardNumber.substring(targetCard.cardNumber.length - 4)})";
      } else {
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
      _saveCards();
      _saveTransactions();
      _saveSavingsGoals();

      notifyListeners();
      analytics.logEvent('savings_withdraw_success', parameters: {'amount': amount, 'to_card': isToCard});
    } catch (e) {
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


  // Wallet ID Verification Logic
  Future<String?> verifyWalletId(String id) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Cannot send to self
    if (id == _walletId) {
      throw Exception('self_transfer_error');
    }
    
    // Return name if found, otherwise null
    return _mockUsers[id];
  }

  /// Atomically process a P2P transfer between Murtaax Wallets.
  /// This simulates a transactional backend operation.
  Future<void> processP2PTransfer({
    required String receiverId,
    required double amount,
    required String currencyCode,
    required String purpose,
  }) async {
    // 1. Validation
    final fee = calculateFee(amount);
    final total = amount + fee;
    
    if (_balance < total) {
      throw Exception('insufficient_funds');
    }

    _checkTransactionLimits(total);

    // Capture state for rollback
    final double originalBalance = _balance;
    final List<Transaction> originalTransactions = List.from(_transactions);

    // 2. Start Simulation (Atomic Block)
    try {
      // Update in-memory state
      _balance -= total;
      
      // Record Transaction
      final tx = Transaction(
        id: "TX${DateTime.now().millisecondsSinceEpoch}",
        title: _mockUsers[receiverId] ?? "Murtaax User",
        date: DateFormat('MMM dd').format(DateTime.now()),
        amount: "-${NumberFormat.simpleCurrency(name: currencyCode).format(total)}",
        numericAmount: amount,
        fee: fee,
        isNegative: true,
        category: "Transfer",
        status: "Success",
        type: "send",
        method: "Murtaax Wallet",
        purpose: purpose,
        referenceId: receiverId,
      );
      
      _transactions.insert(0, tx);
      
      // 3. Persist changes (Critical Section)
      // In a real app, this would be a single DB transaction.
      // Here we use SharedPreferences.
      final bool balanceSaved = await _prefs.setDouble('balance', _balance);
      _saveTransactions();
      
      if (!balanceSaved) {
        throw Exception('persistence_error');
      }
      
      notifyListeners();
      analytics.logEvent('p2p_transfer_success', parameters: {
        'amount': amount,
        'receiver': receiverId,
      });
    } catch (e) {
      // 4. Rollback Logic
      _balance = originalBalance;
      _transactions = originalTransactions;
      notifyListeners();
      rethrow;
    }
  }

  /// Atomically process a withdrawal from Wallet to Bank/Mobile.
  Future<void> processWalletWithdrawal({
    required double amount,
    required double fee,
    required String method,
    required String detail,
    required String provider,
    required String name,
    required String type,
    String? purpose,
  }) async {
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
        status: "Success",
        type: "withdraw",
        method: method,
        purpose: purpose,
        referenceId: detail,
      );

      _transactions.insert(0, tx);

      final bool saved = await _prefs.setDouble('balance', _balance);
      _saveTransactions();

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
      });

      notifyListeners();
      analytics.logEvent('wallet_withdrawal_success', parameters: {
        'amount': amount,
        'method': method,
      });
    } catch (e) {
      _balance = originalBalance;
      _transactions = originalTransactions;
      notifyListeners();
      rethrow;
    }
  }

  /// Send money to a contact or phone number
  Future<void> sendMoney(double amount, String contactInfo, {String? name}) async {
    final fee = calculateFee(amount);
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
        title: name ?? contactInfo,
        date: DateFormat('MMM dd').format(DateTime.now()),
        amount: "-${NumberFormat.simpleCurrency(name: _currencyCode).format(total)}",
        numericAmount: amount,
        fee: fee,
        isNegative: true,
        category: "Transfer",
        status: "Success",
        type: "send",
        method: "Murtaax Wallet",
        referenceId: contactInfo,
      );
      
      _transactions.insert(0, tx);
      
      await _prefs.setDouble('balance', _balance);
      _saveTransactions();
      
      notifyListeners();
      analytics.logEvent('send_money_success', parameters: {
        'amount': amount,
        'recipient': contactInfo,
      });
    } catch (e) {
      _balance = originalBalance;
      _transactions = originalTransactions;
      notifyListeners();
      rethrow;
    }
  }

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
      _saveCryptoHoldings();
      _saveTransactions();

      notifyListeners();
      analytics.logEvent('crypto_buy_success', parameters: {
        'symbol': asset.symbol,
        'fiat_amount': fiatAmount,
        'crypto_amount': cryptoAmount,
      });
    } catch (e) {
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
      _saveCryptoHoldings();
      _saveTransactions();

      notifyListeners();
      analytics.logEvent('crypto_sell_success', parameters: {
        'symbol': asset.symbol,
        'fiat_amount': fiatAmount,
        'crypto_amount': cryptoAmount,
      });
    } catch (e) {
      _balance = originalBalance;
      _cryptoHoldings = originalHoldings;
      _transactions = originalTransactions;
      notifyListeners();
      rethrow;
    }
  }

  // Temporary hack to get context for l10n in state
  // In a real app, you'd use a better service locator or pass context/l10n as params
  BuildContext? contextForL10n;
}
