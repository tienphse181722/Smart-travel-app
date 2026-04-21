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
  final String? description;
  final String? address;
  final double? rating;
  final String? priceRange;
  final String? openHours;

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
    this.description,
    this.address,
    this.rating,
    this.priceRange,
    this.openHours,
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
      'description': description,
      'address': address,
      'rating': rating,
      'priceRange': priceRange,
      'openHours': openHours,
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
      description: json['description'] as String?,
      address: json['address'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      priceRange: json['priceRange'] as String?,
      openHours: json['openHours'] as String?,
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
    String? description,
    String? address,
    double? rating,
    String? priceRange,
    String? openHours,
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
      description: description ?? this.description,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      priceRange: priceRange ?? this.priceRange,
      openHours: openHours ?? this.openHours,
    );
  }
}
