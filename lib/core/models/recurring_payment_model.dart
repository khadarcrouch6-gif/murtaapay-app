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
  final String category;

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
    required this.category,
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
        'category': category,
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
        category: json['category'],
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
    String? category,
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
      category: category ?? this.category,
    );
  }
}
