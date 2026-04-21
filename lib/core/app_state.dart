import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_analytics.dart';
import 'package:intl/intl.dart';
import 'models/bank_account.dart';
import 'models/transaction.dart';
import 'models/quick_profile.dart';
import '../features/cards/models/card_model.dart';

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  late final analytics = AppAnalytics();
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  double _balance = 12450.80;
  double get balance => _balance;

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

  void _loadCards() {
    final List<String>? cardsJson = _prefs.getStringList('virtual_cards');
    if (cardsJson != null) {
      _cards = cardsJson.map((e) => VirtualCard.fromJson(json.decode(e))).toList();
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
        VirtualCard(
          id: "3",
          cardNumber: "4000111122223333",
          cardHolder: "KHADAR RAYAALE",
          expiryDate: "08/29",
          cvv: "109",
          theme: CardThemeType.emerald,
          network: CardNetwork.visa,
          balance: 0.0,
        ),
      ];
      _saveCards();
    }
  }

  void _saveCards() {
    final List<String> cardsJson = _cards.map((e) => json.encode(e.toJson())).toList();
    _prefs.setStringList('virtual_cards', cardsJson);
  }

  void updateCard(int index, VirtualCard card) {
    _cards[index] = card;
    _saveCards();
    notifyListeners();
  }

  void removeCard(int index) {
    _cards.removeAt(index);
    _saveCards();
    notifyListeners();
  }

  void addCard(VirtualCard card) {
    _cards.add(card);
    _saveCards();
    notifyListeners();
  }

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  // Estonian is not RTL, so we can remove or update this check.
  // Arabic was RTL.
  bool get isRtl => _locale.languageCode == 'ar'; 

  int _selectedNavIndex = 0;
  int get selectedNavIndex => _selectedNavIndex;

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
  };

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
  static const double dailyLimit = 50000.0;
  static const double monthlyLimit = 100000.0;

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
  Future<void> transferToSavings(double amount, {String? fromCardId, bool? fromCard, String? goalName}) async {
    final bool isFromCard = fromCardId != null || (fromCard ?? false);
    final String? effectiveFromCardId = fromCardId ?? ((fromCard ?? false) && _cards.isNotEmpty ? _cards.first.id : null);

    final double sourceBalance = isFromCard 
        ? _cards.firstWhere((c) => c.id == effectiveFromCardId).balance 
        : _balance;

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

    try {
      if (isFromCard) {
        final index = _cards.indexWhere((c) => c.id == effectiveFromCardId);
        _cards[index] = _cards[index].copyWith(balance: _cards[index].balance - amount);
      } else {
        _balance -= amount;
      }
      _savingsBalance += amount;

      final tx = Transaction(
        id: "TX${DateTime.now().millisecondsSinceEpoch}",
        title: goalName != null ? "Deposit to $goalName" : (isFromCard ? "Deposit from Card" : "Deposit to Savings"),
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
      _saveCards();
      await _prefs.setDouble('savings_balance', _savingsBalance);
      _saveTransactions();

      notifyListeners();
      analytics.logEvent('savings_deposit_success', parameters: {'amount': amount, 'from_card': isFromCard, 'goal': goalName});
    } catch (e) {
      // Rollback
      _balance = originalBalance;
      _cards = originalCards;
      _savingsBalance = originalSavingsBalance;
      _transactions = originalTransactions;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> withdrawFromSavings(double amount, {String? toCardId, bool? toCard, String? goalName}) async {
    if (_savingsBalance < amount) {
      throw Exception('insufficient_savings');
    }

    final bool isToCard = toCardId != null || (toCard ?? false);
    final String? effectiveToCardId = toCardId ?? ((toCard ?? false) && _cards.isNotEmpty ? _cards.first.id : null);

    // Capture state for rollback
    final double originalBalance = _balance;
    final List<VirtualCard> originalCards = List.from(_cards.map((e) => e.copyWith()));
    final double originalSavingsBalance = _savingsBalance;
    final List<Transaction> originalTransactions = List.from(_transactions);

    try {
      _savingsBalance -= amount;
      if (isToCard) {
        final index = _cards.indexWhere((c) => c.id == effectiveToCardId);
        _cards[index] = _cards[index].copyWith(balance: _cards[index].balance + amount);
      } else {
        _balance += amount;
      }

      final tx = Transaction(
        id: "TX${DateTime.now().millisecondsSinceEpoch}",
        title: goalName != null ? "Withdraw from $goalName" : (isToCard ? "Withdraw to Card" : "Withdraw from Savings"),
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
      _saveCards();
      await _prefs.setDouble('savings_balance', _savingsBalance);
      _saveTransactions();

      notifyListeners();
      analytics.logEvent('savings_withdraw_success', parameters: {'amount': amount, 'to_card': isToCard});
    } catch (e) {
      // Rollback
      _balance = originalBalance;
      _cards = originalCards;
      _savingsBalance = originalSavingsBalance;
      _transactions = originalTransactions;
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

  // Temporary hack to get context for l10n in state
  // In a real app, you'd use a better service locator or pass context/l10n as params
  BuildContext? contextForL10n;
}
