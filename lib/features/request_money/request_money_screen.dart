import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/widgets/contact_sync_list.dart';
import '../../core/app_state.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

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
  
  bool _showAmountInput = false;
  bool _isSearching = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onPersonSelected({Contact? contact, String? name, String? walletId}) {
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
          child: TextField(
            controller: _searchController,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: "Wallet ID or Phone",
              hintStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: isSearching 
                ? IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.grey),
                    onPressed: () { _searchController.clear(); setState(() {}); },
                  )
                : IconButton(
                    icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
                    onPressed: () => _handleSearch(_searchController.text),
                  ),
              filled: true,
              fillColor: theme.brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: (value) => setState(() {}),
            onSubmitted: _handleSearch,
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
                    backgroundColor: AppColors.primary.withOpacity(0.1),
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
                _buildHeader(isSearching ? "Matched in Quick Selection" : "Quick Selection", Icons.speed, theme),
                const SizedBox(height: 12),
                SizedBox(
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
                              CircleAvatar(
                                radius: 28 * context.fontSizeFactor,
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                child: Text(profile.name[0], style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18 * context.fontSizeFactor)),
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
                    _onPersonSelected(contact: contact, name: murtaaxName, walletId: verifiedId);
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

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40 * context.fontSizeFactor,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(name[0], style: TextStyle(fontSize: 32 * context.fontSizeFactor, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          const SizedBox(height: 16),
          Text(name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          if (_selectedWalletId != null)
            Text("ID: $_selectedWalletId", style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          
          SizedBox(height: 32 * context.fontSizeFactor),
          
          TextField(
            controller: _amountController,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            decoration: InputDecoration(
              hintText: "0.00",
              prefixText: r"$ ",
              prefixStyle: theme.textTheme.displaySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              border: InputBorder.none,
            ),
          ),
          const Divider(indent: 40, endIndent: 40),
          const SizedBox(height: 24),
          
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: "What is this for?",
              prefixIcon: const Icon(Icons.note_add_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: theme.brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[50],
            ),
          ),
          
          SizedBox(height: 48 * context.fontSizeFactor),
          
          SizedBox(
            width: double.infinity,
            height: 56 * context.fontSizeFactor,
            child: ElevatedButton(
              onPressed: () {
                // Handle request logic
                _showSuccessDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                "Request Payment",
                style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text("Request Sent!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            Text(
              "We've sent your request for \$${_amountController.text} to ${_selectedMurtaaxName ?? _selectedContact?.displayName}",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Back to Home
                },
                child: const Text("Done"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title, IconData icon, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18 * context.fontSizeFactor, color: theme.colorScheme.primary.withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
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
