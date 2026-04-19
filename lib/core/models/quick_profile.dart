import 'dart:convert';

class QuickProfile {
  final String id;
  final String name;
  final String walletId;
  final String? avatarUrl;
  final String? lastSenderMethod; // e.g., 'Wallet', 'Bank'
  final String? lastReceiverMethod; // e.g., 'Wallet', 'Mobile'
  final double? lastAmount;

  QuickProfile({
    required this.id,
    required this.name,
    required this.walletId,
    this.avatarUrl,
    this.lastSenderMethod,
    this.lastReceiverMethod,
    this.lastAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'walletId': walletId,
      'avatarUrl': avatarUrl,
      'lastSenderMethod': lastSenderMethod,
      'lastReceiverMethod': lastReceiverMethod,
      'lastAmount': lastAmount,
    };
  }

  factory QuickProfile.fromMap(Map<String, dynamic> map) {
    return QuickProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      walletId: map['walletId'] ?? '',
      avatarUrl: map['avatarUrl'],
      lastSenderMethod: map['lastSenderMethod'],
      lastReceiverMethod: map['lastReceiverMethod'],
      lastAmount: map['lastAmount']?.toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory QuickProfile.fromJson(String source) => QuickProfile.fromMap(json.decode(source));

  QuickProfile copyWith({
    String? id,
    String? name,
    String? walletId,
    String? avatarUrl,
    String? lastSenderMethod,
    String? lastReceiverMethod,
    double? lastAmount,
  }) {
    return QuickProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      walletId: walletId ?? this.walletId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastSenderMethod: lastSenderMethod ?? this.lastSenderMethod,
      lastReceiverMethod: lastReceiverMethod ?? this.lastReceiverMethod,
      lastAmount: lastAmount ?? this.lastAmount,
    );
  }
}
