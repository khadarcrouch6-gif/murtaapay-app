import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../app_colors.dart';
import '../app_state.dart';
import '../widgets/adaptive_icon.dart';

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
    final state = AppState();
    
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
              color: Colors.black.withValues(alpha: 0.02),
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
                  ? Colors.grey.withValues(alpha: 0.1)
                  : (isSent == null 
                    ? theme.colorScheme.primary.withValues(alpha: 0.05)
                    : (isSent! ? Colors.red : AppColors.accentTeal).withValues(alpha: 0.1)),
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
              flex: 3,
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
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: (isSent == false || amount.startsWith('+')) ? AppColors.accentTeal : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    status == "Success" ? state.translate("Success", "Guul", ar: "ناجح", de: "Erfolgreich") : state.translate("Pending", "Sugayn", ar: "قيد الانتظار", de: "Ausstehend"),
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
}
