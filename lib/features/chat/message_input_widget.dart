import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../core/models/message_model.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';
import 'personal_info_share_screen.dart';

class MessageInputWidget extends StatefulWidget {
  final Function(Message) onMessageSent;

  const MessageInputWidget({
    super.key,
    required this.onMessageSent,
  });

  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends State<MessageInputWidget> {
  final TextEditingController _messageController = TextEditingController();
  bool _showMediaOptions = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'current_user',
      senderName: 'You',
      senderAvatar: 'assets/images/logo1.png',
      type: MessageType.text,
      content: _messageController.text,
      timestamp: DateTime.now(),
      isRead: true,
    );

    widget.onMessageSent(message);
    _messageController.clear();
    setState(() => _showMediaOptions = false);
  }

  void _sendSMS() {
    if (_messageController.text.trim().isEmpty) return;

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'current_user',
      senderName: 'You',
      senderAvatar: 'assets/images/logo1.png',
      type: MessageType.sms,
      content: _messageController.text,
      timestamp: DateTime.now(),
      isRead: true,
    );

    widget.onMessageSent(message);
    _messageController.clear();
    setState(() => _showMediaOptions = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.smsSentSuccess),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _sendAudio() {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'current_user',
      senderName: 'You',
      senderAvatar: 'assets/images/logo1.png',
      type: MessageType.audio,
      content: 'Audio message',
      timestamp: DateTime.now(),
      audioPath: 'assets/sounds/sample.m4a',
      isRead: true,
    );

    widget.onMessageSent(message);
    setState(() => _showMediaOptions = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.audioSentSuccess),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _sendImage() {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'current_user',
      senderName: 'You',
      senderAvatar: 'assets/images/logo1.png',
      type: MessageType.image,
      content: 'Shared an image',
      timestamp: DateTime.now(),
      imagePath: 'assets/images/logo1.png',
      isRead: true,
    );

    widget.onMessageSent(message);
    setState(() => _showMediaOptions = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.imageSentSuccess),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _sendDocument() {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'current_user',
      senderName: 'You',
      senderAvatar: 'assets/images/logo1.png',
      type: MessageType.document,
      content: 'Shared a document',
      timestamp: DateTime.now(),
      documentPath: '/documents/invoice.pdf',
      documentName: 'invoice_2024.pdf',
      documentType: DocumentType.pdf,
      isRead: true,
    );

    widget.onMessageSent(message);
    setState(() => _showMediaOptions = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.documentSentSuccess),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _sharePersonalInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalInfoShareScreen(
          onInfoShared: (personalInfo) {
            final message = Message(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              senderId: 'current_user',
              senderName: 'You',
              senderAvatar: 'assets/images/logo1.png',
              type: MessageType.personalInfo,
              content: 'Shared personal information',
              timestamp: DateTime.now(),
              personalInfo: personalInfo,
              isRead: true,
            );

            widget.onMessageSent(message);
            setState(() => _showMediaOptions = false);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.personalInfoSharedSuccess),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        border: isDark ? Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.1))) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showMediaOptions) 
            FadeInUp(
              duration: const Duration(milliseconds: 300),
              child: _buildMediaOptions(context, theme, isDark)
            ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12 * context.fontSizeFactor, 
              vertical: 8 * context.fontSizeFactor,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() => _showMediaOptions = !_showMediaOptions);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40 * context.fontSizeFactor,
                    height: 40 * context.fontSizeFactor,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _showMediaOptions ? AppColors.accentTeal : AppColors.accentTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AdaptiveIcon(
                      _showMediaOptions ? FontAwesomeIcons.xmark : FontAwesomeIcons.plus,
                      color: _showMediaOptions ? Colors.white : AppColors.accentTeal,
                      size: 18 * context.fontSizeFactor,
                    ),
                  ),
                ),
                SizedBox(width: 12 * context.fontSizeFactor),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(fontSize: 14 * context.fontSizeFactor, color: theme.textTheme.bodyLarge?.color),
                    maxLines: 4,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.typeAMessage,
                      hintStyle: TextStyle(
                        color: AppColors.grey,
                        fontSize: 14 * context.fontSizeFactor,
                      ),
                      filled: true,
                      fillColor: isDark ? theme.scaffoldBackgroundColor : Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16 * context.fontSizeFactor,
                        vertical: 10 * context.fontSizeFactor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textAlignVertical: TextAlignVertical.center,
                  ),
                ),
                SizedBox(width: 12 * context.fontSizeFactor),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _messageController.text.trim().isEmpty
                      ? GestureDetector(
                          key: const ValueKey('audio'),
                          onTap: _sendAudio,
                          child: Container(
                            width: 40 * context.fontSizeFactor,
                            height: 40 * context.fontSizeFactor,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.accentTeal,
                              shape: BoxShape.circle,
                            ),
                            child: AdaptiveIcon(
                              FontAwesomeIcons.microphone,
                              color: Colors.white,
                              size: 16 * context.fontSizeFactor,
                            ),
                          ),
                        )
                      : GestureDetector(
                          key: const ValueKey('send'),
                          onTap: _sendMessage,
                          child: Container(
                            width: 40 * context.fontSizeFactor,
                            height: 40 * context.fontSizeFactor,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.accentTeal,
                              shape: BoxShape.circle,
                            ),
                            child: AdaptiveIcon(
                              FontAwesomeIcons.paperPlane,
                              color: Colors.white,
                              size: 16 * context.fontSizeFactor,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaOptions(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(20 * context.fontSizeFactor, 12 * context.fontSizeFactor, 20 * context.fontSizeFactor, 4 * context.fontSizeFactor),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.shareContent,
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 12 * context.fontSizeFactor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildMediaButton(
                  context: context,
                  theme: theme,
                  icon: FontAwesomeIcons.commentSms,
                  label: AppLocalizations.of(context)!.sms,
                  onTap: _sendSMS,
                  color: Colors.blue,
                ),
                SizedBox(width: 16 * context.fontSizeFactor),
                _buildMediaButton(
                  context: context,
                  theme: theme,
                  icon: FontAwesomeIcons.image,
                  label: AppLocalizations.of(context)!.gallery,
                  onTap: _sendImage,
                  color: Colors.purple,
                ),
                SizedBox(width: 16 * context.fontSizeFactor),
                _buildMediaButton(
                  context: context,
                  theme: theme,
                  icon: FontAwesomeIcons.fileLines,
                  label: AppLocalizations.of(context)!.file,
                  onTap: _sendDocument,
                  color: Colors.orange,
                ),
                SizedBox(width: 16 * context.fontSizeFactor),
                _buildMediaButton(
                  context: context,
                  theme: theme,
                  icon: FontAwesomeIcons.idCard,
                  label: AppLocalizations.of(context)!.contact,
                  onTap: _sharePersonalInfo,
                  color: AppColors.accentTeal,
                ),
                SizedBox(width: 16 * context.fontSizeFactor),
                _buildMediaButton(
                  context: context,
                  theme: theme,
                  icon: FontAwesomeIcons.locationDot,
                  label: AppLocalizations.of(context)!.location,
                  onTap: () {},
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaButton({
    required BuildContext context,
    required ThemeData theme,
    required dynamic icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56 * context.fontSizeFactor,
            height: 56 * context.fontSizeFactor,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: AdaptiveIcon(
              icon,
              color: color,
              size: 22 * context.fontSizeFactor,
            ),
          ),
          SizedBox(height: 8 * context.fontSizeFactor),
          Text(
            label,
            style: TextStyle(
              fontSize: 11 * context.fontSizeFactor,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}

