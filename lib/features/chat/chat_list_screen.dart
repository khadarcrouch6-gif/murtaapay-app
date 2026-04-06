import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';
import '../../core/models/message_model.dart';
import '../../core/responsive_utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late List<ChatConversation> conversations;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeConversations();
  }

  void _initializeConversations() {
    conversations = [
      ChatConversation(
        id: '1',
        userId: 'user_1',
        userName: 'Ahmed Hassan',
        userAvatar: 'assets/images/logo1.png',
        messages: [
          Message(
            id: 'msg_1',
            senderId: 'user_1',
            senderName: 'Ahmed Hassan',
            senderAvatar: 'assets/images/logo1.png',
            type: MessageType.text,
            content: 'How much do I need to transfer?',
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            isRead: true,
          ),
        ],
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 0,
      ),
      ChatConversation(
        id: '2',
        userId: 'user_2',
        userName: 'Fatima Mohamed',
        userAvatar: 'assets/images/logo1.png',
        messages: [
          Message(
            id: 'msg_2',
            senderId: 'current_user',
            senderName: 'You',
            senderAvatar: 'assets/images/logo1.png',
            type: MessageType.text,
            content: 'Thanks for the help!',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            isRead: true,
          ),
        ],
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
        unreadCount: 0,
      ),
      ChatConversation(
        id: '3',
        userId: 'user_3',
        userName: 'Abdi Ibrahim',
        userAvatar: 'assets/images/logo1.png',
        messages: [
          Message(
            id: 'msg_3',
            senderId: 'user_3',
            senderName: 'Abdi Ibrahim',
            senderAvatar: 'assets/images/logo1.png',
            type: MessageType.text,
            content: 'Can you help me with my account?',
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
            isRead: false,
          ),
        ],
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
        unreadCount: 1,
      ),
      ChatConversation(
        id: '4',
        userId: 'user_4',
        userName: 'Zainab Ali',
        userAvatar: 'assets/images/logo1.png',
        messages: [
          Message(
            id: 'msg_4',
            senderId: 'current_user',
            senderName: 'You',
            senderAvatar: 'assets/images/logo1.png',
            type: MessageType.personalInfo,
            content: 'Shared personal information',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            isRead: true,
            personalInfo: PersonalInfoShare(
              fullName: 'Your Name',
              email: 'email@example.com',
              phone: '+252 61 xxx xxxx',
              address: '123 Main Street',
              city: 'Mogadishu',
              country: 'Somalia',
              postalCode: '12345',
            ),
          ),
        ],
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 0,
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          AppState().translate("Messages", "Farimaha", ar: "الرسائل", de: "Nachrichten"),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24 * context.fontSizeFactor,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FadeInRight(
              child: Center(
                child: IconButton(
                  icon: const Icon(FontAwesomeIcons.circlePlus),
                  color: AppColors.accentTeal,
                  iconSize: 28 * context.fontSizeFactor,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppState().translate("Start new conversation", "Bilow wada hadal cusub", ar: "بدء محادثة جديدة", de: "Neues Gespräch beginnen")),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 12),
                child: Center(
                  child: MaxWidthBox(
                    maxWidth: 600,
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(fontSize: 14 * context.fontSizeFactor),
                      decoration: InputDecoration(
                        hintText: AppState().translate("Search conversations...", "Raadi wada sheekaysiga...", ar: "البحث في المحادثات...", de: "Gespräche suchen..."),
                        hintStyle: TextStyle(
                          color: AppColors.grey,
                          fontSize: 14 * context.fontSizeFactor,
                        ),
                        prefixIcon: Icon(
                          FontAwesomeIcons.magnifyingGlass,
                          color: AppColors.grey,
                          size: 16 * context.fontSizeFactor,
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16 * context.fontSizeFactor, vertical: 12 * context.fontSizeFactor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: AppColors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: AppColors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: AppColors.accentTeal,
                            width: 2 * context.fontSizeFactor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding, vertical: 8),
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    return FadeInUp(
                      delay: Duration(milliseconds: index * 100),
                      child: Center(
                        child: MaxWidthBox(
                          maxWidth: 800,
                          child: _buildConversationTile(conversations[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversationTile(ChatConversation conversation) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              userId: conversation.userId,
              userName: conversation.userName,
              userAvatar: conversation.userAvatar,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.grey.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28 * context.fontSizeFactor,
              backgroundColor: AppColors.accentTeal.withValues(alpha: 0.1),
              child: Icon(
                FontAwesomeIcons.user,
                size: 20 * context.fontSizeFactor,
                color: AppColors.accentTeal,
              ),
            ),
            SizedBox(width: 12 * context.fontSizeFactor),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        conversation.userName,
                        style: TextStyle(
                          fontSize: 15 * context.fontSizeFactor,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _formatTime(conversation.lastMessageTime),
                        style: TextStyle(
                          fontSize: 12 * context.fontSizeFactor,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4 * context.fontSizeFactor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage?.content ??
                              AppState().translate("No messages", "Farimo ma jiraan", ar: "لا توجد رسائل", de: "Keine Nachrichten"),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13 * context.fontSizeFactor,
                            color: conversation.unreadCount > 0
                                ? AppColors.textPrimary
                                : AppColors.grey,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          margin: EdgeInsets.only(left: 8 * context.fontSizeFactor),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8 * context.fontSizeFactor,
                            vertical: 2 * context.fontSizeFactor,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentTeal,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            conversation.unreadCount.toString(),
                            style: TextStyle(
                              fontSize: 12 * context.fontSizeFactor,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    final state = AppState();
    if (difference.inMinutes < 1) {
      return state.translate("now", "hadda", ar: "الآن", de: "jetzt");
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}${state.translate("m ago", "d horta", ar: "د مضت", de: "M vor")}";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}${state.translate("h ago", "saac horta", ar: "س مضت", de: "Std vor")}";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}${state.translate("d ago", "maalmood horta", ar: "ي مضت", de: "T vor")}";
    } else {
      return '${time.day}/${time.month}';
    }
  }
}

