import 'package:flutter/material.dart';
import '../../data/models/ticket.dart';
import '../../data/models/activity.dart';
import '../../data/services/ticket_service.dart';
import '../widgets/ticket_card_v2.dart';
import 'add_ticket_screen_v2.dart';
import 'ticket_detail_screen_v2.dart';
import 'booking_suggestions_screen.dart';

class TicketListScreenV2 extends StatefulWidget {
  final String tripId;
  final List<Activity>? activities;

  const TicketListScreenV2({
    super.key,
    required this.tripId,
    this.activities,
  });

  @override
  State<TicketListScreenV2> createState() => _TicketListScreenV2State();
}

class _TicketListScreenV2State extends State<TicketListScreenV2> {
  final _ticketService = TicketService();
  List<Ticket> _tickets = [];
  bool _isLoading = true;
  String _filterType = 'all';

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
      tickets.sort((a, b) => a.datetime.compareTo(b.datetime));

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

  List<Ticket> get _filteredTickets {
    if (_filterType == 'all') return _tickets;
    return _tickets.where((t) => t.type.name == _filterType).toList();
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
        builder: (context) => AddTicketScreenV2(
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
        builder: (context) => TicketDetailScreenV2(
          ticket: ticket,
          activities: widget.activities,
        ),
      ),
    );

    if (result == true) {
      _loadTickets();
    }
  }

  void _navigateToBookingSuggestions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookingSuggestionsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý vé'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: _navigateToBookingSuggestions,
            tooltip: 'Gợi ý mua vé',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter chips
                if (_tickets.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Tất cả', 'all', Icons.all_inclusive),
                          const SizedBox(width: 8),
                          _buildFilterChip('Xe', 'bus', Icons.directions_bus),
                          const SizedBox(width: 8),
                          _buildFilterChip('Tàu', 'train', Icons.train),
                          const SizedBox(width: 8),
                          _buildFilterChip('Máy bay', 'flight', Icons.flight),
                          const SizedBox(width: 8),
                          _buildFilterChip('Khách sạn', 'hotel', Icons.hotel),
                        ],
                      ),
                    ),
                  ),

                // Ticket list
                Expanded(
                  child: _tickets.isEmpty
                      ? _buildEmptyState()
                      : _filteredTickets.isEmpty
                          ? _buildNoResultsState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredTickets.length,
                              itemBuilder: (context, index) {
                                final ticket = _filteredTickets[index];
                                return TicketCardV2(
                                  ticket: ticket,
                                  onTap: () => _navigateToTicketDetail(ticket),
                                  onDelete: () => _deleteTicket(ticket),
                                );
                              },
                            ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddTicket,
        icon: const Icon(Icons.add),
        label: const Text('Thêm vé'),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _filterType == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterType = value;
        });
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.confirmation_number_outlined,
                size: 80,
                color: Color(0xFF2F80ED),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Bạn chưa có vé',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Thêm vé để quản lý chuyến đi dễ dàng hơn',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Suggestion buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToAddTicket,
                icon: const Icon(Icons.add),
                label: const Text('Thêm vé ngay'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _navigateToBookingSuggestions,
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Gợi ý mua vé'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy vé',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }
}
