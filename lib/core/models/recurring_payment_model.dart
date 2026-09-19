enum RecurringFrequency { weekly, monthly, quarterly }

enum RecurringStatus { active, paused, completed }

class RecurringPayment {
  final String id;
  final String title;
  final String receiverId;
  final String receiverName;
  final double amount;
  final RecurringFrequency frequency;
  final DateTime startDate;
  final DateTime? nextPaymentDate;
  final RecurringStatus status;
  final bool isActive;
  final String category;
  final String? cardId;
  final DateTime? lastExecution;

  RecurringPayment({
    required this.id,
    required this.title,
    required this.receiverId,
    required this.receiverName,
    required this.amount,
    required this.frequency,
    required this.startDate,
    this.nextPaymentDate,
    required this.status,
    this.isActive = true,
    required this.category,
    this.cardId,
    this.lastExecution,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'receiverId': receiverId,
        'receiverName': receiverName,
        'amount': amount,
        'frequency': frequency.index,
        'startDate': startDate.toIso8601String(),
        'nextPaymentDate': nextPaymentDate?.toIso8601String(),
        'status': status.index,
        'isActive': isActive,
        'category': category,
        'cardId': cardId,
        'lastExecution': lastExecution?.toIso8601String(),
      };

  factory RecurringPayment.fromJson(Map<String, dynamic> json) => RecurringPayment(
        id: json['id'],
        title: json['title'],
        receiverId: json['receiverId'],
        receiverName: json['receiverName'],
        amount: json['amount'].toDouble(),
        frequency: RecurringFrequency.values[json['frequency']],
        startDate: DateTime.parse(json['startDate']),
        nextPaymentDate: json['nextPaymentDate'] != null ? DateTime.parse(json['nextPaymentDate']) : null,
        status: RecurringStatus.values[json['status']],
        isActive: json['isActive'] ?? true,
        category: json['category'],
        cardId: json['cardId'],
        lastExecution: json['lastExecution'] != null ? DateTime.parse(json['lastExecution']) : null,
      );

  RecurringPayment copyWith({
    String? id,
    String? title,
    String? receiverId,
    String? receiverName,
    double? amount,
    RecurringFrequency? frequency,
    DateTime? startDate,
    DateTime? nextPaymentDate,
    RecurringStatus? status,
    bool? isActive,
    String? category,
    String? cardId,
    DateTime? lastExecution,
  }) {
    return RecurringPayment(
      id: id ?? this.id,
      title: title ?? this.title,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
      cardId: cardId ?? this.cardId,
      lastExecution: lastExecution ?? this.lastExecution,
    );
  }
}
