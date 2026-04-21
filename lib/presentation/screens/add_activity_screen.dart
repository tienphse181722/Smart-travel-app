import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../data/models/activity.dart';
import '../../data/models/place.dart';
import '../../data/models/food_place.dart';
import '../../data/services/data_service.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedTag;

  List<Place> _places = [];
  List<FoodPlace> _foodPlaces = [];
  List<String> _placeTags = [];
  List<String> _foodTags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTag = null;
        _searchQuery = '';
        _searchController.clear();
      });
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final places = await DataService.loadPlaces();
      final foodPlaces = await DataService.loadFoodPlaces();
      final placeTags = await DataService.getPlaceTags();
      final foodTags = await DataService.getFoodTags();

      setState(() {
        _places = places;
        _foodPlaces = foodPlaces;
        _placeTags = placeTags;
        _foodTags = foodTags;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text('Lỗi: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildTabBar(),
            _buildSearchBar(),
            _buildTagFilter(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPlacesList(),
                        _buildFoodPlacesList(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Thêm hoạt động',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF6B7280),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.place_rounded),
            text: 'Vui chơi',
          ),
          Tab(
            icon: Icon(Icons.restaurant_rounded),
            text: 'Ăn uống',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm địa điểm...',
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: Color(0xFF2F80ED),
              size: 20,
            ),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }

  Widget _buildTagFilter() {
    final tags = _tabController.index == 0 ? _placeTags : _foodTags;

    if (tags.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('Tất cả'),
              selected: _selectedTag == null,
              onSelected: (selected) {
                setState(() => _selectedTag = null);
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF2F80ED),
              labelStyle: TextStyle(
                color: _selectedTag == null ? Colors.white : const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _selectedTag == null
                      ? Colors.transparent
                      : Colors.grey.shade200,
                ),
              ),
            ),
          ),
          ...tags.map((tag) {
            final isSelected = _selectedTag == tag;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedTag = selected ? tag : null);
                },
                backgroundColor: Colors.white,
                selectedColor: const Color(0xFF56CCF2),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? Colors.transparent : Colors.grey.shade200,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPlacesList() {
    var filteredPlaces = _places;

    if (_searchQuery.isNotEmpty) {
      filteredPlaces = filteredPlaces
          .where((place) =>
              place.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedTag != null) {
      filteredPlaces = filteredPlaces
          .where((place) => place.tags.contains(_selectedTag))
          .toList();
    }

    if (filteredPlaces.isEmpty) {
      return _buildEmptyState('Không tìm thấy địa điểm');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPlaces.length,
      itemBuilder: (context, index) {
        return _buildPlaceCard(filteredPlaces[index]);
      },
    );
  }

  Widget _buildFoodPlacesList() {
    var filteredFoodPlaces = _foodPlaces;

    if (_searchQuery.isNotEmpty) {
      filteredFoodPlaces = filteredFoodPlaces
          .where((food) =>
              food.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedTag != null) {
      filteredFoodPlaces = filteredFoodPlaces
          .where((food) => food.tags.contains(_selectedTag))
          .toList();
    }

    if (filteredFoodPlaces.isEmpty) {
      return _buildEmptyState('Không tìm thấy địa điểm ăn uống');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredFoodPlaces.length,
      itemBuilder: (context, index) {
        return _buildFoodPlaceCard(filteredFoodPlaces[index]);
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(Place place) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _selectPlace(place),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.place_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatter.format(place.avgCost),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2F80ED),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: place.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2F80ED),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodPlaceCard(FoodPlace food) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _selectFoodPlace(food),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatter.format(food.avgCost),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: food.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFFF6B6B),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectPlace(Place place) {
    const uuid = Uuid();
    final activity = Activity(
      id: uuid.v4(),
      name: place.name,
      type: ActivityType.place,
      cost: place.avgCost,
      time: '09:00',
      lat: place.lat,
      lng: place.lng,
      tags: place.tags,
      originalId: place.id,
    );

    Navigator.pop(context, activity);
  }

  void _selectFoodPlace(FoodPlace food) {
    const uuid = Uuid();
    final activity = Activity(
      id: uuid.v4(),
      name: food.name,
      type: ActivityType.food,
      cost: food.avgCost,
      time: '12:00',
      lat: food.lat,
      lng: food.lng,
      tags: food.tags,
      originalId: food.id,
    );

    Navigator.pop(context, activity);
  }
}
