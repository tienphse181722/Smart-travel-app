enum SplitType {
  equal,   // Chia đều
  custom,  // Chia custom
}

class Expense {
  final String id;
  final String description;
  final double amount;
  final String paidBy; // Member ID
  final List<String> sharedWith; // List of Member IDs (for equal split)
  final Map<String, double>? customAmounts; // For custom split: memberId -> amount
  final SplitType splitType;
  final String? activityId; // Link to activity (optional)
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.paidBy,
    this.sharedWith = const [],
    this.customAmounts,
    this.splitType = SplitType.equal,
    this.activityId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'paidBy': paidBy,
      'sharedWith': sharedWith,
      'customAmounts': customAmounts,
      'splitType': splitType.name,
      'activityId': activityId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidBy: json['paidBy'] as String,
      sharedWith: json['sharedWith'] != null 
          ? List<String>.from(json['sharedWith'] as List)
          : [],
      customAmounts: json['customAmounts'] != null
          ? Map<String, double>.from(
              (json['customAmounts'] as Map).map(
                (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
              ),
            )
          : null,
      splitType: json['splitType'] != null
          ? SplitType.values.firstWhere(
              (e) => e.name == json['splitType'],
              orElse: () => SplitType.equal,
            )
          : SplitType.equal,
      activityId: json['activityId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Expense copyWith({
    String? id,
    String? description,
    double? amount,
    String? paidBy,
    List<String>? sharedWith,
    Map<String, double>? customAmounts,
    SplitType? splitType,
    String? activityId,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      paidBy: paidBy ?? this.paidBy,
      sharedWith: sharedWith ?? this.sharedWith,
      customAmounts: customAmounts ?? this.customAmounts,
      splitType: splitType ?? this.splitType,
      activityId: activityId ?? this.activityId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
