import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../chat/chat_screen.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../core/responsive_utils.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/detail_row.dart';
import '../../core/app_state.dart';
import '../../core/widgets/success_screen.dart';
import '../../core/models/transaction.dart' as model;

enum HagbadStatus { active, inactive, failed }
enum HagbadFrequency { daily, weekly, tenDays, monthly, yearly }

class HagbadGroup {
  final String id;
  final String name;
  final String adminName;
  final double amount;
  final double serviceFee;
  final double penaltyPerDay; // Added: Daily penalty for late payment
  final HagbadFrequency frequency;
  final HagbadStatus status;
  final List<HagbadMember> members;
  final DateTime startDate;
  final int totalCycles;
  final int currentCycle;

  HagbadGroup({
    required this.id,
    required this.name,
    required this.adminName,
    required this.amount,
    this.serviceFee = 0.0,
    this.penaltyPerDay = 2.0, // Default $2 penalty
    required this.frequency,
    required this.status,
    required this.members,
    required this.startDate,
    this.totalCycles = 10,
    this.currentCycle = 4,
  });

  double get progress => currentCycle / totalCycles;
  double get potProgress => members.isEmpty ? 0 : members.where((m) => m.paidAmount >= amount).length / members.length;
  double get totalPayout => amount * members.length;
  double get currentBalance => members.fold(0.0, (sum, m) => sum + m.paidAmount);
}

class HagbadMember {
  final String name;
  final String? walletId; // Added Wallet ID for verification
  final double paidAmount;
  final double penaltyAmount; // Added for Late Fees
  final DateTime? lastPaymentDate; // Added for History
  final bool hasReceived;
  final bool isTrusted;
  final bool isConfirmed; // Added for invitation acceptance
  final bool hasSignedOath; // Added for Dhaar (Religious Oath)
  final String? guarantorName;
  final String? guarantorId; // Added Guarantor ID
  final bool isGuarantorConfirmed; // Added for Uul acceptance
  final String avatar;
  final int payoutOrder;

  HagbadMember({
    required this.name,
    this.walletId,
    this.paidAmount = 0.0,
    this.penaltyAmount = 0.0,
    this.lastPaymentDate,
    required this.hasReceived,
    required this.isTrusted,
    this.isConfirmed = false,
    this.hasSignedOath = false,
    this.guarantorName,
    this.guarantorId,
    this.isGuarantorConfirmed = false,
    required this.avatar,
    required this.payoutOrder,
  });

  bool isFullyPaid(double totalRequired) => paidAmount >= (totalRequired + penaltyAmount);
}

class HagbadScreen extends StatefulWidget {
  const HagbadScreen({super.key});

  @override
  State<HagbadScreen> createState() => _HagbadScreenState();
}

class _HagbadScreenState extends State<HagbadScreen> {
  final List<HagbadGroup> _groups = [
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
        HagbadMember(name: "Khadar", paidAmount: 50.0, hasReceived: true, isTrusted: true, avatar: "K", payoutOrder: 1, guarantorName: "Abdirahman Ali", isConfirmed: true, hasSignedOath: true, isGuarantorConfirmed: true),
        HagbadMember(name: "Ahmed", paidAmount: 50.0, hasReceived: false, isTrusted: true, avatar: "A", payoutOrder: 2, isConfirmed: true, hasSignedOath: true, isGuarantorConfirmed: true),
        HagbadMember(name: "You", paidAmount: 0.0, hasReceived: false, isTrusted: true, avatar: "Y", payoutOrder: 3, isConfirmed: false, hasSignedOath: false, isGuarantorConfirmed: true),
        HagbadMember(name: "Maryan", paidAmount: 20.0, hasReceived: false, isTrusted: false, avatar: "M", payoutOrder: 4, isConfirmed: true, hasSignedOath: false, isGuarantorConfirmed: true),
        HagbadMember(name: "Abdi", paidAmount: 50.0, hasReceived: false, isTrusted: false, avatar: "A", payoutOrder: 5, isConfirmed: false, hasSignedOath: false, isGuarantorConfirmed: true),
      ],
    ),
    HagbadGroup(
      id: '2',
      name: "Business Partners",
      adminName: "Warsame",
      amount: 200.0,
      frequency: HagbadFrequency.weekly,
      status: HagbadStatus.active,
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      totalCycles: 8,
      currentCycle: 2,
      members: [
        HagbadMember(name: "Warsame", paidAmount: 200.0, hasReceived: false, isTrusted: true, avatar: "W", payoutOrder: 1, isConfirmed: true, hasSignedOath: true, isGuarantorConfirmed: true),
        HagbadMember(name: "Khadar", paidAmount: 200.0, hasReceived: true, isTrusted: true, avatar: "K", payoutOrder: 2, isConfirmed: true, hasSignedOath: true, isGuarantorConfirmed: true),
        HagbadMember(name: "Sahra", paidAmount: 100.0, hasReceived: false, isTrusted: true, avatar: "S", payoutOrder: 3, isConfirmed: true, hasSignedOath: true, isGuarantorConfirmed: false, guarantorName: "You", guarantorId: "Admin-ID"),
      ],
    ),
  ];

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _feeController = TextEditingController();
  final _memberController = TextEditingController();
  HagbadFrequency _selectedFrequency = HagbadFrequency.monthly;
  List<Map<String, String>> _newGroupMembersWithDetails = []; // Store name and ID
  List<Map<String, String>> _suggestedUsers = [];
  bool _isDrawing = false;
  bool _isSearchingUser = false;
  String? _searchError;
  bool _hasAcceptedTerms = false;
  bool _hasConfirmedOath = false;

  final Map<String, Map<String, String>> _mockUsers = {
    '615123456': {'name': 'Abdirahman Ali', 'id': 'MX-9021', 'phone': '615123456'},
    '615998877': {'name': 'Sahra Hassan', 'id': 'MX-4432', 'phone': '615998877'},
    '612000111': {'name': 'Mohamed Ghedi', 'id': 'MX-1120', 'phone': '612000111'},
    '639123456': {'name': 'Ahmed Cali', 'id': 'MX-6301', 'phone': '639123456'},
    '905123456': {'name': 'Mustaf Golis', 'id': 'MX-9005', 'phone': '905123456'},
    '619712345': {'name': 'Aisha Omar', 'id': 'MX-6101', 'phone': '619712345'},
    '617123456': {'name': 'Ibrahim Warsame', 'id': 'MX-2523', 'phone': '617123456'},
    '612299887': {'name': 'Hodan Abdi', 'id': 'MX-2524', 'phone': '612299887'},
    // Somalia - Puntland (252-90)
    '907712345': {'name': 'Jaamac Boqor', 'id': 'MX-2521', 'phone': '907712345'},
    '906655443': {'name': 'Fadumo Puntland', 'id': 'MX-2522', 'phone': '906655443'},
    '907712346': {'name': 'Warsame Garowe', 'id': 'MX-9091', 'phone': '907712346'},
  };

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _feeController.dispose();
    _memberController.dispose();
    super.dispose();
  }

  void _createNewGroup() {
    final l10n = AppLocalizations.of(context)!;
    if (_nameController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseFillAllFields)),
      );
      return;
    }

    setState(() {
      final List<HagbadMember> members = _newGroupMembersWithDetails.asMap().entries.map((entry) {
        int idx = entry.key;
        var details = entry.value;
        return HagbadMember(
          name: details['name']!,
          walletId: details['walletId'],
          paidAmount: 0.0,
          hasReceived: false,
          avatar: details['name'] == "You" ? "Y" : details['name']!.substring(0, 1).toUpperCase(),
          payoutOrder: idx + 1,
          guarantorName: details['guarantorName'],
          guarantorId: details['guarantorId'],
          isTrusted: details['name'] == "You",
          isConfirmed: details['name'] == "You", // Admin is already confirmed
          hasSignedOath: details['name'] == "You", // Admin already signed
        );
      }).toList();

      _groups.add(
        HagbadGroup(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          adminName: l10n.youAdmin,
          amount: double.tryParse(_amountController.text) ?? 0,
          serviceFee: double.tryParse(_feeController.text) ?? 0.0,
          frequency: _selectedFrequency,
          status: HagbadStatus.active,
          startDate: DateTime.now(),
          totalCycles: members.length,
          currentCycle: 1,
          members: members,
        ),
      );
    });

    _nameController.clear();
    _amountController.clear();
    _feeController.clear();
    _memberController.clear();
    _newGroupMembersWithDetails = [];
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(child: Text(l10n.hagbadCreatedSuccess, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
            const Flexible(child: Text("Ogeysiis iyo Dhaar ayaa loo diray xubnaha oo dhan.", style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _performQoriTuur(StateSetter setModalState) async {
    if (_newGroupMembersWithDetails.length < 2) return;

    setModalState(() {
      _isDrawing = true;
    });

    // 1. Initial Shuffle Sound Simulation (Visual)
    for (int i = 0; i < 15; i++) {
      await Future.delayed(Duration(milliseconds: 50 + (i * 15)));
      setModalState(() {
        _newGroupMembersWithDetails.shuffle();
      });
    }

    // 2. Ensuring 'You' is not always last or first
    setModalState(() {
      _newGroupMembersWithDetails.shuffle();
      _isDrawing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.shuffle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Text("Qori-tuurka waa lagu guuleystay! Kala horreyntu waa diyaar."),
            ],
          ),
          backgroundColor: AppColors.primaryDark,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _performLiveQoriTuur(HagbadGroup group) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Check if all members are confirmed
    bool allConfirmed = group.members.every((m) => m.isConfirmed && m.hasSignedOath);
    if (!allConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lama samayn karo Qori-tuur ilaa dhammaan xubnuhu aqbalaan dhaaranaana."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isDrawing = true);

    // Visual animation in the list
    for (int i = 0; i < 20; i++) {
      await Future.delayed(Duration(milliseconds: 100 + (i * 10)));
      setState(() {
        group.members.shuffle();
      });
    }

    setState(() {
      // Finalize the order
      for (int i = 0; i < group.members.length; i++) {
        final m = group.members[i];
        group.members[i] = HagbadMember(
          name: m.name,
          walletId: m.walletId,
          avatar: m.avatar,
          payoutOrder: i + 1, // New order
          paidAmount: m.paidAmount,
          hasReceived: m.hasReceived,
          isTrusted: m.isTrusted,
          isConfirmed: m.isConfirmed,
          hasSignedOath: m.hasSignedOath,
          guarantorName: m.guarantorName,
          guarantorId: m.guarantorId,
        );
      }
      _isDrawing = false;
    });

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("🎰 Qori-tuurku waa Dhammaaday!", textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Kala horreynta cusub ee xubnaha waa tan:"),
              const SizedBox(height: 16),
              ...group.members.map((m) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    CircleAvatar(radius: 12, backgroundColor: AppColors.primaryDark, child: Text("${m.payoutOrder}", style: const TextStyle(fontSize: 10, color: Colors.white))),
                    const SizedBox(width: 12),
                    Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )).toList(),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hagaag")),
          ],
        ),
      );
    }
  }

  // Simulation logic for searching a MurtaaxPay User
  void _lookupAndAddMember(StateSetter setModalState, {Map<String, String>? selectedUser}) async {
    String phone = selectedUser != null ? selectedUser['phone']! : _memberController.text.trim();
    if (phone.isEmpty) return;

    // Normalize input to 9 digits by stripping common prefixes
    phone = phone.replaceAll(RegExp(r'\D'), ''); // Strip non-digits
    if (phone.startsWith('252') && phone.length > 9) {
      phone = phone.substring(3);
    } else if (phone.startsWith('0') && phone.length == 10) {
      phone = phone.substring(1);
    }
    
    // Ensure we are looking for the last 9 digits if it's too long
    if (phone.length > 9) {
      phone = phone.substring(phone.length - 9);
    }

    setModalState(() {
      _isSearchingUser = true;
      _searchError = null;
      _suggestedUsers = []; // Clear suggestions when searching
    });

    // Simulate Network Delay (skip if selected from list for snappier feel)
    if (selectedUser == null) {
      await Future.delayed(const Duration(milliseconds: 800));
    }

    if (_mockUsers.containsKey(phone)) {
      final user = _mockUsers[phone]!;
      
      // Simulation: Users with MX-256 prefixes are "Not Trusted" for this demo to trigger guarantor flow
      bool requiresGuarantor = user['id']!.contains("256") || user['id']!.contains("252");

      if (requiresGuarantor) {
        _showGuarantorDialog(setModalState, user);
      } else {
        setModalState(() {
          if (!_newGroupMembersWithDetails.any((m) => m['walletId'] == user['id'])) {
            _newGroupMembersWithDetails.add({
              'name': user['name']!,
              'walletId': user['id']!,
            });
            _memberController.clear();
          } else {
            _searchError = "User already added";
          }
        });
      }
      
      setModalState(() => _isSearchingUser = false);
    } else {
      setModalState(() {
        _searchError = "User not found on MurtaaxPay";
        _isSearchingUser = false;
      });
    }
  }

  void _showGuarantorDialog(StateSetter setModalState, Map<String, String> user) {
    final l10n = AppLocalizations.of(context)!;
    final gNameController = TextEditingController();
    final gIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.guarantorDetails, style: const TextStyle(color: Colors.orange)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.requireGuarantor, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: gNameController,
              decoration: InputDecoration(labelText: l10n.guarantorNameLabel, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: gIdController,
              decoration: InputDecoration(labelText: l10n.guarantorIdLabel, border: const OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              if (gNameController.text.isNotEmpty && gIdController.text.isNotEmpty) {
                setModalState(() {
                  _newGroupMembersWithDetails.add({
                    'name': user['name']!,
                    'walletId': user['id']!,
                    'guarantorName': gNameController.text,
                    'guarantorId': gIdController.text,
                  });
                  _memberController.clear();
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark),
            child: Text(l10n.add, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _filterSuggestions(String query, StateSetter setModalState) {
    if (query.length < 2) {
      setModalState(() {
        _suggestedUsers = [];
        _searchError = null;
      });
      return;
    }

    // Normalize query for better matching
    String normalizedQuery = query.replaceAll(RegExp(r'\D'), '');
    if (normalizedQuery.startsWith('252') && normalizedQuery.length > 9) {
      normalizedQuery = normalizedQuery.substring(3);
    }

    final matches = _mockUsers.values.where((user) {
      final phoneMatch = user['phone']!.contains(normalizedQuery.isNotEmpty ? normalizedQuery : query);
      final nameMatch = user['name']!.toLowerCase().contains(query.toLowerCase());
      
      // Filter out users who are already in the group members list
      final isAlreadyInGroup = _newGroupMembersWithDetails.any((m) => m['walletId'] == user['id']);
      
      return (phoneMatch || nameMatch) && !isAlreadyInGroup;
    }).toList();

    setModalState(() {
      _suggestedUsers = matches;
    });
  }

  void _showPaymentSheet(HagbadGroup group) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              l10n.payContribution,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
            ),
            const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryDark.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    DetailRow(label: l10n.groupName, value: group.name),
                    const Divider(height: 24),
                    DetailRow(label: l10n.contributionAmount, value: "\$${group.amount.toStringAsFixed(0)}", isBold: true),
                    DetailRow(label: l10n.payoutMethod, value: l10n.hagbadPot),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.hagbadTermsDesc,
                    style: TextStyle(fontSize: 12, color: theme.hintColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _processHagbadPayment(group);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  "${l10n.confirm} \$${group.amount.toStringAsFixed(0)}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, ThemeData theme, {bool isBold = false}) {
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.white70 : theme.hintColor, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _processHagbadPayment(HagbadGroup group) async {
    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context, listen: false);
    final currencyFormatter = NumberFormat.currency(symbol: '\$');

    // 1. Show PIN/Wallet Confirmation Dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFE91E63), // Pinkish color for wallet
                child: Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 16),
              Text(l10n.murtaaxWallet, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Text("${l10n.balance}: ${currencyFormatter.format(appState.balance)}", style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(l10n.confirmPaymentAmount("\$${group.amount.toStringAsFixed(0)}"), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextField(
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 4,
                style: const TextStyle(fontSize: 24, letterSpacing: 16, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: "••••",
                  counterText: "",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(l10n.confirm, style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    // 2. Show Loading
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primaryDark)),
      );
    }

    // Simulate Payment Processing
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.pop(context); // Close loading
      
      // Update state and Notify Group Chat
      setState(() {
        final youIndex = group.members.indexWhere((m) => m.name == "You");
        if (youIndex != -1) {
          final member = group.members[youIndex];
          group.members[youIndex] = HagbadMember(
            name: member.name,
            walletId: member.walletId,
            avatar: member.avatar,
            payoutOrder: member.payoutOrder,
            paidAmount: group.amount,
            penaltyAmount: member.penaltyAmount,
            lastPaymentDate: DateTime.now(),
            hasReceived: member.hasReceived,
            isTrusted: member.isTrusted,
            isConfirmed: member.isConfirmed,
            hasSignedOath: member.hasSignedOath,
            guarantorName: member.guarantorName,
            guarantorId: member.guarantorId,
            isGuarantorConfirmed: member.isGuarantorConfirmed,
          );
        }
      });
      
      // Deduct from real AppState
      appState.deductBalance(group.amount);

      // Add to global transaction history
      appState.addTransaction(model.Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: "Hagbad: ${group.name}",
        date: DateFormat('MMM dd').format(DateTime.now()),
        amount: "-${currencyFormatter.format(group.amount)}",
        isNegative: true,
        category: "Savings",
        status: "Success",
        type: "payment",
      ));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            title: l10n.paymentSuccessful,
            message: "Qaaraankaaga dhan \$${group.amount.toStringAsFixed(0)} si guul leh ayaa loogu shubay Sanduuqa (Pot).",
            subMessage: l10n.newBalance(currencyFormatter.format(appState.balance)),
            buttonText: l10n.backToHome,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );
    }
  }

  // Remove the old _showSuccessPage as it's no longer used

  void _showWithdrawalSheet(HagbadGroup group) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final totalPayout = group.totalPayout - group.serviceFee;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.amber, size: 28),
                const SizedBox(width: 12),
                Text(
                  l10n.payoutReady,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.withOpacity(0.1), Colors.blue.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  DetailRow(label: l10n.totalPot, value: "\$${group.totalPayout.toStringAsFixed(0)}"),
                  if (group.serviceFee > 0)
                    DetailRow(label: l10n.serviceFee, value: "-\$${group.serviceFee.toStringAsFixed(0)}"),
                  const Divider(height: 24),
                  DetailRow(
                    label: l10n.amountToReceive,
                    value: "\$${totalPayout.toStringAsFixed(0)}",
                    isBold: true,
                    valueColor: Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.primaryDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.walletIdTransferNotice,
                    style: TextStyle(fontSize: 12, color: theme.hintColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _processHagbadWithdrawal(group);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  l10n.claimPayout,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _processHagbadWithdrawal(HagbadGroup group) async {
    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context, listen: false);
    final currencyFormatter = NumberFormat.currency(symbol: '\$');
    final payoutAmount = group.totalPayout - group.serviceFee;

    // Show Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.green)),
    );

    // Simulate Withdrawal Processing
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.pop(context); // Close loading
      
      // Update real AppState balance
      appState.addBalance(payoutAmount);

      // Add to global transaction history
      appState.addTransaction(model.Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: "Hagbad Payout: ${group.name}",
        date: DateFormat('MMM dd').format(DateTime.now()),
        amount: "+${currencyFormatter.format(payoutAmount)}",
        isNegative: false,
        category: "Income",
        status: "Success",
        type: "deposit",
      ));

      setState(() {
        // Mark "You" as received
        for (int i = 0; i < group.members.length; i++) {
          if (group.members[i].name == "You") {
            group.members[i] = HagbadMember(
              name: group.members[i].name,
              avatar: group.members[i].avatar,
              payoutOrder: group.members[i].payoutOrder,
              paidAmount: group.members[i].paidAmount,
              hasReceived: true, // Mark as received
              isTrusted: group.members[i].isTrusted,
              guarantorName: group.members[i].guarantorName,
            );
          }
        }
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            title: "Hambalyo!",
            message: "Waxaad si guul leh ula baxday \$${payoutAmount.toStringAsFixed(0)}. Lacagtu waxay hadda ku jirtaa Wallet-kaaga.",
            subMessage: l10n.newBalance(currencyFormatter.format(appState.balance)),
            buttonText: l10n.ok,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.hagbad, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            onPressed: () => _showCreateGroupBottomSheet(context),
            icon: Icon(Icons.add_circle_outline_rounded, color: isDark ? Colors.white : AppColors.primaryDark),
          ),
        ],
      ),
      body: context.responsiveBody(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.horizontalPadding,
            vertical: context.verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: _buildSummaryCard(isDark, l10n),
              ),
              const SizedBox(height: 32),
              FadeInLeft(
                delay: const Duration(milliseconds: 200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.myGroups,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        fontSize: (theme.textTheme.titleLarge?.fontSize ?? 20) * context.fontSizeFactor,
                      ),
                    ),
                    Text(
                      "${_groups.length} ${l10n.activeGroups}",
                      style: TextStyle(color: theme.hintColor, fontSize: 14 * context.fontSizeFactor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_groups.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text(l10n.noHagbadGroups, style: TextStyle(color: theme.hintColor)),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _groups.length,
                  itemBuilder: (context, index) {
                    return FadeInUp(
                      delay: Duration(milliseconds: 300 + (index * 100)),
                      child: _buildGroupCard(_groups[index], theme, isDark, l10n),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGroupBottomSheet(context),
        backgroundColor: AppColors.primaryDark,
        label: Text(l10n.createHagbad, style: const TextStyle(color: Colors.white)),
        icon: const Icon(Icons.group_add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard(bool isDark, AppLocalizations l10n) {
    final appState = Provider.of<AppState>(context);
    final currencyFormatter = NumberFormat.currency(symbol: '\$');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.responsiveValue(mobile: 20.0, tablet: 32.0)),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(isDark ? 0.5 : 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.totalSavingsPot,
            style: TextStyle(color: Colors.white70, fontSize: 14 * context.fontSizeFactor),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormatter.format(appState.balance),
            style: TextStyle(
              color: Colors.white,
              fontSize: 32 * context.fontSizeFactor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _buildSummaryStat(l10n.activeGroups, "${_groups.where((g) => g.status == HagbadStatus.active).length}", Icons.groups_rounded),
              _buildSummaryStat(l10n.nextPayout, "12 ${l10n.days}", Icons.event_repeat_rounded),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 16 * context.fontSizeFactor),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white70, fontSize: 12 * context.fontSizeFactor)),
            Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
          ],
        )
      ],
    );
  }

  Widget _buildGroupCard(HagbadGroup group, ThemeData theme, bool isDark, AppLocalizations l10n) {
    final nextReceiver = group.members.firstWhere((m) => !m.hasReceived, orElse: () => group.members.first);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: context.responsiveValue(mobile: 16.0, tablet: 24.0),
            vertical: 8,
          ),
          iconColor: isDark ? Colors.white70 : AppColors.primaryDark,
          collapsedIconColor: isDark ? Colors.white30 : Colors.grey,
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48 * context.fontSizeFactor,
                height: 48 * context.fontSizeFactor,
                decoration: BoxDecoration(
                  color: _getStatusColor(group.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    _getStatusIcon(group.status),
                    color: _getStatusColor(group.status),
                    size: 24 * context.fontSizeFactor,
                  ),
                ),
              ),
              if (group.members.any((m) => !m.isConfirmed))
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_active, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          title: Text(
            group.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              fontSize: 16 * context.fontSizeFactor,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    "\$${group.amount.toStringAsFixed(0)} / ${_getFrequencyText(group.frequency, l10n)}",
                    style: TextStyle(color: theme.hintColor, fontSize: 12 * context.fontSizeFactor),
                  ),
                  Text(
                    "${l10n.currentBalance}: \$${group.currentBalance.toStringAsFixed(0)}",
                    style: TextStyle(
                      color: isDark ? Colors.greenAccent : Colors.green.shade700,
                      fontSize: 12 * context.fontSizeFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      "\$${group.amount.toStringAsFixed(0)} / ${_getFrequencyText(group.frequency, l10n)}",
                      style: TextStyle(color: theme.hintColor, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "${l10n.currentBalance}: \$${group.currentBalance.toStringAsFixed(0)}",
                      style: TextStyle(
                        color: isDark ? Colors.greenAccent : Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,

                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: group.progress,
                      backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
                      minHeight: 12 * context.fontSizeFactor,
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        "${(group.progress * 10).toStringAsFixed(0)}/10 ${l10n.members} ${l10n.received.toLowerCase()}",
                        style: TextStyle(fontSize: 8 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "\$${group.currentBalance.toStringAsFixed(0)} / \$${group.totalPayout.toStringAsFixed(0)} ${l10n.hagbadPot}",
                style: TextStyle(fontSize: 10 * context.fontSizeFactor, color: theme.hintColor, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: isDark ? Colors.white10 : Colors.grey.shade200),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      Expanded(child: _buildInfoItem(l10n.nextInLine, nextReceiver.name, theme, isHighlight: true)),
                      Expanded(child: Center(child: _buildInfoItem(l10n.potWadar, "\$${group.totalPayout.toStringAsFixed(0)}", theme))),
                      Expanded(child: Align(alignment: Alignment.centerRight, child: _buildInfoItem(l10n.progress, "${group.currentCycle}/${group.totalCycles}", theme))),
                    ],
                  ),
                  if (group.serviceFee > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.withOpacity(0.1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.payoutAfterFee("\$${group.serviceFee.toStringAsFixed(0)}"), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                            Text(
                              "\$${(group.totalPayout - group.serviceFee).toStringAsFixed(0)}",
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text(
                        l10n.rotation,
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 14 * context.fontSizeFactor, 
                          color: theme.colorScheme.onSurface
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (group.adminName == l10n.youAdmin)
                                TextButton.icon(
                                  onPressed: () => _performLiveQoriTuur(group),
                                  icon: const Icon(Icons.shuffle_rounded, size: 14),
                                  label: const Text("Qori-tuurka", style: TextStyle(fontSize: 12)),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8), 
                                    foregroundColor: Colors.purple,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8), 
                                      side: BorderSide(color: Colors.purple.withOpacity(0.2)),
                                    ),
                                  ),
                                ),
                              if (group.adminName == l10n.youAdmin && group.members.any((m) => !m.isFullyPaid(group.amount)))
                                TextButton.icon(
                                  onPressed: () => _remindAllPending(group),
                                  icon: const Icon(Icons.notifications_active_outlined, size: 14),
                                  label: Text(l10n.remindAll, style: const TextStyle(fontSize: 12)),
                                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), foregroundColor: Colors.orange),
                                ),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        userId: group.id,
                                        userName: group.name,
                                        userAvatar: group.name[0],
                                        isGroup: true,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14),
                                label: Text(l10n.groupChat, style: const TextStyle(fontSize: 12)),
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: AppColors.primaryDark),
                              ),
                            ],

                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...group.members.asMap().entries.map((entry) => _buildMemberItem(group, entry.value, entry.key, group.frequency, theme, isDark, l10n)),
                  
                  // Payment History Section
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.history_rounded, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        l10n.paymentHistory,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentHistory(group, l10n, isDark),
                  
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (nextReceiver.name == "You" && !nextReceiver.hasReceived)
                        ElevatedButton(
                          onPressed: () => _showWithdrawalSheet(group),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.account_balance_wallet_rounded, size: 18 * context.fontSizeFactor),
                              const SizedBox(width: 8),
                              Text(l10n.claimPayout),
                            ],
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: () => _showPaymentSheet(group),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: Text(l10n.payContribution),
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton.filled(
                            onPressed: () {
                              // NEW: Admin Manual Penalty Trigger (For testing/Simulation)
                              if (group.adminName == "Khadar Abdi") {
                                 _showPenaltyDialog(group, group.members.indexWhere((m) => m.name == "Maryan"));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                        const SizedBox(width: 12),
                                        Text(l10n.receiptDownloaded),
                                      ],
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.download_rounded, size: 20 * context.fontSizeFactor),
                            tooltip: l10n.downloadReceipt,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blue.withOpacity(0.1),
                              foregroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.outlined(
                            onPressed: () {},
                            icon: Icon(Icons.share_outlined, size: 20 * context.fontSizeFactor),
                            style: IconButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showDhaarDialog(HagbadGroup group, HagbadMember member) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.mosque_rounded, color: Colors.purple, size: 48),
            const SizedBox(height: 16),
            Text(l10n.hagbadOath, style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.hagbadOathDesc, 
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.withOpacity(0.1)),
              ),
              child: const Text(
                "Waxaan ku dhaaranayaa magaca Ilaaha Qaadirka ah inaan bixin doono qaaraanka Hagbad-ka waqtigiisa, si daacad ahna ugu adeegi doono kooxdan.",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, height: 1.5),
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text(l10n.cancel, style: TextStyle(color: Colors.grey.shade600)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              setState(() {
                int idx = group.members.indexOf(member);
                group.members[idx] = HagbadMember(
                  name: member.name,
                  walletId: member.walletId,
                  avatar: member.avatar,
                  payoutOrder: member.payoutOrder,
                  paidAmount: member.paidAmount,
                  hasReceived: member.hasReceived,
                  isTrusted: member.isTrusted,
                  isConfirmed: member.isConfirmed,
                  hasSignedOath: true,
                  guarantorName: member.guarantorName,
                  guarantorId: member.guarantorId,
                );
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.verified_user, color: Colors.white),
                      const SizedBox(width: 12),
                      const Text("Dhaarta waa la aqbalay! Hadda waxaad tahay xubin rasmi ah."),
                    ],
                  ),
                  backgroundColor: Colors.purple,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l10n.iConfirmOath, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, ThemeData theme, {bool isHighlight = false}) {
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 11 * context.fontSizeFactor), overflow: TextOverflow.ellipsis),
        Text(
          value, 
          style: TextStyle(
            fontWeight: FontWeight.w600, 
            fontSize: 13 * context.fontSizeFactor,
            color: isHighlight 
              ? (isDark ? Colors.blue[300] : AppColors.primaryDark) 
              : theme.colorScheme.onSurface
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _getTurnLabel(HagbadFrequency freq, int order, AppLocalizations l10n) {
    switch (freq) {
      case HagbadFrequency.daily:
        return l10n.dayWithNumber(order);
      case HagbadFrequency.weekly:
        return l10n.weekWithNumber(order);
      case HagbadFrequency.monthly:
        return l10n.monthWithNumber(order);
      case HagbadFrequency.tenDays:
      case HagbadFrequency.yearly:
        return l10n.turnWithNumber(order);
    }
  }

  void _swapMemberTurn(HagbadGroup group, int index1, int index2) {
    if (group.members[index1].hasReceived || group.members[index2].hasReceived) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.cannotSwapReceived),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      final member1 = group.members[index1];
      final member2 = group.members[index2];

      // Swap the payoutOrder logic
      final tempOrder = member1.payoutOrder;
      
      // We need to create new objects because fields are final
      group.members[index1] = HagbadMember(
        name: member1.name,
        avatar: member1.avatar,
        payoutOrder: member2.payoutOrder,
        paidAmount: member1.paidAmount,
        hasReceived: member1.hasReceived,
        guarantorName: member1.guarantorName,
        isTrusted: member1.isTrusted,
      );

      group.members[index2] = HagbadMember(
        name: member2.name,
        avatar: member2.avatar,
        payoutOrder: tempOrder,
        paidAmount: member2.paidAmount,
        hasReceived: member2.hasReceived,
        guarantorName: member2.guarantorName,
        isTrusted: member2.isTrusted,
      );

      // Re-sort the list by payoutOrder to reflect the UI change
      group.members.sort((a, b) => a.payoutOrder.compareTo(b.payoutOrder));
    });
  }

  double calculateCurrentPenalty(HagbadGroup group, HagbadMember member) {
    if (member.paidAmount >= group.amount) return member.penaltyAmount;

    // Calculate due date for current cycle
    DateTime dueDate;
    switch (group.frequency) {
      case HagbadFrequency.daily:
        dueDate = group.startDate.add(Duration(days: group.currentCycle));
      case HagbadFrequency.weekly:
        dueDate = group.startDate.add(Duration(days: group.currentCycle * 7));
      case HagbadFrequency.tenDays:
        dueDate = group.startDate.add(Duration(days: group.currentCycle * 10));
      case HagbadFrequency.monthly:
        dueDate = DateTime(group.startDate.year, group.startDate.month + group.currentCycle, group.startDate.day);
      case HagbadFrequency.yearly:
        dueDate = DateTime(group.startDate.year + group.currentCycle, group.startDate.month, group.startDate.day);
    }

    final now = DateTime.now();
    if (now.isAfter(dueDate)) {
      final daysLate = now.difference(dueDate).inDays;
      return member.penaltyAmount + (daysLate * group.penaltyPerDay);
    }
    return member.penaltyAmount;
  }

  void _showPenaltyDialog(HagbadGroup group, int index) {
    final l10n = AppLocalizations.of(context)!;
    final penaltyController = TextEditingController(text: "1"); // Default $1

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.applyPenalty),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${l10n.penaltyAmount} to ${group.members[index].name}", style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 16),
            TextField(
              controller: penaltyController,
              decoration: InputDecoration(
                labelText: l10n.penaltyAmount,
                prefixText: "\$ ",
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(penaltyController.text) ?? 1.0;
              setState(() {
                final m = group.members[index];
                group.members[index] = HagbadMember(
                  name: m.name,
                  walletId: m.walletId,
                  avatar: m.avatar,
                  payoutOrder: m.payoutOrder,
                  paidAmount: m.paidAmount,
                  penaltyAmount: m.penaltyAmount + amount,
                  lastPaymentDate: m.lastPaymentDate,
                  hasReceived: m.hasReceived,
                  isTrusted: m.isTrusted,
                  guarantorName: m.guarantorName,
                  guarantorId: m.guarantorId,
                );
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.penaltyApplied(amount.toStringAsFixed(0), group.members[index].name)),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.applyPenalty, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showReplaceMemberDialog(HagbadGroup group, int index) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.replaceMember),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${l10n.enterNewMemberDetails} for position ${index + 1}", style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: l10n.fullName, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: l10n.phoneNumber, border: const OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  group.members[index] = HagbadMember(
                    name: nameController.text,
                    walletId: "MX-${phoneController.text.padLeft(6, '0')}",
                    avatar: nameController.text[0].toUpperCase(),
                    payoutOrder: index + 1,
                    paidAmount: 0.0, // New member starts fresh
                    hasReceived: false,
                    isTrusted: false,
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.memberReplaced), backgroundColor: Colors.green),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark),
            child: Text(l10n.replaceMember, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _remindMember(HagbadMember member) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(l10n.reminderSent(member.name)),
          ],
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _remindAllPending(HagbadGroup group) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.group_work, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(l10n.allRemindersSent),
          ],
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showSwapOptions(HagbadGroup group, int currentIndex) {
    final l10n = AppLocalizations.of(context)!;
    final currentMember = group.members[currentIndex];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.swapTurn,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: group.members.length,
                itemBuilder: (context, index) {
                  final m = group.members[index];
                  // Can only swap with someone who hasn't received yet and is not yourself
                  if (index == currentIndex || m.hasReceived) return const SizedBox.shrink();

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 15,
                      backgroundColor: AppColors.primaryDark.withOpacity(0.1),
                      child: Text(m.avatar, style: const TextStyle(fontSize: 10, color: AppColors.primaryDark)),
                    ),
                    title: Text(l10n.swapWith(m.name)),
                    onTap: () {
                      Navigator.pop(context);
                      _swapMemberTurn(group, currentIndex, index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateDaysUntilTurn(HagbadGroup group, int payoutOrder) {
    if (payoutOrder < group.currentCycle) return -1; // Already passed
    if (payoutOrder == group.currentCycle) return 0; // Today

    int diff = payoutOrder - group.currentCycle;
    switch (group.frequency) {
      case HagbadFrequency.daily:
        return diff;
      case HagbadFrequency.weekly:
        return diff * 7;
      case HagbadFrequency.tenDays:
        return diff * 10;
      case HagbadFrequency.monthly:
        return diff * 30;
      case HagbadFrequency.yearly:
        return diff * 365;
    }
  }

  Widget _buildPaymentHistory(HagbadGroup group, AppLocalizations l10n, bool isDark) {
    final paidMembers = group.members.where((m) => m.paidAmount > 0).toList();
    
    if (paidMembers.isEmpty) {
      return Text(l10n.noPaymentsYet, style: TextStyle(fontSize: 12, color: isDark ? Colors.white30 : Colors.grey));
    }

    return Column(
      children: paidMembers.map((m) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: Colors.green.withOpacity(0.1),
              child: Text(m.avatar, style: const TextStyle(fontSize: 8, color: Colors.green, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.name == "You" ? l10n.you : m.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  Text(
                    l10n.paidOn("${m.lastPaymentDate?.day}/${m.lastPaymentDate?.month}/${m.lastPaymentDate?.year}"),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Text(
              "+\$${m.paidAmount.toStringAsFixed(0)}",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildMemberItem(HagbadGroup group, HagbadMember member, int index, HagbadFrequency freq, ThemeData theme, bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28 * context.fontSizeFactor,
            height: 28 * context.fontSizeFactor,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    "${member.payoutOrder}",
                    style: TextStyle(fontSize: 10 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  if (member.isConfirmed)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        child: Icon(Icons.check, size: 8 * context.fontSizeFactor, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 16 * context.fontSizeFactor,
            backgroundColor: isDark ? Colors.blue.withOpacity(0.2) : AppColors.primaryDark.withOpacity(0.1),
            child: Text(
              member.avatar,
              style: TextStyle(
                fontSize: 12 * context.fontSizeFactor, 
                fontWeight: FontWeight.bold, 
                color: isDark ? Colors.blue[300] : AppColors.primaryDark
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    Flexible(
                      child: Text(
                        member.name == "You" ? l10n.you : member.name,
                        style: TextStyle(fontSize: 14 * context.fontSizeFactor, color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),

                    ),
                    if (member.isTrusted)
                      Tooltip(
                        message: l10n.trustedMember,
                        child: Icon(Icons.verified_rounded, size: 14 * context.fontSizeFactor, color: Colors.blue),
                      ),
                    if (member.isConfirmed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text("Aqbalay", style: TextStyle(fontSize: 8 * context.fontSizeFactor, color: Colors.green, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                if (member.guarantorName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(Icons.verified_user_outlined, size: 10 * context.fontSizeFactor, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          "Uul: ${member.guarantorName} (${member.guarantorId})",
                          style: TextStyle(fontSize: 10 * context.fontSizeFactor, color: Colors.orange, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                Text(
                  _getTurnLabel(freq, member.payoutOrder, l10n),
                  style: TextStyle(fontSize: 11 * context.fontSizeFactor, color: isDark ? Colors.white54 : Colors.grey.shade600),
                ),
                if (member.name == "You" && (!member.isConfirmed || !member.hasSignedOath))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!member.isConfirmed)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.withOpacity(0.1)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.mail_outline_rounded, size: 16, color: Colors.blue),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          l10n.invitationReceived, 
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(l10n.invitationDesc(group.adminName, group.amount.toStringAsFixed(0)), style: const TextStyle(fontSize: 11)),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        int idx = group.members.indexOf(member);
                                        group.members[idx] = HagbadMember(
                                          name: member.name,
                                          walletId: member.walletId,
                                          avatar: member.avatar,
                                          payoutOrder: member.payoutOrder,
                                          paidAmount: member.paidAmount,
                                          hasReceived: member.hasReceived,
                                          isTrusted: member.isTrusted,
                                          isConfirmed: true,
                                          hasSignedOath: member.hasSignedOath,
                                          guarantorName: member.guarantorName,
                                          guarantorId: member.guarantorId,
                                          isGuarantorConfirmed: member.isGuarantorConfirmed,
                                        );
                                      });
                                    },
                                    icon: const Icon(Icons.check_circle_outline, size: 14),
                                    label: Text(l10n.acceptInvite, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                      minimumSize: const Size(0, 32),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (member.isConfirmed && !member.hasSignedOath)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.purple.withOpacity(0.1)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.mosque_rounded, size: 16, color: Colors.purple),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        l10n.religiousOathRequired, 
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.purple),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(l10n.oathRequirementDesc, style: const TextStyle(fontSize: 11)),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () => _showDhaarDialog(group, member),
                                  icon: const Icon(Icons.menu_book_rounded, size: 14),
                                  label: Text(l10n.signOathNow, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                    minimumSize: const Size(0, 32),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                // NEW: Guarantor Invitation Logic for "You"
                if (group.members.any((m) => m.guarantorName == "You" && !m.isGuarantorConfirmed))
                  Builder(builder: (context) {
                    final memberBeingGuaranteed = group.members.firstWhere((m) => m.guarantorName == "You" && !m.isGuarantorConfirmed);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.verified_user_outlined, size: 16, color: Colors.orange),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Codsi Uulnimo (Guarantor)", 
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text("${memberBeingGuaranteed.name} ayaa kaa codsaday inaad u noqoto Uul (Dammaanad) kooxdan.", style: const TextStyle(fontSize: 11)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      int idx = group.members.indexOf(memberBeingGuaranteed);
                                      group.members[idx] = HagbadMember(
                                        name: memberBeingGuaranteed.name,
                                        walletId: memberBeingGuaranteed.walletId,
                                        avatar: memberBeingGuaranteed.avatar,
                                        payoutOrder: memberBeingGuaranteed.payoutOrder,
                                        paidAmount: memberBeingGuaranteed.paidAmount,
                                        hasReceived: memberBeingGuaranteed.hasReceived,
                                        isTrusted: memberBeingGuaranteed.isTrusted,
                                        isConfirmed: memberBeingGuaranteed.isConfirmed,
                                        hasSignedOath: memberBeingGuaranteed.hasSignedOath,
                                        guarantorName: memberBeingGuaranteed.guarantorName,
                                        guarantorId: memberBeingGuaranteed.guarantorId,
                                        isGuarantorConfirmed: true, // YOU ACCEPTED
                                      );
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Waad aqbashay inaad u noqoto Uul ${memberBeingGuaranteed.name}."), backgroundColor: Colors.orange),
                                    );
                                  },
                                  icon: const Icon(Icons.check, size: 14),
                                  label: const Text("Aqbal Uulnimada", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                    minimumSize: const Size(0, 32),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {}, // Handle rejection if needed
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    minimumSize: const Size(0, 32),
                                  ),
                                  child: const Text("Diid", style: TextStyle(color: Colors.red, fontSize: 10)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                if (member.name == "You" && !member.hasReceived)
                  Builder(builder: (context) {
                    final days = _calculateDaysUntilTurn(group, member.payoutOrder);
                    if (days < 0) return const SizedBox.shrink();
                    
                    String message;
                    if (days == 0) {
                      message = l10n.yourTurnToday;
                    } else if (days == 1) {
                      message = l10n.yourTurnTomorrow;
                    } else {
                      message = l10n.yourTurnInDays(days);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        message,
                        style: const TextStyle(fontSize: 10, color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                      ),
                    );
                  }),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (member.hasSignedOath)
                const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.menu_book_rounded, size: 12, color: Colors.purple),
                      SizedBox(width: 4),
                      Text("Wuu Dhaartay", style: TextStyle(fontSize: 10, color: Colors.purple, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              if (!member.isFullyPaid(group.amount) && group.adminName == l10n.youAdmin && member.name != "You")
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.money_off_csred_rounded, size: 18, color: Colors.red),
                      onPressed: () => _showPenaltyDialog(group, index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: l10n.applyPenalty,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.notification_add_outlined, size: 18, color: Colors.orange),
                      onPressed: () => _remindMember(member),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: l10n.remindMember,
                    ),
                  ],
                ),
              if (!member.hasReceived && group.adminName == l10n.youAdmin)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.person_remove_outlined, size: 18, color: Colors.redAccent),
                      onPressed: () => _showReplaceMemberDialog(group, index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: l10n.replaceMember,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.swap_vert_rounded, size: 18, color: AppColors.primaryDark),
                      onPressed: () => _showSwapOptions(group, index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              if (member.isFullyPaid(group.amount))
                const Icon(Icons.check_circle, color: Colors.green, size: 20)
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(Icons.radio_button_unchecked, color: isDark ? Colors.white24 : Colors.grey, size: 20),
                    if (member.penaltyAmount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          "+ \$${member.penaltyAmount.toStringAsFixed(0)} ${l10n.lateFee}",
                          style: const TextStyle(fontSize: 8, color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (member.paidAmount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          "${l10n.remaining}: \$${(group.amount + member.penaltyAmount - member.paidAmount).toStringAsFixed(0)}",
                          style: const TextStyle(fontSize: 8, color: Colors.orange, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              if (member.hasReceived)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.received,
                        style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (member.guarantorName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_user_outlined, size: 10, color: Colors.grey),
                            const SizedBox(width: 2),
                            Text(
                              member.guarantorName!,
                              style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 10, color: Colors.orange),
                            const SizedBox(width: 2),
                            Text(
                              l10n.guarantor,
                              style: const TextStyle(fontSize: 9, color: Colors.orange, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.debtor.toUpperCase(),
                          style: const TextStyle(color: Colors.red, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(HagbadStatus status) {
    switch (status) {
      case HagbadStatus.active: return Colors.green;
      case HagbadStatus.inactive: return Colors.orange;
      case HagbadStatus.failed: return Colors.red;
    }
  }

  IconData _getStatusIcon(HagbadStatus status) {
    switch (status) {
      case HagbadStatus.active: return Icons.bolt_rounded;
      case HagbadStatus.inactive: return Icons.pause_circle_rounded;
      case HagbadStatus.failed: return Icons.error_outline_rounded;
    }
  }

  String _getFrequencyText(HagbadFrequency freq, AppLocalizations l10n) {
    switch (freq) {
      case HagbadFrequency.daily: return l10n.daily;
      case HagbadFrequency.weekly: return l10n.weekly;
      case HagbadFrequency.tenDays: return l10n.tenDays;
      case HagbadFrequency.monthly: return l10n.monthly;
      case HagbadFrequency.yearly: return l10n.yearly;
    }
  }

  void _showCreateGroupBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    // Ensure Admin is always included in the new group
    if (!_newGroupMembersWithDetails.any((m) => m['name'] == "You")) {
      _newGroupMembersWithDetails.insert(0, {'name': "You", 'walletId': "Admin-ID"});
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.createNewHagbad,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 24),
                // Summary Calculation Box
                if (_amountController.text.isNotEmpty && _newGroupMembersWithDetails.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : AppColors.primaryDark.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white10 : AppColors.primaryDark.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                "${l10n.contributionAmount} x ${l10n.members}",
                                style: TextStyle(fontSize: 12, color: theme.hintColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "\$${_amountController.text} x ${_newGroupMembersWithDetails.length}",
                              style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                            ),
                          ],
                        ),
                        Divider(height: 16, color: isDark ? Colors.white10 : Colors.grey.shade200),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                l10n.potWadar,
                                style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "\$${(double.tryParse(_amountController.text) ?? 0) * _newGroupMembersWithDetails.length}",
                              style: TextStyle(
                                color: isDark ? Colors.blue[400] : AppColors.primaryDark,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                _buildTextField(
                  l10n.groupName, 
                  Icons.group_work_rounded, 
                  _nameController, 
                  isDark,
                  onChanged: (val) => setModalState(() {}), // Refresh UI to update calculation
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(
                      l10n.contributionAmount, 
                      Icons.attach_money_rounded, 
                      _amountController, 
                      isDark, 
                      keyboardType: TextInputType.number,
                      onChanged: (val) => setModalState(() {}), // Refresh UI to update calculation
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTextField(l10n.serviceFee, Icons.admin_panel_settings_rounded, _feeController, isDark, keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 24),
                Text(l10n.frequency, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: HagbadFrequency.values.map((freq) => _buildFrequencyChip(freq, setModalState, l10n, isDark)).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            l10n.phoneNumber, 
                            Icons.phone_android_rounded, 
                            _memberController, 
                            isDark, 
                            keyboardType: TextInputType.phone,
                            onChanged: (val) => _filterSuggestions(val, setModalState),
                          ),
                          if (_searchError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 12),
                              child: Text(_searchError!, style: const TextStyle(color: Colors.red, fontSize: 11)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 56,
                      child: IconButton.filled(
                        onPressed: _isSearchingUser ? null : () => _lookupAndAddMember(setModalState),
                        icon: _isSearchingUser 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.person_search_rounded, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_suggestedUsers.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryDark.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: _suggestedUsers.map((user) => ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.primaryDark.withOpacity(0.1),
                          child: Text(user['name']![0], style: const TextStyle(fontSize: 10, color: AppColors.primaryDark)),
                        ),
                        title: Text(user['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: Text(user['phone']!, style: const TextStyle(fontSize: 11)),
                        trailing: const Icon(Icons.add_circle_outline, size: 18, color: AppColors.primaryDark),
                        onTap: () => _lookupAndAddMember(setModalState, selectedUser: user),
                      )).toList(),
                    ),
                  ),
                ],
                if (_newGroupMembersWithDetails.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(l10n.hagbadTerms, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.hagbadTermsDesc, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          value: _hasAcceptedTerms,
                          onChanged: (val) => setModalState(() => _hasAcceptedTerms = val ?? false),
                          title: Text(l10n.iAgreeToHagbadTerms, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          activeColor: AppColors.primaryDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.mosque_rounded, size: 16, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(l10n.hagbadOath, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(l10n.hagbadOathDesc, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          value: _hasConfirmedOath,
                          onChanged: (val) => setModalState(() => _hasConfirmedOath = val ?? false),
                          title: Text(l10n.iConfirmOath, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_hasAcceptedTerms && _hasConfirmedOath) ? _createNewGroup : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(l10n.createGroup, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, bool isDark, {TextInputType keyboardType = TextInputType.text, ValueChanged<String>? onChanged}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
        prefixIcon: Icon(icon, color: isDark ? Colors.blue[300] : AppColors.primaryDark),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.blue : AppColors.primaryDark)),
      ),
    );
  }

  Widget _buildFrequencyChip(HagbadFrequency freq, StateSetter setModalState, AppLocalizations l10n, bool isDark) {
    bool isSelected = freq == _selectedFrequency;
    return FilterChip(
      label: Text(_getFrequencyText(freq, l10n), style: const TextStyle(fontSize: 11)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      selected: isSelected,
      onSelected: (val) {
        setModalState(() {
          _selectedFrequency = freq;
        });
      },
      selectedColor: isDark ? Colors.blue.withOpacity(0.2) : AppColors.primaryDark.withOpacity(0.2),
      checkmarkColor: isDark ? Colors.blue[300] : AppColors.primaryDark,
      labelStyle: TextStyle(
        color: isSelected 
          ? (isDark ? Colors.blue[300] : AppColors.primaryDark) 
          : (isDark ? Colors.white60 : Colors.grey),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
