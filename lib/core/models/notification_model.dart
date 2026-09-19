import 'package:flutter/material.dart';

class NotificationData {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final String message;
  final DateTime timestamp;
  final dynamic icon;
  final Color? iconColor;
  final int? type; 
  final bool isRead;
  final Map<String, dynamic>? extraData;

  NotificationData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.message,
    required this.timestamp,
    this.icon,
    this.iconColor,
    this.type,
    this.isRead = false,
    this.extraData,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'time': time,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'isRead': isRead,
      'extraData': extraData,
    };
  }

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      time: json['time'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      type: json['type'],
      isRead: json['isRead'] ?? false,
      extraData: json['extraData'],
    );
  }
}
