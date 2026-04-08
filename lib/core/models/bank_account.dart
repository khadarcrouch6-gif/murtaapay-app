import 'dart:convert';

class BankAccount {
  final String id;
  final String bankName;
  final String accountNumber;
  final String? accountHolder;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    this.accountHolder,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolder': accountHolder,
    };
  }

  factory BankAccount.fromMap(Map<String, dynamic> map) {
    return BankAccount(
      id: map['id'] ?? '',
      bankName: map['bankName'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      accountHolder: map['accountHolder'],
    );
  }

  String toJson() => json.encode(toMap());

  factory BankAccount.fromJson(String source) => BankAccount.fromMap(json.decode(source));
}
