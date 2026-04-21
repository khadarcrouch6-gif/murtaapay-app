import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../core/models/message_model.dart';
import '../../core/responsive_utils.dart';
import '../../core/widgets/adaptive_icon.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'chat_message_widget.dart';
import 'message_input_widget.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userAvatar;
  final bool isGroup;

  const ChatScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    this.isGroup = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late List<Message> messages;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeMessages();
  }

  void _initializeMessages() {
    messages = [
      Message(
        id: '1',
        senderId: widget.userId,
        senderName: widget.userName,
        senderAvatar: widget.userAvatar,
        type: MessageType.text,
        content: 'Hey! How are you doing?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      Message(
        id: '2',
        senderId: 'current_user',
        senderName: 'You',
        senderAvatar: 'assets/images/logo1.png',
        type: MessageType.text,
        content: 'I\'m doing great! What about you?',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
        isRead: true,
      ),
      Message(
        id: '3',
        senderId: widget.userId,
        senderName: widget.userName,
        senderAvatar: widget.userAvatar,
        type: MessageType.text,
        content: 'All good here. Want to transfer some money?',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        isRead: true,
      ),
    ];
  }

  void _addMessage(Message message) {
    setState(() {
      messages.add(message);
    });
    _scrollToBottom();
    
    // Simulate real-time response
    if (message.senderId == 'current_user') {
      _simulateResponse(message);
    }
  }

  void _simulateResponse(Message userMessage) {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      String responseText = "Thanks for your message! I'll get back to you shortly.";
      
      if (userMessage.content.toLowerCase().contains('money') || 
          userMessage.type == MessageType.moneyTransfer) {
        responseText = "I've received the transfer request. Processing it now!";
      } else if (userMessage.type == MessageType.personalInfo) {
        responseText = "Got your info. Thanks for sharing!";
      } else if (userMessage.type == MessageType.image) {
        responseText = "Great photo! Looking good.";
      }

      final response = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: widget.userId,
        senderName: widget.userName,
        senderAvatar: widget.userAvatar,
        type: MessageType.text,
        content: responseText,
        timestamp: DateTime.now(),
        isRead: true,
      );

      setState(() {
        messages.add(response);
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Hero(
              tag: 'avatar_${widget.userId}',
              child: CircleAvatar(
                radius: 18 * context.fontSizeFactor,
                backgroundColor: AppColors.accentTeal.withOpacity(0.1),
                child: AdaptiveIcon(
                  FontAwesomeIcons.user,
                  size: 16 * context.fontSizeFactor,
                  color: AppColors.accentTeal,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: TextStyle(
                      color: theme.textTheme.titleMedium?.color,
                      fontSize: 16 * context.fontSizeFactor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)!.online,
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 11 * context.fontSizeFactor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: FadeInLeft(
          child: IconButton(
            icon: AdaptiveIcon(FontAwesomeIcons.chevronLeft, size: 20 * context.fontSizeFactor),
            color: theme.iconTheme.color,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          IconButton(
            icon: AdaptiveIcon(FontAwesomeIcons.phone, size: 16 * context.fontSizeFactor, color: AppColors.accentTeal),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FadeInRight(
              child: PopupMenuButton<String>(
                icon: AdaptiveIcon(FontAwesomeIcons.ellipsisVertical, size: 18 * context.fontSizeFactor),
                color: theme.colorScheme.surface,
                position: PopupMenuPosition.under,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (value) {
                  if (value == 'info') {
                    _showContactInfo(context);
                  } else if (value == 'clear') {
                    _clearChat();
                  } else if (value == 'help') {
                    _showHelpSupport(context);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'info',
                    child: Row(
                      children: [
                        const AdaptiveIcon(FontAwesomeIcons.circleInfo, color: AppColors.accentTeal, size: 16),
                        const SizedBox(width: 12),
                        Text(AppLocalizations.of(context)!.viewInfo, style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'help',
                    child: Row(
                      children: [
                        const AdaptiveIcon(FontAwesomeIcons.circleQuestion, color: Colors.blue, size: 16),
                        const SizedBox(width: 12),
                        Text(AppLocalizations.of(context)!.helpSupport, style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'clear',
                    child: Row(
                      children: [
                        const AdaptiveIcon(FontAwesomeIcons.trash, color: Colors.red, size: 16),
                        const SizedBox(width: 12),
                        Text(AppLocalizations.of(context)!.clearChat, style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: MaxWidthBox(
          maxWidth: 1000,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(
                    context.horizontalPadding, 
                    16, 
                    context.horizontalPadding, 
                    MediaQuery.of(context).viewInsets.bottom + 16
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      child: Center(
                        child: MaxWidthBox(
                          maxWidth: 800,
                          child: ChatMessageWidget(message: message),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Center(
                  child: MaxWidthBox(
                    maxWidth: 800,
                    child: MessageInputWidget(onMessageSent: _addMessage),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContactInfo(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Center(
        child: MaxWidthBox(
          maxWidth: 600,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.contactInformation,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 20 * context.fontSizeFactor,
                      ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  context: context,
                  icon: FontAwesomeIcons.user,
                  label: AppLocalizations.of(context)!.nameLabel,
                  value: widget.userName,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  context: context,
                  icon: FontAwesomeIcons.phone,
                  label: AppLocalizations.of(context)!.phoneLabel,
                  value: '+252 61 xxx xxxx',
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  context: context,
                  icon: FontAwesomeIcons.envelope,
                  label: AppLocalizations.of(context)!.emailLabel,
                  value: 'user@example.com',
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required dynamic icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        AdaptiveIcon(icon, color: AppColors.accentTeal, size: 18 * context.fontSizeFactor),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 12 * context.fontSizeFactor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontSize: 14 * context.fontSizeFactor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showHelpSupport(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Center(
        child: MaxWidthBox(
          maxWidth: 600,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.helpSupport,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 20 * context.fontSizeFactor,
                      ),
                ),
                const SizedBox(height: 20),
                _buildHelpItem(
                  context: context,
                  icon: FontAwesomeIcons.message,
                  title: AppLocalizations.of(context)!.messageTypes,
                  description: AppLocalizations.of(context)!.messageTypesDesc,
                ),
                const SizedBox(height: 16),
                _buildHelpItem(
                  context: context,
                  icon: FontAwesomeIcons.share,
                  title: AppLocalizations.of(context)!.shareInformation,
                  description: AppLocalizations.of(context)!.shareInformationDesc,
                ),
                const SizedBox(height: 16),
                _buildHelpItem(
                  context: context,
                  icon: FontAwesomeIcons.magnifyingGlass,
                  title: AppLocalizations.of(context)!.searchChats,
                  description: AppLocalizations.of(context)!.searchChatsDesc,
                ),
                const SizedBox(height: 16),
                _buildHelpItem(
                  context: context,
                  icon: FontAwesomeIcons.gear,
                  title: AppLocalizations.of(context)!.chatSettings,
                  description: AppLocalizations.of(context)!.chatSettingsDesc,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelpItem({
    required BuildContext context,
    required dynamic icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44 * context.fontSizeFactor,
          height: 44 * context.fontSizeFactor,
          decoration: BoxDecoration(
            color: AppColors.accentTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: AdaptiveIcon(
            icon,
            color: AppColors.accentTeal,
            size: 20 * context.fontSizeFactor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14 * context.fontSizeFactor,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12 * context.fontSizeFactor,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _clearChat() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(AppLocalizations.of(context)!.clearChat, style: TextStyle(color: theme.textTheme.titleLarge?.color)),
        content: Text(AppLocalizations.of(context)!.clearChatConfirm, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => messages.clear());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.clear),
          ),
        ],
      ),
    );
  }
}

