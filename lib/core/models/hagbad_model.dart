enum HagbadFrequency { daily, weekly, monthly, tenDays, yearly }

enum HagbadStatus { active, pending, completed }

class HagbadGroup {
  final String id;
  final String name;
  final String adminName;
  final double amount;
  final HagbadFrequency frequency;
  final HagbadStatus status;
  final DateTime startDate;
  final List<HagbadMember> members;
  final int totalCycles;
  final int currentCycle;

  HagbadGroup({
    required this.id,
    required this.name,
    required this.adminName,
    required this.amount,
    required this.frequency,
    required this.status,
    required this.startDate,
    required this.members,
    required this.totalCycles,
    required this.currentCycle,
  });

  double get totalPayout => amount * (members.isNotEmpty ? members.length : 1);
  double get serviceFee => 1.0;
  double get currentBalance => members.fold(0.0, (sum, m) => sum + m.paidAmount);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'adminName': adminName,
        'amount': amount,
        'frequency': frequency.index,
        'status': status.index,
        'startDate': startDate.toIso8601String(),
        'members': members.map((m) => m.toJson()).toList(),
        'totalCycles': totalCycles,
        'currentCycle': currentCycle,
      };

  factory HagbadGroup.fromJson(Map<String, dynamic> json) => HagbadGroup(
        id: json['id'],
        name: json['name'],
        adminName: json['adminName'],
        amount: json['amount'].toDouble(),
        frequency: HagbadFrequency.values[json['frequency']],
        status: HagbadStatus.values[json['status']],
        startDate: DateTime.parse(json['startDate']),
        members: (json['members'] as List).map((m) => HagbadMember.fromJson(m)).toList(),
        totalCycles: json['totalCycles'],
        currentCycle: json['currentCycle'],
      );

  HagbadGroup copyWith({
    String? id,
    String? name,
    String? adminName,
    double? amount,
    HagbadFrequency? frequency,
    HagbadStatus? status,
    DateTime? startDate,
    List<HagbadMember>? members,
    int? totalCycles,
    int? currentCycle,
  }) {
    return HagbadGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      adminName: adminName ?? this.adminName,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      members: members ?? this.members,
      totalCycles: totalCycles ?? this.totalCycles,
      currentCycle: currentCycle ?? this.currentCycle,
    );
  }
}

class HagbadMember {
  final String name;
  final String? walletId;
  final double paidAmount;
  final double penaltyAmount;
  final DateTime? lastPaymentDate;
  final bool hasReceived;
  final bool isTrusted;
  final bool isConfirmed;
  final bool hasSignedOath;
  final String? guarantorName;
  final String? guarantorId;
  final bool isGuarantorConfirmed;
  final String avatar;
  final int payoutOrder;

  HagbadMember({
    required this.name,
    this.walletId,
    this.paidAmount = 0.0,
    this.penaltyAmount = 0.0,
    this.lastPaymentDate,
    required this.hasReceived,
    required this.isTrusted,
    this.isConfirmed = false,
    this.hasSignedOath = false,
    this.guarantorName,
    this.guarantorId,
    this.isGuarantorConfirmed = false,
    required this.avatar,
    required this.payoutOrder,
  });

  bool isFullyPaid(double totalRequired) => paidAmount >= (totalRequired + penaltyAmount);

  Map<String, dynamic> toJson() => {
        'name': name,
        'walletId': walletId,
        'paidAmount': paidAmount,
        'penaltyAmount': penaltyAmount,
        'lastPaymentDate': lastPaymentDate?.toIso8601String(),
        'hasReceived': hasReceived,
        'isTrusted': isTrusted,
        'isConfirmed': isConfirmed,
        'hasSignedOath': hasSignedOath,
        'guarantorName': guarantorName,
        'guarantorId': guarantorId,
        'isGuarantorConfirmed': isGuarantorConfirmed,
        'avatar': avatar,
        'payoutOrder': payoutOrder,
      };

  factory HagbadMember.fromJson(Map<String, dynamic> json) => HagbadMember(
        name: json['name'],
        walletId: json['walletId'],
        paidAmount: json['paidAmount'].toDouble(),
        penaltyAmount: json['penaltyAmount'].toDouble(),
        lastPaymentDate: json['lastPaymentDate'] != null ? DateTime.parse(json['lastPaymentDate']) : null,
        hasReceived: json['hasReceived'],
        isTrusted: json['isTrusted'],
        isConfirmed: json['isConfirmed'] ?? false,
        hasSignedOath: json['hasSignedOath'] ?? false,
        guarantorName: json['guarantorName'],
        guarantorId: json['guarantorId'],
        isGuarantorConfirmed: json['isGuarantorConfirmed'] ?? false,
        avatar: json['avatar'],
        payoutOrder: json['payoutOrder'],
      );

  HagbadMember copyWith({
    String? name,
    String? walletId,
    double? paidAmount,
    double? penaltyAmount,
    DateTime? lastPaymentDate,
    bool? hasReceived,
    bool? isTrusted,
    bool? isConfirmed,
    bool? hasSignedOath,
    String? guarantorName,
    String? guarantorId,
    bool? isGuarantorConfirmed,
    String? avatar,
    int? payoutOrder,
  }) {
    return HagbadMember(
      name: name ?? this.name,
      walletId: walletId ?? this.walletId,
      paidAmount: paidAmount ?? this.paidAmount,
      penaltyAmount: penaltyAmount ?? this.penaltyAmount,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      hasReceived: hasReceived ?? this.hasReceived,
      isTrusted: isTrusted ?? this.isTrusted,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      hasSignedOath: hasSignedOath ?? this.hasSignedOath,
      guarantorName: guarantorName ?? this.guarantorName,
      guarantorId: guarantorId ?? this.guarantorId,
      isGuarantorConfirmed: isGuarantorConfirmed ?? this.isGuarantorConfirmed,
      avatar: avatar ?? this.avatar,
      payoutOrder: payoutOrder ?? this.payoutOrder,
    );
  }
}
