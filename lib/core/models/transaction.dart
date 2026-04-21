class Transaction {
  final String id;
  final String title;
  final String date; // For display
  final DateTime timestamp; // For sorting and analytics
  final String amount; // For display (e.g. "-$15.99")
  final double numericAmount; // Actual value
  final double fee;
  final bool isNegative;
  final String category; // e.g. "Food", "Transport", "Savings"
  final String status; // "Success", "Pending", "Failed"
  final String type; // "deposit", "withdrawal", "transfer_in", "transfer_out", "payment"
  final String? method; // "Wallet", "Bank", "EVC Plus"
  final String? purpose;
  final String? referenceId; // External ID or Wallet ID
  final String? cardId; // Associated Virtual Card ID

  Transaction({
    required this.id,
    required this.title,
    required this.date,
    DateTime? timestamp,
    required this.amount,
    this.numericAmount = 0.0,
    this.fee = 0.0,
    required this.isNegative,
    required this.category,
    required this.status,
    required this.type,
    this.method,
    this.purpose,
    this.referenceId,
    this.cardId,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'timestamp': timestamp.toIso8601String(),
      'amount': amount,
      'numericAmount': numericAmount,
      'fee': fee,
      'isNegative': isNegative,
      'category': category,
      'status': status,
      'type': type,
      'method': method,
      'purpose': purpose,
      'referenceId': referenceId,
      'cardId': cardId,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      amount: json['amount'] ?? '',
      numericAmount: (json['numericAmount'] ?? 0.0).toDouble(),
      fee: (json['fee'] ?? 0.0).toDouble(),
      isNegative: json['isNegative'] ?? false,
      category: json['category'] ?? 'General',
      status: json['status'] ?? 'Success',
      type: json['type'] ?? 'payment',
      method: json['method'],
      purpose: json['purpose'],
      referenceId: json['referenceId'],
      cardId: json['cardId'],
    );
  }
}
