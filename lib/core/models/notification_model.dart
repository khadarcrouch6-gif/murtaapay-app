import 'package:flutter/material.dart';

class NotificationData {
  final String title;
  final String subtitle;
  final String time;
  final dynamic icon;
  final Color iconColor;
  final int type; // 0: System/Safety, 1: Transactions, 2: Promos, 3: Money Request
  final Map<String, dynamic>? extraData;

  NotificationData({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.type,
    this.extraData,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'time': time,
      'type': type,
      'extraData': extraData,
    };
  }
}
