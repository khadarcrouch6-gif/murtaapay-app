import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/widgets/detail_row.dart';
import '../../core/responsive_utils.dart';
import 'payment_screen.dart';

class ReviewScreen extends StatefulWidget {
  final String amount;
  final String receiverName;
  final String receiverPhone;
  final String method;

  const ReviewScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.receiverPhone,
    required this.method,
  });


  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  void _handlePayment() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          amount: widget.amount,
          receiverName: widget.receiverName,
          receiverPhone: widget.receiverPhone,
          initialMethod: widget.method,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState();
    double sendAmount = double.tryParse(widget.amount) ?? 0;
    double receivedAmount = sendAmount * 1.08;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.translate("Review Transfer", "Dib-u-eegista Wareejinta"), 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.horizontalPadding),
        child: Column(
          children: [
                FadeInDown(
                  child: Container(
                    padding: EdgeInsets.all(24 * context.fontSizeFactor),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      children: [
                        DetailRow(label: state.translate("You send", "Adiga ayaa diraya"), value: "${widget.amount} EUR"),
                        const SizedBox(height: 16),
                        DetailRow(label: state.translate("Payment Method", "Habka Lacag-bixinta"), value: widget.method, valueColor: AppColors.primaryDark),
                        const SizedBox(height: 16),
                        DetailRow(label: state.translate("Fee", "Khidmad"), value: "0.00 EUR", valueColor: AppColors.accentTeal),
                        const SizedBox(height: 16),
                        DetailRow(label: state.translate("Exchange rate", "Qiimaha sarrifka"), value: "1 EUR = 1.08 USD"),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20 * context.fontSizeFactor),
                          child: const Divider(),
                        ),
                        DetailRow(
                          label: state.translate("Receiver gets", "Qaataha wuxuu helayaa"),
                          value: "\$${receivedAmount.toStringAsFixed(2)} USD",
                          valueColor: AppColors.primaryDark,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  child: Container(
                    padding: EdgeInsets.all(20 * context.fontSizeFactor),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryDark,
                          radius: 20 * context.fontSizeFactor,
                          child: FaIcon(FontAwesomeIcons.user, color: Colors.white, size: 16 * context.fontSizeFactor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.receiverName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
                              Text(widget.receiverPhone, style: TextStyle(color: AppColors.grey, fontSize: 14 * context.fontSizeFactor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: ElevatedButton(
                    onPressed: _handlePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentTeal,
                      minimumSize: Size(double.infinity, 56 * context.fontSizeFactor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      state.translate("Confirm & Pay", "Xaqiiji & Bixi"), 
                      style: TextStyle(fontSize: 16 * context.fontSizeFactor, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


