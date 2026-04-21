import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../models/activity.dart';
import '../services/ticket_service.dart';
import '../widgets/ticket_card.dart';
import 'add_ticket_screen.dart';
import 'ticket_detail_screen.dart';

class TicketListScreen extends StatefulWidget {
  final String tripId;
  final List<Activity>? activities;

  const TicketListScreen({
    super.key,
    required this.tripId,
    this.activities,
  });

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  final _ticketService = TicketService();
  List<Ticket> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tickets = await _ticketService.getTicketsByTrip(widget.tripId);
      tickets.sort((a, b) => a.date.compareTo(b.date));

      if (mounted) {
        setState(() {
          _tickets = tickets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách vé: $e')),
        );
      }
    }
  }

  Future<void> _deleteTicket(Ticket ticket) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa vé "${ticket.name}"?'),
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
        await _ticketService.deleteTicket(ticket.id);
        _loadTickets();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa vé')),
          );
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

  Future<void> _navigateToAddTicket() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTicketScreen(
          tripId: widget.tripId,
          activities: widget.activities,
        ),
      ),
    );

    if (result == true) {
      _loadTickets();
    }
  }

  Future<void> _navigateToTicketDetail(Ticket ticket) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketDetailScreen(
          ticket: ticket,
          activities: widget.activities,
        ),
      ),
    );

    if (result == true) {
      _loadTickets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý vé'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tickets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.confirmation_number_outlined,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có vé nào',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Thêm vé máy bay, tàu, xe, khách sạn...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _navigateToAddTicket,
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm vé đầu tiên'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = _tickets[index];
                    return TicketCard(
                      ticket: ticket,
                      onTap: () => _navigateToTicketDetail(ticket),
                      onDelete: () => _deleteTicket(ticket),
                    );
                  },
                ),
      floatingActionButton: _tickets.isNotEmpty
          ? FloatingActionButton(
              onPressed: _navigateToAddTicket,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
