import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../core/models/message_model.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';

class ChatMessageWidget extends StatelessWidget {
  final Message message;

  const ChatMessageWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = message.senderId == 'current_user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CircleAvatar(
                radius: 16 * context.fontSizeFactor,
                backgroundColor: AppColors.accentTeal.withValues(alpha: 0.1),
                child: AdaptiveIcon(
                  FontAwesomeIcons.user,
                  size: 12 * context.fontSizeFactor,
                  color: AppColors.accentTeal,
                ),
              ),
            ),
          Align(
            alignment:
                isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
            child: _buildMessageContent(isCurrentUser, context),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              message.formattedTime,
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 12 * context.fontSizeFactor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(bool isCurrentUser, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage(isCurrentUser, context, theme, isDark);
      case MessageType.sms:
        return _buildSmsMessage(isCurrentUser, context, theme, isDark);
      case MessageType.audio:
        return _buildAudioMessage(isCurrentUser, context, theme, isDark);
      case MessageType.image:
        return _buildImageMessage(isCurrentUser, context, theme, isDark);
      case MessageType.document:
        return _buildDocumentMessage(isCurrentUser, context, theme, isDark);
      case MessageType.personalInfo:
        return _buildPersonalInfoMessage(isCurrentUser, context, theme, isDark);
      case MessageType.notification:
        return _buildNotificationMessage(context, theme, isDark);
      case MessageType.location:
        return _buildLocationMessage(isCurrentUser, context, theme, isDark);
      case MessageType.moneyTransfer:
        return _buildMoneyTransferMessage(isCurrentUser, context, theme, isDark);
    }
  }

  Widget _buildLocationMessage(bool isCurrentUser, BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      width: 200 * context.fontSizeFactor,
      padding: EdgeInsets.all(12 * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppColors.accentTeal : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser ? null : Border.all(color: theme.dividerColor),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AdaptiveIcon(
                FontAwesomeIcons.locationDot,
                color: isCurrentUser ? Colors.white : AppColors.accentTeal,
                size: 16 * context.fontSizeFactor,
              ),
              SizedBox(width: 8 * context.fontSizeFactor),
              Flexible(
                child: Text(
                  AppLocalizations.of(context)!.location,
                  style: TextStyle(
                    color: isCurrentUser ? Colors.white : theme.textTheme.titleSmall?.color,
                    fontSize: 12 * context.fontSizeFactor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 100 * context.fontSizeFactor,
            decoration: BoxDecoration(
              color: isCurrentUser ? Colors.white.withValues(alpha: 0.2) : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: AdaptiveIcon(
                FontAwesomeIcons.map,
                color: isCurrentUser ? Colors.white : AppColors.accentTeal,
                size: 32 * context.fontSizeFactor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message.content,
            style: TextStyle(
              color: isCurrentUser ? Colors.white : theme.textTheme.bodyMedium?.color,
              fontSize: 13 * context.fontSizeFactor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyTransferMessage(bool isCurrentUser, BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      width: 240 * context.fontSizeFactor,
      padding: EdgeInsets.all(16 * context.fontSizeFactor),
      decoration: BoxDecoration(
        gradient: isCurrentUser ? AppColors.accentGradient : null,
        color: isCurrentUser ? null : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: isCurrentUser ? null : Border.all(color: AppColors.accentTeal.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentTeal.withValues(alpha: isDark ? 0.05 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCurrentUser ? Colors.white.withValues(alpha: 0.2) : AppColors.accentTeal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: AdaptiveIcon(
              FontAwesomeIcons.moneyBillTransfer,
              color: isCurrentUser ? Colors.white : AppColors.accentTeal,
              size: 24 * context.fontSizeFactor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isCurrentUser 
                ? AppLocalizations.of(context)!.youSentMoney 
                : AppLocalizations.of(context)!.youReceivedMoney,
            style: TextStyle(
              color: isCurrentUser ? Colors.white.withValues(alpha: 0.9) : theme.textTheme.bodySmall?.color,
              fontSize: 12 * context.fontSizeFactor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message.content,
            style: TextStyle(
              color: isCurrentUser ? Colors.white : theme.textTheme.titleLarge?.color,
              fontSize: 20 * context.fontSizeFactor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isCurrentUser ? Colors.white.withValues(alpha: 0.2) : AppColors.accentTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              AppLocalizations.of(context)!.completed,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : AppColors.accentTeal,
                fontSize: 11 * context.fontSizeFactor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextMessage(bool isCurrentUser, BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 12 * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.accentTeal
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser ? null : Border.all(
          color: theme.dividerColor,
        ),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Text(
        message.content,
        style: TextStyle(
          color: isCurrentUser ? Colors.white : theme.textTheme.bodyLarge?.color,
          fontSize: 14 * context.fontSizeFactor,
        ),
      ),
    );
  }

  Widget _buildSmsMessage(bool isCurrentUser, BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(12 * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.accentTeal
            : AppColors.primaryDark.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser ? null : Border.all(
          color: AppColors.primaryDark.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AdaptiveIcon(
                FontAwesomeIcons.commentSms,
                color: isCurrentUser ? Colors.white : (isDark ? Colors.blue[300] : AppColors.primaryDark),
                size: 16 * context.fontSizeFactor,
              ),
              SizedBox(width: 8 * context.fontSizeFactor),
              Flexible(
                child: Text(
                  AppLocalizations.of(context)!.smsMessage,
                  style: TextStyle(
                    color:
                        isCurrentUser ? Colors.white : (isDark ? Colors.blue[300] : AppColors.primaryDark),
                    fontSize: 12 * context.fontSizeFactor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * context.fontSizeFactor),
          Text(
            message.content,
            style: TextStyle(
              color: isCurrentUser ? Colors.white : theme.textTheme.bodyLarge?.color,
              fontSize: 14 * context.fontSizeFactor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioMessage(bool isCurrentUser, BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      width: 240 * context.fontSizeFactor,
      padding: EdgeInsets.all(12 * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.accentTeal
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser ? null : Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AdaptiveIcon(
                FontAwesomeIcons.play,
                color: isCurrentUser ? Colors.white : AppColors.accentTeal,
                size: 16 * context.fontSizeFactor,
              ),
              SizedBox(width: 8 * context.fontSizeFactor),
              Flexible(
                child: Text(
                  AppLocalizations.of(context)!.audioMessage,
                  style: TextStyle(
                    color: isCurrentUser ? Colors.white : theme.textTheme.titleSmall?.color,
                    fontSize: 12 * context.fontSizeFactor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * context.fontSizeFactor),
          Row(
            children: [
              Container(
                width: 40 * context.fontSizeFactor,
                height: 40 * context.fontSizeFactor,
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.accentTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: AdaptiveIcon(
                  FontAwesomeIcons.play,
                  color:
                      isCurrentUser ? Colors.white : AppColors.accentTeal,
                  size: 16 * context.fontSizeFactor,
                ),
              ),
              SizedBox(width: 12 * context.fontSizeFactor),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 4 * context.fontSizeFactor,
                      decoration: BoxDecoration(
                        color: isCurrentUser
                            ? Colors.white.withValues(alpha: 0.3)
                            : theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '0:45',
                      style: TextStyle(
                        color:
                            isCurrentUser ? Colors.white : theme.textTheme.bodySmall?.color,
                        fontSize: 11 * context.fontSizeFactor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageMessage(bool isCurrentUser, BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      width: 200 * context.fontSizeFactor,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 200 * context.fontSizeFactor,
            height: 150 * context.fontSizeFactor,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: AdaptiveIcon(
              FontAwesomeIcons.image,
              color: AppColors.accentTeal,
              size: 40 * context.fontSizeFactor,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12 * context.fontSizeFactor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'photo_${DateTime.now().millisecond}.jpg',
                  style: TextStyle(
                    fontSize: 12 * context.fontSizeFactor,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '2.4 MB',
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 11 * context.fontSizeFactor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentMessage(bool isCurrentUser, BuildContext context, ThemeData theme, bool isDark) {
    final docType = message.documentType?.name ?? 'document';
    final docName = message.documentName ?? 'document.$docType';

    return Container(
      width: 240 * context.fontSizeFactor,
      padding: EdgeInsets.all(12 * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryDark.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44 * context.fontSizeFactor,
            height: 44 * context.fontSizeFactor,
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: AdaptiveIcon(
              _getDocumentIcon(message.documentType),
              color: isDark ? Colors.blue[300] : AppColors.primaryDark,
              size: 20 * context.fontSizeFactor,
            ),
          ),
          SizedBox(width: 12 * context.fontSizeFactor),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  docName,
                  style: TextStyle(
                    fontSize: 13 * context.fontSizeFactor,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${docType.toUpperCase()} • 1.2 MB',
                  style: TextStyle(
                    fontSize: 11 * context.fontSizeFactor,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: AdaptiveIcon(
              FontAwesomeIcons.download,
              color: isDark ? Colors.blue[300] : AppColors.primaryDark,
              size: 14 * context.fontSizeFactor,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.downloadingDocument),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoMessage(bool isCurrentUser, BuildContext context, ThemeData theme, bool isDark) {
    final info = message.personalInfo;
    if (info == null) {
      return _buildTextMessage(isCurrentUser, context, theme, isDark);
    }

    return Container(
      width: 280 * context.fontSizeFactor,
      padding: EdgeInsets.all(16 * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: AppColors.accentTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentTeal.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AdaptiveIcon(
                FontAwesomeIcons.idCard,
                color: AppColors.accentTeal,
                size: 18 * context.fontSizeFactor,
              ),
              SizedBox(width: 12 * context.fontSizeFactor),
              Flexible(
                child: Text(
                  AppLocalizations.of(context)!.personalInformation,
                  style: TextStyle(
                    fontSize: 14 * context.fontSizeFactor,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem(context, theme, AppLocalizations.of(context)!.fullName, info.fullName),
          const SizedBox(height: 8),
          _buildInfoItem(context, theme, AppLocalizations.of(context)!.emailAddress, info.email),
          const SizedBox(height: 8),
          _buildInfoItem(context, theme, AppLocalizations.of(context)!.phoneNumber, info.phone),
          const SizedBox(height: 8),
          _buildInfoItem(context, theme, AppLocalizations.of(context)!.residentialAddress, info.address),
          const SizedBox(height: 8),
          _buildInfoItem(context, theme, AppLocalizations.of(context)!.city, info.city),
          const SizedBox(height: 8),
          _buildInfoItem(context, theme, AppLocalizations.of(context)!.country, info.country),
          const SizedBox(height: 8),
          _buildInfoItem(context, theme, AppLocalizations.of(context)!.postalCode, info.postalCode),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11 * context.fontSizeFactor,
            color: theme.textTheme.bodySmall?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13 * context.fontSizeFactor,
            color: theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationMessage(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 8 * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message.content,
        style: TextStyle(
          color: theme.textTheme.bodySmall?.color,
          fontSize: 12 * context.fontSizeFactor,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  dynamic _getDocumentIcon(DocumentType? type) {
    switch (type) {
      case DocumentType.pdf:
        return FontAwesomeIcons.filePdf;
      case DocumentType.doc:
        return FontAwesomeIcons.fileWord;
      case DocumentType.image:
        return FontAwesomeIcons.image;
      case DocumentType.video:
        return FontAwesomeIcons.video;
      default:
        return FontAwesomeIcons.file;
    }
  }
}

