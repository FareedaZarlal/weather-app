import 'package:flutter/foundation.dart';

import '../models/location.dart';
import '../models/weather_snapshot.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';

enum AppTab { weather, search, favorites }

class WeatherController extends ChangeNotifier {
  WeatherController({required this.service, required this.storage});

  final WeatherService service;
  final StorageService storage;

  AppTab tab = AppTab.weather;
  WeatherSnapshot? weather;
  Location location = Location.defaultLocation;
  List<Location> favorites = [];
  TemperatureUnit unit = TemperatureUnit.celsius;

  bool loading = true;
  bool isLive = false;
  bool offline = false;
  String? error;

  List<Location> results = [];
  bool searching = false;
  String? searchMessage;

  bool get isFavorite => favorites.any((f) => f.id == location.id);

  bool get isStale =>
      weather != null &&
      DateTime.now().difference(weather!.fetchedAt) >
          const Duration(minutes: 30);

  Future<void> init() async {
    final cache = await storage.loadCachedWeather();
    favorites = await storage.loadFavorites();

    if (cache != null) {
      weather = cache;
      location = cache.location;
      unit = cache.unit;
      loading = false;
    }

    notifyListeners();

    await loadWeather(location, unit, silent: cache != null);
  }

  void setTab(AppTab next) {
    if (tab == next) return;
    tab = next;
    notifyListeners();
  }

  /// Returns true when a fresh forecast was loaded.
  Future<bool> loadWeather(
    Location next,
    TemperatureUnit nextUnit, {
    bool silent = false,
  }) async {
    if (!silent) loading = true;

    error = null;
    notifyListeners();

    try {
      final snapshot = await service.fetchWeather(next, nextUnit);

      weather = snapshot;
      location = snapshot.location;
      unit = snapshot.unit;

      isLive = true;
      offline = false;

      await storage.saveCachedWeather(snapshot);

      return true;
    } on WeatherException catch (e) {
      isLive = false;
      offline = e.offline;

      if (e.offline) {
        // Look for a saved forecast belonging to this exact city.
        final cached = await storage.loadCachedWeatherForLocation(next.id);

        if (cached != null) {
          weather = cached;
          location = cached.location;
          unit = cached.unit;
          error =
              'You’re offline. Showing the saved forecast for ${next.name}.';
        } else {
          // Do not accidentally display another city's weather.
          weather = null;
          location = next;
          unit = nextUnit;
          error =
              'You’re offline. No saved forecast is available for ${next.name}.';
        }
      } else {
        location = next;
        error = e.message;
      }

      return false;
    } catch (_) {
      isLive = false;
      location = next;
      error = 'We couldn’t update the forecast.';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadWeather(location, unit);

  Future<void> chooseLocation(Location next) async {
    location = next;
    tab = AppTab.weather;
    results = [];
    searchMessage = null;

    notifyListeners();

    await loadWeather(next, unit);
  }

  Future<void> changeUnit(TemperatureUnit next) async {
    if (next == unit) return;

    // Only commit the new unit once the forecast in that unit has loaded.
    await loadWeather(location, next);
  }

  Future<void> search(String query) async {
    final clean = query.trim();

    if (clean.isEmpty) {
      results = [];
      searchMessage = 'Enter a city name to begin.';
      notifyListeners();
      return;
    }

    searching = true;
    searchMessage = null;
    notifyListeners();

    try {
      results = await service.searchLocations(clean);

      if (results.isEmpty) {
        searchMessage =
            'No cities found for “$clean”. Check the spelling and try again.';
      }
    } on WeatherException catch (e) {
      results = [];
      searchMessage = e.offline
          ? 'Search needs a connection. You can still open a saved city.'
          : e.message;
    } catch (_) {
      results = [];
      searchMessage = 'Search is unavailable right now.';
    } finally {
      searching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    results = [];
    searchMessage = null;
    notifyListeners();
  }

  Future<void> toggleFavorite(Location target) async {
    final exists = favorites.any((f) => f.id == target.id);

    favorites = exists
        ? favorites.where((f) => f.id != target.id).toList()
        : [...favorites, target];

    notifyListeners();

    await storage.saveFavorites(favorites);
  }
}
