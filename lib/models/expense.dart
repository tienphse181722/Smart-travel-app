class Expense {
  final String id;
  final String description;
  final double amount;
  final String paidBy; // Member ID
  final List<String> sharedWith; // List of Member IDs
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.sharedWith,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'paidBy': paidBy,
      'sharedWith': sharedWith,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidBy: json['paidBy'] as String,
      sharedWith: List<String>.from(json['sharedWith'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Expense copyWith({
    String? id,
    String? description,
    double? amount,
    String? paidBy,
    List<String>? sharedWith,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      paidBy: paidBy ?? this.paidBy,
      sharedWith: sharedWith ?? this.sharedWith,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
