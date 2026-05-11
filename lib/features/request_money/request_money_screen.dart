import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../core/widgets/contact_sync_list.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/widgets/contact_sync_list.dart';
import '../../core/app_state.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class RequestMoneyScreen extends StatefulWidget {
  const RequestMoneyScreen({super.key});

  @override
  State<RequestMoneyScreen> createState() => _RequestMoneyScreenState();
}

class _RequestMoneyScreenState extends State<RequestMoneyScreen> {
  Contact? _selectedContact;
  String? _selectedMurtaaxName;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _showAmountInput = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.requestMoney),
        centerTitle: true,
      ),
      body: _showAmountInput ? _buildAmountInput(l10n) : _buildContactSelection(l10n),
    );
  }

  Widget _buildContactSelection(AppLocalizations l10n) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            l10n.requestMoneyDesc,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        Expanded(
          child: ContactSyncList(
            onContactSelected: (contact, murtaaxName) {
              setState(() {
                _selectedContact = contact;
                _selectedMurtaaxName = murtaaxName;
                _showAmountInput = true;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final name = _selectedMurtaaxName ?? _selectedContact?.displayName ?? "Contact";

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
            child: Text(name[0], style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.secondary)),
          ),
          const SizedBox(height: 16),
          Text(
            "Request from $name",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              hintText: "0.00",
              prefixText: "\$ ",
              border: InputBorder.none,
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: "What's it for? (Optional)",
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _submitRequest(l10n),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Send Request", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _showAmountInput = false),
            child: const Text("Change Contact"),
          ),
        ],
      ),
    );
  }

  void _submitRequest(AppLocalizations l10n) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    // In a real app, this would call an API.
    // For now, we'll just show success and go back.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        content: Text(
          "Request for \$${amount.toStringAsFixed(2)} sent to ${_selectedMurtaaxName ?? _selectedContact?.displayName}",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to Home
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
