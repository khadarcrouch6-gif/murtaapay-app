import 'package:intl/intl.dart';

enum MessageType {
  text,
  image,
  document,
  audio,
  location,
  personalInfo,
  moneyTransfer,
  sms,
  notification,
}

enum DocumentType {
  pdf,
  doc,
  xls,
  ppt,
  txt,
  image,
  video,
}

class PersonalInfoShare {
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String country;
  final String postalCode;

  const PersonalInfoShare({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
    required this.postalCode,
  });
}

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final MessageType type;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final PersonalInfoShare? personalInfo;
  final String? audioPath;
  final String? imagePath;
  final String? documentPath;
  final String? documentName;
  final DocumentType? documentType;

  const Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.type,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.personalInfo,
    this.audioPath,
    this.imagePath,
    this.documentPath,
    this.documentName,
    this.documentType,
  });

  String get formattedTime => DateFormat('HH:mm').format(timestamp);
}

class ChatConversation {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final List<Message> messages;
  final DateTime lastMessageTime;
  final int unreadCount;

  const ChatConversation({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.messages,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  Message? get lastMessage => messages.isNotEmpty ? messages.last : null;
}
