import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cache_service.dart';

class SearchResult {
  final String name;
  final double lat;
  final double lng;
  final String displayName;
  final String source; // 'nominatim' hoặc 'google'

  SearchResult({
    required this.name,
    required this.lat,
    required this.lng,
    required this.displayName,
    required this.source,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat': lat,
      'lng': lng,
      'displayName': displayName,
      'source': source,
    };
  }

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      displayName: json['displayName'] as String,
      source: json['source'] as String,
    );
  }
}

class SearchService {
  static const String _nominatimUrl = 'https://nominatim.openstreetmap.org/search';
  static const String _photonUrl = 'https://photon.komoot.io/api/';
  
  // Google Places API key (optional - chỉ dùng khi Nominatim fail)
  static String? _googleApiKey;
  
  static void setGoogleApiKey(String? apiKey) {
    _googleApiKey = apiKey;
  }

  // Tìm kiếm địa điểm với 2-tier system
  static Future<List<SearchResult>> searchPlace(String query, {
    double? lat,
    double? lng,
    int limit = 5,
  }) async {
    if (query.trim().isEmpty) return [];

    // 1. Kiểm tra cache trước
    final cached = await CacheService.getCachedSearch(query);
    if (cached != null) {
      print('✅ Cache hit for: $query');
      return (cached['results'] as List)
          .map((r) => SearchResult.fromJson(r))
          .toList();
    }

    print('❌ Cache miss for: $query');

    // 2. Thử Nominatim (FREE) trước
    try {
      final results = await _searchWithNominatim(query, lat: lat, lng: lng, limit: limit);
      if (results.isNotEmpty) {
        print('✅ Nominatim success: ${results.length} results');
        await _cacheResults(query, results);
        return results;
      }
    } catch (e) {
      print('⚠️ Nominatim failed: $e');
    }

    // 3. Thử Photon (FREE) nếu Nominatim fail
    try {
      final results = await _searchWithPhoton(query, lat: lat, lng: lng, limit: limit);
      if (results.isNotEmpty) {
        print('✅ Photon success: ${results.length} results');
        await _cacheResults(query, results);
        return results;
      }
    } catch (e) {
      print('⚠️ Photon failed: $e');
    }

    // 4. Fallback sang Google Places API (PAID) nếu có API key
    if (_googleApiKey != null && _googleApiKey!.isNotEmpty) {
      try {
        final results = await _searchWithGoogle(query, lat: lat, lng: lng, limit: limit);
        if (results.isNotEmpty) {
          print('✅ Google Places success: ${results.length} results');
          await _cacheResults(query, results);
          return results;
        }
      } catch (e) {
        print('⚠️ Google Places failed: $e');
      }
    }

    print('❌ All search services failed');
    return [];
  }

  // Tìm kiếm với Nominatim (OpenStreetMap)
  static Future<List<SearchResult>> _searchWithNominatim(
    String query, {
    double? lat,
    double? lng,
    int limit = 5,
  }) async {
    final params = {
      'q': query,
      'format': 'json',
      'limit': limit.toString(),
      'addressdetails': '1',
    };

    // Ưu tiên kết quả gần vị trí hiện tại
    if (lat != null && lng != null) {
      params['lat'] = lat.toString();
      params['lon'] = lng.toString();
    }

    final uri = Uri.parse(_nominatimUrl).replace(queryParameters: params);
    
    final response = await http.get(
      uri,
      headers: {
        'User-Agent': 'SmartTravelApp/1.0',
        'Accept-Language': 'vi,en',
      },
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) {
        return SearchResult(
          name: item['name'] ?? item['display_name'] ?? 'Unknown',
          lat: double.parse(item['lat']),
          lng: double.parse(item['lon']),
          displayName: item['display_name'] ?? '',
          source: 'nominatim',
        );
      }).toList();
    }

    throw Exception('Nominatim API error: ${response.statusCode}');
  }

  // Tìm kiếm với Photon (alternative free service)
  static Future<List<SearchResult>> _searchWithPhoton(
    String query, {
    double? lat,
    double? lng,
    int limit = 5,
  }) async {
    final params = {
      'q': query,
      'limit': limit.toString(),
      'lang': 'vi',
    };

    if (lat != null && lng != null) {
      params['lat'] = lat.toString();
      params['lon'] = lng.toString();
    }

    final uri = Uri.parse(_photonUrl).replace(queryParameters: params);
    
    final response = await http.get(uri).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> features = data['features'] ?? [];
      
      return features.map((feature) {
        final props = feature['properties'];
        final coords = feature['geometry']['coordinates'];
        
        return SearchResult(
          name: props['name'] ?? props['street'] ?? 'Unknown',
          lat: coords[1].toDouble(),
          lng: coords[0].toDouble(),
          displayName: props['name'] ?? '',
          source: 'photon',
        );
      }).toList();
    }

    throw Exception('Photon API error: ${response.statusCode}');
  }

  // Tìm kiếm với Google Places API (fallback)
  static Future<List<SearchResult>> _searchWithGoogle(
    String query, {
    double? lat,
    double? lng,
    int limit = 5,
  }) async {
    if (_googleApiKey == null || _googleApiKey!.isEmpty) {
      throw Exception('Google API key not set');
    }

    final params = {
      'input': query,
      'key': _googleApiKey!,
      'language': 'vi',
    };

    if (lat != null && lng != null) {
      params['location'] = '$lat,$lng';
      params['radius'] = '50000'; // 50km
    }

    final uri = Uri.parse('https://maps.googleapis.com/maps/api/place/autocomplete/json')
        .replace(queryParameters: params);
    
    final response = await http.get(uri).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data['status'] != 'OK') {
        throw Exception('Google API error: ${data['status']}');
      }

      final List<dynamic> predictions = data['predictions'] ?? [];
      final results = <SearchResult>[];

      // Lấy chi tiết từng địa điểm để có lat/lng
      for (var prediction in predictions.take(limit)) {
        try {
          final placeId = prediction['place_id'];
          final details = await _getGooglePlaceDetails(placeId);
          if (details != null) {
            results.add(details);
          }
        } catch (e) {
          print('Error getting place details: $e');
        }
      }

      return results;
    }

    throw Exception('Google API error: ${response.statusCode}');
  }

  // Lấy chi tiết địa điểm từ Google Places
  static Future<SearchResult?> _getGooglePlaceDetails(String placeId) async {
    if (_googleApiKey == null || _googleApiKey!.isEmpty) return null;

    final params = {
      'place_id': placeId,
      'key': _googleApiKey!,
      'fields': 'name,geometry,formatted_address',
      'language': 'vi',
    };

    final uri = Uri.parse('https://maps.googleapis.com/maps/api/place/details/json')
        .replace(queryParameters: params);
    
    final response = await http.get(uri).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data['status'] == 'OK') {
        final result = data['result'];
        final location = result['geometry']['location'];
        
        return SearchResult(
          name: result['name'] ?? 'Unknown',
          lat: location['lat'].toDouble(),
          lng: location['lng'].toDouble(),
          displayName: result['formatted_address'] ?? '',
          source: 'google',
        );
      }
    }

    return null;
  }

  // Cache kết quả tìm kiếm
  static Future<void> _cacheResults(String query, List<SearchResult> results) async {
    final cacheData = {
      'results': results.map((r) => r.toJson()).toList(),
    };
    await CacheService.cacheSearchResult(query, cacheData);
  }

  // Lấy thống kê sử dụng API
  static Future<Map<String, dynamic>> getUsageStats() async {
    final cacheStats = await CacheService.getCacheStats();
    return {
      'cache': cacheStats,
      'message': 'Cache giúp giảm ${cacheStats['valid']} API calls',
    };
  }
}
