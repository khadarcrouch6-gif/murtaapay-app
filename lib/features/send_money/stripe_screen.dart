import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/app_colors.dart';
import 'payment_success_screen.dart';
import 'credit_card_screen.dart';

class StripeScreen extends StatefulWidget {
  final String amount;
  final String receiverName;
  final String receiverPhone;

  const StripeScreen({
    super.key,
    required this.amount,
    required this.receiverName,
    required this.receiverPhone,
  });

  @override
  State<StripeScreen> createState() => _StripeScreenState();
}

class _StripeScreenState extends State<StripeScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _expiryMmyyController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  bool _isProcessing = false;

  void _processPayment() async {
    if (_emailController.text.isEmpty || _cardController.text.isEmpty || _expiryMmyyController.text.isEmpty || _cvcController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete the Stripe form")),
      );
      return;
    }

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(
            amount: widget.amount,
            receiverName: widget.receiverName,
            method: "Stripe",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color stripeColor = Color(0xFF635BFF);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FontAwesomeIcons.stripe, color: stripeColor, size: 48),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Center(
                child: Column(
                  children: [
                    const Text("Total Due", style: TextStyle(color: AppColors.grey, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text("${widget.amount} EUR", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 4),
                    Text("To ${widget.receiverName}", style: const TextStyle(color: AppColors.grey, fontSize: 14)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              child: const Text("Contact", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 12),
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Email",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: stripeColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
               delay: const Duration(milliseconds: 150),
               child: const Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 12),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _cardController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        CardNumberFormatter(),
                      ],
                      decoration: const InputDecoration(
                        hintText: "Card information",
                        prefixIcon: Icon(Icons.credit_card_rounded, color: AppColors.grey),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: InputBorder.none,
                      ),
                    ),
                    Divider(height: 1, color: AppColors.grey.withValues(alpha: 0.3)),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _expiryMmyyController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              ExpiryDateFormatter(),
                            ],
                            decoration: const InputDecoration(
                              hintText: "MM / YY",
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Container(width: 1, height: 48, color: AppColors.grey.withValues(alpha: 0.3)),
                        Expanded(
                          child: TextField(
                            controller: _cvcController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            decoration: const InputDecoration(
                              hintText: "CVC",
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: InputBorder.none,
                            ),
                            obscureText: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            FadeInUp(
              delay: const Duration(milliseconds: 250),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: stripeColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isProcessing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text("Processing...", style: TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        )
                      : Text(
                          "Pay ${widget.amount} EUR",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ),
            if (_isProcessing)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: FadeIn(
                    child: const Text(
                      "Processing via Stripe secure 3D secure...",
                      style: TextStyle(color: AppColors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _cardController.dispose();
    _expiryMmyyController.dispose();
    _cvcController.dispose();
    super.dispose();
  }
}

