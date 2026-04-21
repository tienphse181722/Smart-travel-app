import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trip.dart';
import 'ticket_service.dart';

class TripService {
  static const String _tripsKey = 'trips';
  final _ticketService = TicketService();

  // Lấy tất cả trips
  Future<List<Trip>> getTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final tripsJson = prefs.getString(_tripsKey);
    
    if (tripsJson == null) {
      return [];
    }

    try {
      final List<dynamic> decoded = json.decode(tripsJson);
      return decoded.map((json) => Trip.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Lấy trip theo ID
  Future<Trip?> getTripById(String id) async {
    final trips = await getTrips();
    try {
      return trips.firstWhere((trip) => trip.id == id);
    } catch (e) {
      return null;
    }
  }

  // Thêm trip mới
  Future<void> addTrip(Trip trip) async {
    final trips = await getTrips();
    trips.add(trip);
    await _saveTrips(trips);
  }

  // Cập nhật trip
  Future<void> updateTrip(Trip trip) async {
    final trips = await getTrips();
    final index = trips.indexWhere((t) => t.id == trip.id);
    
    if (index != -1) {
      trips[index] = trip;
      await _saveTrips(trips);
    }
  }

  // Xóa trip
  Future<void> deleteTrip(String id) async {
    // Xóa tất cả vé liên quan
    await _ticketService.deleteTicketsByTrip(id);
    
    // Xóa trip
    final trips = await getTrips();
    trips.removeWhere((t) => t.id == id);
    await _saveTrips(trips);
  }

  // Lưu danh sách trips
  Future<void> _saveTrips(List<Trip> trips) async {
    final prefs = await SharedPreferences.getInstance();
    final tripsJson = json.encode(trips.map((t) => t.toJson()).toList());
    await prefs.setString(_tripsKey, tripsJson);
  }

  // Xóa tất cả trips (for testing)
  Future<void> clearAllTrips() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tripsKey);
  }
}
