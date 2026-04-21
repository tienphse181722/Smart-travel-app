import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _searchCacheKey = 'search_cache';
  static const Duration _cacheExpiry = Duration(days: 7);

  // Lưu kết quả tìm kiếm vào cache
  static Future<void> cacheSearchResult(String query, Map<String, dynamic> result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cache = await _getCache();
      
      cache[query.toLowerCase()] = {
        'result': result,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await prefs.setString(_searchCacheKey, jsonEncode(cache));
    } catch (e) {
      print('Error caching search result: $e');
    }
  }

  // Lấy kết quả từ cache
  static Future<Map<String, dynamic>?> getCachedSearch(String query) async {
    try {
      final cache = await _getCache();
      final cached = cache[query.toLowerCase()];

      if (cached == null) return null;

      // Kiểm tra expiry
      final timestamp = DateTime.parse(cached['timestamp'] as String);
      if (DateTime.now().difference(timestamp) > _cacheExpiry) {
        // Cache đã hết hạn
        await _removeCachedItem(query);
        return null;
      }

      return cached['result'] as Map<String, dynamic>;
    } catch (e) {
      print('Error getting cached search: $e');
      return null;
    }
  }

  // Lấy toàn bộ cache
  static Future<Map<String, dynamic>> _getCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheString = prefs.getString(_searchCacheKey);
      
      if (cacheString == null) return {};
      
      return Map<String, dynamic>.from(jsonDecode(cacheString));
    } catch (e) {
      print('Error getting cache: $e');
      return {};
    }
  }

  // Xóa 1 item khỏi cache
  static Future<void> _removeCachedItem(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cache = await _getCache();
      cache.remove(query.toLowerCase());
      await prefs.setString(_searchCacheKey, jsonEncode(cache));
    } catch (e) {
      print('Error removing cached item: $e');
    }
  }

  // Xóa toàn bộ cache
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_searchCacheKey);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Lấy thống kê cache
  static Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final cache = await _getCache();
      int validCount = 0;
      int expiredCount = 0;

      for (var entry in cache.values) {
        final timestamp = DateTime.parse(entry['timestamp'] as String);
        if (DateTime.now().difference(timestamp) > _cacheExpiry) {
          expiredCount++;
        } else {
          validCount++;
        }
      }

      return {
        'total': cache.length,
        'valid': validCount,
        'expired': expiredCount,
      };
    } catch (e) {
      print('Error getting cache stats: $e');
      return {'total': 0, 'valid': 0, 'expired': 0};
    }
  }

  // Dọn dẹp cache hết hạn
  static Future<void> cleanExpiredCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cache = await _getCache();
      final newCache = <String, dynamic>{};

      for (var entry in cache.entries) {
        final timestamp = DateTime.parse(entry.value['timestamp'] as String);
        if (DateTime.now().difference(timestamp) <= _cacheExpiry) {
          newCache[entry.key] = entry.value;
        }
      }

      await prefs.setString(_searchCacheKey, jsonEncode(newCache));
    } catch (e) {
      print('Error cleaning expired cache: $e');
    }
  }
}
