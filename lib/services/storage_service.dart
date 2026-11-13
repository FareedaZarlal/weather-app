import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/location.dart';
import '../models/weather_snapshot.dart';

class StorageService {
  static const _weatherKey = 'skycast:last-weather';
  static const _cityWeatherKey = 'skycast:weather:';
  static const _favoritesKey = 'skycast:favorites';

  String _keyForLocation(String locationId) {
    return '$_cityWeatherKey${Uri.encodeComponent(locationId)}';
  }

  Future<WeatherSnapshot?> loadCachedWeather() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_weatherKey);

      if (raw == null) return null;

      final snapshot = WeatherSnapshot.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );

      // Migrate an older single-city cache to the new per-city cache.
      await saveCachedWeather(snapshot);

      return snapshot;
    } catch (_) {
      return null;
    }
  }

  Future<WeatherSnapshot?> loadCachedWeatherForLocation(
    String locationId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyForLocation(locationId));

      if (raw == null) return null;

      final snapshot = WeatherSnapshot.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );

      // Make sure the cached forecast belongs to the requested city.
      if (snapshot.location.id != locationId) return null;

      return snapshot;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCachedWeather(WeatherSnapshot weather) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(weather.toJson());

      // Save this city's forecast separately.
      await prefs.setString(_keyForLocation(weather.location.id), encoded);

      // Keep the latest forecast for app startup.
      await prefs.setString(_weatherKey, encoded);
    } catch (_) {
      // The live forecast still works without persistence.
    }
  }

  Future<List<Location>> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_favoritesKey);

      if (raw == null) return [];

      return (jsonDecode(raw) as List)
          .map((e) => Location.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveFavorites(List<Location> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        _favoritesKey,
        jsonEncode(favorites.map((e) => e.toJson()).toList()),
      );
    } catch (_) {
      // Favoriting stays usable for the current session.
    }
  }
}
