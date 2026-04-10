import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import 'sadaqah_screen.dart';

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
              IconButton(onPressed: () {}, icon: const Icon(Icons.share_rounded, color: Colors.white)),
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
                        "${widget.campaign.description}\n\nThis is a community effort to support our brothers and sisters. Your contribution, no matter how small, makes a big difference in changing lives. We ensure 100% of your donation reaches the intended recipients.",
                        style: TextStyle(fontSize: 15, height: 1.6, color: theme.textTheme.bodyMedium?.color ?? AppColors.textPrimary),
                      ),
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
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: isDark ? Border.all(color: theme.dividerColor.withValues(alpha: 0.1)) : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("\$${widget.campaign.raisedAmount.toInt()}", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? theme.colorScheme.onSurface : AppColors.primaryDark)),
                  Text("${state.translate("Raised of", "Laga ururiyay", ar: "تم جمع من", de: "Gesammelt von", et: "Kogutud")}\$${widget.campaign.goalAmount.toInt()} ${state.translate("goal", "hadaf", ar: "الهدف", de: "Ziel", et: "eesmärk")}", style: TextStyle(color: theme.textTheme.bodySmall?.color ?? AppColors.grey, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: AppColors.accentTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text("${(progress * 100).toInt()}%", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.accentTeal)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? theme.scaffoldBackgroundColor : AppColors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.people_alt_rounded, color: theme.textTheme.bodySmall?.color ?? AppColors.grey, size: 16),
              const SizedBox(width: 8),
              Text("124 ${state.translate("people donated", "qof ayaa deeq bixiyay", ar: "أشخاص تبرعوا", de: "Personen haben gespendet", et: "inimest annetasid")}", style: TextStyle(color: theme.textTheme.bodySmall?.color ?? AppColors.grey, fontSize: 13)),
            ],
          )
        ],
      ),
    );
  }

  void _showDonateDialog(BuildContext context, AppState state, ThemeData theme, bool isDark) {
    int selectedAmount = 50;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 5, decoration: BoxDecoration(color: isDark ? Colors.grey[700] : Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 24),
                Text(state.translate("Choose Donation Amount", "Dooro Cadadka Deeqda", ar: "اختر مبلغ التبرع", de: "Spendenbetrag wählen", et: "Vali annetuse summa"), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [10, 50, 100, 500].map((amount) {
                    bool isSelected = selectedAmount == amount;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedAmount = amount),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.accentTeal : Colors.transparent,
                          border: Border.all(color: isSelected ? AppColors.accentTeal : (isDark ? Colors.grey[700]! : Colors.grey[300]!)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text("\$$amount", style: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? theme.colorScheme.onSurface : AppColors.primaryDark),
                          fontWeight: FontWeight.bold, fontSize: 16,
                        )),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                TextField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.attach_money, color: isDark ? theme.colorScheme.onSurface : null),
                    hintText: state.translate("Custom Amount", "Cadad Kale", ar: "مبلغ مخصص", de: "Eigener Betrag", et: "Muu summa"),
                    hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.accentTeal)),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.translate("Thank you for your generous donation!", "Waad ku mahadsan tahay deeqdaada deeqsinimada leh!", ar: "شكراً لك على تبرعك السخي!", de: "Vielen Dank für Ihre großzügige Spende!", et: "Täname teid helde annetuse eest!"))));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentTeal,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(state.translate("Confirm Donation", "Xaqiiji Deeqda", ar: "تأكيد التبرع", de: "Spende bestätigen", et: "Kinnita annetus"), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          );
        }
      ),
    );
  }
}
