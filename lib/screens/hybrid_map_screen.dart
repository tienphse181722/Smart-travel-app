import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import '../models/activity.dart';
import '../services/osrm_service.dart';
import '../services/search_service.dart';
import '../services/route_optimizer_service.dart';

class HybridMapScreen extends StatefulWidget {
  final List<Activity> activities;
  final String title;

  const HybridMapScreen({
    super.key,
    required this.activities,
    required this.title,
  });

  @override
  State<HybridMapScreen> createState() => _HybridMapScreenState();
}

class _HybridMapScreenState extends State<HybridMapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  
  List<Activity> _activities = [];
  RouteData? _routeData;
  bool _isLoadingRoute = false;
  bool _isSearching = false;
  List<SearchResult> _searchResults = [];
  bool _showOptimizeButton = true;
  Timer? _debounceTimer;
  String _currentSearchQuery = '';
  bool _isDarkMode = false;
  
  late AnimationController _bottomSheetController;
  late Animation<double> _bottomSheetAnimation;

  @override
  void initState() {
    super.initState();
    _activities = List.from(widget.activities);
    _loadRoute();
    
    _bottomSheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bottomSheetAnimation = CurvedAnimation(
      parent: _bottomSheetController,
      curve: Curves.easeOutCubic,
    );
    _bottomSheetController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bottomSheetController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadRoute() async {
    if (_activities.length < 2) return;

    setState(() {
      _isLoadingRoute = true;
    });

    try {
      final waypoints = _activities.map((a) => LatLng(a.lat, a.lng)).toList();
      final routeData = await OSRMService.getRoute(waypoints);

      if (mounted) {
        setState(() {
          _routeData = routeData;
          _isLoadingRoute = false;
        });
      }
    } catch (e) {
      print('Load route error: $e');
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
        });
        _showSnackBar('Không thể tải route. Vui lòng thử lại.', Colors.red);
      }
    }
  }

  Future<void> _optimizeRoute() async {
    if (_activities.length < 3) {
      _showSnackBar('Cần ít nhất 3 điểm để tối ưu', Colors.orange);
      return;
    }

    setState(() {
      _isLoadingRoute = true;
      _showOptimizeButton = false;
    });

    try {
      // Tối ưu thứ tự activities
      final optimized = RouteOptimizerService.optimizeRoute(_activities);
      
      // Lấy route mới
      final waypoints = optimized.map((a) => LatLng(a.lat, a.lng)).toList();
      final routeData = await OSRMService.getRoute(waypoints);

      if (mounted) {
        setState(() {
          _activities = optimized;
          _routeData = routeData;
          _isLoadingRoute = false;
        });
        
        _showSnackBar('Đã tối ưu route!', Colors.green);
      }
    } catch (e) {
      print('Optimize route error: $e');
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
          _showOptimizeButton = true; // Re-enable button on error
        });
        _showSnackBar('Không thể tối ưu route. Vui lòng thử lại.', Colors.red);
      }
    }
  }

  Future<void> _searchPlace(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _currentSearchQuery = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _currentSearchQuery = query;
    });

    try {
      // Lấy vị trí trung tâm hiện tại để ưu tiên kết quả gần
      final center = _mapController.camera.center;
      
      final results = await SearchService.searchPlace(
        query,
        lat: center.latitude,
        lng: center.longitude,
        limit: 5,
      );

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      print('Search error: $e');
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        _showSnackBar('Lỗi tìm kiếm. Vui lòng thử lại.', Colors.red);
      }
    }
  }

  void _onSearchChanged(String value) {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    if (value.length < 3) {
      setState(() {
        _searchResults = [];
        _currentSearchQuery = '';
      });
      return;
    }

    // Set new timer (debounce 500ms)
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchPlace(value);
    });
  }

  void _selectSearchResult(SearchResult result) {
    // Di chuyển map đến vị trí được chọn
    _mapController.move(LatLng(result.lat, result.lng), 15);
    
    // Xóa search results
    setState(() {
      _searchResults = [];
      _searchController.clear();
    });

    // Hiển thị thông tin
    _showSnackBar('📍 ${result.name}', const Color(0xFF2F80ED));
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final center = RouteOptimizerService.calculateCenter(_activities);
    final zoom = RouteOptimizerService.calculateZoomLevel(_activities);
    
    // Theme colors
    final bgColor = _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = _isDarkMode ? Colors.white : Colors.black87;
    final cardColor = _isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final borderColor = _isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(center.lat, center.lng),
              initialZoom: zoom,
              minZoom: 5,
              maxZoom: 18,
            ),
            children: [
              // OpenStreetMap tiles (FREE) - Dark or Light mode
              TileLayer(
                urlTemplate: _isDarkMode
                    ? 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.smart_travel_app',
                maxZoom: 19,
              ),
              
              // Route polyline
              if (_routeData != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routeData!.polylinePoints,
                      strokeWidth: 4,
                      color: const Color(0xFF2F80ED),
                      borderStrokeWidth: 2,
                      borderColor: Colors.white,
                    ),
                  ],
                ),
              
              // Markers
              MarkerLayer(
                markers: _activities.asMap().entries.map((entry) {
                  final index = entry.key;
                  final activity = entry.value;
                  final isFood = activity.type == ActivityType.food;

                  return Marker(
                    point: LatLng(activity.lat, activity.lng),
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () => _showActivityInfo(activity, index),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Shadow
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          // Marker
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isFood
                                    ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)]
                                    : [const Color(0xFF2F80ED), const Color(0xFF56CCF2)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Top bar
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(bgColor: cardColor, textColor: textColor, borderColor: borderColor),
                if (_searchResults.isNotEmpty) _buildSearchResults(cardColor: cardColor, textColor: textColor),
              ],
            ),
          ),

          // Bottom sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(_bottomSheetAnimation),
              child: _buildBottomSheet(cardColor: cardColor, textColor: textColor),
            ),
          ),

          // Loading indicator
          if (_isLoadingRoute)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar({
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDarkMode ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: _isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFF7F9FC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm địa điểm...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: _isDarkMode ? Colors.grey[600] : Colors.grey[400]),
                      suffixIcon: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear_rounded, color: textColor),
                                  onPressed: () {
                                    _searchController.clear();
                                    _debounceTimer?.cancel();
                                    setState(() {
                                      _searchResults = [];
                                      _currentSearchQuery = '';
                                    });
                                  },
                                )
                              : Icon(Icons.search_rounded, color: _isDarkMode ? Colors.grey[600] : Colors.grey),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 8),
                // Dark mode toggle
                Container(
                  decoration: BoxDecoration(
                    color: _isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFF7F9FC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: _isDarkMode ? Colors.amber : const Color(0xFF2F80ED),
                    ),
                    onPressed: () {
                      setState(() {
                        _isDarkMode = !_isDarkMode;
                      });
                    },
                    tooltip: _isDarkMode ? 'Chế độ sáng' : 'Chế độ tối',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults({
    required Color cardColor,
    required Color textColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isDarkMode ? Colors.grey[800]! : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDarkMode ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        itemCount: _searchResults.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: _isDarkMode ? Colors.grey[800] : Colors.grey[300],
        ),
        itemBuilder: (context, index) {
          final result = _searchResults[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.place_rounded,
                color: Color(0xFF2F80ED),
                size: 20,
              ),
            ),
            title: _buildHighlightedText(
              result.name,
              _currentSearchQuery,
              TextStyle(fontWeight: FontWeight.w600, color: textColor),
            ),
            subtitle: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: result.source == 'nominatim'
                        ? Colors.green.withValues(alpha: 0.1)
                        : result.source == 'photon'
                            ? Colors.blue.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    result.source == 'nominatim' || result.source == 'photon'
                        ? 'FREE'
                        : result.source.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: result.source == 'nominatim' || result.source == 'photon'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            onTap: () => _selectSearchResult(result),
          );
        },
      ),
    );
  }

  // Helper method to highlight search keyword
  Widget _buildHighlightedText(String text, String query, TextStyle style) {
    if (query.isEmpty) {
      return Text(text, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) {
      return Text(text, style: style);
    }

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: style.copyWith(
              backgroundColor: const Color(0xFF2F80ED).withValues(alpha: 0.2),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2F80ED),
            ),
          ),
          TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }

  Widget _buildBottomSheet({
    required Color cardColor,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDarkMode ? 0.5 : 0.26),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _isDarkMode ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.location_on_rounded,
                        label: 'Điểm đến',
                        value: '${_activities.length}',
                        color: const Color(0xFF2F80ED),
                        textColor: textColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.route_rounded,
                        label: 'Khoảng cách',
                        value: _routeData?.distanceText ?? '--',
                        color: const Color(0xFF56CCF2),
                        textColor: textColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.access_time_rounded,
                        label: 'Thời gian',
                        value: _routeData?.durationText ?? '--',
                        color: const Color(0xFFFF6B6B),
                        textColor: textColor,
                      ),
                    ),
                  ],
                ),
                
                if (_showOptimizeButton && _activities.length >= 3) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _optimizeRoute,
                      icon: const Icon(Icons.auto_fix_high_rounded),
                      label: const Text(
                        'Tối ưu route',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F80ED),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showActivityInfo(Activity activity, int index) {
    final isFood = activity.type == ActivityType.food;
    final bgColor = _isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = _isDarkMode ? Colors.white : Colors.black87;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isFood
                            ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)]
                            : [const Color(0xFF2F80ED), const Color(0xFF56CCF2)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          isFood ? 'Ăn uống' : 'Vui chơi',
                          style: TextStyle(
                            fontSize: 14,
                            color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (activity.tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: activity.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,
                          color: _isDarkMode ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}
