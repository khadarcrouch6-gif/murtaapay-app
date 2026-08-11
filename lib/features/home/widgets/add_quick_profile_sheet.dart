import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_state.dart';
import '../../../core/models/quick_profile.dart';
import '../../../l10n/app_localizations.dart';

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
    if (_idController.text.trim().isEmpty) return;

    setState(() {
      _isVerifying = true;
      _isVerified = false;
      _verifiedName = null;
    });

    final state = Provider.of<AppState>(context, listen: false);
    
    // Determine type for resolution
    String type = 'wallet';
    if (_payoutMethod == 'Bank') type = 'bank';
    if (_payoutMethod == 'Mobile') type = 'mobile';

    // Skip auto-verification for "Other" bank as it's not in the system
    if (type == 'bank' && _selectedBank == 'Other') {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _isVerifying = false;
        _isVerified = true; // Allow manual entry
      });
      return;
    }

    final name = await state.resolveAccountName(
      _idController.text.trim(), 
      type: type, 
      bankName: type == 'bank' ? _selectedBank : _selectedProvider
    );

    setState(() {
      _isVerifying = false;
      if (name != null && name.isNotEmpty) {
        _isVerified = true;
        _verifiedName = name;
        _nameController.text = name; // Auto-fill and lock if verified? User said "magacana clear garee" if number deleted, implying it fills.
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
              // Navigate to subscription/upgrade screen
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
                    color: Colors.grey.withOpacity(0.3),
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

              if (_payoutMethod == 'Bank') ...[
                DropdownButtonFormField<String>(
                  value: _selectedBank,
                  decoration: const InputDecoration(
                    labelText: 'Select Bank',
                    border: OutlineInputBorder(),
                  ),
                  items: _banks.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (val) => setState(() {
                  _selectedBank = val;
                  _isVerified = false;
                  _verifiedName = null;
                  _idController.clear();
                  _nameController.clear();
                }),
                  validator: (val) => val == null ? 'Please select a bank' : null,
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Colors.orange),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Bank transfers may take up to 24 hours to reflect.',
                        style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              if (_payoutMethod == 'Mobile') ...[
                DropdownButtonFormField<String>(
                  value: _selectedProvider,
                  decoration: const InputDecoration(
                    labelText: 'Select Provider',
                    border: OutlineInputBorder(),
                  ),
                  items: _mobileProviders.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (val) => setState(() {
                    _selectedProvider = val;
                    _isVerified = false;
                    _verifiedName = null;
                    _idController.clear();
                    _nameController.clear();
                  }),
                  validator: (val) => val == null ? 'Please select a provider' : null,
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _idController,
                keyboardType: _payoutMethod == 'Mobile' ? TextInputType.phone : TextInputType.number,
                maxLength: _payoutMethod == 'Bank' ? (_selectedBank == 'IBS Bank' ? 12 : 10) : null,
                inputFormatters: [
                  if (_payoutMethod == 'Bank' || _payoutMethod == 'Mobile')
                    FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  labelText: _payoutMethod == 'Wallet' ? 'Wallet ID' : (_payoutMethod == 'Bank' ? 'Account Number' : 'Phone Number'),
                  border: const OutlineInputBorder(),
                  counterText: '',
                  helperText: _isVerified ? 'Account verified' : 'Click the icon to verify',
                  helperStyle: TextStyle(color: _isVerified ? Colors.green : Colors.grey),
                  suffixIcon: IconButton(
                    icon: _isVerifying 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(_isVerified ? Icons.check_circle : Icons.verified_user, color: _isVerified ? Colors.green : AppColors.primaryDark),
                    onPressed: _isVerifying ? null : _verifyAccount,
                  ),
                ),
                onChanged: (_) => setState(() {
                  _isVerified = false;
                  _verifiedName = null;
                  _nameController.clear(); // Clear name on change to force re-verification
                }),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'This field is required';
                  if (_payoutMethod == 'Bank') {
                    final requiredLen = _selectedBank == 'IBS Bank' ? 12 : 10;
                    if (_selectedBank != 'Other' && val.length != requiredLen) {
                      return 'Account number must be $requiredLen digits';
                    }
                  }
                  return null;
                },
              ),
              
              if (_verifiedName != null) ...[
                const SizedBox(height: 8),
                Text('Verified Name: $_verifiedName', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],

              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                readOnly: _selectedBank != 'Other',
                decoration: InputDecoration(
                  labelText: 'Account Name',
                  hintText: (_selectedBank == 'Other') ? 'Enter name manually' : 'Verified automatically',
                  border: const OutlineInputBorder(),
                  fillColor: (_selectedBank == 'Other') ? Colors.transparent : const Color(0xFFF5F5F5),
                  filled: true,
                ),
                validator: (val) => val!.isEmpty ? (_selectedBank == 'Other' ? 'Please enter a name' : 'Please verify to get name') : null,
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
