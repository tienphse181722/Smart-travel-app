import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/place.dart';
import '../models/food_place.dart';

class DataService {
  static Map<String, dynamic>? _northData;
  static Map<String, dynamic>? _centralData;
  static Map<String, dynamic>? _southData;

  // STEP 2: PROVINCE DETECTION - Detect which region a province belongs to
  static String detectRegion(String provinceName) {
    final normalized = normalizeVietnamese(provinceName.toLowerCase());
    
    final northProvinces = [
      'Hà Nội', 'Hải Phòng', 'Quảng Ninh', 'Lào Cai', 'Yên Bái', 'Hà Giang',
      'Thái Bình', 'Hòa Bình', 'Sơn La', 'Lai Châu', 'Điện Biên', 'Phú Thọ',
      'Tuyên Quang', 'Bắc Kạn', 'Lạng Sơn', 'Cao Bằng', 'Bắc Giang', 'Bắc Ninh',
      'Hải Dương', 'Hưng Yên', 'Ninh Bình', 'Nam Định', 'Thái Nguyên', 'Vĩnh Phúc'
    ];
    
    final centralProvinces = [
      'Hà Tĩnh', 'Quảng Bình', 'Quảng Trị', 'Thừa Thiên Huế', 'Đà Nẵng',
      'Quảng Nam', 'Quảng Ngãi', 'Bình Định', 'Phú Yên', 'Khánh Hòa',
      'Ninh Thuận', 'Bình Thuận', 'Gia Lai', 'Kon Tum', 'Đắk Lắk', 'Đắk Nông', 'Lâm Đồng'
    ];
    
    // Check with normalized names
    for (var p in northProvinces) {
      if (normalizeVietnamese(p.toLowerCase()) == normalized ||
          normalized.contains(normalizeVietnamese(p.toLowerCase()))) {
        return 'north';
      }
    }
    
    for (var p in centralProvinces) {
      if (normalizeVietnamese(p.toLowerCase()) == normalized ||
          normalized.contains(normalizeVietnamese(p.toLowerCase()))) {
        return 'central';
      }
    }
    
    return 'south';
  }
  
  // Helper: Normalize Vietnamese text (remove diacritics) - PUBLIC
  static String normalizeVietnamese(String text) {
    const vietnamese = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const normalized = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    
    var result = text;
    for (var i = 0; i < vietnamese.length; i++) {
      result = result.replaceAll(vietnamese[i], normalized[i]);
    }
    return result;
  }

  // STEP 3: LOAD JSON - Load only the required region file
  static Future<Map<String, dynamic>> loadRegionData(String region) async {
    if (region == 'north' && _northData != null) return _northData!;
    if (region == 'central' && _centralData != null) return _centralData!;
    if (region == 'south' && _southData != null) return _southData!;

    String filePath;
    if (region == 'north') {
      filePath = 'assets/data/vietnam_mien_bac.json';
    } else if (region == 'central') {
      filePath = 'assets/data/vietnam_mien_trung.json';
    } else {
      filePath = 'assets/data/vietnam_mien_nam.json';
    }

    final String response = await rootBundle.loadString(filePath);
    final data = json.decode(response) as Map<String, dynamic>;

    if (region == 'north') _northData = data;
    if (region == 'central') _centralData = data;
    if (region == 'south') _southData = data;

    return data;
  }

  // STEP 4 & 5: FILTER EXACT PROVINCE & FETCH PLACES
  // STEP 6: AI RANKING (sort by rating, hot_trend tags)
  static Future<List<Place>> getPlacesByProvince(String provinceName) async {
    // Step 2: Detect region
    final region = detectRegion(provinceName);
    
    // Step 3: Load only that region's JSON
    final regionData = await loadRegionData(region);
    
    // Step 4: Filter exact province (with normalized comparison)
    final provinces = regionData['provinces'] as List;
    final normalizedInput = normalizeVietnamese(provinceName.toLowerCase());
    
    final province = provinces.firstWhere(
      (p) {
        final provinceName = p['name'] as String;
        final cityName = p['city'] as String?;
        final searchTerms = p['search_terms'] as List?;
        
        final normalizedProvince = normalizeVietnamese(provinceName.toLowerCase());
        final normalizedCity = cityName != null ? normalizeVietnamese(cityName.toLowerCase()) : '';
        
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
            final normalizedTerm = normalizeVietnamese(term.toString().toLowerCase());
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
      print('⚠️ Province not found: $provinceName (normalized: $normalizedInput)');
      return [];
    }
    
    print('✅ Found province: ${province['name']} (${province['city']}) in region: $region');
    
    // Step 5: Fetch places only in that province
    final placesJson = province['places'] as List;
    final places = placesJson.map((p) => Place.fromJson(p)).toList();
    
    print('✅ Loaded ${places.length} places from ${province['name']}');
    
    // Step 6: AI RANKING - Sort by hot_trend and rating (NO NEW DATA)
    places.sort((a, b) {
      // Priority 1: hot_trend tag
      final aHasHotTrend = a.tags.contains('hot_trend');
      final bHasHotTrend = b.tags.contains('hot_trend');
      if (aHasHotTrend && !bHasHotTrend) return -1;
      if (!aHasHotTrend && bHasHotTrend) return 1;
      
      // Priority 2: di_san_the_gioi tag
      final aHasWorldHeritage = a.tags.contains('di_san_the_gioi');
      final bHasWorldHeritage = b.tags.contains('di_san_the_gioi');
      if (aHasWorldHeritage && !bHasWorldHeritage) return -1;
      if (!aHasWorldHeritage && bHasWorldHeritage) return 1;
      
      // Priority 3: Alphabetical
      return a.name.compareTo(b.name);
    });
    
    return places;
  }

  // NEW: Get province suggestions based on input (search by province name, city name, or search terms)
  static Future<List<Map<String, String>>> getProvinceSuggestions(String query) async {
    if (query.isEmpty) return [];
    
    final normalizedQuery = normalizeVietnamese(query.toLowerCase());
    final List<Map<String, String>> suggestions = [];
    
    // Load all regions
    for (var region in ['north', 'central', 'south']) {
      final regionData = await loadRegionData(region);
      final provinces = regionData['provinces'] as List;
      
      for (var province in provinces) {
        final provinceName = province['name'] as String;
        final cityName = province['city'] as String?;
        final searchTerms = province['search_terms'] as List?;
        
        final normalizedProvince = normalizeVietnamese(provinceName.toLowerCase());
        final normalizedCity = cityName != null ? normalizeVietnamese(cityName.toLowerCase()) : '';
        
        bool matches = false;
        
        // Check province name
        if (normalizedProvince.contains(normalizedQuery)) {
          matches = true;
        }
        
        // Check city name
        if (cityName != null && normalizedCity.contains(normalizedQuery)) {
          matches = true;
        }
        
        // Check search terms
        if (searchTerms != null) {
          for (var term in searchTerms) {
            final normalizedTerm = normalizeVietnamese(term.toString().toLowerCase());
            if (normalizedTerm.contains(normalizedQuery)) {
              matches = true;
              break;
            }
          }
        }
        
        if (matches) {
          suggestions.add({
            'province': provinceName,
            'city': cityName ?? provinceName,
            'display': cityName != null ? '$provinceName ($cityName)' : provinceName,
          });
        }
      }
    }
    
    return suggestions;
  }

  // Load all places (for backward compatibility)
  static Future<List<Place>> loadPlaces() async {
    final List<Place> allPlaces = [];
    
    for (var region in ['north', 'central', 'south']) {
      final regionData = await loadRegionData(region);
      allPlaces.addAll(_extractPlaces(regionData));
    }
    
    return allPlaces;
  }

  // Extract places from JSON structure
  static List<Place> _extractPlaces(Map<String, dynamic> regionData) {
    final List<Place> places = [];
    final provinces = regionData['provinces'] as List;
    
    for (var province in provinces) {
      final provincePlaces = province['places'] as List;
      for (var place in provincePlaces) {
        places.add(Place.fromJson(place));
      }
    }
    
    return places;
  }

  // Load food places (category = "an_uong")
  static Future<List<FoodPlace>> loadFoodPlaces() async {
    final List<FoodPlace> allFoodPlaces = [];
    
    for (var region in ['north', 'central', 'south']) {
      final regionData = await loadRegionData(region);
      allFoodPlaces.addAll(_extractFoodPlaces(regionData));
    }
    
    return allFoodPlaces;
  }

  // Extract food places from JSON structure
  static List<FoodPlace> _extractFoodPlaces(Map<String, dynamic> regionData) {
    final List<FoodPlace> foodPlaces = [];
    final provinces = regionData['provinces'] as List;
    
    for (var province in provinces) {
      final provincePlaces = province['places'] as List;
      for (var place in provincePlaces) {
        if (place['category'] == 'an_uong') {
          foodPlaces.add(FoodPlace.fromJson(place));
        }
      }
    }
    
    return foodPlaces;
  }

  // Search places theo tên
  static Future<List<Place>> searchPlaces(String query) async {
    final places = await loadPlaces();
    if (query.isEmpty) return places;
    
    return places
        .where((place) =>
            place.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Search food places theo tên
  static Future<List<FoodPlace>> searchFoodPlaces(String query) async {
    final foodPlaces = await loadFoodPlaces();
    if (query.isEmpty) return foodPlaces;
    
    return foodPlaces
        .where((food) =>
            food.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Filter places theo tag
  static Future<List<Place>> filterPlacesByTag(String tag) async {
    final places = await loadPlaces();
    return places.where((place) => place.tags.contains(tag)).toList();
  }

  // Filter food places theo tag
  static Future<List<FoodPlace>> filterFoodPlacesByTag(String tag) async {
    final foodPlaces = await loadFoodPlaces();
    return foodPlaces.where((food) => food.tags.contains(tag)).toList();
  }

  // Get all unique tags từ places
  static Future<List<String>> getPlaceTags() async {
    final places = await loadPlaces();
    final Set<String> tags = {};
    for (var place in places) {
      tags.addAll(place.tags);
    }
    return tags.toList()..sort();
  }

  // Get all unique tags từ food places
  static Future<List<String>> getFoodTags() async {
    final foodPlaces = await loadFoodPlaces();
    final Set<String> tags = {};
    for (var food in foodPlaces) {
      tags.addAll(food.tags);
    }
    return tags.toList()..sort();
  }
}
