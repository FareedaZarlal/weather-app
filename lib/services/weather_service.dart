import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/location.dart';
import '../models/weather_snapshot.dart';

class WeatherException implements Exception {
  final String message;

  /// True when the failure looks like a connectivity problem.
  final bool offline;

  const WeatherException(this.message, {this.offline = false});

  @override
  String toString() => message;
}

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  static const _timeout = Duration(seconds: 10);
  final http.Client _client;

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode != 200) {
        throw WeatherException(
          'Weather service returned ${response.statusCode}.',
        );
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on WeatherException {
      rethrow;
    } on TimeoutException {
      throw const WeatherException(
        'The weather service took too long to respond. Please retry.',
      );
    } on FormatException {
      throw const WeatherException(
        'The weather service sent an unreadable response.',
      );
    } catch (_) {
      // SocketException / ClientException / TLS errors → connectivity problem.
      throw const WeatherException(
        'Couldn’t reach the weather service. Check your connection.',
        offline: true,
      );
    }
  }

  Future<List<Location>> searchLocations(String query) async {
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': query,
      'count': '8',
      'language': 'en',
      'format': 'json',
    });
    final json = await _getJson(uri);
    final results = (json['results'] as List?) ?? const [];
    return results.map((raw) {
      final r = raw as Map<String, dynamic>;
      return Location(
        id: '${r['id']}',
        name: r['name'] as String,
        region: r['admin1'] as String?,
        country: (r['country'] as String?) ?? '',
        latitude: (r['latitude'] as num).toDouble(),
        longitude: (r['longitude'] as num).toDouble(),
        timezone: (r['timezone'] as String?) ?? 'UTC',
      );
    }).toList();
  }

  Future<WeatherSnapshot> fetchWeather(
    Location location,
    TemperatureUnit unit,
  ) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '${location.latitude}',
      'longitude': '${location.longitude}',
      'current': 'temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code,is_day',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,uv_index_max,sunrise',
      'temperature_unit': unit.apiName,
      'wind_speed_unit': 'kmh',
      'timezone': 'auto',
      'forecast_days': '7',
    });
    final json = await _getJson(uri);
    final current = json['current'] as Map<String, dynamic>?;
    final daily = json['daily'] as Map<String, dynamic>?;
    final times = (daily?['time'] as List?) ?? const [];
    if (current == null || daily == null || times.isEmpty) {
      throw const WeatherException(
        'The weather service returned an incomplete forecast.',
      );
    }

    num? at(String key, int i) {
      final list = daily[key] as List?;
      if (list == null || i >= list.length) return null;
      return list[i] as num?;
    }

    final timezone = (json['timezone'] as String?) ?? location.timezone;
    final sunrises = daily['sunrise'] as List?;

    return WeatherSnapshot(
      location: location.copyWith(timezone: timezone),
      timezone: timezone,
      utcOffsetSeconds: (json['utc_offset_seconds'] as num?)?.toInt() ?? 0,
      unit: unit,
      fetchedAt: DateTime.now(),
      current: CurrentWeather(
        time: current['time'] as String,
        temperature: (current['temperature_2m'] as num).toDouble(),
        apparentTemperature: (current['apparent_temperature'] as num)
            .toDouble(),
        humidity: (current['relative_humidity_2m'] as num).round(),
        windSpeed: (current['wind_speed_10m'] as num).toDouble(),
        weatherCode: (current['weather_code'] as num).toInt(),
        isDay: (current['is_day'] as num) == 1,
      ),
      daily: List.generate(times.length, (i) {
        return DailyWeather(
          date: times[i] as String,
          weatherCode: (at('weather_code', i) ?? 0).toInt(),
          temperatureMax: (at('temperature_2m_max', i) ?? 0).toDouble(),
          temperatureMin: (at('temperature_2m_min', i) ?? 0).toDouble(),
          precipitationProbability:
              (at('precipitation_probability_max', i) ?? 0).round(),
          uvIndexMax: (at('uv_index_max', i) ?? 0).toDouble(),
          sunrise:
              (sunrises != null && i < sunrises.length
                  ? sunrises[i] as String?
                  : null) ??
              '',
        );
      }),
    );
  }
}
