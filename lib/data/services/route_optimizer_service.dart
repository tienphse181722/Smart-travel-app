import '../models/activity.dart';
import 'itinerary_service.dart';

class RouteOptimizerService {
  // Tối ưu route cho danh sách activities trong 1 ngày
  // Sử dụng thuật toán Nearest Neighbor (greedy)
  static List<Activity> optimizeRoute(List<Activity> activities) {
    if (activities.length <= 2) {
      return activities;
    }

    final List<Activity> optimized = [];
    final List<Activity> remaining = List.from(activities);

    // Bắt đầu từ activity đầu tiên
    optimized.add(remaining.removeAt(0));

    // Tìm activity gần nhất tiếp theo
    while (remaining.isNotEmpty) {
      final current = optimized.last;
      double minDistance = double.infinity;
      int nearestIndex = 0;

      for (int i = 0; i < remaining.length; i++) {
        final distance = ItineraryService.calculateDistance(
          current.lat,
          current.lng,
          remaining[i].lat,
          remaining[i].lng,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestIndex = i;
        }
      }

      optimized.add(remaining.removeAt(nearestIndex));
    }

    return optimized;
  }

  // Tính tổng khoảng cách của route
  static double calculateTotalDistance(List<Activity> activities) {
    if (activities.length <= 1) return 0;

    double total = 0;
    for (int i = 0; i < activities.length - 1; i++) {
      total += ItineraryService.calculateDistance(
        activities[i].lat,
        activities[i].lng,
        activities[i + 1].lat,
        activities[i + 1].lng,
      );
    }

    return total;
  }

  // Tính thời gian di chuyển ước tính (giả sử tốc độ trung bình 30km/h)
  static Duration estimateTravelTime(double distanceKm) {
    const double avgSpeedKmh = 30.0;
    final hours = distanceKm / avgSpeedKmh;
    return Duration(minutes: (hours * 60).round());
  }

  // Lấy danh sách các đoạn đường (segments) với khoảng cách
  static List<RouteSegment> getRouteSegments(List<Activity> activities) {
    final List<RouteSegment> segments = [];

    for (int i = 0; i < activities.length - 1; i++) {
      final from = activities[i];
      final to = activities[i + 1];
      final distance = ItineraryService.calculateDistance(
        from.lat,
        from.lng,
        to.lat,
        to.lng,
      );

      segments.add(RouteSegment(
        from: from,
        to: to,
        distance: distance,
        estimatedTime: estimateTravelTime(distance),
      ));
    }

    return segments;
  }

  // Kiểm tra xem route có hợp lý không (không có đoạn quá xa)
  static bool isRouteReasonable(List<Activity> activities, {double maxSegmentKm = 15.0}) {
    for (int i = 0; i < activities.length - 1; i++) {
      final distance = ItineraryService.calculateDistance(
        activities[i].lat,
        activities[i].lng,
        activities[i + 1].lat,
        activities[i + 1].lng,
      );

      if (distance > maxSegmentKm) {
        return false;
      }
    }

    return true;
  }

  // Tính điểm trung tâm (center) của tất cả activities
  static MapCenter calculateCenter(List<Activity> activities) {
    if (activities.isEmpty) {
      return MapCenter(lat: 16.0544, lng: 108.2425); // Default: Đà Nẵng
    }

    double sumLat = 0;
    double sumLng = 0;

    for (var activity in activities) {
      sumLat += activity.lat;
      sumLng += activity.lng;
    }

    return MapCenter(
      lat: sumLat / activities.length,
      lng: sumLng / activities.length,
    );
  }

  // Tính zoom level phù hợp dựa trên khoảng cách xa nhất
  static double calculateZoomLevel(List<Activity> activities) {
    if (activities.length <= 1) return 14.0;

    double maxDistance = 0;

    for (int i = 0; i < activities.length; i++) {
      for (int j = i + 1; j < activities.length; j++) {
        final distance = ItineraryService.calculateDistance(
          activities[i].lat,
          activities[i].lng,
          activities[j].lat,
          activities[j].lng,
        );

        if (distance > maxDistance) {
          maxDistance = distance;
        }
      }
    }

    // Zoom level dựa trên khoảng cách
    if (maxDistance < 2) return 14.0;
    if (maxDistance < 5) return 13.0;
    if (maxDistance < 10) return 12.0;
    if (maxDistance < 20) return 11.0;
    if (maxDistance < 50) return 10.0;
    return 9.0;
  }
}

class RouteSegment {
  final Activity from;
  final Activity to;
  final double distance;
  final Duration estimatedTime;

  RouteSegment({
    required this.from,
    required this.to,
    required this.distance,
    required this.estimatedTime,
  });
}

class MapCenter {
  final double lat;
  final double lng;

  MapCenter({required this.lat, required this.lng});
}
