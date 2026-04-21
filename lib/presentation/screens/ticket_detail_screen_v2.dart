import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../data/models/ticket.dart';
import '../../data/models/activity.dart';
import '../../data/services/ticket_service.dart';
import 'add_ticket_screen_v2.dart';

class TicketDetailScreenV2 extends StatefulWidget {
  final Ticket ticket;
  final List<Activity>? activities;

  const TicketDetailScreenV2({
    super.key,
    required this.ticket,
    this.activities,
  });

  @override
  State<TicketDetailScreenV2> createState() => _TicketDetailScreenV2State();
}

class _TicketDetailScreenV2State extends State<TicketDetailScreenV2> {
  final _ticketService = TicketService();
  late Ticket _ticket;

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
  }

  IconData _getTypeIcon() {
    switch (_ticket.type) {
      case TicketType.bus:
        return Icons.directions_bus;
      case TicketType.train:
        return Icons.train;
      case TicketType.flight:
        return Icons.flight;
      case TicketType.hotel:
        return Icons.hotel;
    }
  }

  Color _getTypeColor() {
    switch (_ticket.type) {
      case TicketType.bus:
        return const Color(0xFFFF6B6B);
      case TicketType.train:
        return const Color(0xFF4ECDC4);
      case TicketType.flight:
        return const Color(0xFF2F80ED);
      case TicketType.hotel:
        return const Color(0xFFFF9F43);
    }
  }

  Color _getStatusColor() {
    switch (_ticket.status) {
      case TicketStatus.notBooked:
        return Colors.grey;
      case TicketStatus.booked:
        return Colors.green;
      case TicketStatus.used:
        return Colors.blue;
    }
  }

  Future<void> _editTicket() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTicketScreenV2(
          tripId: _ticket.tripId,
          activities: widget.activities,
          ticketToEdit: _ticket,
        ),
      ),
    );

    if (result == true) {
      final updatedTicket = await _ticketService.getTicketById(_ticket.id);
      if (updatedTicket != null && mounted) {
        setState(() {
          _ticket = updatedTicket;
        });
      }
    }
  }

  Future<void> _deleteTicket() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa vé "${_ticket.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _ticketService.deleteTicket(_ticket.id);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi xóa vé: $e')),
          );
        }
      }
    }
  }

  void _copyTicketCode() {
    Clipboard.setData(ClipboardData(text: _ticket.code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép mã vé')),
    );
  }

  String? _getActivityName() {
    if (_ticket.linkedActivityId == null || widget.activities == null) {
      return null;
    }

    try {
      final activity = widget.activities!.firstWhere(
        (a) => a.id == _ticket.linkedActivityId,
      );
      return activity.name;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activityName = _getActivityName();
    final typeColor = _getTypeColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết vé'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editTicket,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTicket,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Ticket image
          if (_ticket.imagePath != null)
            Card(
              clipBehavior: Clip.antiAlias,
              child: Image.file(
                File(_ticket.imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          if (_ticket.imagePath != null) const SizedBox(height: 16),

          // Main info card
          Card(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    typeColor.withValues(alpha: 0.05),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type & Status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [typeColor, typeColor.withValues(alpha: 0.7)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _getTypeIcon(),
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: typeColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _ticket.typeDisplayName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: typeColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor().withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _ticket.statusDisplayName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _ticket.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Route
                  if (_ticket.route != null) ...[
                    _buildInfoSection(
                      'Tuyến đường',
                      _ticket.route!,
                      Icons.route,
                      typeColor,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Datetime
                  _buildInfoSection(
                    'Ngày giờ',
                    DateFormat('EEEE, dd/MM/yyyy - HH:mm', 'vi').format(_ticket.datetime),
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                  const SizedBox(height: 16),

                  // Code
                  Text(
                    'Mã vé',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _ticket.code,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: _copyTicketCode,
                          tooltip: 'Sao chép mã',
                        ),
                      ],
                    ),
                  ),

                  // Linked activity
                  if (activityName != null) ...[
                    const SizedBox(height: 16),
                    _buildInfoSection(
                      'Liên kết với hoạt động',
                      activityName,
                      Icons.link,
                      Theme.of(context).colorScheme.secondary,
                    ),
                  ],

                  // Notes
                  if (_ticket.notes != null && _ticket.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Ghi chú',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _ticket.notes!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
