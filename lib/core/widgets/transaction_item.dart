import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../app_colors.dart';
import '../responsive_utils.dart';
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
  final String? avatarUrl;
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
    this.avatarUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsetsDirectional.only(bottom: 12 * context.fontSizeFactor),
        padding: EdgeInsets.all(16 * context.fontSizeFactor),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10 * context.fontSizeFactor,
              offset: Offset(0, 4 * context.fontSizeFactor),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 48 * context.fontSizeFactor,
              width: 48 * context.fontSizeFactor,
              decoration: BoxDecoration(
                color: (avatarUrl != null || icon != null)
                  ? Colors.grey.withValues(alpha: 0.1)
                  : (isSent == null 
                    ? theme.colorScheme.primary.withValues(alpha: 0.05)
                    : (isSent! ? Colors.red : AppColors.accentTeal).withValues(alpha: 0.1)),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(24 * context.fontSizeFactor),
                      child: Image.network(
                        avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Text(
                          title.isNotEmpty ? title[0] : "?",
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18 * context.fontSizeFactor,
                          ),
                        ),
                      ),
                    )
                  : (icon != null 
                    ? AdaptiveIcon(icon, color: AppColors.primaryDark, size: 20 * context.fontSizeFactor)
                    : (isSent == null 
                      ? Text(
                          title.isNotEmpty ? title[0] : "?",
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18 * context.fontSizeFactor,
                          ),
                        )
                      : AdaptiveIcon(
                          isSent! ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown,
                          color: isSent! ? Colors.red : AppColors.accentTeal,
                          size: 16 * context.fontSizeFactor,
                        ))),
              ),
            ),
            SizedBox(width: 16 * context.fontSizeFactor),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: (theme.textTheme.bodyLarge?.fontSize ?? 16) * context.fontSizeFactor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    date != null ? "$subtitle • $date" : subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.grey,
                      fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) * context.fontSizeFactor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8 * context.fontSizeFactor),
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
                        fontSize: (theme.textTheme.bodyLarge?.fontSize ?? 16) * context.fontSizeFactor,
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
                      fontSize: (theme.textTheme.labelSmall?.fontSize ?? 11) * context.fontSizeFactor,
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
        margin: EdgeInsetsDirectional.only(bottom: 12 * context.fontSizeFactor),
        padding: EdgeInsets.all(16 * context.fontSizeFactor),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20 * context.fontSizeFactor),
        ),
        child: Row(
          children: [
            ShimmerPlaceholder.circular(size: 48 * context.fontSizeFactor),
            SizedBox(width: 16 * context.fontSizeFactor),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerPlaceholder(width: 120 * context.fontSizeFactor, height: 16 * context.fontSizeFactor),
                  SizedBox(height: 8 * context.fontSizeFactor),
                  ShimmerPlaceholder(width: 80 * context.fontSizeFactor, height: 12 * context.fontSizeFactor),
                ],
              ),
            ),
            SizedBox(width: 12 * context.fontSizeFactor),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ShimmerPlaceholder(width: 60 * context.fontSizeFactor, height: 16 * context.fontSizeFactor),
                  SizedBox(height: 8 * context.fontSizeFactor),
                  ShimmerPlaceholder(width: 40 * context.fontSizeFactor, height: 12 * context.fontSizeFactor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
