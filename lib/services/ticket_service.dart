import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/ticket.dart';

class TicketService {
  static const String _ticketsKey = 'tickets';

  // Lấy tất cả vé
  Future<List<Ticket>> getTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final ticketsJson = prefs.getString(_ticketsKey);
    
    if (ticketsJson == null) {
      return [];
    }

    final List<dynamic> decoded = json.decode(ticketsJson);
    return decoded.map((json) => Ticket.fromJson(json)).toList();
  }

  // Lấy vé theo trip
  Future<List<Ticket>> getTicketsByTrip(String tripId) async {
    final tickets = await getTickets();
    return tickets.where((ticket) => ticket.tripId == tripId).toList();
  }

  // Lấy vé theo activity
  Future<List<Ticket>> getTicketsByActivity(String activityId) async {
    final tickets = await getTickets();
    return tickets.where((ticket) => ticket.linkedActivityId == activityId).toList();
  }

  // Lấy vé theo ID
  Future<Ticket?> getTicketById(String id) async {
    final tickets = await getTickets();
    try {
      return tickets.firstWhere((ticket) => ticket.id == id);
    } catch (e) {
      return null;
    }
  }

  // Thêm vé mới
  Future<void> addTicket(Ticket ticket) async {
    final tickets = await getTickets();
    tickets.add(ticket);
    await _saveTickets(tickets);
  }

  // Cập nhật vé
  Future<void> updateTicket(Ticket ticket) async {
    final tickets = await getTickets();
    final index = tickets.indexWhere((t) => t.id == ticket.id);
    
    if (index != -1) {
      tickets[index] = ticket;
      await _saveTickets(tickets);
    }
  }

  // Xóa vé
  Future<void> deleteTicket(String id) async {
    final tickets = await getTickets();
    final ticket = tickets.firstWhere((t) => t.id == id);
    
    // Xóa ảnh nếu có
    if (ticket.imagePath != null) {
      await deleteTicketImage(ticket.imagePath!);
    }
    
    tickets.removeWhere((t) => t.id == id);
    await _saveTickets(tickets);
  }

  // Lưu danh sách vé
  Future<void> _saveTickets(List<Ticket> tickets) async {
    final prefs = await SharedPreferences.getInstance();
    final ticketsJson = json.encode(tickets.map((t) => t.toJson()).toList());
    await prefs.setString(_ticketsKey, ticketsJson);
  }

  // Lưu ảnh vé
  Future<String> saveTicketImage(File imageFile, String ticketId) async {
    final directory = await getApplicationDocumentsDirectory();
    final ticketsDir = Directory('${directory.path}/tickets');
    
    if (!await ticketsDir.exists()) {
      await ticketsDir.create(recursive: true);
    }

    final fileName = '${ticketId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = await imageFile.copy('${ticketsDir.path}/$fileName');
    
    return savedImage.path;
  }

  // Xóa ảnh vé
  Future<void> deleteTicketImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore errors when deleting image
    }
  }

  // Xóa tất cả vé của một trip
  Future<void> deleteTicketsByTrip(String tripId) async {
    final tickets = await getTicketsByTrip(tripId);
    
    for (final ticket in tickets) {
      await deleteTicket(ticket.id);
    }
  }
}
