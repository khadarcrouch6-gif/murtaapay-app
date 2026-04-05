import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/detail_row.dart';
import 'package:responsive_framework/responsive_framework.dart';

class PayBillsScreen extends StatefulWidget {
  const PayBillsScreen({super.key});

  @override
  State<PayBillsScreen> createState() => _PayBillsScreenState();
}

class _PayBillsScreenState extends State<PayBillsScreen> {
  final List<Map<String, dynamic>> _categories = [
    {"title": "Electricity", "icon": Icons.lightbulb_outline_rounded, "color": Colors.orange},
    {"title": "Water", "icon": Icons.water_drop_outlined, "color": Colors.blue},
    {"title": "Internet", "icon": Icons.wifi_rounded, "color": Colors.purple},
    {"title": "TV Cable", "icon": Icons.tv_rounded, "color": Colors.red},
    {"title": "Education", "icon": Icons.school_outlined, "color": Colors.green},
    {"title": "Gov Services", "icon": Icons.account_balance_rounded, "color": Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppState();
    return Scaffold(
      appBar: AppBar(
        title: Text(state.translate("Pay Bills", "Bixi Biilasha", ar: "دفع الفواتير", de: "Rechnungen bezahlen"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor)),
        centerTitle: true,
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 900,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(state.translate("Select Category", "Dooro Qaybta", ar: "اختر الفئة", de: "Kategorie wählen"), style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: context.responsiveValue(mobile: 2, tablet: 3, desktop: 4),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    return _buildBillCategory(
                      context,
                      state,
                      _categories[index]["title"],
                      _categories[index]["icon"],
                      _categories[index]["color"],
                    );
                  },
                ),
                const SizedBox(height: 32),
                Text(state.translate("Recent Bills", "Biilashii Dhowaa", ar: "الفواتير الأخيرة", de: "Letzte Rechnungen"), style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildRecentBill(context, state, "Somtel Internet", "Oct 20, 2023", "\$25.00", "Internet", "ACC-992831"),
                _buildRecentBill(context, state, "BECO Electricity", "Oct 15, 2023", "\$42.50", "Electricity", "ACC-110293"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillCategory(BuildContext context, AppState state, String title, IconData icon, Color color) {
    final theme = Theme.of(context);
    String translatedTitle = state.translate(title, title, ar: _getArCategory(title), de: _getDeCategory(title));
    return GestureDetector(
      onTap: () => _showPayDialog(context, state, title, icon, color),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28 * context.fontSizeFactor),
            ),
            const SizedBox(height: 12),
            Text(translatedTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color)),
          ],
        ),
      ),
    );
  }

  void _showPayDialog(BuildContext context, AppState state, String category, IconData icon, Color color) {
    TextEditingController idController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text("${state.translate("Pay", "Bixi", ar: "دفع", de: "Bezahlen")} ${state.translate(category, category, ar: _getArCategory(category), de: _getDeCategory(category))}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: idController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  labelText: "${state.translate(category, category, ar: _getArCategory(category), de: _getDeCategory(category))} ID / ${state.translate("Account Number", "Lambarka Koontada", ar: "رقم الحساب", de: "Kontonummer")}",
                  labelStyle: TextStyle(color: AppColors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.tag, color: AppColors.grey),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: state.translate("Amount to Pay (\$)", "Cadadka la bixinayo (\$)", ar: "المبلغ المراد دفعه (\$)", de: "Zu zahlender Betrag (\$)"),
                  labelStyle: TextStyle(color: AppColors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.attach_money, color: AppColors.grey),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (idController.text.isNotEmpty && amountController.text.isNotEmpty) {
                    Navigator.pop(context);
                    _showSuccessDialog(context, state, category, amountController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: AppColors.accentTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(state.translate("Confirm Payment", "Xaqiiji Lacag Bixinta", ar: "تأكيد الدفع", de: "Zahlung bestätigen"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, AppState state, String category, String amount) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.accentTeal, size: 80),
            const SizedBox(height: 24),
            Text(state.translate("Payment Successful!", "Lacag bixinta waa lagu guulaystay!", ar: "تم الدفع بنجاح!", de: "Zahlung erfolgreich!"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: theme.textTheme.bodyLarge?.color)),
            const SizedBox(height: 12),
            Text(
              "${state.translate("Your payment of", "Lacag bixintaadi", ar: "دفعتك بمبلغ", de: "Ihre Zahlung von")} \$$amount ${state.translate("for", "ee", ar: "لـ", de: "für")} ${state.translate(category, category, ar: _getArCategory(category), de: _getDeCategory(category))} ${state.translate("has been processed.", "waa laga gudubay.", ar: "تمت معالجتها.", de: "wurde bearbeitet.")}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(onPressed: () => Navigator.pop(context), 
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(state.translate("Back to Bills", "Ku laabo Biillasha", ar: "العودة إلى الفواتير", de: "Zurück zu Rechnungen"), style: const TextStyle(color: Colors.white))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBill(BuildContext context, AppState state, String title, String date, String amount, String category, String id) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showBillDetail(context, state, title, date, amount, category, id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.1 : 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, shape: BoxShape.circle),
              child: Icon(Icons.receipt_long_rounded, color: theme.colorScheme.primary, size: 24 * context.fontSizeFactor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color)),
                  Text(date, style: TextStyle(color: AppColors.grey, fontSize: 12 * context.fontSizeFactor)),
                ],
              ),
            ),
            Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color)),
          ],
        ),
      ),
    );
  }

  void _showBillDetail(BuildContext context, AppState state, String title, String date, String amount, String category, String id) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(32, 20, 32, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Text(state.translate("Bill Details", "Faahfaahinta Biilka", ar: "تفاصيل الفاتورة", de: "Rechnungsdetails"), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
              const SizedBox(height: 24),
              DetailRow(label: state.translate("Service Provider", "Bixiyaha Adeegga", ar: "مزود الخدمة", de: "Dienstanbieter"), value: title),
              DetailRow(label: state.translate("Category", "Qaybta", ar: "الفئة", de: "Kategorie"), value: state.translate(category, category, ar: _getArCategory(category), de: _getDeCategory(category))),
              DetailRow(label: state.translate("Account ID", "Aqoonsiga Xisaabta", ar: "رقم الحساب", de: "Konto-ID"), value: id),
              DetailRow(label: state.translate("Amount Paid", "Lacagta la bixiyay", ar: "المبلغ المدفوع", de: "Gezahlter Betrag"), value: amount),
              DetailRow(label: state.translate("Payment Date", "Taariikhda Lacag Bixinta", ar: "تاريخ الدفع", de: "Zahlungsdatum"), value: date),
              DetailRow(label: state.translate("Status", "Heerka", ar: "الحالة", de: "Status"), value: state.translate("Completed", "Dhammaystiran", ar: "مكتمل", de: "Abgeschlossen"), valueColor: AppColors.accentTeal),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(state.translate("Download Receipt", "Soo deji Receipt-ka", ar: "تحميل الإيصال", de: "Beleg herunterladen"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(state.translate("Close", "Xidh", ar: "إغلاق", de: "Schließen"), style: const TextStyle(color: AppColors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getArCategory(String title) {
    switch (title) {
      case "Electricity": return "الكهرباء";
      case "Water": return "المياه";
      case "Internet": return "الإنترنت";
      case "TV Cable": return "كابل التلفزيون";
      case "Education": return "التعليم";
      case "Gov Services": return "الخدمات الحكومية";
      default: return title;
    }
  }

  String _getDeCategory(String title) {
    switch (title) {
      case "Electricity": return "Strom";
      case "Water": return "Wasser";
      case "Internet": return "Internet";
      case "TV Cable": return "TV-Kabel";
      case "Education": return "Bildung";
      case "Gov Services": return "Behördendienste";
      default: return title;
    }
  }
}

