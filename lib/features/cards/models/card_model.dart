enum CardThemeType { obsidian, gold, emerald, midnight }
enum CardNetwork { visa, mastercard, amex }

class VirtualCard {
  final String id;
  final String cardNumber;
  final String cardHolder;
  final String expiryDate;
  final String cvv;
  final CardThemeType theme;
  final CardNetwork network;
  final bool isFrozen;
  final bool allowOnline;
  final bool allowInternational;
  final bool allowContactless;
  final double dailyLimit;
  final double currentSpending;
  final double balance;

  VirtualCard({
    required this.id,
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryDate,
    required this.cvv,
    this.theme = CardThemeType.obsidian,
    this.network = CardNetwork.visa,
    this.isFrozen = false,
    this.allowOnline = true,
    this.allowInternational = true,
    this.allowContactless = true,
    this.dailyLimit = 1000.0,
    this.currentSpending = 450.0,
    this.balance = 0.0,
  });

  VirtualCard copyWith({
    bool? isFrozen,
    bool? allowOnline,
    bool? allowInternational,
    bool? allowContactless,
    double? dailyLimit,
    double? currentSpending,
    double? balance,
    CardNetwork? network,
  }) {
    return VirtualCard(
      id: id,
      cardNumber: cardNumber,
      cardHolder: cardHolder,
      expiryDate: expiryDate,
      cvv: cvv,
      theme: theme,
      network: network ?? this.network,
      isFrozen: isFrozen ?? this.isFrozen,
      allowOnline: allowOnline ?? this.allowOnline,
      allowInternational: allowInternational ?? this.allowInternational,
      allowContactless: allowContactless ?? this.allowContactless,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      currentSpending: currentSpending ?? this.currentSpending,
      balance: balance ?? this.balance,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardNumber': cardNumber,
      'cardHolder': cardHolder,
      'expiryDate': expiryDate,
      'cvv': cvv,
      'theme': theme.name,
      'network': network.name,
      'isFrozen': isFrozen,
      'allowOnline': allowOnline,
      'allowInternational': allowInternational,
      'allowContactless': allowContactless,
      'dailyLimit': dailyLimit,
      'currentSpending': currentSpending,
      'balance': balance,
    };
  }

  factory VirtualCard.fromJson(Map<String, dynamic> json) {
    return VirtualCard(
      id: json['id'],
      cardNumber: json['cardNumber'],
      cardHolder: json['cardHolder'],
      expiryDate: json['expiryDate'],
      cvv: json['cvv'],
      theme: CardThemeType.values.byName(json['theme']),
      network: CardNetwork.values.byName(json['network']),
      isFrozen: json['isFrozen'] ?? false,
      allowOnline: json['allowOnline'] ?? true,
      allowInternational: json['allowInternational'] ?? true,
      allowContactless: json['allowContactless'] ?? true,
      dailyLimit: (json['dailyLimit'] as num?)?.toDouble() ?? 1000.0,
      currentSpending: (json['currentSpending'] as num?)?.toDouble() ?? 0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
