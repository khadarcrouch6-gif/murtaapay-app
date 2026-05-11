import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../core/models/hagbad_model.dart';
import '../../core/widgets/contact_sync_list.dart';
import '../chat/chat_screen.dart';
import 'hagbad_history_screen.dart';

class HagbadScreen extends StatefulWidget {
  const HagbadScreen({super.key});

  @override
  State<HagbadScreen> createState() => _HagbadScreenState();
}

class _HagbadScreenState extends State<HagbadScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);
    final groups = appState.hagbadGroups.where((g) => g.status != HagbadStatus.pending || g.members.any((m) => m.name == "Me" && m.isConfirmed)).toList();
    final invitations = appState.hagbadGroups.where((g) => g.status == HagbadStatus.pending && g.members.any((m) => m.name == "Me" && !m.isConfirmed)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.hagbad, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showCreateGroupDialog(context),
          ),
        ],
      ),
      body: groups.isEmpty && invitations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AdaptiveIcon(FontAwesomeIcons.users, size: 64, color: AppColors.grey),
                  const SizedBox(height: 16),
                  Text("No saving groups yet", style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showCreateGroupDialog(context),
                    child: const Text("Create First Group"),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (invitations.isNotEmpty) ...[
                  Text(l10n.invitationReceived.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.grey, fontSize: 12, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  ...invitations.map((g) => _buildInvitationCard(g, l10n, theme)),
                  const SizedBox(height: 24),
                ],
                if (groups.isNotEmpty) ...[
                  Text(l10n.myGroups.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.grey, fontSize: 12, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  ...groups.map((g) => _buildGroupCard(g)),
                ],
              ],
            ),
    );
  }

  Widget _buildInvitationCard(HagbadGroup group, AppLocalizations l10n, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(group.adminName[0], style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.invitationDesc(group.adminName, group.amount.toStringAsFixed(0)),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "${group.name} • ${group.members.length} Members",
                        style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Logic to decline - maybe just remove from local state for mock
                    },
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showAcceptInvitationDialog(group),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l10n.acceptInvite),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAcceptInvitationDialog(HagbadGroup group) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.acceptInvite),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_user_outlined, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(l10n.oathRequirementDesc),
            const SizedBox(height: 8),
            Text(
              "\"Waxaan ku dhaaranayaa magaca Ilaaha Qaadirka ah inaan bixin doono qaaraanka Hagbad-ka waqtigiisa...\"",
              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              final appState = Provider.of<AppState>(context, listen: false);
              final myIndex = group.members.indexWhere((m) => m.name == "Me");
              if (myIndex != -1) {
                final updatedMember = group.members[myIndex].copyWith(
                  isConfirmed: true,
                  hasSignedOath: true,
                );
                appState.updateHagbadMember(group.id, myIndex, updatedMember);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("You have joined ${group.name}!")),
                );
              }
            },
            child: Text(l10n.signOathNow),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final cyclesController = TextEditingController(text: "12");
    final searchController = TextEditingController();
    HagbadFrequency selectedFreq = HagbadFrequency.monthly;
    List<HagbadMember> invitedMembers = [
      HagbadMember(name: "Me", avatar: "M", payoutOrder: 1, hasReceived: false, isTrusted: true, hasSignedOath: true, isConfirmed: true),
    ];
    bool isSearching = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final appState = Provider.of<AppState>(context, listen: false);
          
          return AlertDialog(
            title: const Text("Create New Hagbad"),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Group Name", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "Amount", prefixText: "\$ ", border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<HagbadFrequency>(
                            value: selectedFreq,
                            decoration: const InputDecoration(labelText: "Freq", border: OutlineInputBorder()),
                            items: HagbadFrequency.values.map((f) => DropdownMenuItem(value: f, child: Text(f.name.toUpperCase()))).toList(),
                            onChanged: (val) => setDialogState(() => selectedFreq = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: cyclesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Total Cycles", border: OutlineInputBorder()),
                    ),
                    const Divider(height: 32),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Add Members (Search by Wallet ID)", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: "Enter Wallet ID (e.g. 102235)",
                              border: const OutlineInputBorder(),
                              suffixIcon: isSearching ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2))) : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: isSearching ? null : () async {
                            final id = searchController.text.trim();
                            if (id.isEmpty) return;
                            
                            setDialogState(() => isSearching = true);
                            try {
                              final name = await appState.verifyWalletId(id);
                              if (name != null) {
                                if (invitedMembers.any((m) => m.walletId == id)) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Member already added")));
                                  }
                                } else {
                                  setDialogState(() {
                                    invitedMembers.add(HagbadMember(
                                      name: name,
                                      walletId: id,
                                      avatar: name[0],
                                      payoutOrder: invitedMembers.length + 1,
                                      hasReceived: false,
                                      isTrusted: false,
                                      isConfirmed: false,
                                    ));
                                    searchController.clear();
                                  });
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Wallet ID not found")));
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
                              }
                            } finally {
                              setDialogState(() => isSearching = false);
                            }
                          },
                          icon: const Icon(Icons.person_add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 150),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: invitedMembers.length,
                        itemBuilder: (context, index) {
                          final m = invitedMembers[index];
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(radius: 12, child: Text(m.avatar, style: const TextStyle(fontSize: 10))),
                            title: Text(m.name, style: const TextStyle(fontSize: 13)),
                            subtitle: Text(m.walletId ?? "Admin", style: const TextStyle(fontSize: 11)),
                            trailing: m.name == "Me" ? null : IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 18, color: Colors.red),
                              onPressed: () => setDialogState(() => invitedMembers.removeAt(index)),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
                    final newGroup = HagbadGroup(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      adminName: "Me",
                      amount: double.parse(amountController.text),
                      frequency: selectedFreq,
                      status: HagbadStatus.pending,
                      startDate: DateTime.now(),
                      totalCycles: int.parse(cyclesController.text),
                      currentCycle: 1,
                      members: invitedMembers,
                    );
                    appState.createHagbadGroup(newGroup);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Hagbad created. Invitations sent!")),
                    );
                  }
                },
                child: const Text("Create & Invite"),
              ),
            ],
          );
        },
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
            color: AppColors.accentTeal.withValues(alpha: 0.1),
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        runSpacing: 0,
                        spacing: 0,
                        children: [
                          TextButton.icon(
                            onPressed: () => _showInviteMemberDialog(group),
                            icon: const Icon(Icons.person_add_alt_1, size: 18),
                            label: const Text("Invite"),
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                          ),
                          TextButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HagbadHistoryScreen(groupId: group.id),
                              ),
                            ),
                            icon: const Icon(Icons.history, size: 18),
                            label: const Text("History"),
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                          ),
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
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                          ),
                        ],
                      ),
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
    final nextMember = group.members.firstWhere(
      (m) => m.payoutOrder == group.currentCycle,
      orElse: () => group.members.first,
    );

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[50],
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
        ),
        if (group.status == HagbadStatus.active) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(Icons.stars, color: AppColors.primaryDark, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Next Payout: ${nextMember.name} (Turn ${group.currentCycle})",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                ),
                if (group.adminName == "Me" || group.adminName == "Khadar Abdi")
                  TextButton(
                    onPressed: () => _showProcessPayoutDialog(group, nextMember),
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    child: const Text("Pay Out"),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showProcessPayoutDialog(HagbadGroup group, HagbadMember member) {
    final l10n = AppLocalizations.of(context)!;
    final payoutAmount = group.totalPayout - group.serviceFee;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Payout"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Are you sure you want to process the payout for ${member.name}?"),
            const SizedBox(height: 12),
            Text("Payout Amount: \$${payoutAmount.toStringAsFixed(2)}"),
            Text("Service Fee: \$${group.serviceFee.toStringAsFixed(2)}"),
            const Divider(),
            const Text(
              "Note: This will move the group to the next cycle.",
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              try {
                await Provider.of<AppState>(context, listen: false).processHagbadPayout(group.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Payout successful for ${member.name}")),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
              }
            },
            child: const Text("Process Payout"),
          ),
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
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: AppColors.accentTeal.withValues(alpha: 0.1),
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
            if (!member.isConfirmed)
              const Text("Invitation Pending", style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
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
                onPressed: () => _showDhaarDialog(group, member, index)
              ),
            IconButton(
              tooltip: "Apply Penalty",
              icon: const Icon(Icons.report_problem_outlined, color: Colors.red, size: 20), 
              onPressed: () => _showPenaltyDialog(group, index)
            ),
            if (member.hasReceived)
              const Icon(Icons.check_circle, color: Colors.green, size: 20)
            else if (member.name == "Me" && member.paidAmount < group.amount)
              IconButton(
                tooltip: "Pay Contribution",
                icon: const Icon(Icons.payment, color: Colors.blue, size: 20),
                onPressed: () => _showPayContributionDialog(group, index),
              ),
          ],
        ),
      ),
    );
  }

  void _showPayContributionDialog(HagbadGroup group, int memberIndex) {
    final amount = group.amount;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pay Contribution"),
        content: Text("Do you want to pay \$${amount.toStringAsFixed(2)} for this cycle's Hagbad?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final appState = Provider.of<AppState>(context, listen: false);
              try {
                await appState.payHagbad(group.id, memberIndex, amount);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Payment successful!")),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
              }
            },
            child: const Text("Pay Now"),
          ),
        ],
      ),
    );
  }

  void _showDhaarDialog(HagbadGroup group, HagbadMember member, int index) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.mosque_rounded, color: Colors.purple),
            const SizedBox(width: 10),
            Expanded(child: Text(l10n.hagbadOath)),
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
              final updatedMember = member.copyWith(hasSignedOath: true);
              Provider.of<AppState>(context, listen: false).updateHagbadMember(group.id, index, updatedMember);
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
              final member = group.members[index];
              final updatedMember = member.copyWith(
                penaltyAmount: member.penaltyAmount + amount
              );
              Provider.of<AppState>(context, listen: false).updateHagbadMember(group.id, index, updatedMember);
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
              Provider.of<AppState>(context, listen: false).randomizeHagbadTurns(group.id);
              Navigator.pop(context);
            },
            child: const Text("Randomize"),
          ),
        ],
      ),
    );
  }

  void _showInviteMemberDialog(HagbadGroup group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Center(
        child: MaxWidthBox(
          maxWidth: 600,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Invite to ${group.name}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Expanded(
                  child: ContactSyncList(
                    onContactSelected: (contact, murtaaxName) {
                      if (murtaaxName != null) {
                        final newMember = HagbadMember(
                          name: murtaaxName,
                          walletId: "CONTACT", // Placeholder since we identified by phone
                          avatar: murtaaxName[0],
                          payoutOrder: group.members.length + 1,
                          hasReceived: false,
                          isTrusted: false,
                          isConfirmed: false,
                        );
                        Provider.of<AppState>(context, listen: false).addHagbadMember(group.id, newMember);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("$murtaaxName added to group")),
                        );
                      } else {
                        // This case is handled by the "INVITE" button in ContactSyncList
                        // but if the user just taps the tile, we can show a prompt
                        _showAppInvitePrompt(contact);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAppInvitePrompt(Contact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Invite to MurtaaxPay"),
        content: Text("${contact.displayName} is not on MurtaaxPay yet. Would you like to invite them to the app first?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              // The invite logic is already in ContactSyncList, 
              // but we can trigger it here or just close.
              Navigator.pop(context);
            },
            child: const Text("Invite via SMS"),
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
