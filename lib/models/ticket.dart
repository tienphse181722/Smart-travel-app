class Ticket {
  final String id;
  final String name;
  final DateTime date;
  final String ticketCode;
  final String? imagePath; // Đường dẫn ảnh vé được lưu trong app
  final String? bookingUrl; // Link đặt vé/khách sạn (optional)
  final String? notes;
  final String tripId;
  final String? activityId; // Liên kết với activity nếu có

  Ticket({
    required this.id,
    required this.name,
    required this.date,
    required this.ticketCode,
    this.imagePath,
    this.bookingUrl,
    this.notes,
    required this.tripId,
    this.activityId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'ticketCode': ticketCode,
      'imagePath': imagePath,
      'bookingUrl': bookingUrl,
      'notes': notes,
      'tripId': tripId,
      'activityId': activityId,
    };
  }

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as String,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      ticketCode: json['ticketCode'] as String,
      imagePath: json['imagePath'] as String?,
      bookingUrl: json['bookingUrl'] as String?,
      notes: json['notes'] as String?,
      tripId: json['tripId'] as String,
      activityId: json['activityId'] as String?,
    );
  }

  Ticket copyWith({
    String? id,
    String? name,
    DateTime? date,
    String? ticketCode,
    String? imagePath,
    String? bookingUrl,
    String? notes,
    String? tripId,
    String? activityId,
  }) {
    return Ticket(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      ticketCode: ticketCode ?? this.ticketCode,
      imagePath: imagePath ?? this.imagePath,
      bookingUrl: bookingUrl ?? this.bookingUrl,
      notes: notes ?? this.notes,
      tripId: tripId ?? this.tripId,
      activityId: activityId ?? this.activityId,
    );
  }
}
