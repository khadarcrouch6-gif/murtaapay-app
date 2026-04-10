import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import 'sadaqah_screen.dart';
import 'success_donation_screen.dart';

class CampaignDetailScreen extends StatefulWidget {
  final Campaign campaign;
  const CampaignDetailScreen({super.key, required this.campaign});

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppState();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    double progress = widget.campaign.raisedAmount / widget.campaign.goalAmount;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.campaign.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: AppColors.primaryDark),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withValues(alpha: 0.3), Colors.black.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () => _showShareSheet(context, state),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInUp(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.accentTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_rounded, color: AppColors.accentTeal, size: 16),
                            const SizedBox(width: 6),
                            Text(state.translate("Verified Organizer", "Qaban-qaabiye la Hubiyay", ar: "منظم تم التحقق منه", de: "Verifizierter Organisator", et: "Kontrollitud korraldaja"), style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: Text(widget.campaign.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                    ),
                    const SizedBox(height: 8),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: Text("${state.translate("Organized by", "Waxaa qaban-qaabiyay", ar: "تم تنظيمه بواسطة", de: "Organisiert von", et: "Korraldaja:")} ${widget.campaign.creator}", style: TextStyle(color: theme.textTheme.bodySmall?.color ?? AppColors.grey)),
                    ),
                    const SizedBox(height: 32),
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: _buildProgressCard(state, progress, theme, isDark),
                    ),
                    const SizedBox(height: 32),
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: Text(state.translate("About", "Ku saabsan", ar: "حول", de: "Über", et: "Teave"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: Text(
                        "${widget.campaign.description}\n\nThis fundraiser was started to handle the urgent costs for Ahmed's surgery. Every dollar brings us closer to the goal and helps save a life. Join the 142 donors who have already contributed.",
                        style: TextStyle(fontSize: 15, height: 1.6, color: theme.textTheme.bodyMedium?.color ?? AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Divider(color: theme.dividerColor.withOpacity(0.1)),
                    const SizedBox(height: 32),
                    FadeInUp(
                      delay: const Duration(milliseconds: 600),
                      child: _buildTrustSection(context, state),
                    ),
                    const SizedBox(height: 32),
                    FadeInUp(
                      delay: const Duration(milliseconds: 700),
                      child: _buildDonorsList(context, state),
                    ),
                    const SizedBox(height: 120), // padding for bottom button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
          border: isDark ? Border(top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))) : null,
        ),
        child: ElevatedButton(
          onPressed: () => _showDonateDialog(context, state, theme, isDark),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentTeal,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(state.translate("Donate Now", "Hadda Deeq Bixi", ar: "تبرع الآن", de: "Jetzt spenden", et: "Aneta kohe"), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildProgressCard(AppState state, double progress, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(isDark ? 0.1 : 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("\$${widget.campaign.raisedAmount.toInt()}", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              const SizedBox(width: 8),
              Text(state.translate("raised of", "la ururiyay"), style: TextStyle(color: AppColors.grey, fontSize: 14)),
              const SizedBox(width: 4),
              Text("\$${widget.campaign.goalAmount.toInt()} goal", style: TextStyle(color: AppColors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.people_alt_rounded, color: AppColors.accentTeal, size: 16),
              const SizedBox(width: 8),
              Text(
                "${widget.campaign.donorCount} ${state.translate("people donated", "qof ayaa deeq bixiyay")}",
                style: const TextStyle(color: AppColors.accentTeal, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTrustSection(BuildContext context, AppState state) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark.withOpacity(0.03), AppColors.primaryDark.withOpacity(0.01)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildTrustItem(Icons.verified_user_rounded, state.translate("Secure & Protected", "Ammaan ah oo la ilaaliyo"), state.translate("Bank-level encryption for every transaction.", "Sir qarsoodi ah oo heerkiisu sarreeyo.")),
          const SizedBox(height: 16),
          _buildTrustItem(Icons.monetization_on_rounded, state.translate("0% Platform Fees", "0% Khidmadda Platform-ka"), state.translate("We don't take a cut. 100% goes to the cause.", "Ma jiro wax naga go'aya. 100% waxay u socotaa mashaariicda.")),
          const SizedBox(height: 16),
          _buildTrustItem(Icons.account_balance_wallet_rounded, state.translate("Free Withdrawals", "Kala bixis Bilaash ah"), state.translate("Organizers pay \$0 to withdraw their funds.", "Qofna khidmad lagama rabo inuu lacagtiisa kala baxo.")),
        ],
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.accentTeal.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.accentTeal, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(subtitle, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  void _showShareSheet(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.translate("Share this Campaign", "Kala Qaybi Ololahan"), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareOption(Icons.message_rounded, "WhatsApp", Colors.green),
                _buildShareOption(Icons.facebook_rounded, "Facebook", Colors.blue),
                _buildShareOption(Icons.link_rounded, state.translate("Link", "Link-ga"), AppColors.primaryDark),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Expanded(child: Text("https://murtaaxpay.app/donate/ahmed-surgery", style: TextStyle(color: AppColors.grey, fontSize: 12), overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  Icon(Icons.copy_rounded, color: AppColors.primaryDark, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDonorsList(BuildContext context, AppState state) {
    final donors = [
      {"name": "Ali Hassan", "amount": 50, "time": "2m ago"},
      {"name": "Anonymous", "amount": 100, "time": "15m ago"},
      {"name": "Sahra Jama", "amount": 25, "time": "1h ago"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(state.translate("Recent Donations", "Deeqaha u Dambeeyay"), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...donors.map((donor) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.accentTeal.withOpacity(0.1),
                child: Text(donor["name"].toString().substring(0, 1), style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(donor["name"].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(donor["time"].toString(), style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Text("\$${donor["amount"]}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentTeal)),
            ],
          ),
        )).toList(),
      ],
    );
  }

  void _showDonateDialog(BuildContext context, AppState state, ThemeData theme, bool isDark) {
    int selectedAmount = 50;
    int currentStep = 0;
    String selectedMethod = "Mobile";
    final TextEditingController customAmountController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, -10)),
            ],
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Row(
                children: [
                   if (currentStep > 0) IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => setModalState(() => currentStep--)),
                   const Spacer(),
                   Text(
                     currentStep == 0 ? state.translate("Select Amount", "Dooro Cadadka") : 
                     currentStep == 1 ? state.translate("Payment Method", "Habka Lacag Bixinta") :
                     state.translate("Finalize Donation", "Xaqiiji Deeqda"),
                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                   ),
                   const Spacer(),
                   if (currentStep > 0) const SizedBox(width: 48),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      if (currentStep == 0) ...[
                        _buildAmountStep(state, selectedAmount, customAmountController, theme, (val) => setModalState(() => selectedAmount = val)),
                      ] else if (currentStep == 1) ...[
                        _buildPaymentMethodStep(state, selectedMethod, theme, (val) => setModalState(() => selectedMethod = val)),
                      ] else ...[
                        _buildDetailsStep(state, selectedMethod, phoneController),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(state.translate("Total", "Wartada"), style: const TextStyle(color: AppColors.grey)),
                        Text("\$${customAmountController.text.isNotEmpty ? customAmountController.text : selectedAmount}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.accentTeal)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        onPressed: () {
                          if (currentStep < 2) {
                            setModalState(() => currentStep++);
                          } else {
                             final double amount = customAmountController.text.isNotEmpty 
                                ? double.tryParse(customAmountController.text) ?? 0 
                                : selectedAmount.toDouble();
                            _processDonation(context, state, amount);
                          }
                        },
                        child: Text(
                          currentStep < 2 ? state.translate("Continue", "Sii Soco") : state.translate("Donate Now", "Hadda Deeq"),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.grey),
                        const SizedBox(width: 4),
                        Text(state.translate("Secured by MurtaaxPay", "MurtaaxPay ayaa dammaanad qaaday"), style: const TextStyle(color: AppColors.grey, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountStep(AppState state, int selectedAmount, TextEditingController controller, ThemeData theme, Function(int) onSelect) {
    final amounts = [10, 20, 50, 100, 250, 500];
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2),
          itemCount: amounts.length,
          itemBuilder: (context, index) => GestureDetector(
            onTap: () {
              onSelect(amounts[index]);
              controller.clear();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: selectedAmount == amounts[index] ? AppColors.accentTeal.withOpacity(0.12) : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selectedAmount == amounts[index] ? AppColors.accentTeal : theme.dividerColor.withOpacity(0.1),
                  width: selectedAmount == amounts[index] ? 2 : 1,
                ),
                boxShadow: selectedAmount == amounts[index] 
                  ? [BoxShadow(color: AppColors.accentTeal.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))]
                  : [],
              ),
              alignment: Alignment.center,
              child: Text(
                "\$${amounts[index]}", 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  color: selectedAmount == amounts[index] ? AppColors.accentTeal : theme.colorScheme.primary.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: (val) { if (val.isNotEmpty) onSelect(0); },
          decoration: InputDecoration(
            hintText: state.translate("Custom Amount", "Cadad Kale"),
            prefixIcon: const Icon(Icons.attach_money_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodStep(AppState state, String selectedMethod, ThemeData theme, Function(String) onSelect) {
    final methods = [
      {"id": "Mobile", "name": "Mobile Money", "so": "Mobile-ka", "icon": Icons.phone_android_rounded},
      {"id": "Bank", "name": "Bank Transfer", "so": "Bangiga", "icon": Icons.account_balance_rounded},
      {"id": "Card", "name": "Credit Card", "so": "Kaarka", "icon": Icons.credit_card_rounded},
    ];

    return Column(
      children: methods.map((m) => GestureDetector(
        onTap: () => onSelect(m["id"] as String),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selectedMethod == m["id"] ? AppColors.accentTeal.withOpacity(0.08) : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selectedMethod == m["id"] ? AppColors.accentTeal : theme.dividerColor.withOpacity(0.1),
              width: selectedMethod == m["id"] ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: selectedMethod == m["id"] ? AppColors.accentTeal.withOpacity(0.1) : theme.dividerColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(m["icon"] as IconData, color: selectedMethod == m["id"] ? AppColors.accentTeal : AppColors.grey, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                state.translate(m["name"] as String, m["so"] as String), 
                style: TextStyle(
                  fontWeight: selectedMethod == m["id"] ? FontWeight.bold : FontWeight.w500,
                  color: selectedMethod == m["id"] ? theme.colorScheme.primary : AppColors.grey,
                ),
              ),
              const Spacer(),
              if (selectedMethod == m["id"]) 
                const Icon(Icons.check_circle_rounded, color: AppColors.accentTeal, size: 24),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildDetailsStep(AppState state, String method, TextEditingController phoneController) {
    if (method == "Mobile") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(state.translate("Enter Phone Number", "Geli Lambarka Mobile-ka"), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: "E.g. 061XXXXXXX",
              prefixIcon: const Icon(Icons.phone_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProviderLogo("EVC+", Colors.blue),
              _buildProviderLogo("Sahal", Colors.orange),
              _buildProviderLogo("Zaad", Colors.red),
            ],
          ),
        ],
      );
    } else if (method == "Bank") {
      return Column(
        children: [
           const Icon(Icons.account_balance_rounded, size: 64, color: AppColors.grey),
           const SizedBox(height: 16),
           Text(state.translate("Select Local Bank", "Dooro Bangiga"), style: const TextStyle(fontWeight: FontWeight.bold)),
           const SizedBox(height: 8),
           Text(state.translate("Transfer directly via your bank app.", "Si toos ah ugu wareeji barnaamijkaaga bangiga.")),
        ],
      );
    } else {
      return Column(
        children: [
           const Icon(Icons.credit_card_rounded, size: 64, color: AppColors.grey),
           const SizedBox(height: 16),
           Text(state.translate("Pay with Visa/Mastercard", "Ku bixi Visa/Mastercard"), style: const TextStyle(fontWeight: FontWeight.bold)),
           const SizedBox(height: 8),
           Text(state.translate("Secure international payment gateway.", "Habka lacag bixinta ee caalamiga ah ee sugan.")),
        ],
      );
    }
  }

  Widget _buildProviderLogo(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.5))),
      child: Text(name, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  void _processDonation(BuildContext context, AppState state, double amount) {
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid amount")));
      return;
    }

    if (!state.hasSufficientBalance(amount)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(state.translate("Insufficient balance in your MurtaaxPay wallet.", "Haraagaagu kuguma filna.")),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    state.deductBalance(amount);
    Navigator.pop(context); // Close dialog
    Navigator.push(context, MaterialPageRoute(builder: (context) => SuccessDonationScreen(amount: amount)));
  }
}
