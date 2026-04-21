import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/adaptive_icon.dart';
import 'shimmer_loading.dart';

class TransactionItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final String status;
  final String? date;
  final bool? isSent;
  final dynamic icon;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
    this.date,
    this.isSent,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: (icon != null)
                  ? Colors.grey.withOpacity(0.1)
                  : (isSent == null 
                    ? theme.colorScheme.primary.withOpacity(0.05)
                    : (isSent! ? Colors.red : AppColors.accentTeal).withOpacity(0.1)),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: icon != null 
                  ? AdaptiveIcon(icon, color: AppColors.primaryDark, size: 20)
                  : (isSent == null 
                    ? Text(
                        title.isNotEmpty ? title[0] : "?",
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : AdaptiveIcon(
                        isSent! ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown,
                        color: isSent! ? Colors.red : AppColors.accentTeal,
                        size: 16,
                      )),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    date != null ? "$subtitle • $date" : subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      amount,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: (isSent == false || amount.startsWith('+')) 
                            ? AppColors.accentTeal 
                            : (isSent == true || amount.startsWith('-')) 
                                ? Colors.red 
                                : null,
                      ),
                    ),
                  ),
                  Text(
                    status == "Success" ? l10n.success : l10n.pending,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: status == "Success" ? AppColors.accentTeal : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget skeleton(BuildContext context) {
    final theme = Theme.of(context);
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const ShimmerPlaceholder.circular(size: 48),
            const SizedBox(width: 16),
            const Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerPlaceholder(width: 120, height: 16),
                  SizedBox(height: 8),
                  ShimmerPlaceholder(width: 80, height: 12),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ShimmerPlaceholder(width: 60, height: 16),
                  SizedBox(height: 8),
                  ShimmerPlaceholder(width: 40, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
