import 'activity.dart';
import 'member.dart';
import 'expense.dart';

class Trip {
  final String id;
  final String destination;
  final int numberOfDays;
  final DateTime startDate;
  final List<List<Activity>> dailyActivities;
  final DateTime createdAt;
  final List<Member> members;
  final List<Expense> expenses;

  Trip({
    required this.id,
    required this.destination,
    required this.numberOfDays,
    required this.startDate,
    required this.dailyActivities,
    required this.createdAt,
    this.members = const [],
    this.expenses = const [],
  });

  double get totalCost {
    double total = 0;
    for (var dayActivities in dailyActivities) {
      for (var activity in dayActivities) {
        total += activity.cost;
      }
    }
    // Thêm chi phí từ expenses
    for (var expense in expenses) {
      total += expense.amount;
    }
    return total;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destination': destination,
      'numberOfDays': numberOfDays,
      'startDate': startDate.toIso8601String(),
      'dailyActivities': dailyActivities
          .map((day) => day.map((activity) => activity.toJson()).toList())
          .toList(),
      'createdAt': createdAt.toIso8601String(),
      'members': members.map((m) => m.toJson()).toList(),
      'expenses': expenses.map((e) => e.toJson()).toList(),
    };
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      destination: json['destination'] as String,
      numberOfDays: json['numberOfDays'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      dailyActivities: (json['dailyActivities'] as List)
          .map((day) => (day as List)
              .map((activity) => Activity.fromJson(activity))
              .toList())
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      members: json['members'] != null
          ? (json['members'] as List).map((m) => Member.fromJson(m)).toList()
          : [],
      expenses: json['expenses'] != null
          ? (json['expenses'] as List).map((e) => Expense.fromJson(e)).toList()
          : [],
    );
  }

  Trip copyWith({
    String? id,
    String? destination,
    int? numberOfDays,
    DateTime? startDate,
    List<List<Activity>>? dailyActivities,
    DateTime? createdAt,
    List<Member>? members,
    List<Expense>? expenses,
  }) {
    return Trip(
      id: id ?? this.id,
      destination: destination ?? this.destination,
      numberOfDays: numberOfDays ?? this.numberOfDays,
      startDate: startDate ?? this.startDate,
      dailyActivities: dailyActivities ?? this.dailyActivities,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
      expenses: expenses ?? this.expenses,
    );
  }
}
