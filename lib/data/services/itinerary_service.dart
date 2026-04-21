import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/activity.dart';
import '../models/place.dart';
import '../models/food_place.dart';
import '../models/trip.dart';
import 'data_service.dart';

class ItineraryService {
  static const uuid = Uuid();

  // Auto generate lịch trình cho chuyến đi với thuật toán thông minh
  static Future<Trip> generateTrip({
    required String destination,
    required int numberOfDays,
    required DateTime startDate,
  }) async {
    print('🚀 Generating trip for: $destination');
    
    // STEP 1: Get AI-ranked places for the specific province ONLY
    final places = await DataService.getPlacesByProvince(destination);
    
    if (places.isEmpty) {
      throw Exception('Không tìm thấy địa điểm nào cho "$destination". Vui lòng kiểm tra tên tỉnh/thành phố.');
    }
    
    // STEP 2: Get food places from the same province ONLY
    final region = DataService.detectRegion(destination);
    final regionData = await DataService.loadRegionData(region);
    final provinces = regionData['provinces'] as List;
    
    // Normalize province name for matching (support both province name and city name)
    final normalizedInput = DataService.normalizeVietnamese(destination.toLowerCase());
    final province = provinces.firstWhere(
      (p) {
        final provinceName = p['name'] as String;
        final cityName = p['city'] as String?;
        final searchTerms = p['search_terms'] as List?;
        
        final normalizedProvince = DataService.normalizeVietnamese(provinceName.toLowerCase());
        final normalizedCity = cityName != null ? DataService.normalizeVietnamese(cityName.toLowerCase()) : '';
        
        // Match by province name, city name, or search terms
        if (normalizedProvince == normalizedInput ||
            normalizedProvince.contains(normalizedInput) ||
            normalizedInput.contains(normalizedProvince)) {
          return true;
        }
        
        if (cityName != null && (normalizedCity == normalizedInput ||
            normalizedCity.contains(normalizedInput) ||
            normalizedInput.contains(normalizedCity))) {
          return true;
        }
        
        if (searchTerms != null) {
          for (var term in searchTerms) {
            final normalizedTerm = DataService.normalizeVietnamese(term.toString().toLowerCase());
            if (normalizedTerm == normalizedInput ||
                normalizedTerm.contains(normalizedInput) ||
                normalizedInput.contains(normalizedTerm)) {
              return true;
            }
          }
        }
        
        return false;
      },
      orElse: () => null,
    );
    
    if (province == null) {
      throw Exception('Không tìm thấy tỉnh/thành phố "$destination"');
    }
    
    final placesJson = province['places'] as List;
    final foodPlaces = placesJson
        .where((p) => p['category'] == 'an_uong')
        .map((p) => FoodPlace.fromJson(p))
        .toList();
    
    if (foodPlaces.isEmpty) {
      throw Exception('Không tìm thấy địa điểm ăn uống nào cho "$destination"');
    }
    
    print('✅ Found ${places.length} places and ${foodPlaces.length} food places in ${province['name']}');

    final List<List<Activity>> dailyActivities = [];

    // Tạo lịch trình thông minh cho từng ngày
    for (int day = 0; day < numberOfDays; day++) {
      final dayActivities = _generateSmartDayActivities(
        places: places,
        foodPlaces: foodPlaces,
        dayIndex: day,
        previousDayActivities: day > 0 ? dailyActivities[day - 1] : null,
      );
      dailyActivities.add(dayActivities);
    }

    return Trip(
      id: uuid.v4(),
      destination: province['name'] as String, // Use exact province name from JSON
      numberOfDays: numberOfDays,
      startDate: startDate,
      dailyActivities: dailyActivities,
      createdAt: DateTime.now(),
    );
  }

  // Generate activities thông minh cho 1 ngày
  static List<Activity> _generateSmartDayActivities({
    required List<Place> places,
    required List<FoodPlace> foodPlaces,
    required int dayIndex,
    List<Activity>? previousDayActivities,
  }) {
    final List<Activity> activities = [];
    final random = Random(dayIndex);
    final usedPlaceIds = <String>{};
    final usedFoodIds = <String>{};

    // Lấy địa điểm cuối cùng của ngày hôm trước (nếu có)
    Activity? lastActivity = previousDayActivities?.isNotEmpty == true
        ? previousDayActivities!.last
        : null;

    // Sáng: Place (8:00 - 11:00)
    final morningPlace = _selectSmartPlace(
      places: places,
      usedIds: usedPlaceIds,
      preferredTags: ['biển', 'núi', 'thiên nhiên', 'check-in'],
      lastLocation: lastActivity,
      random: random,
    );
    activities.add(_createActivityFromPlace(morningPlace, '08:00'));
    usedPlaceIds.add(morningPlace.id);

    // Trưa: Food gần với địa điểm sáng (12:00 - 13:30)
    final lunchFood = _selectSmartFood(
      foodPlaces: foodPlaces,
      usedIds: usedFoodIds,
      preferredTags: ['đặc sản', 'bình dân', 'hải sản'],
      nearLocation: activities.last,
      random: random,
    );
    activities.add(_createActivityFromFood(lunchFood, '12:00'));
    usedFoodIds.add(lunchFood.id);

    // Chiều: Place gần với địa điểm trưa (14:00 - 17:00)
    final afternoonPlace = _selectSmartPlace(
      places: places,
      usedIds: usedPlaceIds,
      preferredTags: ['văn hóa', 'check-in', 'vui chơi'],
      lastLocation: activities.last,
      random: random,
    );
    activities.add(_createActivityFromPlace(afternoonPlace, '14:00'));
    usedPlaceIds.add(afternoonPlace.id);

    // Tối: Food gần với địa điểm chiều (18:00 - 20:00)
    final dinnerFood = _selectSmartFood(
      foodPlaces: foodPlaces,
      usedIds: usedFoodIds,
      preferredTags: ['cao cấp', 'nhậu', 'cafe'],
      nearLocation: activities.last,
      random: random,
    );
    activities.add(_createActivityFromFood(dinnerFood, '18:00'));
    usedFoodIds.add(dinnerFood.id);

    return activities;
  }

  // Chọn Place thông minh dựa trên tags và khoảng cách
  static Place _selectSmartPlace({
    required List<Place> places,
    required Set<String> usedIds,
    required List<String> preferredTags,
    Activity? lastLocation,
    required Random random,
  }) {
    // Lọc các địa điểm chưa dùng
    var availablePlaces = places.where((p) => !usedIds.contains(p.id)).toList();

    if (availablePlaces.isEmpty) {
      availablePlaces = places;
    }

    // Ưu tiên địa điểm có tags phù hợp
    var preferredPlaces = availablePlaces.where((place) {
      return place.tags.any((tag) => preferredTags.contains(tag));
    }).toList();

    if (preferredPlaces.isEmpty) {
      preferredPlaces = availablePlaces;
    }

    // Nếu có vị trí trước đó, ưu tiên địa điểm gần
    if (lastLocation != null && preferredPlaces.length > 3) {
      preferredPlaces.sort((a, b) {
        final distA = calculateDistance(
          lastLocation.lat,
          lastLocation.lng,
          a.lat,
          a.lng,
        );
        final distB = calculateDistance(
          lastLocation.lat,
          lastLocation.lng,
          b.lat,
          b.lng,
        );
        return distA.compareTo(distB);
      });

      // Chọn trong top 3 gần nhất để có sự đa dạng
      final topNear = preferredPlaces.take(3).toList();
      return topNear[random.nextInt(topNear.length)];
    }

    return preferredPlaces[random.nextInt(preferredPlaces.length)];
  }

  // Chọn Food thông minh dựa trên tags và khoảng cách
  static FoodPlace _selectSmartFood({
    required List<FoodPlace> foodPlaces,
    required Set<String> usedIds,
    required List<String> preferredTags,
    Activity? nearLocation,
    required Random random,
  }) {
    // Lọc các địa điểm chưa dùng
    var availableFoods = foodPlaces.where((f) => !usedIds.contains(f.id)).toList();

    if (availableFoods.isEmpty) {
      availableFoods = foodPlaces;
    }

    // Ưu tiên địa điểm có tags phù hợp
    var preferredFoods = availableFoods.where((food) {
      return food.tags.any((tag) => preferredTags.contains(tag));
    }).toList();

    if (preferredFoods.isEmpty) {
      preferredFoods = availableFoods;
    }

    // Nếu có vị trí gần, ưu tiên địa điểm gần
    if (nearLocation != null && preferredFoods.length > 3) {
      preferredFoods.sort((a, b) {
        final distA = calculateDistance(
          nearLocation.lat,
          nearLocation.lng,
          a.lat,
          a.lng,
        );
        final distB = calculateDistance(
          nearLocation.lat,
          nearLocation.lng,
          b.lat,
          b.lng,
        );
        return distA.compareTo(distB);
      });

      // Chọn trong top 3 gần nhất
      final topNear = preferredFoods.take(3).toList();
      return topNear[random.nextInt(topNear.length)];
    }

    return preferredFoods[random.nextInt(preferredFoods.length)];
  }

  // Helper: Tạo Activity từ Place
  static Activity _createActivityFromPlace(Place place, String time) {
    return Activity(
      id: uuid.v4(),
      name: place.name,
      type: ActivityType.place,
      cost: place.avgCost,
      time: time,
      lat: place.lat,
      lng: place.lng,
      tags: place.tags,
      originalId: place.id,
    );
  }

  // Helper: Tạo Activity từ FoodPlace
  static Activity _createActivityFromFood(FoodPlace food, String time) {
    return Activity(
      id: uuid.v4(),
      name: food.name,
      type: ActivityType.food,
      cost: food.avgCost,
      time: time,
      lat: food.lat,
      lng: food.lng,
      tags: food.tags,
      originalId: food.id,
    );
  }

  // Tính khoảng cách giữa 2 điểm (Haversine formula)
  static double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371; // km

    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }

  // Tìm các địa điểm gần nhau (trong bán kính km)
  static Future<List<dynamic>> findNearbyPlaces(
    Activity activity,
    double radiusKm,
  ) async {
    final places = await DataService.loadPlaces();
    final foodPlaces = await DataService.loadFoodPlaces();
    final List<dynamic> nearbyPlaces = [];

    // Tìm places gần
    for (var place in places) {
      if (place.id == activity.originalId) continue;
      final distance = calculateDistance(
        activity.lat,
        activity.lng,
        place.lat,
        place.lng,
      );
      if (distance <= radiusKm) {
        nearbyPlaces.add({
          'type': 'place',
          'data': place,
          'distance': distance,
        });
      }
    }

    // Tìm food places gần
    for (var food in foodPlaces) {
      if (food.id == activity.originalId) continue;
      final distance = calculateDistance(
        activity.lat,
        activity.lng,
        food.lat,
        food.lng,
      );
      if (distance <= radiusKm) {
        nearbyPlaces.add({
          'type': 'food',
          'data': food,
          'distance': distance,
        });
      }
    }

    // Sắp xếp theo khoảng cách
    nearbyPlaces.sort((a, b) => 
      (a['distance'] as double).compareTo(b['distance'] as double)
    );

    return nearbyPlaces;
  }
}
