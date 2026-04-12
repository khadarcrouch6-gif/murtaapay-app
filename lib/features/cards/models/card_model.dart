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
  });

  VirtualCard copyWith({
    bool? isFrozen,
    bool? allowOnline,
    bool? allowInternational,
    bool? allowContactless,
    double? dailyLimit,
    double? currentSpending,
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
    );
  }
}
