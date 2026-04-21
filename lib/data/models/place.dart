class Place {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final List<String> tags;
  final double avgCost;
  final String? description;
  final String? address;
  final double? rating;
  final String? priceRange;
  final String? openHours;
  final String? category;

  Place({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.tags,
    required this.avgCost,
    this.description,
    this.address,
    this.rating,
    this.priceRange,
    this.openHours,
    this.category,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      lat: (json['coordinates']['lat'] as num).toDouble(),
      lng: (json['coordinates']['lng'] as num).toDouble(),
      tags: List<String>.from(json['tags'] as List),
      avgCost: json['avg_cost'] != null ? (json['avg_cost'] as num).toDouble() : 0.0,
      description: json['description'] as String?,
      address: json['address'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      priceRange: json['price_range'] as String?,
      openHours: json['open_hours'] as String?,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coordinates': {
        'lat': lat,
        'lng': lng,
      },
      'tags': tags,
      'avg_cost': avgCost,
      'description': description,
      'address': address,
      'rating': rating,
      'price_range': priceRange,
      'open_hours': openHours,
      'category': category,
    };
  }
}
