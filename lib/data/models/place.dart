class Place {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final List<String> tags;
  final double avgCost;

  Place({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.tags,
    required this.avgCost,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      tags: List<String>.from(json['tags'] as List),
      avgCost: (json['avg_cost'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'tags': tags,
      'avg_cost': avgCost,
    };
  }
}
