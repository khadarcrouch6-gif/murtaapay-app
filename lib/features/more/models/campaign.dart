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
  final bool isVerified;
  final List<String> donorAvatars;
  final List<String> partnerLogos;
  final List<Donor> recentDonors;
  final List<CampaignUpdate> updates;
  final String status; // 'new', 'trending', 'ending_soon', 'completed'
  final DateTime? endDate;
  final String? organizerTitle; // e.g., "Sheikh", "Imam", "Organization"
  final String? organizerSubtitle; // e.g., "Sheikh Umal", "Al-Nuor Foundation"
  final List<String> galleryUrls;

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
    this.isVerified = true,
    this.donorAvatars = const [],
    this.partnerLogos = const [],
    this.recentDonors = const [],
    this.updates = const [],
    this.status = 'active',
    this.endDate,
    this.organizerTitle,
    this.organizerSubtitle,
    this.galleryUrls = const [],
  });

  double get progress => (raisedAmount / goalAmount).clamp(0.0, 1.0);

  String get milestoneText {
    if (progress >= 1.0) return "Goal Reached! 🎉";
    if (progress >= 0.9) return "Almost There! 🔥";
    if (progress >= 0.75) return "75% Completed 🚀";
    if (progress >= 0.5) return "Halfway There! 🙌";
    if (progress >= 0.25) return "Gaining Momentum ✨";
    return "";
  }

  int get daysLeft {
    if (endDate == null) return 0;
    final difference = endDate!.difference(DateTime.now()).inDays;
    return difference > 0 ? difference : 0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'goalAmount': goalAmount,
    'raisedAmount': raisedAmount,
    'creator': creator,
    'iconCodePoint': icon.codePoint,
    'iconFontFamily': icon.fontFamily,
    'imageUrl': imageUrl,
    'category': category,
    'donorCount': donorCount,
    'lastDonationAgo': lastDonationAgo,
    'isUrgent': isUrgent,
    'isVerified': isVerified,
    'donorAvatars': donorAvatars,
    'partnerLogos': partnerLogos,
    'recentDonors': recentDonors.map((e) => e.toJson()).toList(),
    'updates': updates.map((e) => e.toJson()).toList(),
    'status': status,
    'endDate': endDate?.toIso8601String(),
    'organizerTitle': organizerTitle,
    'organizerSubtitle': organizerSubtitle,
    'galleryUrls': galleryUrls,
  };

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    goalAmount: (json['goalAmount'] as num).toDouble(),
    raisedAmount: (json['raisedAmount'] as num).toDouble(),
    creator: json['creator'],
    icon: IconData(
      json['iconCodePoint'] ?? json['icon'],
      fontFamily: json['iconFontFamily'] ?? 'MaterialIcons',
    ),
    imageUrl: json['imageUrl'],
    category: json['category'],
    donorCount: json['donorCount'],
    lastDonationAgo: json['lastDonationAgo'],
    isUrgent: json['isUrgent'] ?? false,
    isVerified: json['isVerified'] ?? true,
    donorAvatars: List<String>.from(json['donorAvatars'] ?? []),
    partnerLogos: List<String>.from(json['partnerLogos'] ?? []),
    recentDonors: (json['recentDonors'] as List? ?? [])
        .map((e) => Donor.fromJson(e as Map<String, dynamic>))
        .toList(),
    updates: (json['updates'] as List? ?? [])
        .map((e) => CampaignUpdate.fromJson(e as Map<String, dynamic>))
        .toList(),
    status: json['status'] ?? 'active',
    endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    organizerTitle: json['organizerTitle'],
    organizerSubtitle: json['organizerSubtitle'],
    galleryUrls: List<String>.from(json['galleryUrls'] ?? []),
  );

  Campaign copyWith({
    double? raisedAmount,
    int? donorCount,
    String? lastDonationAgo,
    bool? isVerified,
    List<String>? donorAvatars,
    List<Donor>? recentDonors,
    List<CampaignUpdate>? updates,
    String? status,
    DateTime? endDate,
    IconData? icon,
    String? organizerTitle,
    String? organizerSubtitle,
    List<String>? galleryUrls,
  }) {
    return Campaign(
      id: id,
      title: title,
      description: description,
      goalAmount: goalAmount,
      raisedAmount: raisedAmount ?? this.raisedAmount,
      creator: creator,
      icon: icon ?? this.icon,
      imageUrl: imageUrl,
      category: category,
      donorCount: donorCount ?? this.donorCount,
      lastDonationAgo: lastDonationAgo ?? this.lastDonationAgo,
      isUrgent: isUrgent,
      isVerified: isVerified ?? this.isVerified,
      donorAvatars: donorAvatars ?? this.donorAvatars,
      partnerLogos: partnerLogos,
      recentDonors: recentDonors ?? this.recentDonors,
      updates: updates ?? this.updates,
      status: status ?? this.status,
      endDate: endDate ?? this.endDate,
      organizerTitle: organizerTitle ?? this.organizerTitle,
      organizerSubtitle: organizerSubtitle ?? this.organizerSubtitle,
      galleryUrls: galleryUrls ?? this.galleryUrls,
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
