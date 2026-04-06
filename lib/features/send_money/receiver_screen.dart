import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/responsive_utils.dart';
import '../../l10n/app_localizations.dart';
import 'review_screen.dart';

class ReceiverScreen extends StatefulWidget {
  final String amount;
  final String method;
  const ReceiverScreen({super.key, required this.amount, required this.method});


  @override
  State<ReceiverScreen> createState() => _ReceiverScreenState();
}

class _ReceiverScreenState extends State<ReceiverScreen> {
  final TextEditingController _idController = TextEditingController();
  String _verifiedName = "";
  bool _isSearching = false;

  void _lookupName(String value) {
    if (value.length >= 4) {
      setState(() => _isSearching = true);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _verifiedName = value.toUpperCase().startsWith("M") ? "Mohamed Hassan Ali" : "Hassan Mohamed Abdi";
          });
        }
      });
    } else {
      setState(() {
        _verifiedName = "";
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.receiverDetails, 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * context.fontSizeFactor)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.enterReceiverPhone,
                    style: TextStyle(fontSize: 16 * context.fontSizeFactor, color: AppColors.grey),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _idController,
                    onChanged: _lookupName,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(fontSize: 18 * context.fontSizeFactor, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: l10n.phoneNumber,
                      prefixIcon: const Icon(Icons.phone_android_rounded),
                      suffixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),

                  const SizedBox(height: 16),
                  if (_isSearching)
                    const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                  else if (_verifiedName.isNotEmpty)
                    FadeIn(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.accentTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Icon(Icons.verified_user_rounded, color: AppColors.accentTeal, size: 20 * context.fontSizeFactor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "${l10n.receiver}: $_verifiedName", 
                                style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.recent, 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
                  const SizedBox(height: 16),
                  _buildRecentItem(context, "Mohamed Ali", "615 123 456"),
                  _buildRecentItem(context, "Ahmed Hersi", "634 987 654"),
                  
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56 * context.fontSizeFactor,
                    child: Opacity(
                      opacity: _idController.text.isNotEmpty ? 1.0 : 0.5,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_idController.text.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewScreen(
                                  amount: widget.amount,
                                  receiverName: _verifiedName.isNotEmpty ? _verifiedName : "Receiver",
                                  receiverPhone: _idController.text,
                                  method: widget.method,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.pleaseEnterDetails)),
                            );
                          }
                        },
                        child: Text(
                          l10n.continueToReview,
                          style: TextStyle(fontSize: 16 * context.fontSizeFactor, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentItem(BuildContext context, String name, String detail) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryDark.withValues(alpha: 0.1),
        child: Text(name[0], style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 14 * context.fontSizeFactor)),
      ),
      title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * context.fontSizeFactor)),
      subtitle: Text(detail, style: TextStyle(fontSize: 14 * context.fontSizeFactor)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14 * context.fontSizeFactor, color: AppColors.grey),
      onTap: () {
        setState(() {
          _idController.text = detail;
          _lookupName(_idController.text);
        });
      },
    );
  }
}
