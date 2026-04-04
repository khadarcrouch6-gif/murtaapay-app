import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Last updated: Oct 2023", style: TextStyle(color: AppColors.grey)),
            const SizedBox(height: 24),
            _buildSection("1. Acceptance of Terms", "By using MurtaaxPay, you agree to comply with these terms. If you do not agree, please stop using the service."),
            _buildSection("2. User Verification", "MurtaaxPay requires all users to provide valid identity documentation (KYC) to prevent fraud and comply with international regulations."),
            _buildSection("3. Transaction Fees", "Transaction fees are displayed before every transfer. Fees may vary depending on the destination and method of payment."),
            _buildSection("4. Privacy Policy", "We value your privacy. Your biometric data (FaceID/Fingerprint) is stored on your device only and is never transmitted to our servers."),
            _buildSection("5. Limitation of Liability", "MurtaaxPay is not responsible for any delays caused by intermediary banks or mobile network operators."),
            const SizedBox(height: 40),
            Center(
              child: Text(
                "© 2023 MurtaaxPay. All rights reserved.",
                style: TextStyle(color: AppColors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
