import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app_analytics.dart';
import 'app_colors.dart';
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
  
  double _dailyLimit = 2000.0;
  double _todaySpent = 450.0;
  double get dailyLimit => _dailyLimit;
  double get remainingLimit => _dailyLimit - _todaySpent;

  String _userName = "Mohamed Osman";
  String get userName => _userName;
  String _currencyCode = "USD";
  String get currencyCode => _currencyCode;
  
  bool _biometricEnabled = true;
  bool get biometricEnabled => _biometricEnabled;

  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  List<Map<String, String>> _recentWithdrawals = [
    {"name": "Ahmed Abdi", "detail": "615000111", "provider": "EVC Plus", "type": "mobile"},
  ];
  List<Map<String, String>> get recentWithdrawals => _recentWithdrawals;

  List<QuickProfile> _quickProfiles = [
    QuickProfile(id: "1", name: "Sahra Ali", walletId: "102236", initials: "SA", color: Colors.blue),
  ];
  List<QuickProfile> get quickProfiles => _quickProfiles;

  List<CardModel> _cards = [
    CardModel(id: "C1", cardNumber: "**** **** **** 1234", expiryDate: "12/26", cardHolder: "MOHAMED OSMAN", balance: 1500.0, type: "Virtual", status: "Active"),
  ];
  List<CardModel> get cards => _cards;
  
  List<NotificationData> _notifications = [];
  List<NotificationData> get notifications => _notifications;

  final Map<String, String> mockUsers = {
    "102235": "Ahmed Abdi",
    "102236": "Sahra Ali",
    "102237": "Hassan Nur",
    "+252615000111": "Fartun Duale",
  };

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadTransactions();
    _isInitialized = true;
    notifyListeners();
  }

  void addNotification(NotificationData notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  bool verifyPin(String pin) => pin == "0011";

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
      amount: "\$${amount.toStringAsFixed(2)}",
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

    addNotification(NotificationData(
      title: isSplit ? "Split Bill Requested" : "Money Requested",
      subtitle: isSplit 
          ? "You requested a split of ${tx.amount} from $splitCount people."
          : "You requested ${tx.amount} from $receiverName.",
      time: "Just now",
      type: 3,
      icon: Icons.request_page_rounded,
      iconColor: AppColors.accentTeal,
      extraData: {
        'requestId': tx.id,
        'amount': amount,
        'receiverName': receiverName,
        'isSplit': isSplit,
      },
    ));

    await _saveTransactions();
    notifyListeners();
  }

  Future<void> approveMoneyRequest(String requestId, String pin) async {
    if (!verifyPin(pin)) throw Exception("Invalid PIN");
    
    final txIdx = _transactions.indexWhere((t) => t.id == requestId);
    if (txIdx == -1) throw Exception("Request not found");
    
    final req = _transactions[txIdx];
    if (_balance < req.numericAmount) throw Exception("insufficient_funds");
    
    if (req.numericAmount > remainingLimit) throw Exception("daily_limit_exceeded");

    _balance -= req.numericAmount;
    _todaySpent += req.numericAmount;
    
    _transactions[txIdx] = req.copyWith(
      status: "Success",
      isNegative: true,
      amount: "-\$${req.numericAmount.toStringAsFixed(2)}",
    );
    
    addNotification(NotificationData(
      title: "Request Paid",
      subtitle: "You paid \$${req.numericAmount.toStringAsFixed(2)} to ${req.referenceId}",
      time: "Just now",
      type: 1,
      icon: Icons.check_circle,
      iconColor: AppColors.accentTeal,
    ));

    await _saveTransactions();
    notifyListeners();
  }

  Future<void> _loadTransactions() async {
    final List<String>? txJson = _prefs.getStringList('transactions');
    if (txJson != null) {
      _transactions = txJson.map((e) => Transaction.fromJson(json.decode(e))).toList();
    } else {
      _transactions = [
        Transaction(id: "1", title: "Zaad Deposit", date: "Oct 28", amount: "+\$500.00", numericAmount: 500.0, isNegative: false, category: "Deposit", status: "Success", type: "deposit"),
      ];
    }
  }

  Future<void> _saveTransactions() async {
    final List<String> txJson = _transactions.map((e) => json.encode(e.toJson())).toList();
    await _prefs.setStringList('transactions', txJson);
  }

  Future<String?> verifyWalletId(String id) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return mockUsers[id];
  }

  void updateMarketRates() {}
  void setNavIndex(int index) {}

  double calculateFeeForSource(double amount, String source, {String? payoutMethod}) {
    if (source.contains("International")) return amount * 0.025;
    if (source.contains("Bank")) return 0.50;
    if (source.contains("Mobile")) return math.max(0.10, amount * 0.01);
    return 0.0;
  }

  void addBalance(double amount) {
    _balance += amount;
    notifyListeners();
  }

  void addTransaction(Transaction tx) {
    _transactions.insert(0, tx);
    _saveTransactions();
    notifyListeners();
  }

  Future<Transaction> processWalletWithdrawal({
    required double amount,
    required double fee,
    required String method,
    required String detail,
    required String provider,
    required String name,
    required String type,
    required String purpose,
  }) async {
    if (_balance < (amount + fee)) throw Exception("insufficient_funds");
    if (amount > remainingLimit) throw Exception("daily_limit_exceeded");
    
    _balance -= (amount + fee);
    _todaySpent += amount;

    final tx = Transaction(
      id: "WTH-${DateTime.now().millisecondsSinceEpoch}",
      title: "Withdrawal to $provider",
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: "-\$${amount.toStringAsFixed(2)}",
      numericAmount: amount,
      isNegative: true,
      category: "Withdrawal",
      status: "Success",
      type: "withdrawal",
      method: method,
      referenceId: detail,
      timestamp: DateTime.now(),
    );

    _transactions.insert(0, tx);
    await _saveTransactions();
    
    // Add to recent if not exists
    if (!_recentWithdrawals.any((r) => r['detail'] == detail)) {
      _recentWithdrawals.insert(0, {"name": name, "detail": detail, "provider": provider, "type": type});
    }

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
    required String purpose,
  }) async {
    final cardIdx = _cards.indexWhere((c) => c.id == cardId);
    if (cardIdx == -1) throw Exception("Card not found");
    
    if (_cards[cardIdx].balance < (amount + fee)) throw Exception("insufficient_funds");

    _cards[cardIdx] = _cards[cardIdx].copyWith(
      balance: _cards[cardIdx].balance - (amount + fee)
    );

    final tx = Transaction(
      id: "CWTH-${DateTime.now().millisecondsSinceEpoch}",
      title: "Card Withdrawal to $provider",
      date: DateFormat('MMM dd').format(DateTime.now()),
      amount: "-\$${amount.toStringAsFixed(2)}",
      numericAmount: amount,
      isNegative: true,
      category: "Withdrawal",
      status: "Success",
      type: "card_withdrawal",
      method: method,
      referenceId: detail,
      timestamp: DateTime.now(),
    );

    _transactions.insert(0, tx);
    await _saveTransactions();
    notifyListeners();
    return tx;
  }

  bool verifyCardPin(String pin, {String? cardId}) => pin == "1122";

  void addBank(BankAccount bank) {}

  String translate(String en, String so, {String? ar, String? de}) {
    // Mock translation logic
    return en;
  }
}
