import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/place.dart';
import '../models/food_place.dart';

class DataService {
  static List<Place>? _places;
  static List<FoodPlace>? _foodPlaces;

  // Load places từ JSON
  static Future<List<Place>> loadPlaces() async {
    if (_places != null) return _places!;

    final String response =
        await rootBundle.loadString('assets/data/places.json');
    final List<dynamic> data = json.decode(response);
    _places = data.map((json) => Place.fromJson(json)).toList();
    return _places!;
  }

  // Load food places từ JSON
  static Future<List<FoodPlace>> loadFoodPlaces() async {
    if (_foodPlaces != null) return _foodPlaces!;

    final String response =
        await rootBundle.loadString('assets/data/foods.json');
    final List<dynamic> data = json.decode(response);
    _foodPlaces = data.map((json) => FoodPlace.fromJson(json)).toList();
    return _foodPlaces!;
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
