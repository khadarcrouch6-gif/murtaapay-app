import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../chat/chat_screen.dart';

enum HagbadFrequency { daily, weekly, monthly, tenDays, yearly }
enum HagbadStatus { active, pending, completed }

class HagbadGroup {
  final String id;
  final String name;
  final String adminName;
  final double amount;
  final HagbadFrequency frequency;
  final HagbadStatus status;
  final DateTime startDate;
  final List<HagbadMember> members;
  final int totalCycles;
  final int currentCycle;

  HagbadGroup({
    required this.id,
    required this.name,
    required this.adminName,
    required this.amount,
    required this.frequency,
    required this.status,
    required this.startDate,
    required this.members,
    required this.totalCycles,
    required this.currentCycle,
  });

  double get totalPayout => amount * (members.length > 0 ? members.length : 1);
  double get serviceFee => 1.0; 
  double get currentBalance => members.fold(0.0, (sum, m) => sum + m.paidAmount);
}

class HagbadMember {
  final String name;
  final String? walletId;
  final double paidAmount;
  final double penaltyAmount;
  final DateTime? lastPaymentDate;
  final bool hasReceived;
  final bool isTrusted;
  final bool isConfirmed;
  final bool hasSignedOath;
  final String? guarantorName;
  final String? guarantorId;
  final bool isGuarantorConfirmed;
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

  HagbadMember copyWith({
    String? name,
    String? walletId,
    double? paidAmount,
    double? penaltyAmount,
    DateTime? lastPaymentDate,
    bool? hasReceived,
    bool? isTrusted,
    bool? isConfirmed,
    bool? hasSignedOath,
    String? guarantorName,
    String? guarantorId,
    bool? isGuarantorConfirmed,
    String? avatar,
    int? payoutOrder,
  }) {
    return HagbadMember(
      name: name ?? this.name,
      walletId: walletId ?? this.walletId,
      paidAmount: paidAmount ?? this.paidAmount,
      penaltyAmount: penaltyAmount ?? this.penaltyAmount,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      hasReceived: hasReceived ?? this.hasReceived,
      isTrusted: isTrusted ?? this.isTrusted,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      hasSignedOath: hasSignedOath ?? this.hasSignedOath,
      guarantorName: guarantorName ?? this.guarantorName,
      guarantorId: guarantorId ?? this.guarantorId,
      isGuarantorConfirmed: isGuarantorConfirmed ?? this.isGuarantorConfirmed,
      avatar: avatar ?? this.avatar,
      payoutOrder: payoutOrder ?? this.payoutOrder,
    );
  }

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
        HagbadMember(name: "Fardowsa", paidAmount: 0.0, hasReceived: false, isTrusted: false, avatar: "F", payoutOrder: 3, guarantorName: "Khadar Abdi", isConfirmed: true),
        HagbadMember(name: "Mustafe", paidAmount: 0.0, hasReceived: false, isTrusted: true, avatar: "M", payoutOrder: 4, isConfirmed: false),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.hagbad, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // TODO: Implement Create Group
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _groups.length,
        itemBuilder: (context, index) => _buildGroupCard(_groups[index]),
      ),
    );
  }

  Widget _buildGroupCard(HagbadGroup group) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accentTeal.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const AdaptiveIcon(FontAwesomeIcons.users, color: AppColors.accentTeal, size: 20),
        ),
        title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text("${group.members.length} Members • \$${group.amount} ${group.frequency.name}"),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGroupSummary(group, l10n, theme),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.members, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            userId: group.id,
                            userName: group.name,
                            userAvatar: "G",
                            isGroup: true,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.chat_outlined, size: 18),
                      label: Text(l10n.groupChat),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...group.members.asMap().entries.map((entry) => _buildMemberItem(group, entry.value, entry.key, group.frequency, theme, isDark, l10n)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showQoriTuur(group),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Qori-tuur (Randomize Turns)"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSummary(HagbadGroup group, AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? Colors.white10 : Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem("Balance", "\$${group.currentBalance}", Colors.green),
          _buildSummaryItem("Cycle", "${group.currentCycle}/${group.totalCycles}", Colors.blue),
          _buildSummaryItem("Payout", "\$${group.totalPayout}", Colors.orange),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ],
    );
  }

  Widget _buildMemberItem(HagbadGroup group, HagbadMember member, int index, HagbadFrequency freq, ThemeData theme, bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: AppColors.accentTeal.withOpacity(0.1),
          child: Text(member.avatar, style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold)),
        ),
        title: Row(
          children: [
            Text(member.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (member.isTrusted) const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.verified, size: 14, color: Colors.blue),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getTurnLabel(freq, member.payoutOrder, l10n), style: const TextStyle(fontSize: 12)),
            if (member.penaltyAmount > 0)
              Text("Penalty: \$${member.penaltyAmount}", style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!member.hasSignedOath)
              IconButton(
                tooltip: "Sign Oath (Dhaar)",
                icon: const Icon(Icons.mosque_outlined, color: Colors.purple, size: 20), 
                onPressed: () => _showDhaarDialog(group, member)
              ),
            IconButton(
              tooltip: "Apply Penalty",
              icon: const Icon(Icons.report_problem_outlined, color: Colors.red, size: 20), 
              onPressed: () => _showPenaltyDialog(group, index)
            ),
            if (member.hasReceived)
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.mosque_rounded, color: Colors.purple),
            const SizedBox(width: 10),
            Text(l10n.hagbadOath),
          ],
        ),
        content: const Text(
          "Waxaan ku dhaaranayaa magaca Ilaaha Qaadirka ah inaan bixin doono qaaraanka Hagbad-ka waqtigiisa, haddii aan dib u dhacona aan bixin doono ganaaxa lagu heshiiyey.",
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                int idx = group.members.indexOf(member);
                group.members[idx] = member.copyWith(hasSignedOath: true);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${member.name} has signed the oath.")),
              );
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showPenaltyDialog(HagbadGroup group, int index) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: "1");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.applyPenalty),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Enter penalty amount for ${group.members[index].name}"),
            const SizedBox(height: 16),
            TextField(
              controller: controller, 
              keyboardType: TextInputType.number, 
              decoration: const InputDecoration(
                prefixText: r"$ ",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 1.0;
              setState(() {
                group.members[index] = group.members[index].copyWith(
                  penaltyAmount: group.members[index].penaltyAmount + amount
                );
              });
              Navigator.pop(context);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showQoriTuur(HagbadGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Qori-tuur"),
        content: const Text("This will randomize the payout order for all members who haven't received their payout yet. Proceed?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final members = List<HagbadMember>.from(group.members);
                final received = members.where((m) => m.hasReceived).toList();
                final remaining = members.where((m) => !m.hasReceived).toList();
                remaining.shuffle();
                
                for (int i = 0; i < remaining.length; i++) {
                  int idx = members.indexOf(remaining[i]);
                  members[idx] = remaining[i].copyWith(payoutOrder: received.length + i + 1);
                }
                
                // Sort by payout order
                members.sort((a, b) => a.payoutOrder.compareTo(b.payoutOrder));
                
                // In a real app, you'd update the group in a provider/database
                int gIdx = _groups.indexOf(group);
                _groups[gIdx] = HagbadGroup(
                  id: group.id,
                  name: group.name,
                  adminName: group.adminName,
                  amount: group.amount,
                  frequency: group.frequency,
                  status: group.status,
                  startDate: group.startDate,
                  members: members,
                  totalCycles: group.totalCycles,
                  currentCycle: group.currentCycle,
                );
              });
              Navigator.pop(context);
            },
            child: const Text("Randomize"),
          ),
        ],
      ),
    );
  }

  String _getTurnLabel(HagbadFrequency freq, int order, AppLocalizations l10n) {
    switch (freq) {
      case HagbadFrequency.daily: return l10n.dayWithNumber(order);
      case HagbadFrequency.weekly: return l10n.weekWithNumber(order);
      case HagbadFrequency.monthly: return l10n.monthWithNumber(order);
      case HagbadFrequency.tenDays: return "10-Maalmood $order";
      case HagbadFrequency.yearly: return "Sanadka $order";
    }
  }
}
