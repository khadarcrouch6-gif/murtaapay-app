import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../core/models/hagbad_model.dart';
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

    final totalHagbadBalance = groups.fold(0.0, (sum, g) => sum + g.currentBalance);

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
      body: context.responsiveBody(
        child: groups.isEmpty && invitations.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AdaptiveIcon(FontAwesomeIcons.users, size: 64, color: AppColors.grey),
                    const SizedBox(height: 16),
                    Text(l10n.noSavingGroups, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _showCreateGroupDialog(context),
                      child: Text(l10n.createFirstGroup),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: context.horizontalPadding / 2,
                  vertical: 16,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _buildTotalBalanceCard(totalHagbadBalance, l10n, theme),
                  ),
                  const SizedBox(height: 24),
                  if (invitations.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(l10n.invitationReceived.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.grey, fontSize: 12, letterSpacing: 1.2)),
                    ),
                    const SizedBox(height: 12),
                    ...invitations.map((g) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildInvitationCard(g, l10n, theme),
                    )),
                    const SizedBox(height: 24),
                  ],
                  if (groups.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(l10n.myGroups.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.grey, fontSize: 12, letterSpacing: 1.2)),
                    ),
                    const SizedBox(height: 12),
                    ...groups.map((g) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildGroupCard(g),
                    )),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildTotalBalanceCard(double totalBalance, AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Hagbad Balance",
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "\$${totalBalance.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Locked in Groups",
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
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
                        "${group.name} • ${group.members.length} ${l10n.members}",
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
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        scrollable: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            const Icon(Icons.verified_user_rounded, size: 48, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(l10n.acceptInvite, textAlign: TextAlign.center),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.oathRequirementDesc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Text(
                  "\"${l10n.fullOathText}\"",
                  style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
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
                  SnackBar(
                    content: Text(l10n.joinedGroup(group.name)),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l10n.signOathNow),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context, listen: false);
    
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final searchController = TextEditingController();
    HagbadFrequency selectedFreq = HagbadFrequency.monthly;
    List<HagbadMember> invitedMembers = [
      HagbadMember(
        name: "Me", 
        walletId: appState.walletId,
        avatar: "M", 
        payoutOrder: 1, 
        hasReceived: false, 
        isTrusted: true, 
        hasSignedOath: true, 
        isConfirmed: true
      ),
    ];
    final cyclesController = TextEditingController(text: invitedMembers.length.toString());
    bool isSearching = false;
    List<Map<String, String>> searchMatches = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(l10n.createNewHagbad),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: l10n.groupName, border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.amount, prefixText: r"$ ", border: const OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<HagbadFrequency>(
                        initialValue: selectedFreq,
                        decoration: InputDecoration(labelText: l10n.frequency, border: const OutlineInputBorder()),
                        items: [
                          DropdownMenuItem(value: HagbadFrequency.daily, child: Text(l10n.daily)),
                          DropdownMenuItem(value: HagbadFrequency.weekly, child: Text(l10n.weekly)),
                          DropdownMenuItem(value: HagbadFrequency.tenDays, child: Text(l10n.tenDays)),
                          DropdownMenuItem(value: HagbadFrequency.monthly, child: Text(l10n.monthly)),
                          DropdownMenuItem(value: HagbadFrequency.yearly, child: Text(l10n.yearly)),
                        ],
                        onChanged: (val) => setDialogState(() => selectedFreq = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cyclesController,
                  readOnly: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.totalCycles, 
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: theme.disabledColor.withValues(alpha: 0.05),
                    suffixIcon: const Icon(Icons.lock_outline, size: 16),
                    helperText: invitedMembers.length > 1 
                        ? "Cycles match the ${invitedMembers.length} members"
                        : "Starting with Admin only (1 Cycle)",
                  ),
                ),
                const Divider(height: 32),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.addMembers, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: (val) {
                          setDialogState(() {
                            if (val.isEmpty) {
                              searchMatches = [];
                              return;
                            }
                            final query = val.toLowerCase();
                            searchMatches = [];
                            
                            // Search in verified mock users
                            appState.mockUsers.forEach((id, name) {
                              if (id != appState.walletId && (id.contains(query) || name.toLowerCase().contains(query))) {
                                searchMatches.add({'id': id, 'name': name});
                              }
                            });

                            // Search in quick profiles
                            for (var p in appState.quickProfiles) {
                              if (p.walletId != appState.walletId && (p.walletId.contains(query) || p.name.toLowerCase().contains(query))) {
                                if (!searchMatches.any((m) => m['id'] == p.walletId)) {
                                  searchMatches.add({'id': p.walletId, 'name': p.name});
                                }
                              }
                            }
                            
                            // Limit to 5 results for clarity
                            if (searchMatches.length > 5) {
                              searchMatches = searchMatches.sublist(0, 5);
                            }
                          });
                        },
                        decoration: InputDecoration(
                          hintText: l10n.enterWalletOrPhoneHint,
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
                          if (!context.mounted) return;
                          
                          if (name != null) {
                            if (invitedMembers.any((m) => m.walletId == id)) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.memberAlreadyAdded)));
                              }
                            } else {
                              setDialogState(() {
                                final isMe = name == "Me" || id == appState.walletId;
                                invitedMembers.add(HagbadMember(
                                  name: name,
                                  walletId: id,
                                  avatar: name.isNotEmpty ? name[0] : "?",
                                  payoutOrder: invitedMembers.length + 1,
                                  hasReceived: false,
                                  isTrusted: isMe,
                                  isConfirmed: isMe,
                                  hasSignedOath: isMe,
                                ));
                                cyclesController.text = invitedMembers.length.toString();
                                searchController.clear();
                                searchMatches = [];
                              });
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.walletOrPhoneNotFound)));
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            String errorMsg = e.toString().contains('self_transfer_error') ? l10n.selfTransferError : e.toString();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
                          }
                        } finally {
                          if (context.mounted) {
                            setDialogState(() => isSearching = false);
                          }
                        }
                      },
                      icon: const Icon(Icons.person_add_alt_1),
                    ),
                  ],
                ),
                if (searchMatches.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: searchMatches.map((match) {
                      final name = match['name']!;
                      final id = match['id']!;
                      final isAlreadyAdded = invitedMembers.any((m) => m.walletId == id);
                      
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Text(name.isNotEmpty ? name[0] : "?", style: const TextStyle(fontSize: 10, color: AppColors.primary)),
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text(id, style: const TextStyle(fontSize: 11)),
                        trailing: isAlreadyAdded 
                            ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                            : const Icon(Icons.add_circle_outline, size: 20),
                        onTap: isAlreadyAdded ? null : () {
                          setDialogState(() {
                            final isMe = name == "Me" || id == appState.walletId;
                            invitedMembers.add(HagbadMember(
                              name: name,
                              walletId: id,
                              avatar: name.isNotEmpty ? name[0] : "?",
                              payoutOrder: invitedMembers.length + 1,
                              hasReceived: false,
                              isTrusted: isMe,
                              isConfirmed: isMe,
                              hasSignedOath: isMe,
                            ));
                            cyclesController.text = invitedMembers.length.toString();
                            searchController.clear();
                            searchMatches = [];
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                if (invitedMembers.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  constraints: const BoxConstraints(maxHeight: 250),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(), // Better for nested scrolling
                    itemCount: invitedMembers.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final m = invitedMembers[index];
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.primary,
                          child: Text(m.avatar, style: const TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                        title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: m.walletId != null ? Text(m.walletId!, style: const TextStyle(fontSize: 11)) : null,
                        trailing: m.name == "Me" ? null : IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                          onPressed: () => setDialogState(() {
                            invitedMembers.removeAt(index);
                            cyclesController.text = invitedMembers.length.toString();
                          }),
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
              TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
                    final pinSuccess = await _showSecurityPinDialog(context);
                    if (!pinSuccess || !context.mounted) return;

                    final newGroup = HagbadGroup(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      adminName: "Me",
                      amount: double.parse(amountController.text),
                      frequency: selectedFreq,
                      status: HagbadStatus.pending,
                      startDate: DateTime.now(),
                      totalCycles: invitedMembers.length,
                      currentCycle: 1,
                      members: invitedMembers,
                    );
                    
                    Provider.of<AppState>(context, listen: false).createHagbadGroup(newGroup);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.hagbadCreatedSuccess)),
                    );
                  }
                },
                child: Text(l10n.createAndInvite),
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
        subtitle: Text("${group.members.length} ${l10n.members} • \$${group.amount} ${_getFreqLabel(group.frequency, l10n)}"),
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
                          if (group.adminName == "Me" || group.adminName == "Khadar Abdi")
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            onPressed: () => _showDeleteGroupDialog(group),
                            tooltip: l10n.deleteGroup,
                          ),
                          TextButton.icon(
                            onPressed: (group.adminName == "Me" || group.adminName == "Khadar Abdi") 
                                ? () => _showInviteMemberDialog(group) 
                                : null,
                            icon: const Icon(Icons.person_add_alt_1, size: 18),
                            label: Text(l10n.invite),
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
                            label: Text(l10n.history),
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
                if (group.adminName == "Me" || group.adminName == "Khadar Abdi")
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (group.members.every((m) => m.isConfirmed) && group.status == HagbadStatus.pending)
                        ? () => _showQoriTuur(group) 
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (group.members.every((m) => m.isConfirmed) && group.status == HagbadStatus.pending) ? AppColors.primaryDark : AppColors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(group.status == HagbadStatus.pending ? l10n.qoriTuurStart : l10n.qoriTuurRandomize),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFreqLabel(HagbadFrequency freq, AppLocalizations l10n) {
    switch (freq) {
      case HagbadFrequency.daily: return l10n.daily;
      case HagbadFrequency.weekly: return l10n.weekly;
      case HagbadFrequency.tenDays: return l10n.tenDays;
      case HagbadFrequency.monthly: return l10n.monthly;
      case HagbadFrequency.yearly: return l10n.yearly;
    }
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
              _buildSummaryItem(l10n.balance, "\$${group.currentBalance}", Colors.green),
              _buildSummaryItem(l10n.cycle, "${group.currentCycle}/${group.totalCycles}", Colors.blue),
              _buildSummaryItem(l10n.payout, "\$${group.totalPayout}", Colors.orange),
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
                  l10n.nextPayoutWithMember(nextMember.name, group.currentCycle),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                ),
                if (group.adminName == "Me" || group.adminName == "Khadar Abdi")
                  TextButton(
                    onPressed: () => _showProcessPayoutDialog(group, nextMember),
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    child: Text(l10n.payOut),
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
        scrollable: true,
        title: Text(l10n.confirmPayout),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.confirmPayoutDesc(member.name)),
            const SizedBox(height: 12),
            Text("${l10n.payoutAmount}: \$${payoutAmount.toStringAsFixed(2)}"),
            Text("${l10n.serviceFee}: \$${group.serviceFee.toStringAsFixed(2)}"),
            const Divider(),
            Text(
              l10n.payoutNote,
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              final pinSuccess = await _showSecurityPinDialog(context);
              if (!pinSuccess || !context.mounted) return;

              try {
                if (context.mounted) {
                  await Provider.of<AppState>(context, listen: false).processHagbadPayout(group.id);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.payoutSuccessfulFor(member.name))),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.processPayoutError(e.toString()))),
                  );
                }
              }
            },
            child: Text(l10n.processPayout),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (member.walletId != null)
                    Text(member.walletId!, style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
                ],
              ),
            ),
            if (member.isTrusted) Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(Icons.verified, size: 14, color: theme.primaryColor),
            ),
            if (member.guarantorId != null) Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Tooltip(
                message: "${l10n.guarantor}: ${member.guarantorName}",
                child: const Icon(Icons.shield_outlined, size: 14, color: Colors.green),
              ),
            ),
            if (!member.isTrusted && member.guarantorId == null && member.name != "Me") Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Tooltip(
                message: l10n.requireGuarantor,
                child: const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(_getTurnLabel(freq, member.payoutOrder, l10n), style: const TextStyle(fontSize: 12)),
                if (member.guarantorName != null)
                  Text("• ${l10n.guarantor}: ${member.guarantorName}", style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w500)),
              ],
            ),
            if (!member.isConfirmed)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(l10n.invitationPending, style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            if (member.penaltyAmount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(l10n.penalty(member.penaltyAmount.toString()), style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (member.hasReceived)
              const Icon(Icons.check_circle, color: Colors.green, size: 20)
            else if (member.name == "Me" && member.paidAmount < group.amount)
              IconButton(
                tooltip: l10n.payContribution,
                icon: const Icon(Icons.payment, color: Colors.blue, size: 20),
                onPressed: () => _showPayContributionDialog(group, index),
              ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              tooltip: "Actions",
              onSelected: (value) {
                switch (value) {
                  case 'dhaar': _showDhaarDialog(group, member, index); break;
                  case 'penalty': _showPenaltyDialog(group, index); break;
                  case 'guarantor': _showGuarantorDialog(group, member, index); break;
                  case 'swap': _showSwapTurnDialog(group, member, index); break;
                  case 'edit': _showEditMemberDialog(group, member, index); break;
                  case 'remove': _showRemoveMemberDialog(group, member, index); break;
                }
              },
              itemBuilder: (context) => [
                if (!member.hasSignedOath)
                  PopupMenuItem(
                    value: 'dhaar', 
                    child: Row(children: [const Icon(Icons.mosque_outlined, color: Colors.purple, size: 18), const SizedBox(width: 8), Text(l10n.signOathDhaar, style: const TextStyle(fontSize: 13))]),
                  ),
                PopupMenuItem(
                  value: 'penalty', 
                  child: Row(children: [const Icon(Icons.report_problem_outlined, color: Colors.red, size: 18), const SizedBox(width: 8), Text(l10n.applyPenalty, style: const TextStyle(fontSize: 13))]),
                ),
                if (group.adminName == "Me" || group.adminName == "Khadar Abdi") ...[
                  PopupMenuItem(
                    value: 'guarantor', 
                    child: Row(children: [const Icon(Icons.security, color: Colors.green, size: 18), const SizedBox(width: 8), Text(l10n.guarantor, style: const TextStyle(fontSize: 13))]),
                  ),
                  const PopupMenuItem(
                    value: 'swap', 
                    child: Row(children: [Icon(Icons.swap_vert_outlined, color: Colors.blueGrey, size: 18), SizedBox(width: 8), Text("Swap Turn", style: TextStyle(fontSize: 13))]),
                  ),
                  PopupMenuItem(
                    value: 'edit', 
                    child: Row(children: [const Icon(Icons.edit_outlined, color: Colors.grey, size: 18), const SizedBox(width: 8), Text(l10n.edit, style: const TextStyle(fontSize: 13))]),
                  ),
                  PopupMenuItem(
                    value: 'remove', 
                    child: Row(children: [const Icon(Icons.person_remove_outlined, color: Colors.red, size: 18), const SizedBox(width: 8), Text(l10n.removeMember, style: const TextStyle(fontSize: 13))]),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPayContributionDialog(HagbadGroup group, int memberIndex) {
    final l10n = AppLocalizations.of(context)!;
    final amount = group.amount;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(l10n.payContribution),
        content: Text(l10n.payContributionConfirm(amount.toStringAsFixed(2))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              final pinSuccess = await _showSecurityPinDialog(context);
              if (!pinSuccess || !context.mounted) return;

              final appState = Provider.of<AppState>(context, listen: false);
              try {
                await appState.payHagbad(group.id, memberIndex, amount);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.success),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${l10n.error}: ${e.toString()}")),
                  );
                }
              }
            },
            child: Text(l10n.payNow),
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
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.mosque_rounded, color: Colors.purple),
            const SizedBox(width: 10),
            Expanded(child: Text(l10n.hagbadOath)),
          ],
        ),
        content: Text(
          l10n.fullOathText,
          style: const TextStyle(fontStyle: FontStyle.italic),
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
                SnackBar(content: Text(l10n.memberSignedOath(member.name))),
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
        scrollable: true,
        title: Text(l10n.applyPenalty),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.enterPenaltyAmount(group.members[index].name)),
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
                onPressed: () async {
                  final pinSuccess = await _showSecurityPinDialog(context);
                  if (!pinSuccess || !context.mounted) return;

                  final amount = double.tryParse(controller.text) ?? 1.0;
                  final member = group.members[index];
                  final updatedMember = member.copyWith(
                    penaltyAmount: member.penaltyAmount + amount
                  );
                  Provider.of<AppState>(context, listen: false).updateHagbadMember(group.id, index, updatedMember);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(l10n.confirm),
              ),
        ],
      ),
    );
  }

  void _showQoriTuur(HagbadGroup group) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    bool isSpinning = false;
    String? currentName;
    
    // Get members who haven't received payout yet
    final remainingMembers = group.members.where((m) => !m.hasReceived).toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(l10n.qoriTuur, textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSpinning)
                  Column(
                    children: [
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const SizedBox(
                              height: 150,
                              width: 150,
                              child: CircularProgressIndicator(
                                strokeWidth: 10, 
                                color: AppColors.primary,
                                backgroundColor: AppColors.accentTeal,
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 100),
                              child: CircleAvatar(
                                key: ValueKey<String>(currentName ?? ""),
                                radius: 50,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                child: Text(
                                  currentName?[0] ?? "?",
                                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        currentName ?? "Selecting...", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      const Text("Randomizing turns...", style: TextStyle(color: AppColors.grey)),
                    ],
                  )
                else
                  Column(
                    children: [
                      AdaptiveIcon(FontAwesomeIcons.dice, size: 60, color: AppColors.accentTeal),
                      const SizedBox(height: 16),
                      Text(
                        l10n.qoriTuurDesc,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Participants: ${remainingMembers.length}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            if (!isSpinning)
              TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            if (!isSpinning)
              ElevatedButton(
                onPressed: () async {
                  final pinSuccess = await _showSecurityPinDialog(context);
                  if (!pinSuccess || !context.mounted) return;

                  setDialogState(() => isSpinning = true);
                  
                  // Simple animation effect
                  for (int i = 0; i < 20; i++) {
                    await Future.delayed(Duration(milliseconds: 50 + (i * 10)));
                    if (context.mounted) {
                      setDialogState(() {
                        currentName = remainingMembers[i % remainingMembers.length].name;
                      });
                    }
                  }

                  await Future.delayed(const Duration(milliseconds: 500));

                  if (context.mounted) {
                    Provider.of<AppState>(context, listen: false).randomizeHagbadTurns(group.id);
                    Navigator.pop(context);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Turns randomized successfully!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: Text(l10n.randomize),
              ),
          ],
        ),
      ),
    );
  }

  void _showInviteMemberDialog(HagbadGroup group) {
    final l10n = AppLocalizations.of(context)!;
    final searchController = TextEditingController();
    bool isSearching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Center(
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
                      l10n.inviteToGroup(group.name),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: l10n.enterWalletOrPhoneHint,
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
                              final name = await Provider.of<AppState>(context, listen: false).verifyWalletId(id);
                              if (name != null) {
                                if (group.members.any((m) => m.walletId == id)) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.memberAlreadyInGroup)));
                                  }
                                } else {
                                  final catchUpAmount = (group.currentCycle - 1) * group.amount;
                                  final newMember = HagbadMember(
                                    name: name,
                                    walletId: id,
                                    avatar: name[0],
                                    payoutOrder: group.members.length + 1,
                                    hasReceived: false,
                                    isTrusted: false,
                                    isConfirmed: group.status == HagbadStatus.active, // Auto-confirm if group is already active
                                    paidAmount: group.status == HagbadStatus.active ? catchUpAmount : 0.0,
                                  );

                                  if (context.mounted && group.status == HagbadStatus.active && catchUpAmount > 0) {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Add Late Member"),
                                        content: Text("Since the group is in cycle ${group.currentCycle}, the new member must pay \$${catchUpAmount.toStringAsFixed(2)} to catch up with previous contributions. Add them now?"),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
                                          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.confirm)),
                                        ],
                                      ),
                                    );
                                    if (confirmed != true) {
                                       if (context.mounted) setDialogState(() => isSearching = false);
                                       return;
                                    }
                                  }

                                  if (context.mounted) {
                                    final pinSuccess = await _showSecurityPinDialog(context);
                                    if (!pinSuccess || !context.mounted) return;

                                    try {
                                      Provider.of<AppState>(context, listen: false).addHagbadMember(
                                        group.id, 
                                        newMember,
                                        catchUpAmount: newMember.paidAmount,
                                      );
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.memberInvitedSuccess(name))));
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                      }
                                    }
                                  }
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.walletOrPhoneNotFound)));
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                String errorMsg = e.toString().contains('self_transfer_error') ? l10n.selfTransferError : e.toString();
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
                              }
                            } finally {
                              if (context.mounted) {
                                setDialogState(() => isSearching = false);
                              }
                            }
                          },
                          icon: const Icon(Icons.person_add),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showGuarantorDialog(HagbadGroup group, HagbadMember member, int index) {
    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context, listen: false);
    final searchController = TextEditingController();
    bool isSearching = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          scrollable: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(l10n.guarantorDetails),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.requireGuarantor, style: const TextStyle(fontSize: 13, color: AppColors.grey)),
              const SizedBox(height: 16),
              if (member.guarantorName != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(member.guarantorName!, style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (member.guarantorId != null) Text(member.guarantorId!, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          final updatedMember = member.copyWith(
                            guarantorName: null,
                            guarantorId: null,
                            isGuarantorConfirmed: false,
                          );
                          appState.updateHagbadMember(group.id, index, updatedMember);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: l10n.guarantorIdLabel,
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
                      
                      // PIN verification before sensitive administrative actions
                      final success = await _showSecurityPinDialog(context);
                      if (!success || !context.mounted) return;

                      setDialogState(() => isSearching = true);
                      try {
                        final name = await appState.verifyWalletId(id);
                        if (name != null) {
                          final updatedMember = member.copyWith(
                            guarantorName: name,
                            guarantorId: id,
                            isGuarantorConfirmed: true,
                          );
                          appState.updateHagbadMember(group.id, index, updatedMember);
                          
                          // Log as significant event
                          appState.logHagbadEvent(group.id, "Guarantor assigned: $name for ${member.name}");

                          // Send notification/SMS to guarantor
                          appState.sendHagbadNotification(
                            id, 
                            "You have been assigned as a guarantor for ${member.name} in the '${group.name}' Hagbad group.",
                            isSms: true,
                          );
                          
                          if (context.mounted) Navigator.pop(context);
                        } else {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.walletIdNotFound)));
                        }
                      } catch (e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      } finally {
                        if (context.mounted) setDialogState(() => isSearching = false);
                      }
                    },
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                onPressed: () async {
                  // PIN verification before sensitive administrative actions
                  final success = await _showSecurityPinDialog(context);
                  if (!success || !context.mounted) return;

                  final updatedMember = member.copyWith(
                    guarantorName: "Admin (Accepted)",
                    guarantorId: "ADMIN",
                    isGuarantorConfirmed: true,
                  );
                  appState.updateHagbadMember(group.id, index, updatedMember);
                  appState.logHagbadEvent(group.id, "Admin (${group.adminName}) vouched for ${member.name}");
                  if (context.mounted) Navigator.pop(context);
                },
                  child: const Text("Skip (Admin Accepted)"),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ],
        ),
      ),
    );
  }

  void _showDeleteGroupDialog(HagbadGroup group) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteGroup),
        content: Text(l10n.deleteGroupConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              final success = await _showSecurityPinDialog(context);
              if (success && context.mounted) {
                Provider.of<AppState>(context, listen: false).deleteHagbadGroup(group.id);
                Navigator.pop(context);
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showRemoveMemberDialog(HagbadGroup group, HagbadMember member, int index) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeMember),
        content: Text(l10n.removeMemberConfirm(member.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              final success = await _showSecurityPinDialog(context);
              if (success && context.mounted) {
                Provider.of<AppState>(context, listen: false).removeHagbadMember(group.id, index);
                Navigator.pop(context);
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditMemberDialog(HagbadGroup group, HagbadMember member, int index) {
    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context, listen: false);
    final nameController = TextEditingController(text: member.name);
    final walletIdController = TextEditingController(text: member.walletId);
    final guarantorNameController = TextEditingController(text: member.guarantorName);
    final guarantorIdController = TextEditingController(text: member.guarantorId);
    bool isTrusted = member.isTrusted;
    bool isConfirmed = member.isConfirmed;
    bool hasReceived = member.hasReceived;
    bool isGuarantorConfirmed = member.isGuarantorConfirmed;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          scrollable: true,
          title: Row(
            children: [
              const Icon(Icons.admin_panel_settings, color: Colors.blue),
              const SizedBox(width: 8),
              Text(l10n.edit),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.personalDetails.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: walletIdController,
                  decoration: InputDecoration(
                    labelText: "Wallet ID / Phone",
                    prefixIcon: const Icon(Icons.account_balance_wallet),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                const Text("TRUST & STATUS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                SwitchListTile(
                  title: Text(l10n.trustedMember),
                  subtitle: const Text("Admin vouching for this member"),
                  value: isTrusted,
                  onChanged: (val) => setDialogState(() => isTrusted = val),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text("Confirmed Participation"),
                  subtitle: const Text("Member has accepted invitation"),
                  value: isConfirmed,
                  onChanged: (val) => setDialogState(() => isConfirmed = val),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text("Payout Completed"),
                  subtitle: const Text("Manually override payout status"),
                  value: hasReceived,
                  onChanged: (val) => setDialogState(() => hasReceived = val),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),
                const Text("GUARANTOR (HAG-DOR)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                TextField(
                  controller: guarantorNameController,
                  decoration: InputDecoration(
                    labelText: "Guarantor Name",
                    prefixIcon: const Icon(Icons.security),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: guarantorIdController,
                  decoration: InputDecoration(
                    labelText: "Guarantor Wallet ID",
                    prefixIcon: const Icon(Icons.vpn_key),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SwitchListTile(
                  title: const Text("Guarantor Confirmed"),
                  value: isGuarantorConfirmed,
                  onChanged: (val) => setDialogState(() => isGuarantorConfirmed = val),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () async {
                // PIN verification before sensitive administrative actions
                final success = await _showSecurityPinDialog(context);
                if (!success || !context.mounted) return;

                final updatedMember = member.copyWith(
                  name: nameController.text.trim(),
                  walletId: walletIdController.text.trim(),
                  isTrusted: isTrusted,
                  isConfirmed: isConfirmed,
                  hasReceived: hasReceived,
                  guarantorName: guarantorNameController.text.trim().isEmpty ? null : guarantorNameController.text.trim(),
                  guarantorId: guarantorIdController.text.trim().isEmpty ? null : guarantorIdController.text.trim(),
                  isGuarantorConfirmed: isGuarantorConfirmed,
                  avatar: nameController.text.trim().isNotEmpty ? nameController.text.trim()[0] : member.avatar,
                );
                appState.updateHagbadMember(group.id, index, updatedMember);
                
                if (isTrusted && !member.isTrusted) {
                  appState.logHagbadEvent(group.id, "Admin manually vouched for ${updatedMember.name}");
                }
                
                if (updatedMember.guarantorId != member.guarantorId && updatedMember.guarantorId != null) {
                   appState.sendHagbadNotification(
                     updatedMember.guarantorId!, 
                     "You have been assigned as a guarantor for ${updatedMember.name} in group '${group.name}'. Please confirm in-app."
                   );
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: Text(l10n.saveChanges),
            ),
          ],
        ),
      ),
    );
  }

  void _showSwapTurnDialog(HagbadGroup group, HagbadMember member, int index) {
    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: false,
        title: Text(l10n.swapTurn),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select a member to swap turns with ${member.name}.", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: group.members.length,
                separatorBuilder: (context, i) => i == index ? const SizedBox.shrink() : const Divider(height: 1),
                itemBuilder: (context, i) {
                  if (i == index) return const SizedBox.shrink();
                  final otherMember = group.members[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      child: Text(otherMember.avatar, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(otherMember.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text("Current: ${_getTurnLabel(group.frequency, otherMember.payoutOrder, l10n)}"),
                    trailing: const Icon(Icons.swap_horiz, color: Colors.blue),
                    onTap: () async {
                      // PIN verification before sensitive administrative actions
                      final success = await _showSecurityPinDialog(context);
                      if (success && context.mounted) {
                        appState.swapHagbadTurns(group.id, index, i);
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
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

  Future<bool> _showSecurityPinDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final state = Provider.of<AppState>(context, listen: false);
    final TextEditingController pinController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.enterSecurityPin, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.enterTransactionPin, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.grey, fontSize: 14)),
            const SizedBox(height: 20),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 10),
              decoration: InputDecoration(
                counterText: "",
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              if (state.verifyPin(pinController.text)) {
                if (context.mounted) Navigator.pop(context, true);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Incorrect PIN"), duration: Duration(seconds: 2)),
                  );
                }
              }
            },
            child: Text(l10n.confirm, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentTeal)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
