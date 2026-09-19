import 'dart:convert';
import 'package:flutter/material.dart';

class QuickProfile {
  final String id;
  final String name;
  final String walletId; // Primary identifier (Wallet ID, Phone, or Account Number)
  final String? avatarUrl;
  final String? initials;
  final Color? color;
  final String? payoutMethod; // 'Wallet', 'Bank', 'Mobile'
  final String? bankName;
  final bool isVerified;
  final String? verificationStatus; // 'pending', 'verified', 'failed'
  final DateTime? verifiedAt;
  final String? lastSenderMethod; 
  final String? lastReceiverMethod;
  final double? lastAmount;
  final int transactionCount;
  final DateTime? lastTransactionDate;
  final bool isFavorite;

  QuickProfile({
    required this.id,
    required this.name,
    required this.walletId,
    this.avatarUrl,
    this.initials,
    this.color,
    this.payoutMethod,
    this.bankName,
    this.isVerified = false,
    this.verificationStatus,
    this.verifiedAt,
    this.lastSenderMethod,
    this.lastReceiverMethod,
    this.lastAmount,
    this.transactionCount = 0,
    this.lastTransactionDate,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'walletId': walletId,
      'avatarUrl': avatarUrl,
      'initials': initials,
      'color': color?.value,
      'payoutMethod': payoutMethod,
      'bankName': bankName,
      'isVerified': isVerified,
      'verificationStatus': verificationStatus,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'lastSenderMethod': lastSenderMethod,
      'lastReceiverMethod': lastReceiverMethod,
      'lastAmount': lastAmount,
      'transactionCount': transactionCount,
      'lastTransactionDate': lastTransactionDate?.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory QuickProfile.fromMap(Map<String, dynamic> map) {
    return QuickProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      walletId: map['walletId'] ?? '',
      avatarUrl: map['avatarUrl'],
      initials: map['initials'],
      color: map['color'] != null ? Color(map['color']) : null,
      payoutMethod: map['payoutMethod'],
      bankName: map['bankName'],
      isVerified: map['isVerified'] ?? false,
      verificationStatus: map['verificationStatus'],
      verifiedAt: map['verifiedAt'] != null ? DateTime.parse(map['verifiedAt']) : null,
      lastSenderMethod: map['lastSenderMethod'],
      lastReceiverMethod: map['lastReceiverMethod'],
      lastAmount: map['lastAmount']?.toDouble(),
      transactionCount: map['transactionCount'] ?? 0,
      lastTransactionDate: map['lastTransactionDate'] != null 
          ? DateTime.parse(map['lastTransactionDate']) 
          : null,
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory QuickProfile.fromJson(String source) => QuickProfile.fromMap(json.decode(source));

  QuickProfile copyWith({
    String? id,
    String? name,
    String? walletId,
    String? avatarUrl,
    String? initials,
    Color? color,
    String? payoutMethod,
    String? bankName,
    bool? isVerified,
    String? verificationStatus,
    DateTime? verifiedAt,
    String? lastSenderMethod,
    String? lastReceiverMethod,
    double? lastAmount,
    int? transactionCount,
    DateTime? lastTransactionDate,
    bool? isFavorite,
  }) {
    return QuickProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      walletId: walletId ?? this.walletId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      initials: initials ?? this.initials,
      color: color ?? this.color,
      payoutMethod: payoutMethod ?? this.payoutMethod,
      bankName: bankName ?? this.bankName,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      lastSenderMethod: lastSenderMethod ?? this.lastSenderMethod,
      lastReceiverMethod: lastReceiverMethod ?? this.lastReceiverMethod,
      lastAmount: lastAmount ?? this.lastAmount,
      transactionCount: transactionCount ?? this.transactionCount,
      lastTransactionDate: lastTransactionDate ?? this.lastTransactionDate,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
