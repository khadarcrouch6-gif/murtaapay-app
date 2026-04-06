import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import '../../l10n/app_localizations.dart';
import 'review_screen.dart';

class WalletReceiverScreen extends StatefulWidget {
  final String amount;
  final String method;
  
  const WalletReceiverScreen({
    super.key, 
    required this.amount, 
    required this.method
  });

  @override
  State<WalletReceiverScreen> createState() => _WalletReceiverScreenState();
}

class _WalletReceiverScreenState extends State<WalletReceiverScreen> {
  final TextEditingController _walletIdController = TextEditingController();
  String _verifiedReceiverName = "";
  bool _isSearching = false;

  void _lookupWalletId(String value) {
    if (value.length >= 4) {
      setState(() => _isSearching = true);
      // Simulate ID lookup from Murtaax server
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _verifiedReceiverName = _mockLookup(value);
          });
        }
      });
    } else {
      setState(() {
        _isSearching = false;
        _verifiedReceiverName = "";
      });
    }
  }

  String _mockLookup(String id) {
    if (id.startsWith("10")) return "Ayaanle Rayaale";
    if (id.startsWith("20")) return "Mohamed Abdi Ali";
    if (id.startsWith("30")) return "Sahra Hassan Duale";
    return "Murtaax User #$id";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.murtaaxTransfer, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Text(
                  l10n.enterReceiverWalletId,
                  style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.walletIdTransferNotice,
                style: TextStyle(color: AppColors.grey, fontSize: 13 * context.fontSizeFactor),
              ),
              const SizedBox(height: 32),
              
              // Search / ID Entry Box
              FadeInUp(
                child: TextField(
                  controller: _walletIdController,
                  onChanged: _lookupWalletId,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: l10n.enterWalletIdHint,
                    prefixIcon: const Icon(Icons.account_circle_outlined, color: AppColors.accentTeal),
                    suffixIcon: _isSearching 
                      ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.accentTeal, width: 2)),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Verified Receiver Display
              if (_verifiedReceiverName.isNotEmpty)
                FadeInUp(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.accentTeal,
                          child: Icon(Icons.check_rounded, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.verifiedReceiverLabel, 
                                style: const TextStyle(color: AppColors.accentTeal, fontSize: 10, fontWeight: FontWeight.bold)),
                              Text(_verifiedReceiverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.recentContacts, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  TextButton(
                    onPressed: () {}, 
                    child: Text(l10n.seeAll)),
                ],
              ),
              const SizedBox(height: 16),

              // Horizontal Recents
              SizedBox(
                height: 105,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildRecentUser("AR", "Ayaanle", "102234"),
                    _buildRecentUser("MA", "Mohamed", "204456"),
                    _buildRecentUser("SH", "Sahra", "309987"),
                    _buildRecentUser("HM", "Hassan", "401122"),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 56 * context.fontSizeFactor,
                child: ElevatedButton(
                  onPressed: _verifiedReceiverName.isEmpty ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewScreen(
                          amount: widget.amount,
                          receiverName: _verifiedReceiverName,
                          receiverPhone: _walletIdController.text,
                          method: widget.method,
                        ),
                      ),
                    );
                  },
                  child: Text(l10n.continueToReview),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentUser(String initials, String name, String id) {
    return GestureDetector(
      onTap: () {
        _walletIdController.text = id;
        _lookupWalletId(id);
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primaryDark.withValues(alpha: 0.1),
              child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _walletIdController.dispose();
    super.dispose();
  }
}

