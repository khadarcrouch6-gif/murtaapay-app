import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_state.dart';
import '../../../core/models/quick_profile.dart';
import 'package:murtaaxpay_app/l10n/app_localizations.dart';
import '../../profile/account_limits_screen.dart';
import '../../profile/premium_upgrade_screen.dart';

class AddQuickProfileSheet extends StatefulWidget {
  final String? initialPhone;
  final String? initialName;

  const AddQuickProfileSheet({super.key, this.initialPhone, this.initialName});

  static Future<void> show(BuildContext context, {String? phone, String? name}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddQuickProfileSheet(initialPhone: phone, initialName: name),
    );
  }

  @override
  State<AddQuickProfileSheet> createState() => _AddQuickProfileSheetState();
}

class _AddQuickProfileSheetState extends State<AddQuickProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _idController;
  String _payoutMethod = 'Wallet';
  String? _selectedBank;
  String? _selectedProvider;
  bool _isVerifying = false;
  bool _isVerified = false;
  String? _verifiedName;

  final List<String> _banks = [
    'IBS Bank',
    'Salaam Bank',
    'Premier Bank',
    'Dahabshil Bank',
    'Amal Bank',
    'Other'
  ];

  final List<String> _mobileProviders = [
    'Hormuud (EVC Plus)',
    'Telesom (Zaad)',
    'Golis (Sahal)',
    'Somtel (e-Dahab)',
    'Somnet',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _idController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _verifyAccount() async {
    final id = _idController.text.trim();
    if (id.isEmpty) return;

    setState(() {
      _isVerifying = true;
      _isVerified = false;
      _verifiedName = null;
      _selectedBank = null;
      _selectedProvider = null;
    });

    final state = Provider.of<AppState>(context, listen: false);

    // Part One Logic: Auto-detection and Verification via AppState
    String? type;
    if (_payoutMethod == 'Bank') type = 'bank';
    if (_payoutMethod == 'Mobile') type = 'mobile';
    if (_payoutMethod == 'Wallet') type = 'wallet';

    final details = await state.resolveAccountDetails(id, type: type);

    setState(() {
      _isVerifying = false;
      if (details != null) {
        _isVerified = true;
        _verifiedName = details['name'];
        if (details['type'] == 'bank') {
          _selectedBank = details['bank'];
        } else if (details['type'] == 'mobile') {
          // Map to provider name if available, otherwise generic
          _selectedProvider = details['bank'] ?? 'Mobile Provider'; 
          if (_selectedProvider == 'Mobile Provider') {
            // Auto-detect provider if not returned by backend mock
            if (id.startsWith('61')) _selectedProvider = 'Hormuud (EVC Plus)';
            else if (id.startsWith('62')) _selectedProvider = 'Somnet';
            else if (id.startsWith('63')) _selectedProvider = 'Telesom (Zaad)';
            else if (id.startsWith('65')) _selectedProvider = 'Golis (Sahal)';
            else if (id.startsWith('77')) _selectedProvider = 'Somtel (e-Dahab)';
          }
        }
        _nameController.text = details['name']!;
      } else {
        _isVerified = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account verification failed. Please check the ID/Number.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_isVerified) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify the account first.')),
      );
      return;
    }

    final state = Provider.of<AppState>(context, listen: false);
    
    try {
      final profile = QuickProfile(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        walletId: _idController.text.trim(),
        payoutMethod: _payoutMethod,
        bankName: _payoutMethod == 'Bank' ? _selectedBank : (_payoutMethod == 'Mobile' ? _selectedProvider : null),
        isVerified: true,
        avatarUrl: 'https://ui-avatars.com/api/?name=${_nameController.text.trim().replaceAll(' ', '+')}&background=random',
      );

      state.saveQuickProfile(profile);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile for ${profile.name} saved!')),
      );
    } catch (e) {
      if (e.toString().contains('profile_limit_reached')) {
        _showLimitReachedDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Limit Reached'),
        content: const Text('Standard users can save up to 5 profiles. Upgrade to Premium for unlimited profiles!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumUpgradeScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomPadding),
        child: Form(
          key: _formKey,
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
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Add Quick Profile',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              
              // Payout Method Selection
              const Text('Payout Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              Row(
                children: ['Wallet', 'Bank', 'Mobile'].map((method) {
                  final isSelected = _payoutMethod == method;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(method),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() {
                          _payoutMethod = method;
                          _isVerified = false;
                          _verifiedName = null;
                          _selectedBank = null;
                          _selectedProvider = null;
                          _idController.clear();
                          _nameController.clear();
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _idController,
                keyboardType: _payoutMethod == 'Mobile' ? TextInputType.phone : TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  labelText: _payoutMethod == 'Wallet' ? 'Receiver Wallet ID' : (_payoutMethod == 'Bank' ? 'Receiver Bank Account Number' : 'Receiver Phone Number'),
                  hintText: _payoutMethod == 'Bank' ? 'Enter account number' : null,
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(_payoutMethod == 'Wallet' ? Icons.account_balance_wallet : (_payoutMethod == 'Bank' ? Icons.account_balance : Icons.phone_android)),
                  suffixIcon: _isVerifying 
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : IconButton(
                        icon: Icon(_isVerified ? Icons.check_circle : Icons.verified_user, color: _isVerified ? Colors.green : AppColors.primaryDark),
                        onPressed: _verifyAccount,
                      ),
                ),
                onChanged: (_) {
                  if (_isVerified) {
                    setState(() {
                      _isVerified = false;
                      _verifiedName = null;
                      _selectedBank = null;
                      _selectedProvider = null;
                    });
                  }
                },
              ),
              
              if (_isVerified) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified, color: Colors.green, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _verifiedName ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                                ),
                                Text(
                                  _payoutMethod == 'Bank' ? '$_selectedBank Account' : (_payoutMethod == 'Mobile' ? '$_selectedProvider Number' : 'MurtaaxPay Wallet'),
                                  style: TextStyle(fontSize: 13, color: Colors.green.withValues(alpha: 0.8)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_payoutMethod == 'Bank') ...[
                        const Divider(height: 24),
                        const Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.orange),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Transaction Pending: Bank transfers require 24 hours for final verification.',
                                style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Profile Nickname (e.g. My Brother)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (val) => val!.isEmpty ? 'Please enter a name for this profile' : null,
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isVerified ? _saveProfile : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: const Text('Save Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

