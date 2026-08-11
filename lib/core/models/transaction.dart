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
  final String? subCategory; // e.g. "Groceries", "Dining Out", "Utility Bill"
  final String status; // "Success", "Pending", "Failed"
  final String type; // "deposit", "withdrawal", "transfer_in", "transfer_out", "payment"
  final String? method; // "EVC Plus", "Bank Account", etc (Payout Method)
  final String? paymentMethod; // "Main Wallet", "Debit Card", etc (Sender Source)
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
    this.subCategory,
    required this.status,
    required this.type,
    this.method,
    this.paymentMethod,
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
      'subCategory': subCategory,
      'status': status,
      'type': type,
      'method': method,
      'paymentMethod': paymentMethod,
      'purpose': purpose,
      'referenceId': referenceId,
      'cardId': cardId,
    };
    Transaction copyWith({
    String? id,
    String? title,
    String? date,
    DateTime? timestamp,
    String? amount,
    double? numericAmount,
    double? fee,
    bool? isNegative,
    String? category,
    String? subCategory,
    String? status,
    String? type,
    String? method,
    String? paymentMethod,
    String? purpose,
    String? referenceId,
    String? cardId,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      timestamp: timestamp ?? this.timestamp,
      amount: amount ?? this.amount,
      numericAmount: numericAmount ?? this.numericAmount,
      fee: fee ?? this.fee,
      isNegative: isNegative ?? this.isNegative,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      status: status ?? this.status,
      type: type ?? this.type,
      method: method ?? this.method,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      purpose: purpose ?? this.purpose,
      referenceId: referenceId ?? this.referenceId,
      cardId: cardId ?? this.cardId,
    );
  }
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
      subCategory: json['subCategory'],
      status: json['status'] ?? 'Success',
      type: json['type'] ?? 'payment',
      method: json['method'],
      paymentMethod: json['paymentMethod'],
      purpose: json['purpose'],
      referenceId: json['referenceId'],
      cardId: json['cardId'],
    );
    Transaction copyWith({
    String? id,
    String? title,
    String? date,
    DateTime? timestamp,
    String? amount,
    double? numericAmount,
    double? fee,
    bool? isNegative,
    String? category,
    String? subCategory,
    String? status,
    String? type,
    String? method,
    String? paymentMethod,
    String? purpose,
    String? referenceId,
    String? cardId,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      timestamp: timestamp ?? this.timestamp,
      amount: amount ?? this.amount,
      numericAmount: numericAmount ?? this.numericAmount,
      fee: fee ?? this.fee,
      isNegative: isNegative ?? this.isNegative,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      status: status ?? this.status,
      type: type ?? this.type,
      method: method ?? this.method,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      purpose: purpose ?? this.purpose,
      referenceId: referenceId ?? this.referenceId,
      cardId: cardId ?? this.cardId,
    );
  }
}
  Transaction copyWith({
    String? id,
    String? title,
    String? date,
    DateTime? timestamp,
    String? amount,
    double? numericAmount,
    double? fee,
    bool? isNegative,
    String? category,
    String? subCategory,
    String? status,
    String? type,
    String? method,
    String? paymentMethod,
    String? purpose,
    String? referenceId,
    String? cardId,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      timestamp: timestamp ?? this.timestamp,
      amount: amount ?? this.amount,
      numericAmount: numericAmount ?? this.numericAmount,
      fee: fee ?? this.fee,
      isNegative: isNegative ?? this.isNegative,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      status: status ?? this.status,
      type: type ?? this.type,
      method: method ?? this.method,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      purpose: purpose ?? this.purpose,
      referenceId: referenceId ?? this.referenceId,
      cardId: cardId ?? this.cardId,
    );
  }
}
