import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.termsConditions, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${l10n.lastUpdated}: ${l10n.apr2026}", 
              style: const TextStyle(color: AppColors.grey)
            ),
            const SizedBox(height: 24),
            _buildSection(
              l10n.acceptanceOfTerms, 
              l10n.acceptanceOfTermsDesc
            ),
            _buildSection(
              l10n.userVerificationL10n, 
              l10n.userVerificationDescL10n
            ),
            _buildSection(
              l10n.transactionFees, 
              l10n.transactionFeesDesc
            ),
            _buildSection(
              l10n.privacyPolicyL10n, 
              l10n.privacyPolicyDescL10n
            ),
            _buildSection(
              l10n.limitationOfLiability, 
              l10n.limitationOfLiabilityDesc
            ),
            _buildSection(
              l10n.hagbadTerms, 
              l10n.hagbadTermsDesc
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                "${l10n.copyrightMurtaaxPay} ${l10n.allRightsReserved}",
                style: const TextStyle(color: AppColors.grey, fontSize: 12),
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
