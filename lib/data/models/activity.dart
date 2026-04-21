enum ActivityType { food, place }

class Activity {
  final String id;
  final String name;
  final ActivityType type;
  final double cost;
  final String time;
  final double lat;
  final double lng;
  final List<String> tags;
  final String? originalId; // ID từ place hoặc food

  Activity({
    required this.id,
    required this.name,
    required this.type,
    required this.cost,
    required this.time,
    required this.lat,
    required this.lng,
    required this.tags,
    this.originalId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'cost': cost,
      'time': time,
      'lat': lat,
      'lng': lng,
      'tags': tags,
      'originalId': originalId,
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] == 'ActivityType.food' 
          ? ActivityType.food 
          : ActivityType.place,
      cost: (json['cost'] as num).toDouble(),
      time: json['time'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      tags: List<String>.from(json['tags'] as List),
      originalId: json['originalId'] as String?,
    );
  }

  Activity copyWith({
    String? id,
    String? name,
    ActivityType? type,
    double? cost,
    String? time,
    double? lat,
    double? lng,
    List<String>? tags,
    String? originalId,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      cost: cost ?? this.cost,
      time: time ?? this.time,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      tags: tags ?? this.tags,
      originalId: originalId ?? this.originalId,
    );
  }
}
