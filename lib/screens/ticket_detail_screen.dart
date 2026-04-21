import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ticket.dart';
import '../models/activity.dart';
import '../services/ticket_service.dart';
import 'add_ticket_screen.dart';

class TicketDetailScreen extends StatefulWidget {
  final Ticket ticket;
  final List<Activity>? activities;

  const TicketDetailScreen({
    super.key,
    required this.ticket,
    this.activities,
  });

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _ticketService = TicketService();
  late Ticket _ticket;

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
  }

  Future<void> _editTicket() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTicketScreen(
          tripId: _ticket.tripId,
          activities: widget.activities,
          ticketToEdit: _ticket,
        ),
      ),
    );

    if (result == true) {
      // Reload ticket data
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
    Clipboard.setData(ClipboardData(text: _ticket.ticketCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép mã vé')),
    );
  }

  Future<void> _openBookingUrl() async {
    if (_ticket.bookingUrl == null) return;

    final url = Uri.parse(_ticket.bookingUrl!);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở link')),
        );
      }
    }
  }

  String? _getActivityName() {
    if (_ticket.activityId == null || widget.activities == null) {
      return null;
    }

    try {
      final activity = widget.activities!.firstWhere(
        (a) => a.id == _ticket.activityId,
      );
      return activity.name;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activityName = _getActivityName();

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

          // Ticket info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.confirmation_number,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _ticket.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEEE, dd/MM/yyyy', 'vi').format(_ticket.date),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Ticket code
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
                            _ticket.ticketCode,
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
                    const SizedBox(height: 20),
                    Text(
                      'Liên kết với hoạt động',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.link,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              activityName,
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

                  // Booking URL
                  if (_ticket.bookingUrl != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Link đặt vé',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _openBookingUrl,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.open_in_new,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _ticket.bookingUrl!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Notes
                  if (_ticket.notes != null && _ticket.notes!.isNotEmpty) ...[
                    const SizedBox(height: 20),
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
}
