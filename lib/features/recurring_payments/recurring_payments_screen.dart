import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/app_state.dart';
import '../../core/app_colors.dart';
import '../../core/models/recurring_payment_model.dart';
import '../../l10n/app_localizations.dart';
import '../../core/widgets/adaptive_icon.dart';
import '../../core/widgets/contact_sync_list.dart';
import 'package:responsive_framework/responsive_framework.dart';

class RecurringPaymentsScreen extends StatefulWidget {
  const RecurringPaymentsScreen({super.key});

  @override
  State<RecurringPaymentsScreen> createState() => _RecurringPaymentsScreenState();
}

class _RecurringPaymentsScreenState extends State<RecurringPaymentsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recurringPayments, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddRecurringDialog(context),
          ),
        ],
      ),
      body: state.recurringPayments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AdaptiveIcon(FontAwesomeIcons.calendarCheck, size: 64, color: AppColors.grey),
                  const SizedBox(height: 16),
                  Text("No recurring payments yet", style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showAddRecurringDialog(context),
                    child: Text(l10n.add),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.recurringPayments.length,
              itemBuilder: (context, index) {
                final payment = state.recurringPayments[index];
                return _buildRecurringCard(payment, index, l10n, theme);
              },
            ),
    );
  }

  Widget _buildRecurringCard(RecurringPayment payment, int index, AppLocalizations l10n, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryDark.withAlpha(25),
          child: const Icon(Icons.repeat, color: AppColors.primaryDark),
        ),
        title: Text(payment.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${payment.receiverName} • \$${payment.amount.toStringAsFixed(2)}"),
            Text(
              "Next: ${payment.nextPaymentDate != null ? DateFormat('MMM dd, yyyy').format(payment.nextPaymentDate!) : 'Not scheduled'}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (val) {
            if (val == 'delete') {
              Provider.of<AppState>(context, listen: false).deleteRecurringPayment(index);
            } else if (val == 'pause') {
              final updated = payment.copyWith(status: payment.status == RecurringStatus.active ? RecurringStatus.paused : RecurringStatus.active);
              Provider.of<AppState>(context, listen: false).updateRecurringPayment(index, updated);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'pause',
              child: Text(payment.status == RecurringStatus.active ? "Pause" : "Resume"),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRecurringDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String? selectedReceiver;
    String? selectedReceiverName;
    RecurringFrequency selectedFreq = RecurringFrequency.monthly;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Schedule Payment"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Description (e.g. Rent)", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Amount", prefixText: "\$ ", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<RecurringFrequency>(
                  value: selectedFreq,
                  decoration: const InputDecoration(labelText: "Frequency", border: OutlineInputBorder()),
                  items: RecurringFrequency.values.map((f) => DropdownMenuItem(value: f, child: Text(f.name.toUpperCase()))).toList(),
                  onChanged: (val) => setDialogState(() => selectedFreq = val!),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(selectedReceiverName ?? "Select Recipient"),
                  subtitle: Text(selectedReceiver ?? ""),
                  trailing: const Icon(Icons.person_add_alt_1),
                  onTap: () async {
                    final result = await _showContactPicker(context);
                    if (result != null) {
                      setDialogState(() {
                        selectedReceiver = result['walletId'];
                        selectedReceiverName = result['name'];
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && amountController.text.isNotEmpty && selectedReceiver != null) {
                  final newPayment = RecurringPayment(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    receiverId: selectedReceiver!,
                    receiverName: selectedReceiverName!,
                    amount: double.parse(amountController.text),
                    frequency: selectedFreq,
                    startDate: DateTime.now(),
                    nextPaymentDate: DateTime.now().add(const Duration(days: 30)),
                    status: RecurringStatus.active,
                    category: "Transfer",
                  );
                  Provider.of<AppState>(context, listen: false).addRecurringPayment(newPayment);
                  Navigator.pop(context);
                }
              },
              child: const Text("Schedule"),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, String>?> _showContactPicker(BuildContext context) async {
    Map<String, String>? selected;
    await showModalBottomSheet(
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
                const SizedBox(height: 16),
                const Text("Select Recipient", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Expanded(
                  child: ContactSyncList(
                    onContactSelected: (contact, murtaaxName) {
                      if (murtaaxName != null) {
                        selected = {
                          'name': murtaaxName,
                          'walletId': contact.phones.first.number,
                        };
                        Navigator.pop(context);
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
    return selected;
  }
}
