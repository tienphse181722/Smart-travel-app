class Debt {
  final String fromMemberId;
  final String toMemberId;
  final double amount;

  Debt({
    required this.fromMemberId,
    required this.toMemberId,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromMemberId': fromMemberId,
      'toMemberId': toMemberId,
      'amount': amount,
    };
  }

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      fromMemberId: json['fromMemberId'] as String,
      toMemberId: json['toMemberId'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }
}
