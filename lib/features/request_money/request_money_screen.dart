import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/widgets/contact_sync_list.dart';
import '../../core/app_state.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/widgets/success_screen.dart';
import 'package:intl/intl.dart';

class RequestMoneyScreen extends StatefulWidget {
  const RequestMoneyScreen({super.key});

  @override
  State<RequestMoneyScreen> createState() => _RequestMoneyScreenState();
}

class _RequestMoneyScreenState extends State<RequestMoneyScreen> {
  Contact? _selectedContact;
  String? _selectedMurtaaxName;
  String? _selectedWalletId;
  
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _searchController = TextEditingController();
  final _noteFocusNode = FocusNode();
  
  bool _showAmountInput = false;
  bool _isSearching = false;
  bool _isSplitEnabled = false;
  bool _isKeypadVisible = true;
  int _splitPeopleCount = 2;
  List<double> _individualShares = [];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    _noteFocusNode.addListener(() {
      if (_noteFocusNode.hasFocus) {
        setState(() => _isKeypadVisible = false);
      }
    });
  }

  void _onAmountChanged() {
    if (_isSplitEnabled) {
      _updateSplitShares();
    }
  }

  void _updateSplitShares() {
    double total = double.tryParse(_amountController.text) ?? 0;
    if (total <= 0) {
      _individualShares = List.generate(_splitPeopleCount, (_) => 0.0);
      setState(() {});
      return;
    }

    // Calculate integer split
    int baseAmount = (total / _splitPeopleCount).floor();
    int remainder = (total.toInt() - (baseAmount * _splitPeopleCount));

    List<double> newShares = List.generate(_splitPeopleCount, (index) {
      return (index < remainder) ? (baseAmount + 1).toDouble() : baseAmount.toDouble();
    });

    // Handle any remaining decimals if total was not an integer
    double sum = newShares.fold(0, (a, b) => a + b);
    if (sum < total) {
      newShares[newShares.length - 1] = double.parse((newShares[newShares.length - 1] + (total - sum)).toStringAsFixed(2));
    }

    setState(() {
      _individualShares = newShares;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _searchController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  DateTime? _expiryDate;
  String _reminderOption = "24h";

  void _showExpiryPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.accentTeal,
              primary: AppColors.accentTeal,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  void _showReminderPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Auto-Reminder", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            _buildReminderOption("None"),
            _buildReminderOption("12h"),
            _buildReminderOption("24h"),
            _buildReminderOption("48h"),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderOption(String option) {
    return ListTile(
      title: Text(option == "None" ? "No reminder" : "Send if unpaid in $option"),
      trailing: _reminderOption == option ? const Icon(Icons.check_circle, color: AppColors.accentTeal) : null,
      onTap: () {
        setState(() => _reminderOption = option);
        Navigator.pop(context);
      },
    );
  }

  void _onPersonSelected({Contact? contact, required String name, required String walletId}) {
    setState(() {
      _selectedContact = contact;
      _selectedMurtaaxName = name;
      _selectedWalletId = walletId;
      _showAmountInput = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _showAmountInput ? "Request from ${_selectedMurtaaxName ?? _selectedContact?.displayName}" : l10n.requestMoney,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20 * context.fontSizeFactor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (_showAmountInput) {
              setState(() => _showAmountInput = false);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: context.responsiveBody(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _showAmountInput ? _buildAmountInput(l10n, theme) : _buildContactSelection(l10n, theme),
        ),
      ),
    );
  }

  Widget _buildContactSelection(AppLocalizations l10n, ThemeData theme) {
    final appState = Provider.of<AppState>(context);
    final quickProfiles = appState.quickProfiles;
    final searchQuery = _searchController.text.toLowerCase();
    final bool isSearching = searchQuery.isNotEmpty;

    final filteredQuickProfiles = searchQuery.isEmpty 
        ? quickProfiles 
        : quickProfiles.where((p) => 
            p.name.toLowerCase().contains(searchQuery) || 
            p.walletId.toLowerCase().contains(searchQuery)
          ).toList();

    final List<MapEntry<String, String>> globalMatches = searchQuery.isEmpty
        ? []
        : appState.mockUsers.entries
            .where((e) => e.key.contains(searchQuery) || e.value.toLowerCase().contains(searchQuery))
            .take(10)
            .toList();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.horizontalPadding,
            vertical: 16,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: "Wallet ID or Phone",
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: AppColors.accentTeal),
                    suffixIcon: isSearching 
                      ? IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.grey),
                          onPressed: () { _searchController.clear(); setState(() {}); },
                        )
                      : null,
                    filled: true,
                    fillColor: theme.brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                  onSubmitted: _handleSearch,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  // QR Scanner logic would go here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("QR Scanner opening..."))
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accentTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.accentTeal),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              if (isSearching && globalMatches.isNotEmpty) ...[
                _buildHeader("Murtaax Network", Icons.public, theme),
                ...globalMatches.map((e) => ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(e.value[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(e.value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text("ID: ${e.key}", style: theme.textTheme.bodySmall),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => _onPersonSelected(name: e.value, walletId: e.key),
                )),
                const Divider(height: 32),
              ],

              if (filteredQuickProfiles.isNotEmpty) ...[
                _buildHeader(isSearching ? "Matched in Quick Selection" : "Recent & Quick Selection", Icons.speed, theme),
                const SizedBox(height: 12),
                FadeInRight(
                  duration: const Duration(milliseconds: 400),
                  child: SizedBox(
                    height: 110 * context.fontSizeFactor,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding - 8),
                      itemCount: filteredQuickProfiles.length,
                      itemBuilder: (context, index) {
                        final profile = filteredQuickProfiles[index];
                        return GestureDetector(
                          onTap: () => _onPersonSelected(name: profile.name, walletId: profile.walletId),
                          child: Container(
                            width: 85 * context.fontSizeFactor,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 28 * context.fontSizeFactor,
                                      backgroundColor: AppColors.accentTeal.withValues(alpha: 0.1),
                                      child: Text(profile.name[0], style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentTeal, fontSize: 18 * context.fontSizeFactor)),
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                        child: const Icon(Icons.history, size: 12, color: AppColors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  profile.name,
                                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const Divider(height: 32),
              ],

              _buildHeader(isSearching ? "Matched in Contacts" : "All Contacts", Icons.contacts, theme),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: ContactSyncList(
                  searchQuery: searchQuery,
                  onContactSelected: (contact, murtaaxName, verifiedId) {
                    _onPersonSelected(contact: contact, name: murtaaxName ?? "", walletId: verifiedId ?? "");
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput(AppLocalizations l10n, ThemeData theme) {
    final name = _selectedMurtaaxName ?? _selectedContact?.displayName ?? "Contact";
    final bool isSystemKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final bool showCustomKeypad = _isKeypadVisible && !isSystemKeyboardVisible;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (_isKeypadVisible) setState(() => _isKeypadVisible = false);
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  // Compact Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 18 * context.fontSizeFactor,
                        backgroundColor: AppColors.accentTeal.withValues(alpha: 0.1),
                        child: Text(name[0], style: TextStyle(fontSize: 16 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: AppColors.accentTeal)),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            if (_selectedWalletId != null)
                              Text("ID: $_selectedWalletId", style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 10)),
                          ],
                        ),
                      ),
                      if (_selectedWalletId != null) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, color: Colors.blue, size: 14),
                      ]
                    ],
                  ),
                  
                  SizedBox(height: 15 * context.fontSizeFactor),
                  
                  // Amount Display - Tap to reopen keypad
                  GestureDetector(
                    onTap: () => setState(() => _isKeypadVisible = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isKeypadVisible ? Colors.transparent : AppColors.accentTeal.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _amountController.text.isEmpty ? "\$0.00" : "\$${_amountController.text}",
                            style: TextStyle(
                              fontSize: (showCustomKeypad ? 38 : 30) * context.fontSizeFactor,
                              fontWeight: FontWeight.w900,
                              color: AppColors.accentTeal,
                            ),
                          ),
                          if (!_isKeypadVisible)
                            const Text("Tap to edit amount", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Compact Smart Suggestions
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ["5", "10", "20", "50", "100"].map((amount) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ActionChip(
                          label: Text("\$$amount", style: const TextStyle(fontSize: 11)),
                          onPressed: () => setState(() {
                            _amountController.text = amount;
                            _isKeypadVisible = true;
                          }),
                          backgroundColor: _amountController.text == amount ? AppColors.accentTeal : Colors.transparent,
                          labelStyle: TextStyle(
                            color: _amountController.text == amount ? Colors.white : AppColors.accentTeal,
                            fontWeight: FontWeight.bold,
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          side: BorderSide(color: AppColors.accentTeal.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      )).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _noteController,
                    focusNode: _noteFocusNode,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Add a note...",
                      prefixIcon: const Icon(Icons.edit_note_rounded, color: AppColors.accentTeal, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: theme.brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),

                  const SizedBox(height: 12),
                  
                  // Smart Options
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        children: [
                          _buildOptionTile(
                            icon: Icons.timer_outlined,
                            title: "Expires",
                            subtitle: _expiryDate == null ? "Never" : DateFormat('MMM dd').format(_expiryDate!),
                            color: Colors.blue,
                            onTap: _showExpiryPicker,
                          ),
                          const Divider(height: 12),
                          _buildOptionTile(
                            icon: Icons.notifications_active_outlined,
                            title: "Reminder",
                            subtitle: _reminderOption == "None" ? "None" : "Every $_reminderOption",
                            color: Colors.purple,
                            onTap: _showReminderPicker,
                          ),
                          const Divider(height: 12),
                          // Split Bill Toggle
                          Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.call_split_rounded, color: Colors.orange, size: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(child: Text("Split bill?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                  SizedBox(
                                    height: 28,
                                    child: Switch(
                                      value: _isSplitEnabled, 
                                      onChanged: (v) {
                                        setState(() {
                                          _isSplitEnabled = v;
                                          if (v) {
                                            _updateSplitShares();
                                            _isKeypadVisible = false;
                                          }
                                        });
                                      }, 
                                      activeColor: Colors.orange
                                    ),
                                  ),
                                ],
                              ),
                              if (_isSplitEnabled) 
                                FadeInDown(
                                  duration: const Duration(milliseconds: 200),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            const SizedBox(width: 32),
                                            const Text("Split: ", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                            const Spacer(),
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle_outline, size: 18),
                                              onPressed: _splitPeopleCount > 2 ? () {
                                                setState(() => _splitPeopleCount--);
                                                _updateSplitShares();
                                              } : null,
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: Text("$_splitPeopleCount", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add_circle_outline, size: 18),
                                              onPressed: () {
                                                setState(() => _splitPeopleCount++);
                                                _updateSplitShares();
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                            const Text(" people", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ...List.generate(_individualShares.length, (index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 6),
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 8),
                                                CircleAvatar(
                                                  radius: 9,
                                                  backgroundColor: AppColors.accentTeal.withValues(alpha: 0.1),
                                                  child: Text("${index + 1}", style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.accentTeal)),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    index == 0 ? "You" : "Person ${index + 1}",
                                                    style: const TextStyle(fontSize: 11),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Container(
                                                  width: 65,
                                                  height: 26,
                                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                                  decoration: BoxDecoration(
                                                    color: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Text("\$", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentTeal, fontSize: 10)),
                                                      Expanded(
                                                        child: TextField(
                                                          keyboardType: TextInputType.number,
                                                          textAlign: TextAlign.right,
                                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                          decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                                                          controller: TextEditingController(text: _individualShares[index].toStringAsFixed(0))..selection = TextSelection.fromPosition(TextPosition(offset: _individualShares[index].toStringAsFixed(0).length)),
                                                          onChanged: (val) {
                                                            double? newVal = double.tryParse(val);
                                                            if (newVal != null) {
                                                              setState(() {
                                                                _individualShares[index] = newVal;
                                                              });
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                        _buildSplitSummary(),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          // Ultra-Compact Numeric Keypad
          if (showCustomKeypad)
            FadeInUp(
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
                  border: Border(top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.05))),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _isKeypadVisible = false),
                      child: Container(
                        width: 30,
                        height: 3,
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(1.5)),
                      ),
                    ),
                    _buildKeypad(),
                  ],
                ),
              ),
            ),

          // Bottom Action Button
          Container(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 8 + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
              boxShadow: [
                if (!showCustomKeypad) 
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, -2))
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _amountController.text.isEmpty ? null : _showSuccessDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  _isSplitEnabled ? "Request Split Bill" : "Send Request", 
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 3.2,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      children: [
        ...["1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "0"].map((key) => _buildKeypadButton(key)),
        _buildKeypadButton("backspace", isIcon: true),
      ],
    );
  }

  Widget _buildKeypadButton(String val, {bool isIcon = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isIcon) {
              if (_amountController.text.isNotEmpty) {
                _amountController.text = _amountController.text.substring(0, _amountController.text.length - 1);
              }
            } else {
              if (val == "." && _amountController.text.contains(".")) return;
              if (_amountController.text.length < 9) {
                _amountController.text += val;
              }
            }
          });
        },
        child: Center(
          child: isIcon 
            ? const Icon(Icons.backspace_outlined, color: Colors.grey, size: 16)
            : Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildSplitSummary() {
    double total = double.tryParse(_amountController.text) ?? 0;
    double currentSum = _individualShares.fold(0, (a, b) => a + b);
    bool matches = (currentSum - total).abs() < 0.01;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: matches ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            matches ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            size: 16,
            color: matches ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            matches 
                ? "Total matches: \$$total" 
                : "Total mismatch: \$$currentSum / \$$total",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: matches ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    final name = _selectedMurtaaxName ?? _selectedContact?.displayName ?? "Contact";
    final amount = _amountController.text;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          title: "Request Sent!",
          message: "We've sent your request for \$$amount to $name",
          buttonText: "Done",
          subMessage: "Awaiting confirmation from $name",
          transactionData: {
            'title': 'Money Request',
            'amount': '\$$amount',
            'receiver': name,
            'date': DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now()),
            'status': 'Pending',
            'type': 'request_out',
            'reference': 'REQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
            'note': _noteController.text,
            'expiry': _expiryDate == null ? 'Never' : DateFormat('MMM dd, yyyy').format(_expiryDate!),
            'reminder': _reminderOption,
            'isSplit': _isSplitEnabled.toString(),
            'splitCount': _isSplitEnabled ? _splitPeopleCount.toString() : '1',
          },
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }

  Widget _buildHeader(String title, IconData icon, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18 * context.fontSizeFactor, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSearch(String value) async {
    if (value.isEmpty) return;
    
    setState(() => _isSearching = true);
    final appState = Provider.of<AppState>(context, listen: false);
    
    final name = await appState.verifyWalletId(value);
    setState(() => _isSearching = false);

    if (name != null) {
      _onPersonSelected(name: name, walletId: value);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found. Please check the ID or Phone number.")),
        );
      }
    }
  }
}
