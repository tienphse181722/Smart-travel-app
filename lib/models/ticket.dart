enum TicketType {
  bus,      // Xe
  train,    // Tàu
  flight,   // Máy bay
  hotel,    // Khách sạn
}

enum TicketStatus {
  notBooked,  // Chưa đặt
  booked,     // Đã đặt
  used,       // Đã sử dụng
}

class Ticket {
  final String id;
  final TicketType type;
  final String name;
  final DateTime datetime;
  final String code;
  final String? from;  // Điểm đi
  final String? to;    // Điểm đến
  final String? imagePath;
  final TicketStatus status;
  final String? notes;
  final String tripId;
  final String? linkedActivityId;

  Ticket({
    required this.id,
    required this.type,
    required this.name,
    required this.datetime,
    required this.code,
    this.from,
    this.to,
    this.imagePath,
    this.status = TicketStatus.notBooked,
    this.notes,
    required this.tripId,
    this.linkedActivityId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'datetime': datetime.toIso8601String(),
      'code': code,
      'from': from,
      'to': to,
      'imagePath': imagePath,
      'status': status.name,
      'notes': notes,
      'tripId': tripId,
      'linkedActivityId': linkedActivityId,
    };
  }

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as String,
      type: TicketType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TicketType.bus,
      ),
      name: json['name'] as String,
      datetime: DateTime.parse(json['datetime'] as String),
      code: json['code'] as String,
      from: json['from'] as String?,
      to: json['to'] as String?,
      imagePath: json['imagePath'] as String?,
      status: TicketStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TicketStatus.notBooked,
      ),
      notes: json['notes'] as String?,
      tripId: json['tripId'] as String,
      linkedActivityId: json['linkedActivityId'] as String?,
    );
  }

  Ticket copyWith({
    String? id,
    TicketType? type,
    String? name,
    DateTime? datetime,
    String? code,
    String? from,
    String? to,
    String? imagePath,
    TicketStatus? status,
    String? notes,
    String? tripId,
    String? linkedActivityId,
  }) {
    return Ticket(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      datetime: datetime ?? this.datetime,
      code: code ?? this.code,
      from: from ?? this.from,
      to: to ?? this.to,
      imagePath: imagePath ?? this.imagePath,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      tripId: tripId ?? this.tripId,
      linkedActivityId: linkedActivityId ?? this.linkedActivityId,
    );
  }

  // Helper methods
  String get typeDisplayName {
    switch (type) {
      case TicketType.bus:
        return 'Xe';
      case TicketType.train:
        return 'Tàu';
      case TicketType.flight:
        return 'Máy bay';
      case TicketType.hotel:
        return 'Khách sạn';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case TicketStatus.notBooked:
        return 'Chưa đặt';
      case TicketStatus.booked:
        return 'Đã đặt';
      case TicketStatus.used:
        return 'Đã sử dụng';
    }
  }

  String? get route {
    if (from != null && to != null) {
      return '$from → $to';
    }
    return null;
  }
}
