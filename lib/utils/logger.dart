import 'package:flutter/foundation.dart';

class AppLogger {
  static const String _prefix = '🗺️ SmartTravel';

  // Log levels
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix $tagStr 🔍 $message');
    }
  }

  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix $tagStr ℹ️ $message');
    }
  }

  static void success(String message, [String? tag]) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix $tagStr ✅ $message');
    }
  }

  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix $tagStr ⚠️ $message');
    }
  }

  static void error(String message, [String? tag, Object? error]) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix $tagStr ❌ $message');
      if (error != null) {
        debugPrint('Error details: $error');
      }
    }
  }

  // Cache specific logs
  static void cacheHit(String query) {
    success('Cache hit for: $query', 'Cache');
  }

  static void cacheMiss(String query) {
    info('Cache miss for: $query', 'Cache');
  }

  // Search specific logs
  static void searchSuccess(String service, int resultCount) {
    success('$service success: $resultCount results', 'Search');
  }

  static void searchFailed(String service, String reason) {
    warning('$service failed: $reason', 'Search');
  }

  // Route specific logs
  static void routeCalculated(double distance, Duration duration) {
    success('Route calculated: ${distance.toStringAsFixed(1)}km, ${duration.inMinutes}min', 'Route');
  }

  static void routeOptimized(int pointCount) {
    success('Route optimized for $pointCount points', 'Route');
  }
}
