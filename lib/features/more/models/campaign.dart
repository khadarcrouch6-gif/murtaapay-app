import 'package:flutter/material.dart';

class Campaign {
  final String id;
  final String title;
  final String description;
  final double goalAmount;
  final double raisedAmount;
  final String creator;
  final IconData icon;
  final String imageUrl;
  final String category;
  final int donorCount;
  final String lastDonationAgo;
  final bool isUrgent;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.goalAmount,
    required this.raisedAmount,
    required this.creator,
    required this.icon,
    required this.imageUrl,
    required this.category,
    required this.donorCount,
    required this.lastDonationAgo,
    this.isUrgent = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'goalAmount': goalAmount,
    'raisedAmount': raisedAmount,
    'creator': creator,
    'icon': icon.codePoint,
    'imageUrl': imageUrl,
    'category': category,
    'donorCount': donorCount,
    'lastDonationAgo': lastDonationAgo,
    'isUrgent': isUrgent,
  };

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    goalAmount: (json['goalAmount'] as num).toDouble(),
    raisedAmount: (json['raisedAmount'] as num).toDouble(),
    creator: json['creator'],
    icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
    imageUrl: json['imageUrl'],
    category: json['category'],
    donorCount: json['donorCount'],
    lastDonationAgo: json['lastDonationAgo'],
    isUrgent: json['isUrgent'] ?? false,
  );
}
