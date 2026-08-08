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
  final List<String> donorAvatars;
  final List<String> partnerLogos;
  final List<Donor> recentDonors;
  final List<CampaignUpdate> updates;
  final String status; // 'new', 'trending', 'ending_soon', 'completed'

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
    this.donorAvatars = const [],
    this.partnerLogos = const [],
    this.recentDonors = const [],
    this.updates = const [],
    this.status = 'active',
  });

  double get progress => (raisedAmount / goalAmount).clamp(0.0, 1.0);

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
    'donorAvatars': donorAvatars,
    'partnerLogos': partnerLogos,
    'recentDonors': recentDonors.map((e) => e.toJson()).toList(),
    'updates': updates.map((e) => e.toJson()).toList(),
    'status': status,
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
    donorAvatars: List<String>.from(json['donorAvatars'] ?? []),
    partnerLogos: List<String>.from(json['partnerLogos'] ?? []),
    recentDonors: (json['recentDonors'] as List? ?? [])
        .map((e) => Donor.fromJson(e as Map<String, dynamic>))
        .toList(),
    updates: (json['updates'] as List? ?? [])
        .map((e) => CampaignUpdate.fromJson(e as Map<String, dynamic>))
        .toList(),
    status: json['status'] ?? 'active',
  );

  Campaign copyWith({
    double? raisedAmount,
    int? donorCount,
    String? lastDonationAgo,
    List<String>? donorAvatars,
    List<Donor>? recentDonors,
    List<CampaignUpdate>? updates,
    String? status,
  }) {
    return Campaign(
      id: id,
      title: title,
      description: description,
      goalAmount: goalAmount,
      raisedAmount: raisedAmount ?? this.raisedAmount,
      creator: creator,
      icon: icon,
      imageUrl: imageUrl,
      category: category,
      donorCount: donorCount ?? this.donorCount,
      lastDonationAgo: lastDonationAgo ?? this.lastDonationAgo,
      isUrgent: isUrgent,
      donorAvatars: donorAvatars ?? this.donorAvatars,
      partnerLogos: partnerLogos,
      recentDonors: recentDonors ?? this.recentDonors,
      updates: updates ?? this.updates,
      status: status ?? this.status,
    );
  }
}

class Donor {
  final String name;
  final double amount;
  final DateTime donatedAt;
  final String? avatarUrl;
  final bool isAnonymous;
  final String? message;

  Donor({
    required this.name,
    required this.amount,
    required this.donatedAt,
    this.avatarUrl,
    this.isAnonymous = false,
    this.message,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'amount': amount,
    'donatedAt': donatedAt.toIso8601String(),
    'avatarUrl': avatarUrl,
    'isAnonymous': isAnonymous,
    'message': message,
  };

  factory Donor.fromJson(Map<String, dynamic> json) => Donor(
    name: json['name'],
    amount: (json['amount'] as num).toDouble(),
    donatedAt: DateTime.parse(json['donatedAt']),
    avatarUrl: json['avatarUrl'],
    isAnonymous: json['isAnonymous'] ?? false,
    message: json['message'],
  );
}

class CampaignUpdate {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime timestamp;

  CampaignUpdate({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'imageUrl': imageUrl,
    'timestamp': timestamp.toIso8601String(),
  };

  factory CampaignUpdate.fromJson(Map<String, dynamic> json) => CampaignUpdate(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    imageUrl: json['imageUrl'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}
