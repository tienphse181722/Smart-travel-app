import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingSuggestionsScreen extends StatelessWidget {
  const BookingSuggestionsScreen({super.key});

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gợi ý đặt vé'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.confirmation_number_rounded,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  'Bạn chưa có vé?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Đặt vé ngay để chuẩn bị cho chuyến đi',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tàu / Xe
          _buildCategorySection(
            context,
            title: '🚌 Tàu / Xe',
            description: 'Đặt vé tàu, xe khách đi khắp Việt Nam',
            suggestions: [
              BookingSuggestion(
                name: 'Vexere',
                description: 'Đặt vé xe khách, xe limousine',
                url: 'https://vexere.com',
                icon: Icons.directions_bus,
                color: const Color(0xFFFF6B6B),
              ),
              BookingSuggestion(
                name: 'VNR - Đường sắt VN',
                description: 'Đặt vé tàu hỏa trực tuyến',
                url: 'https://dsvn.vn',
                icon: Icons.train,
                color: const Color(0xFF4ECDC4),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Máy bay
          _buildCategorySection(
            context,
            title: '✈️ Máy bay',
            description: 'So sánh giá và đặt vé máy bay',
            suggestions: [
              BookingSuggestion(
                name: 'Traveloka',
                description: 'Đặt vé máy bay giá rẻ',
                url: 'https://www.traveloka.com/vi-vn/flight',
                icon: Icons.flight,
                color: const Color(0xFF2F80ED),
              ),
              BookingSuggestion(
                name: 'Skyscanner',
                description: 'So sánh giá vé từ nhiều hãng',
                url: 'https://www.skyscanner.com.vn',
                icon: Icons.flight_takeoff,
                color: const Color(0xFF00D9FF),
              ),
              BookingSuggestion(
                name: 'Vietnam Airlines',
                description: 'Hãng hàng không quốc gia',
                url: 'https://www.vietnamairlines.com',
                icon: Icons.flight,
                color: const Color(0xFF006A4E),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Khách sạn
          _buildCategorySection(
            context,
            title: '🏨 Khách sạn',
            description: 'Tìm và đặt phòng khách sạn',
            suggestions: [
              BookingSuggestion(
                name: 'Booking.com',
                description: 'Đặt khách sạn toàn cầu',
                url: 'https://www.booking.com',
                icon: Icons.hotel,
                color: const Color(0xFF003580),
              ),
              BookingSuggestion(
                name: 'Agoda',
                description: 'Khách sạn giá tốt châu Á',
                url: 'https://www.agoda.com/vi-vn',
                icon: Icons.hotel,
                color: const Color(0xFFD71149),
              ),
              BookingSuggestion(
                name: 'Traveloka',
                description: 'Đặt khách sạn trong nước',
                url: 'https://www.traveloka.com/vi-vn/hotel',
                icon: Icons.hotel,
                color: const Color(0xFF2F80ED),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber.shade700,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mẹo đặt vé',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Đặt vé sớm để có giá tốt\n'
                        '• So sánh giá từ nhiều nguồn\n'
                        '• Lưu mã vé vào app sau khi đặt',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context, {
    required String title,
    required String description,
    required List<BookingSuggestion> suggestions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        ...suggestions.map((suggestion) => _buildSuggestionCard(context, suggestion)),
      ],
    );
  }

  Widget _buildSuggestionCard(BuildContext context, BookingSuggestion suggestion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _launchUrl(context, suggestion.url),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: suggestion.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  suggestion.icon,
                  color: suggestion.color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      suggestion.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookingSuggestion {
  final String name;
  final String description;
  final String url;
  final IconData icon;
  final Color color;

  BookingSuggestion({
    required this.name,
    required this.description,
    required this.url,
    required this.icon,
    required this.color,
  });
}
