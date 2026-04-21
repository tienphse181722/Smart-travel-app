import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OSRMService {
  static const String _osrmUrl = 'https://router.project-osrm.org/route/v1/driving';

  // Lấy route từ OSRM
  static Future<RouteData?> getRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return null;

    try {
      // Tạo coordinates string: lng,lat;lng,lat;...
      final coordinates = waypoints
          .map((point) => '${point.longitude},${point.latitude}')
          .join(';');

      final url = '$_osrmUrl/$coordinates?overview=full&geometries=geojson';
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['code'] == 'Ok' && data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry']['coordinates'] as List;
          
          // Convert coordinates to LatLng
          final polylinePoints = geometry.map((coord) {
            return LatLng(coord[1].toDouble(), coord[0].toDouble());
          }).toList();

          return RouteData(
            polylinePoints: polylinePoints,
            distance: route['distance'].toDouble() / 1000, // meters to km
            duration: Duration(seconds: route['duration'].toInt()),
          );
        }
      }

      print('OSRM API error: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error getting OSRM route: $e');
      return null;
    }
  }

  // Lấy route cho nhiều điểm (tối ưu thứ tự)
  static Future<RouteData?> getOptimizedRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return null;

    try {
      // OSRM Trip service - tự động tối ưu thứ tự
      final coordinates = waypoints
          .map((point) => '${point.longitude},${point.latitude}')
          .join(';');

      final url = 'https://router.project-osrm.org/trip/v1/driving/$coordinates?overview=full&geometries=geojson';
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['code'] == 'Ok' && data['trips'] != null && data['trips'].isNotEmpty) {
          final trip = data['trips'][0];
          final geometry = trip['geometry']['coordinates'] as List;
          
          final polylinePoints = geometry.map((coord) {
            return LatLng(coord[1].toDouble(), coord[0].toDouble());
          }).toList();

          return RouteData(
            polylinePoints: polylinePoints,
            distance: trip['distance'].toDouble() / 1000,
            duration: Duration(seconds: trip['duration'].toInt()),
          );
        }
      }

      print('OSRM Trip API error: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error getting optimized route: $e');
      return null;
    }
  }

  // Tính khoảng cách và thời gian giữa 2 điểm
  static Future<RouteSegment?> getRouteSegment(LatLng from, LatLng to) async {
    try {
      final coordinates = '${from.longitude},${from.latitude};${to.longitude},${to.latitude}';
      final url = '$_osrmUrl/$coordinates?overview=false';
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['code'] == 'Ok' && data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          
          return RouteSegment(
            distance: route['distance'].toDouble() / 1000,
            duration: Duration(seconds: route['duration'].toInt()),
          );
        }
      }

      return null;
    } catch (e) {
      print('Error getting route segment: $e');
      return null;
    }
  }
}

class RouteData {
  final List<LatLng> polylinePoints;
  final double distance; // km
  final Duration duration;

  RouteData({
    required this.polylinePoints,
    required this.distance,
    required this.duration,
  });

  String get distanceText {
    if (distance < 1) {
      return '${(distance * 1000).toInt()} m';
    }
    return '${distance.toStringAsFixed(1)} km';
  }

  String get durationText {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class RouteSegment {
  final double distance; // km
  final Duration duration;

  RouteSegment({
    required this.distance,
    required this.duration,
  });
}
