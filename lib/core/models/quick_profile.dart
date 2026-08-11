import 'dart:convert';

class QuickProfile {
  final String id;
  final String name;
  final String walletId; // Primary identifier (Wallet ID, Phone, or Account Number)
  final String? avatarUrl;
  final String? payoutMethod; // 'Wallet', 'Bank', 'Mobile'
  final String? bankName;
  final bool isVerified;
  final String? lastSenderMethod; 
  final String? lastReceiverMethod;
  final double? lastAmount;
  final int transactionCount;
  final DateTime? lastTransactionDate;

  QuickProfile({
    required this.id,
    required this.name,
    required this.walletId,
    this.avatarUrl,
    this.payoutMethod,
    this.bankName,
    this.isVerified = false,
    this.lastSenderMethod,
    this.lastReceiverMethod,
    this.lastAmount,
    this.transactionCount = 0,
    this.lastTransactionDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'walletId': walletId,
      'avatarUrl': avatarUrl,
      'payoutMethod': payoutMethod,
      'bankName': bankName,
      'isVerified': isVerified,
      'lastSenderMethod': lastSenderMethod,
      'lastReceiverMethod': lastReceiverMethod,
      'lastAmount': lastAmount,
      'transactionCount': transactionCount,
      'lastTransactionDate': lastTransactionDate?.toIso8601String(),
    };
  }

  factory QuickProfile.fromMap(Map<String, dynamic> map) {
    return QuickProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      walletId: map['walletId'] ?? '',
      avatarUrl: map['avatarUrl'],
      payoutMethod: map['payoutMethod'],
      bankName: map['bankName'],
      isVerified: map['isVerified'] ?? false,
      lastSenderMethod: map['lastSenderMethod'],
      lastReceiverMethod: map['lastReceiverMethod'],
      lastAmount: map['lastAmount']?.toDouble(),
      transactionCount: map['transactionCount'] ?? 0,
      lastTransactionDate: map['lastTransactionDate'] != null 
          ? DateTime.parse(map['lastTransactionDate']) 
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory QuickProfile.fromJson(String source) => QuickProfile.fromMap(json.decode(source));

  QuickProfile copyWith({
    String? id,
    String? name,
    String? walletId,
    String? avatarUrl,
    String? payoutMethod,
    String? bankName,
    bool? isVerified,
    String? lastSenderMethod,
    String? lastReceiverMethod,
    double? lastAmount,
    int? transactionCount,
    DateTime? lastTransactionDate,
  }) {
    return QuickProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      walletId: walletId ?? this.walletId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      payoutMethod: payoutMethod ?? this.payoutMethod,
      bankName: bankName ?? this.bankName,
      isVerified: isVerified ?? this.isVerified,
      lastSenderMethod: lastSenderMethod ?? this.lastSenderMethod,
      lastReceiverMethod: lastReceiverMethod ?? this.lastReceiverMethod,
      lastAmount: lastAmount ?? this.lastAmount,
      transactionCount: transactionCount ?? this.transactionCount,
      lastTransactionDate: lastTransactionDate ?? this.lastTransactionDate,
    );
  }
}
