import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:murtaaxpay_app/l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../core/widgets/pin_entry_dialog.dart';
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
    final guarantorInvites = appState.hagbadGroups.where((g) => g.members.any((m) => m.guarantorId == appState.walletId && !m.isGuarantorConfirmed)).toList();

    final totalHagbadBalance = groups.fold(0.0, (sum, g) => sum + g.currentBalance);
    final scale = context.fontSizeFactor;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.hagbad, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * scale)),
      ),
      body: Stack(
        children: [
          context.responsiveBody(
            child: groups.isEmpty && invitations.isEmpty && guarantorInvites.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AdaptiveIcon(FontAwesomeIcons.users, size: 64 * scale, color: AppColors.grey),
                        SizedBox(height: 16 * scale),
                        Text(l10n.noSavingGroups, style: theme.textTheme.titleMedium?.copyWith(fontSize: 16 * scale)),
                        SizedBox(height: 8 * scale),
                        ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _showCreateGroupDialog(context);
                          },
                          style: context.elevatedButtonStyle(minimumSize: Size(200 * scale, 48 * scale)),
                          child: Text(l10n.createFirstGroup, style: TextStyle(fontSize: 14 * scale)),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.horizontalPadding / 2,
                      vertical: 16 * scale,
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                        child: _buildTotalBalanceCard(totalHagbadBalance, l10n, theme),
                      ),
                      SizedBox(height: 24 * scale),
                      if (invitations.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                          child: Text(l10n.invitationReceived.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.grey, fontSize: 12 * scale, letterSpacing: 1.2 * scale)),
                        ),
                        SizedBox(height: 12 * scale),
                        ...invitations.map((g) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                          child: _buildInvitationCard(g, l10n, theme),
                        )),
                        SizedBox(height: 24 * scale),
                      ],
                      if (guarantorInvites.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                          child: Text("GUARANTOR REQUESTS (UUL)", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.grey, fontSize: 12 * scale, letterSpacing: 1.2 * scale)),
                        ),
                        SizedBox(height: 12 * scale),
                        ...guarantorInvites.map((g) {
                          final memberToGuarantee = g.members.firstWhere((m) => m.guarantorId == appState.walletId && !m.isGuarantorConfirmed);
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                            child: _buildGuarantorInviteCard(g, memberToGuarantee, l10n, theme),
                          );
                        }),
                        SizedBox(height: 24 * scale),
                      ],
                      if (groups.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                          child: Text(l10n.myGroups.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.grey, fontSize: 12 * scale, letterSpacing: 1.2 * scale)),
                        ),
                        SizedBox(height: 12 * scale),
                        ...groups.map((g) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                          child: _buildGroupCard(g),
                        )),
                      ],
                      SizedBox(height: 120 * scale),
                    ],
                  ),
          ),
          if (groups.isNotEmpty || invitations.isNotEmpty || guarantorInvites.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildStickyBottomButton(context, l10n),
            ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomButton(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final scale = context.fontSizeFactor;
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.horizontalPadding,
        16 * scale,
        context.horizontalPadding,
        (16 + MediaQuery.of(context).padding.bottom) * scale
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30 * scale)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.3 : 0.08),
            blurRadius: 20 * scale,
            offset: Offset(0, -5 * scale),
          )
        ],
      ),
      child: Center(
        child: MaxWidthBox(
          maxWidth: 500,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showCreateGroupDialog(context);
            },
            style: context.elevatedButtonStyle(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              height: 60,
              borderRadius: 20,
              elevation: 8,
            ),
            child: Text(l10n.createNewHagbad, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * scale)),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalBalanceCard(double totalBalance, AppLocalizations l10n, ThemeData theme) {
    final scale = context.fontSizeFactor;
    return Container(
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20 * scale,
            offset: Offset(0, 10 * scale),
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
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14 * scale, fontWeight: FontWeight.w500),
              ),
              Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 20 * scale),
            ],
          ),
          SizedBox(height: 8 * scale),
          Text(
            "\$${totalBalance.toStringAsFixed(2)}",
            style: TextStyle(color: Colors.white, fontSize: 32 * scale, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16 * scale),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20 * scale),
            ),
            child: Text(
              "Locked in Groups",
              style: TextStyle(color: Colors.white, fontSize: 12 * scale, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationCard(HagbadGroup group, AppLocalizations l10n, ThemeData theme) {
    final scale = context.fontSizeFactor;
    return Card(
      margin: EdgeInsets.only(bottom: 12 * scale),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16 * scale),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Padding(
        padding: EdgeInsets.all(16.0 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(group.adminName[0], style: TextStyle(color: Colors.white, fontSize: 14 * scale)),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.invitationDesc(group.adminName, group.amount.toStringAsFixed(0)),
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14 * scale),
                      ),
                      Text(
                        "${group.name} • ${group.members.length} ${l10n.members}",
                        style: TextStyle(fontSize: 12 * scale, color: theme.textTheme.bodySmall?.color),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16 * scale),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // Logic to decline - maybe just remove from local state for mock
                    },
                    style: context.outlinedButtonStyle(),
                    child: Text(l10n.cancel, style: TextStyle(fontSize: 14 * scale)),
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showAcceptInvitationDialog(group);
                    },
                    style: context.elevatedButtonStyle(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l10n.acceptInvite, style: TextStyle(fontSize: 14 * scale)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24 * context.fontSizeFactor)),
        title: Column(
          children: [
            Icon(Icons.verified_user_rounded, size: 48 * context.fontSizeFactor, color: AppColors.primary),
            SizedBox(height: 12 * context.fontSizeFactor),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(l10n.acceptInvite, textAlign: TextAlign.center, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.oathRequirementDesc, textAlign: TextAlign.center, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
              SizedBox(height: 16 * context.fontSizeFactor),
              Container(
                padding: EdgeInsets.all(12 * context.fontSizeFactor),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
                ),
                child: Text(
                  "\"${l10n.fullOathText}\"",
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13 * context.fontSizeFactor, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text(l10n.cancel, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
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
            style: context.elevatedButtonStyle(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              height: 48,
            ),
            child: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.signOathNow, style: TextStyle(fontSize: 14 * context.fontSizeFactor))),
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
    bool isSearchFocused = false;
    List<Map<String, String>> searchMatches = [];
    final searchFocusNode = FocusNode();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * context.fontSizeFactor)),
            title: Text(l10n.createNewHagbad, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                TextField(
                  controller: nameController,
                  style: TextStyle(fontSize: 14 * context.fontSizeFactor),
                  decoration: InputDecoration(
                    labelText: l10n.groupName, 
                    labelStyle: TextStyle(fontSize: 14 * context.fontSizeFactor),
                    border: const OutlineInputBorder()
                  ),
                ),
                SizedBox(height: 16 * context.fontSizeFactor),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 14 * context.fontSizeFactor),
                        decoration: InputDecoration(
                          labelText: l10n.amount, 
                          labelStyle: TextStyle(fontSize: 14 * context.fontSizeFactor),
                          prefixText: r"$ ", 
                          border: const OutlineInputBorder()
                        ),
                      ),
                    ),
                    SizedBox(width: 8 * context.fontSizeFactor),
                    Expanded(
                      child: DropdownButtonFormField<HagbadFrequency>(
                        value: selectedFreq,
                        decoration: InputDecoration(
                          labelText: l10n.frequency, 
                          labelStyle: TextStyle(fontSize: 14 * context.fontSizeFactor),
                          border: const OutlineInputBorder()
                        ),
                        items: [
                          DropdownMenuItem(value: HagbadFrequency.daily, child: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.daily, style: TextStyle(fontSize: 14 * context.fontSizeFactor)))),
                          DropdownMenuItem(value: HagbadFrequency.weekly, child: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.weekly, style: TextStyle(fontSize: 14 * context.fontSizeFactor)))),
                          DropdownMenuItem(value: HagbadFrequency.tenDays, child: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.tenDays, style: TextStyle(fontSize: 14 * context.fontSizeFactor)))),
                          DropdownMenuItem(value: HagbadFrequency.monthly, child: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.monthly, style: TextStyle(fontSize: 14 * context.fontSizeFactor)))),
                          DropdownMenuItem(value: HagbadFrequency.yearly, child: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.yearly, style: TextStyle(fontSize: 14 * context.fontSizeFactor)))),
                        ],
                        onChanged: (val) => setDialogState(() => selectedFreq = val!),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16 * context.fontSizeFactor),
                TextField(
                  controller: cyclesController,
                  readOnly: true,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 14 * context.fontSizeFactor),
                  decoration: InputDecoration(
                    labelText: l10n.totalCycles, 
                    labelStyle: TextStyle(fontSize: 14 * context.fontSizeFactor),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: theme.disabledColor.withValues(alpha: 0.1),
                    suffixIcon: Icon(Icons.lock_outline, size: 16 * context.fontSizeFactor),
                    helperText: invitedMembers.length > 1 
                        ? "Cycles match the ${invitedMembers.length} members"
                        : "Starting with Admin only (1 Cycle)",
                    helperStyle: TextStyle(fontSize: 11 * context.fontSizeFactor),
                  ),
                ),
                Divider(height: 32 * context.fontSizeFactor),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.addMembers, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                ),
                SizedBox(height: 8 * context.fontSizeFactor),
                Row(
                  children: [
                    Expanded(
                      child: Focus(
                        onFocusChange: (hasFocus) {
                          setDialogState(() {
                            isSearchFocused = hasFocus;
                          });
                        },
                        child: TextField(
                          controller: searchController,
                          focusNode: searchFocusNode,
                          style: TextStyle(fontSize: 14 * context.fontSizeFactor),
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
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            appState.addToSearchHistory(val, 'hagbad');
                          }
                        },
                        decoration: InputDecoration(
                          hintText: l10n.enterWalletOrPhoneHint,
                          hintStyle: TextStyle(fontSize: 14 * context.fontSizeFactor),
                          prefixIcon: Icon(Icons.search, size: 20 * context.fontSizeFactor),
                          suffixIcon: searchController.text.isNotEmpty 
                            ? IconButton(
                                icon: Icon(Icons.clear, size: 20 * context.fontSizeFactor),
                                onPressed: () {
                                  searchController.clear();
                                  setDialogState(() {
                                    searchMatches = [];
                                  });
                                },
                              )
                            : null,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8 * context.fontSizeFactor),
                    IconButton.filled(
                      onPressed: isSearching ? null : () async {
                        HapticFeedback.mediumImpact();
                        final id = searchController.text.trim();
                        if (id.isEmpty) return;
                        
                        appState.addToSearchHistory(id, 'hagbad');
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
                      icon: Icon(Icons.person_add_alt_1, size: 20 * context.fontSizeFactor),
                    ),
                  ],
                ),
                if (isSearchFocused && appState.hagbadSearchHistory.isNotEmpty && searchController.text.isEmpty)
                Container(
                  margin: EdgeInsets.only(top: 8 * context.fontSizeFactor),
                  padding: EdgeInsets.all(12 * context.fontSizeFactor),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            appState.translate("Recent Searches", "Baaritaanadii ugu dambeeyay"),
                            style: TextStyle(fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: AppColors.grey),
                          ),
                          GestureDetector(
                            onTap: () => appState.clearSearchHistory('hagbad'),
                            child: Text(
                              appState.translate("Clear All", "Tirtir dhamaan"),
                              style: TextStyle(fontSize: 12 * context.fontSizeFactor, color: theme.primaryColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12 * context.fontSizeFactor),
                      Wrap(
                        spacing: 8 * context.fontSizeFactor,
                        runSpacing: 8 * context.fontSizeFactor,
                        children: appState.hagbadSearchHistory.map((query) {
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                searchController.text = query;
                                searchFocusNode.unfocus();
                                // Trigger search logic
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10 * context.fontSizeFactor, vertical: 4 * context.fontSizeFactor),
                              decoration: BoxDecoration(
                                color: AppColors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.history, size: 14 * context.fontSizeFactor, color: AppColors.grey),
                                  SizedBox(width: 4 * context.fontSizeFactor),
                                  Text(query, style: TextStyle(fontSize: 12 * context.fontSizeFactor)),
                                  SizedBox(width: 4 * context.fontSizeFactor),
                                  GestureDetector(
                                    onTap: () => appState.removeFromSearchHistory(query, 'hagbad'),
                                    child: Icon(Icons.close, size: 14 * context.fontSizeFactor, color: AppColors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                if (searchMatches.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 8 * context.fontSizeFactor),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
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
                          radius: 12 * context.fontSizeFactor,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Text(name.isNotEmpty ? name[0] : "?", style: TextStyle(fontSize: 10 * context.fontSizeFactor, color: AppColors.primary)),
                        ),
                        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13 * context.fontSizeFactor)),
                        subtitle: Text(id, style: TextStyle(fontSize: 11 * context.fontSizeFactor)),
                        trailing: isAlreadyAdded 
                            ? Icon(Icons.check_circle, color: Colors.green, size: 20 * context.fontSizeFactor)
                            : Icon(Icons.add_circle_outline, size: 20 * context.fontSizeFactor),
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
                SizedBox(height: 12 * context.fontSizeFactor),
                if (invitedMembers.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 8 * context.fontSizeFactor),
                  constraints: BoxConstraints(maxHeight: 250 * context.fontSizeFactor),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
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
                          radius: 14 * context.fontSizeFactor,
                          backgroundColor: AppColors.primary,
                          child: Text(m.avatar, style: TextStyle(color: Colors.white, fontSize: 10 * context.fontSizeFactor)),
                        ),
                        title: Text(m.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13 * context.fontSizeFactor)),
                        subtitle: m.walletId != null ? Text(m.walletId!, style: TextStyle(fontSize: 11 * context.fontSizeFactor)) : null,
                        trailing: m.name == "Me" ? null : IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: Colors.red, size: 20 * context.fontSizeFactor),
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
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: Text(l10n.cancel, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
              ),
              ElevatedButton(
                style: context.elevatedButtonStyle(),
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
                    final appState = Provider.of<AppState>(context, listen: false);
                    final l10n = AppLocalizations.of(context)!;
                    
                    showDialog(
                      context: context,
                      builder: (context) => PinEntryDialog(
                        title: l10n.enterSecurityPin,
                        description: l10n.enterTransactionPin,
                        onValidate: (pin) async => appState.verifyPin(pin),
                        onConfirm: (pin) {
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
                          
                          appState.createHagbadGroup(newGroup);
                          Navigator.pop(context); // Close dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.hagbadCreatedSuccess)),
                          );
                        },
                      ),
                    );
                  }
                },
                child: Text(l10n.createAndInvite, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGuarantorInviteCard(HagbadGroup group, HagbadMember member, AppLocalizations l10n, ThemeData theme) {
    final scale = context.fontSizeFactor;
    return Card(
      margin: EdgeInsets.only(bottom: 12 * scale),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16 * scale),
        side: BorderSide(color: Colors.purple.withValues(alpha: 0.2)),
      ),
      color: Colors.purple.withValues(alpha: 0.05),
      child: Padding(
        padding: EdgeInsets.all(16.0 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.security, color: Colors.white, size: 20 * scale),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${member.name} needs a Guarantor (Uul)",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14 * scale),
                      ),
                      Text(
                        "Group: ${group.name} • Amount: \$${group.amount.toStringAsFixed(0)}",
                        style: TextStyle(fontSize: 12 * scale, color: theme.textTheme.bodySmall?.color),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * scale),
            Text(
              "By accepting, you agree to cover their debt if they fail to pay. This is a sacred social trust (Aaminaad).",
              style: TextStyle(fontSize: 12 * scale, fontStyle: FontStyle.italic, color: theme.textTheme.bodySmall?.color),
            ),
            SizedBox(height: 16 * scale),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      final appState = Provider.of<AppState>(context, listen: false);
                      final mIdx = group.members.indexWhere((m) => m.name == member.name && m.guarantorId == appState.walletId);
                      if (mIdx != -1) {
                         final updatedMember = group.members[mIdx].copyWith(
                           guarantorName: null,
                           guarantorId: null,
                           isGuarantorConfirmed: false,
                         );
                         appState.updateHagbadMember(group.id, mIdx, updatedMember);
                         appState.logHagbadEvent(group.id, "Guarantor request declined by ${appState.userName} for ${member.name}");
                         
                         // Notify the member that their guarantor request was declined
                         if (member.walletId != null) {
                           appState.sendHagbadNotification(
                             member.walletId!,
                             "${appState.userName} declined your guarantor request for '${group.name}'.",
                             isSms: true,
                           );
                         }
                      }
                    },
                    style: context.outlinedButtonStyle(height: 48),
                    child: Text(l10n.cancel, style: TextStyle(fontSize: 14 * scale)),
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final appState = Provider.of<AppState>(context, listen: false);
                      final l10n = AppLocalizations.of(context)!;
                      
                      showDialog(
                        context: context,
                        builder: (context) => PinEntryDialog(
                          title: l10n.enterSecurityPin,
                          description: l10n.enterTransactionPin,
                          onValidate: (pin) async => appState.verifyPin(pin),
                          onConfirm: (pin) {
                            final mIdx = group.members.indexWhere((m) => m.name == member.name && m.guarantorId == appState.walletId);
                            if (mIdx != -1) {
                              final updatedMember = group.members[mIdx].copyWith(
                                isGuarantorConfirmed: true,
                              );
                              appState.updateHagbadMember(group.id, mIdx, updatedMember);
                              appState.logHagbadEvent(group.id, "Guarantor request accepted by ${appState.userName} for ${member.name}");
                              
                              // Notify the member that their guarantor request was accepted
                              if (member.walletId != null) {
                                appState.sendHagbadNotification(
                                  member.walletId!,
                                  "${appState.userName} has accepted to be your guarantor for '${group.name}'.",
                                  isSms: true,
                                );
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("You are now the guarantor for ${member.name}"))
                              );
                            }
                          },
                        ),
                      );
                    },
                    style: context.elevatedButtonStyle(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      height: 48,
                    ),
                    child: Text("Accept Uul", style: TextStyle(fontSize: 14 * scale)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(HagbadGroup group) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scale = context.fontSizeFactor;

    return Card(
      margin: EdgeInsets.only(bottom: 16 * scale),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * scale)),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 8 * scale),
        leading: Container(
          padding: EdgeInsets.all(10 * scale),
          decoration: BoxDecoration(
            color: AppColors.accentTeal.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: AdaptiveIcon(FontAwesomeIcons.users, color: AppColors.accentTeal, size: 20 * scale),
        ),
        title: Text(group.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * scale)),
        subtitle: Text(
          "${group.members.length} ${l10n.members} • \$${group.amount} ${_getFreqLabel(group.frequency, l10n)}",
          style: TextStyle(fontSize: 13 * scale),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.0 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGroupSummary(group, l10n, theme),
                Divider(height: 32 * scale),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.members, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale)),
                    SizedBox(width: 8 * scale),
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        runSpacing: 0,
                        spacing: 0,
                        children: [
              if (group.adminName == "Me" || group.adminName == "Khadar Abdi")
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red, size: 20 * scale),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showDeleteGroupDialog(group);
                },
                tooltip: l10n.deleteGroup,
              ),
              TextButton.icon(
                onPressed: (group.adminName == "Me" || group.adminName == "Khadar Abdi") 
                    ? () {
                        HapticFeedback.lightImpact();
                        _showInviteMemberDialog(group);
                      } 
                    : null,
                icon: Icon(Icons.person_add_alt_1, size: 18 * scale),
                label: Text(l10n.invite, style: TextStyle(fontSize: 13 * scale)),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              ),
              TextButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HagbadHistoryScreen(groupId: group.id),
                    ),
                  );
                },
                icon: Icon(Icons.history, size: 18 * scale),
                label: Text(l10n.history, style: TextStyle(fontSize: 13 * scale)),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              ),
              TextButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        userId: group.id,
                        userName: group.name,
                        userAvatar: "G",
                        isGroup: true,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.chat_outlined, size: 18 * scale),
                label: Text(l10n.groupChat, style: TextStyle(fontSize: 13 * scale)),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              ),
            ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12 * scale),
                ...group.members.asMap().entries.map((entry) => _buildMemberItem(group, entry.value, entry.key, group.frequency, theme, isDark, l10n)),
                SizedBox(height: 16 * scale),
                if (group.adminName == "Me" || group.adminName == "Khadar Abdi")
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (group.members.every((m) => m.isConfirmed) && group.status == HagbadStatus.pending)
                        ? () {
                            HapticFeedback.mediumImpact();
                            _showQoriTuur(group);
                          } 
                        : null,
                    style: context.elevatedButtonStyle(
                      backgroundColor: (group.members.every((m) => m.isConfirmed) && group.status == HagbadStatus.pending) ? AppColors.primaryDark : AppColors.grey,
                      foregroundColor: Colors.white,
                      borderRadius: 12,
                    ),
                    child: Text(
                      group.status == HagbadStatus.pending ? l10n.qoriTuurStart : l10n.qoriTuurRandomize,
                      style: TextStyle(fontSize: 14 * scale, fontWeight: FontWeight.bold),
                    ),
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
    final scale = context.fontSizeFactor;
    final nextMember = group.members.firstWhere(
      (m) => m.payoutOrder == group.currentCycle,
      orElse: () => group.members.first,
    );

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16 * scale),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
            borderRadius: BorderRadius.circular(15 * scale),
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
          SizedBox(height: 12 * scale),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(Icons.stars, color: AppColors.primaryDark, size: 20 * scale),
                SizedBox(width: 8 * scale),
                Text(
                  l10n.nextPayoutWithMember(nextMember.name, group.currentCycle),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13 * scale, color: AppColors.primaryDark),
                ),
                if (group.adminName == "Me" || group.adminName == "Khadar Abdi")
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showProcessPayoutDialog(group, nextMember);
                    },
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    child: Text(l10n.payOut, style: TextStyle(fontSize: 13 * scale)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * context.fontSizeFactor)),
        title: Text(l10n.confirmPayout, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.confirmPayoutDesc(member.name), style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
            SizedBox(height: 12 * context.fontSizeFactor),
            Text("${l10n.payoutAmount}: \$${payoutAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
            Text("${l10n.serviceFee}: \$${group.serviceFee.toStringAsFixed(2)}", style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
            const Divider(),
            Text(
              l10n.payoutNote,
              style: TextStyle(fontSize: 12 * context.fontSizeFactor, fontStyle: FontStyle.italic),
            ),
          ],
        ),
            actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text(l10n.cancel, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
          ),
          ElevatedButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              showDialog(
                context: context,
                builder: (context) => PinEntryDialog(
                  title: l10n.enterSecurityPin,
                  description: l10n.enterTransactionPin,
                  onValidate: (pin) async {
                    final appState = Provider.of<AppState>(context, listen: false);
                    return appState.verifyPin(pin);
                  },
                  onConfirm: (pin) async {
                    final appState = Provider.of<AppState>(context, listen: false);
                    try {
                      await appState.processHagbadPayout(group.id);
                      Navigator.pop(context); // Close confirm payout dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.payoutSuccessfulFor(member.name))),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.processPayoutError(e.toString()))),
                      );
                    }
                  },
                ),
              );
            },
            style: context.elevatedButtonStyle(),
            child: Text(l10n.processPayout, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    final scale = context.fontSizeFactor;
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12 * scale, color: AppColors.grey)),
        SizedBox(height: 4 * scale),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale, color: color)),
      ],
    );
  }

  Widget _buildMemberItem(HagbadGroup group, HagbadMember member, int index, HagbadFrequency freq, ThemeData theme, bool isDark, AppLocalizations l10n) {
    final scale = context.fontSizeFactor;
    return Container(
      margin: EdgeInsets.only(bottom: 8 * scale),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 4 * scale),
        leading: CircleAvatar(
          backgroundColor: AppColors.accentTeal.withValues(alpha: 0.1),
          child: Text(member.avatar, style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 14 * scale)),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14 * scale)),
                  if (member.walletId != null)
                    Text(member.walletId!, style: TextStyle(fontSize: 11 * scale, color: theme.textTheme.bodySmall?.color)),
                ],
              ),
            ),
            if (member.isTrusted) Padding(
              padding: EdgeInsets.only(left: 4 * scale),
              child: Icon(Icons.verified, size: 14 * scale, color: theme.primaryColor),
            ),
            if (member.guarantorId != null) Padding(
              padding: EdgeInsets.only(left: 4 * scale),
              child: Tooltip(
                message: "${l10n.guarantor}: ${member.guarantorName}",
                child: Icon(Icons.shield_outlined, size: 14 * scale, color: Colors.green),
              ),
            ),
            if (!member.isTrusted && member.guarantorId == null && member.name != "Me") Padding(
              padding: EdgeInsets.only(left: 4 * scale),
              child: Tooltip(
                message: l10n.requireGuarantor,
                child: Icon(Icons.warning_amber_rounded, size: 14 * scale, color: Colors.orange),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8 * scale,
              runSpacing: 2 * scale,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(_getTurnLabel(freq, member.payoutOrder, l10n), style: TextStyle(fontSize: 12 * scale)),
                if (member.guarantorName != null)
                  Text("• ${l10n.guarantor}: ${member.guarantorName}", style: TextStyle(fontSize: 11 * scale, color: Colors.green, fontWeight: FontWeight.w500)),
              ],
            ),
            if (!member.isConfirmed)
              Padding(
                padding: EdgeInsets.only(top: 2 * scale),
                child: Text(l10n.invitationPending, style: TextStyle(color: Colors.orange, fontSize: 11 * scale, fontWeight: FontWeight.bold)),
              ),
            if (member.penaltyAmount > 0)
              Padding(
                padding: EdgeInsets.only(top: 2 * scale),
                child: Text(l10n.penalty(member.penaltyAmount.toString()), style: TextStyle(color: Colors.red, fontSize: 11 * scale, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (member.hasReceived)
              Icon(Icons.check_circle, color: Colors.green, size: 20 * scale)
            else if (member.name == "Me" && member.paidAmount < group.amount)
              IconButton(
                tooltip: l10n.payContribution,
                icon: Icon(Icons.payment, color: Colors.blue, size: 20 * scale),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showPayContributionDialog(group, index);
                },
              ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 20 * scale),
              tooltip: "Actions",
              onSelected: (value) {
                HapticFeedback.selectionClick();
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
                    child: Row(children: [Icon(Icons.mosque_outlined, color: Colors.purple, size: 18 * scale), SizedBox(width: 8 * scale), Text(l10n.signOathDhaar, style: TextStyle(fontSize: 13 * scale))]),
                  ),
                PopupMenuItem(
                  value: 'penalty', 
                  child: Row(children: [Icon(Icons.report_problem_outlined, color: Colors.red, size: 18 * scale), SizedBox(width: 8 * scale), Text(l10n.applyPenalty, style: TextStyle(fontSize: 13 * scale))]),
                ),
                if (group.adminName == "Me" || group.adminName == "Khadar Abdi") ...[
                  PopupMenuItem(
                    value: 'guarantor', 
                    child: Row(children: [Icon(Icons.security, color: Colors.green, size: 18 * scale), SizedBox(width: 8 * scale), Text(l10n.guarantor, style: TextStyle(fontSize: 13 * scale))]),
                  ),
                  PopupMenuItem(
                    value: 'swap', 
                    child: Row(children: [Icon(Icons.swap_vert_outlined, color: Colors.blueGrey, size: 18 * scale), SizedBox(width: 8 * scale), Text("Swap Turn", style: TextStyle(fontSize: 13 * scale))]),
                  ),
                  PopupMenuItem(
                    value: 'edit', 
                    child: Row(children: [Icon(Icons.edit_outlined, color: Colors.grey, size: 18 * scale), SizedBox(width: 8 * scale), Text(l10n.edit, style: TextStyle(fontSize: 13 * scale))]),
                  ),
                  PopupMenuItem(
                    value: 'remove', 
                    child: Row(children: [Icon(Icons.person_remove_outlined, color: Colors.red, size: 18 * scale), SizedBox(width: 8 * scale), Text(l10n.removeMember, style: TextStyle(fontSize: 13 * scale))]),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * context.fontSizeFactor)),
        title: Text(l10n.payContribution, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
        content: Text(l10n.payContributionConfirm(amount.toStringAsFixed(2)), style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
            actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text(l10n.cancel, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
          ),
          ElevatedButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              showDialog(
                context: context,
                builder: (context) => PinEntryDialog(
                  title: l10n.enterSecurityPin,
                  description: l10n.enterTransactionPin,
                  onValidate: (pin) async {
                    final appState = Provider.of<AppState>(context, listen: false);
                    return appState.verifyPin(pin);
                  },
                  onConfirm: (pin) async {
                    final appState = Provider.of<AppState>(context, listen: false);
                    try {
                      await appState.payHagbad(group.id, memberIndex, amount);
                      Navigator.pop(context); // Close pay contribution dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.success),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${l10n.error}: ${e.toString()}")),
                      );
                    }
                  },
                ),
              );
            },
            style: context.elevatedButtonStyle(),
            child: Text(l10n.payNow, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * context.fontSizeFactor)),
        title: Row(
          children: [
            Icon(Icons.mosque_rounded, color: Colors.purple, size: 24 * context.fontSizeFactor),
            SizedBox(width: 10 * context.fontSizeFactor),
            Expanded(child: Text(l10n.hagbadOath, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(
          l10n.fullOathText,
          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14 * context.fontSizeFactor),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text(l10n.cancel, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
          ),
          ElevatedButton(
            style: context.elevatedButtonStyle(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              final updatedMember = member.copyWith(hasSignedOath: true);
              Provider.of<AppState>(context, listen: false).updateHagbadMember(group.id, index, updatedMember);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.memberSignedOath(member.name))),
              );
            },
            child: Text(l10n.confirm, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * context.fontSizeFactor)),
        title: Text(l10n.applyPenalty, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.enterPenaltyAmount(group.members[index].name), style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
            SizedBox(height: 16 * context.fontSizeFactor),
            TextField(
              controller: controller, 
              keyboardType: TextInputType.number, 
              style: TextStyle(fontSize: 14 * context.fontSizeFactor),
              decoration: InputDecoration(
                prefixText: r"$ ",
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(fontSize: 14 * context.fontSizeFactor),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text(l10n.cancel, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                final member = group.members[index];
                final updatedMember = member.copyWith(penaltyAmount: member.penaltyAmount + amount);
                Provider.of<AppState>(context, listen: false).updateHagbadMember(group.id, index, updatedMember);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.penaltyApplied(member.name, amount.toString()))),
                );
              }
            },
            style: context.elevatedButtonStyle(),
            child: Text(l10n.apply, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24 * context.fontSizeFactor)),
          title: Text(l10n.qoriTuur, textAlign: TextAlign.center, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSpinning)
                  Column(
                    children: [
                      SizedBox(
                        height: 150 * context.fontSizeFactor,
                        width: 150 * context.fontSizeFactor,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 150 * context.fontSizeFactor,
                              width: 150 * context.fontSizeFactor,
                              child: CircularProgressIndicator(
                                strokeWidth: 10 * context.fontSizeFactor, 
                                color: AppColors.primary,
                                backgroundColor: AppColors.accentTeal,
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 100),
                              child: CircleAvatar(
                                key: ValueKey<String>(currentName ?? ""),
                                radius: 50 * context.fontSizeFactor,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                child: Text(
                                  currentName?[0] ?? "?",
                                  style: TextStyle(fontSize: 40 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24 * context.fontSizeFactor),
                      Text(
                        currentName ?? "Selecting...", 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor),
                      ),
                      SizedBox(height: 8 * context.fontSizeFactor),
                      Text("Randomizing turns...", style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor)),
                    ],
                  )
                else
                  Column(
                    children: [
                      AdaptiveIcon(FontAwesomeIcons.dice, size: 60 * context.fontSizeFactor, color: AppColors.accentTeal),
                      SizedBox(height: 16 * context.fontSizeFactor),
                      Text(
                        l10n.qoriTuurDesc,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14 * context.fontSizeFactor),
                      ),
                      SizedBox(height: 16 * context.fontSizeFactor),
                      Container(
                        padding: EdgeInsets.all(12 * context.fontSizeFactor),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
                        ),
                        child: Text(
                          "Participants: ${remainingMembers.length}",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            if (!isSpinning)
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: Text(l10n.cancel, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
              ),
            if (!isSpinning)
              ElevatedButton(
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  showDialog(
                    context: context,
                    builder: (context) => PinEntryDialog(
                      title: l10n.enterSecurityPin,
                      description: l10n.enterTransactionPin,
                      onValidate: (pin) async {
                        final appState = Provider.of<AppState>(context, listen: false);
                        return appState.verifyPin(pin);
                      },
                      onConfirm: (pin) async {
                        final appState = Provider.of<AppState>(context, listen: false);
                        setDialogState(() => isSpinning = true);
                        
                        // Simple animation effect
                        for (int i = 0; i < 20; i++) {
                          await Future.delayed(Duration(milliseconds: 50 + (i * 10)));
                          setDialogState(() {
                            currentName = remainingMembers[i % remainingMembers.length].name;
                          });
                        }

                        await Future.delayed(const Duration(milliseconds: 500));

                        appState.randomizeHagbadTurns(group.id);
                        Navigator.pop(context); // Close QoriTuur dialog
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Turns randomized successfully!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  );
                },
                style: context.elevatedButtonStyle(),
                child: Text(l10n.randomize, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(20 * context.fontSizeFactor)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 8 * context.fontSizeFactor),
                    width: 40 * context.fontSizeFactor,
                    height: 4 * context.fontSizeFactor,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2 * context.fontSizeFactor),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0 * context.fontSizeFactor),
                    child: Text(
                      l10n.inviteToGroup(group.name),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * context.fontSizeFactor),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0 * context.fontSizeFactor),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            style: TextStyle(fontSize: 14 * context.fontSizeFactor),
                            decoration: InputDecoration(
                              hintText: l10n.enterWalletOrPhoneHint,
                              hintStyle: TextStyle(fontSize: 14 * context.fontSizeFactor),
                              border: const OutlineInputBorder(),
                              suffixIcon: isSearching 
                                  ? SizedBox(width: 20 * context.fontSizeFactor, height: 20 * context.fontSizeFactor, child: Padding(padding: EdgeInsets.all(10 * context.fontSizeFactor), child: CircularProgressIndicator(strokeWidth: 2))) 
                                  : (searchController.text.isNotEmpty 
                                      ? IconButton(
                                          icon: Icon(Icons.clear_rounded, size: 20 * context.fontSizeFactor),
                                          onPressed: () {
                                            HapticFeedback.lightImpact();
                                            searchController.clear();
                                            setDialogState(() {});
                                          },
                                        )
                                      : null),
                            ),
                          ),
                        ),
                        SizedBox(width: 8 * context.fontSizeFactor),
                        IconButton.filled(
                          onPressed: isSearching ? null : () async {
                            HapticFeedback.mediumImpact();
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
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * context.fontSizeFactor)),
                                        title: Text("Add Late Member", style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                                        content: Text("Since the group is in cycle ${group.currentCycle}, the new member must pay \$${catchUpAmount.toStringAsFixed(2)} to catch up with previous contributions. Add them now?", style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel, style: TextStyle(fontSize: 14 * context.fontSizeFactor))),
                                          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.confirm, style: TextStyle(fontSize: 14 * context.fontSizeFactor))),
                                        ],
                                      ),
                                    );
                                    if (confirmed != true) {
                                       if (context.mounted) setDialogState(() => isSearching = false);
                                       return;
                                    }
                                  }

                                  if (context.mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => PinEntryDialog(
                                        title: l10n.enterSecurityPin,
                                        description: l10n.enterTransactionPin,
                                        onValidate: (pin) async {
                                          final appState = Provider.of<AppState>(context, listen: false);
                                          return appState.verifyPin(pin);
                                        },
                                        onConfirm: (pin) async {
                                          final appState = Provider.of<AppState>(context, listen: false);
                                          try {
                                            appState.addHagbadMember(
                                              group.id, 
                                              newMember,
                                              catchUpAmount: newMember.paidAmount,
                                            );
                                            Navigator.pop(context); // Close invite bottom sheet
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.memberInvitedSuccess(name))));
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                          }
                                        },
                                      ),
                                    );
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
                          icon: Icon(Icons.person_add, size: 20 * context.fontSizeFactor),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 32 * context.fontSizeFactor),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * context.fontSizeFactor)),
          title: Text(l10n.guarantorDetails, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.requireGuarantor, style: TextStyle(fontSize: 13 * context.fontSizeFactor, color: AppColors.grey)),
              SizedBox(height: 16 * context.fontSizeFactor),
              if (member.guarantorName != null) ...[
                Container(
                  padding: EdgeInsets.all(12 * context.fontSizeFactor),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12 * context.fontSizeFactor),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20 * context.fontSizeFactor),
                      SizedBox(width: 12 * context.fontSizeFactor),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(member.guarantorName!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                            if (member.guarantorId != null) Text(member.guarantorId!, style: TextStyle(fontSize: 12 * context.fontSizeFactor)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 18 * context.fontSizeFactor),
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
                SizedBox(height: 16 * context.fontSizeFactor),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      style: TextStyle(fontSize: 14 * context.fontSizeFactor),
                      decoration: InputDecoration(
                        hintText: l10n.guarantorIdLabel,
                        hintStyle: TextStyle(fontSize: 14 * context.fontSizeFactor),
                        border: const OutlineInputBorder(),
                        suffixIcon: isSearching 
                            ? SizedBox(width: 20 * context.fontSizeFactor, height: 20 * context.fontSizeFactor, child: Padding(padding: EdgeInsets.all(10 * context.fontSizeFactor), child: CircularProgressIndicator(strokeWidth: 2))) 
                            : (searchController.text.isNotEmpty 
                                ? IconButton(
                                    icon: Icon(Icons.clear_rounded, size: 20 * context.fontSizeFactor),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      searchController.clear();
                                      setDialogState(() {});
                                    },
                                  )
                                : null),
                      ),
                    ),
                  ),
                  SizedBox(width: 8 * context.fontSizeFactor),
                  IconButton.filled(
                    onPressed: isSearching ? null : () {
                      HapticFeedback.mediumImpact();
                      final id = searchController.text.trim();
                      if (id.isEmpty) return;
                      
                      showDialog(
                        context: context,
                        builder: (context) => PinEntryDialog(
                          title: l10n.enterSecurityPin,
                          description: l10n.enterTransactionPin,
                          onValidate: (pin) async {
                            final appState = Provider.of<AppState>(context, listen: false);
                            return appState.verifyPin(pin);
                          },
                          onConfirm: (pin) async {
                            final appState = Provider.of<AppState>(context, listen: false);
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
                        ),
                      );
                    },
                    icon: Icon(Icons.search, size: 20 * context.fontSizeFactor),
                  ),
                ],
              ),
              SizedBox(height: 16 * context.fontSizeFactor),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  // PIN verification before sensitive administrative actions
                  showDialog(
                    context: context,
                    builder: (context) => PinEntryDialog(
                      title: l10n.enterSecurityPin,
                      description: l10n.enterTransactionPin,
                      onValidate: (pin) async {
                        final appState = Provider.of<AppState>(context, listen: false);
                        return appState.verifyPin(pin);
                      },
                      onConfirm: (pin) async {
                        final appState = Provider.of<AppState>(context, listen: false);
                        final updatedMember = member.copyWith(
                          guarantorName: "Admin (Accepted)",
                          guarantorId: "ADMIN",
                          isGuarantorConfirmed: true,
                        );
                        appState.updateHagbadMember(group.id, index, updatedMember);
                        appState.logHagbadEvent(group.id, "Admin (${group.adminName}) vouched for ${member.name}");
                        Navigator.pop(context); // Close guarantor details dialog
                      },
                    ),
                  );
                },
                  style: context.outlinedButtonStyle(),
                  child: Text("Skip (Admin Accepted)", style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Text(l10n.cancel, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * context.fontSizeFactor)),
        title: Text(l10n.deleteGroup, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
        content: Text(l10n.deleteGroupConfirm, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text(l10n.cancel, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              showDialog(
                context: context,
                builder: (context) => PinEntryDialog(
                  title: l10n.enterSecurityPin,
                  description: l10n.enterTransactionPin,
                  onValidate: (pin) async {
                    final appState = Provider.of<AppState>(context, listen: false);
                    return appState.verifyPin(pin);
                  },
                  onConfirm: (pin) {
                    final appState = Provider.of<AppState>(context, listen: false);
                    appState.deleteHagbadGroup(group.id);
                    Navigator.pop(context);
                  },
                ),
              );
            },
            child: Text(l10n.delete, style: TextStyle(color: Colors.red, fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * context.fontSizeFactor)),
        title: Text(l10n.removeMember, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
        content: Text(l10n.removeMemberConfirm(member.name), style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text(l10n.cancel, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              showDialog(
                context: context,
                builder: (context) => PinEntryDialog(
                  title: l10n.enterSecurityPin,
                  description: l10n.enterTransactionPin,
                  onValidate: (pin) async {
                    final appState = Provider.of<AppState>(context, listen: false);
                    return appState.verifyPin(pin);
                  },
                  onConfirm: (pin) {
                    final appState = Provider.of<AppState>(context, listen: false);
                    appState.removeHagbadMember(group.id, index);
                    Navigator.pop(context);
                  },
                ),
              );
            },
            child: Text(l10n.delete, style: TextStyle(color: Colors.red, fontSize: 14 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * context.fontSizeFactor)),
          title: Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.blue, size: 24 * context.fontSizeFactor),
              SizedBox(width: 8 * context.fontSizeFactor),
              Text(l10n.edit, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.personalDetails.toUpperCase(), style: TextStyle(fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: Colors.grey)),
                SizedBox(height: 8 * context.fontSizeFactor),
                TextField(
                  controller: nameController,
                  style: TextStyle(fontSize: 14 * context.fontSizeFactor),
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    labelStyle: TextStyle(fontSize: 14 * context.fontSizeFactor),
                    prefixIcon: Icon(Icons.person, size: 20 * context.fontSizeFactor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * context.fontSizeFactor)),
                  ),
                ),
                SizedBox(height: 16 * context.fontSizeFactor),
                TextField(
                  controller: walletIdController,
                  style: TextStyle(fontSize: 14 * context.fontSizeFactor),
                  decoration: InputDecoration(
                    labelText: "Wallet ID / Phone",
                    labelStyle: TextStyle(fontSize: 14 * context.fontSizeFactor),
                    prefixIcon: Icon(Icons.account_balance_wallet, size: 20 * context.fontSizeFactor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * context.fontSizeFactor)),
                  ),
                ),
                SizedBox(height: 24 * context.fontSizeFactor),
                Text("TRUST & STATUS", style: TextStyle(fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: Colors.grey)),
                SwitchListTile(
                  title: Text(l10n.trustedMember, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
                  subtitle: Text("Admin vouching for this member", style: TextStyle(fontSize: 12 * context.fontSizeFactor)),
                  value: isTrusted,
                  onChanged: (val) => setDialogState(() => isTrusted = val),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: Text("Confirmed Participation", style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
                  subtitle: Text("Member has accepted invitation", style: TextStyle(fontSize: 12 * context.fontSizeFactor)),
                  value: isConfirmed,
                  onChanged: (val) => setDialogState(() => isConfirmed = val),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: Text("Payout Completed", style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
                  subtitle: Text("Manually override payout status", style: TextStyle(fontSize: 12 * context.fontSizeFactor)),
                  value: hasReceived,
                  onChanged: (val) => setDialogState(() => hasReceived = val),
                  contentPadding: EdgeInsets.zero,
                ),
                SizedBox(height: 24 * context.fontSizeFactor),
                Text("GUARANTOR (HAG-DOR)", style: TextStyle(fontSize: 12 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: Colors.grey)),
                SizedBox(height: 8 * context.fontSizeFactor),
                TextField(
                  controller: guarantorNameController,
                  style: TextStyle(fontSize: 14 * context.fontSizeFactor),
                  decoration: InputDecoration(
                    labelText: "Guarantor Name",
                    labelStyle: TextStyle(fontSize: 14 * context.fontSizeFactor),
                    prefixIcon: Icon(Icons.security, size: 20 * context.fontSizeFactor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * context.fontSizeFactor)),
                  ),
                ),
                SizedBox(height: 16 * context.fontSizeFactor),
                TextField(
                  controller: guarantorIdController,
                  style: TextStyle(fontSize: 14 * context.fontSizeFactor),
                  decoration: InputDecoration(
                    labelText: "Guarantor Wallet ID",
                    labelStyle: TextStyle(fontSize: 14 * context.fontSizeFactor),
                    prefixIcon: Icon(Icons.vpn_key, size: 20 * context.fontSizeFactor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * context.fontSizeFactor)),
                  ),
                ),
                SwitchListTile(
                  title: Text("Guarantor Confirmed", style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
                  value: isGuarantorConfirmed,
                  onChanged: (val) => setDialogState(() => isGuarantorConfirmed = val),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Text(l10n.cancel, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
            ),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                showDialog(
                  context: context,
                  builder: (context) => PinEntryDialog(
                    title: l10n.enterSecurityPin,
                    description: l10n.enterTransactionPin,
                    onValidate: (pin) async {
                      final appState = Provider.of<AppState>(context, listen: false);
                      return appState.verifyPin(pin);
                    },
                    onConfirm: (pin) {
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

                      Navigator.pop(context);
                    },
                  ),
                );
              },
              style: context.elevatedButtonStyle(),
              child: Text(l10n.saveChanges, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * context.fontSizeFactor)),
        title: Text(l10n.swapTurn, style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select a member to swap turns with ${member.name}.", style: TextStyle(color: Colors.grey[600], fontSize: 13 * context.fontSizeFactor)),
            SizedBox(height: 16 * context.fontSizeFactor),
            SizedBox(
              width: double.maxFinite,
              height: 300 * context.fontSizeFactor,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: group.members.length,
                separatorBuilder: (context, i) => i == index ? const SizedBox.shrink() : Divider(height: 1 * context.fontSizeFactor),
                itemBuilder: (context, i) {
                  if (i == index) return const SizedBox.shrink();
                  final otherMember = group.members[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: CircleAvatar(
                      radius: 18 * context.fontSizeFactor,
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      child: Text(otherMember.avatar, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
                    ),
                    title: Text(otherMember.name, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14 * context.fontSizeFactor)),
                    subtitle: Text("Current: ${_getTurnLabel(group.frequency, otherMember.payoutOrder, l10n)}", style: TextStyle(fontSize: 12 * context.fontSizeFactor)),
                    trailing: Icon(Icons.swap_horiz, color: Colors.blue, size: 20 * context.fontSizeFactor),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      showDialog(
                        context: context,
                        builder: (context) => PinEntryDialog(
                          title: l10n.enterSecurityPin,
                          description: l10n.enterTransactionPin,
                          onValidate: (pin) async {
                            final appState = Provider.of<AppState>(context, listen: false);
                            return appState.verifyPin(pin);
                          },
                          onConfirm: (pin) {
                            final appState = Provider.of<AppState>(context, listen: false);
                            appState.swapHagbadTurns(group.id, index, i);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text(l10n.cancel, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
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
