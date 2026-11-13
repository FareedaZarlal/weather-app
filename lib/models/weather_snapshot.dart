import 'location.dart';

enum TemperatureUnit {
  celsius,
  fahrenheit;

  String get apiName => name;
  String get symbol => this == celsius ? '°C' : '°F';
}

class CurrentWeather {
  final String time;
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final bool isDay;

  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.isDay,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> j) => CurrentWeather(
    time: j['time'] as String,
    temperature: (j['temperature'] as num).toDouble(),
    apparentTemperature: (j['apparentTemperature'] as num).toDouble(),
    humidity: (j['humidity'] as num).round(),
    windSpeed: (j['windSpeed'] as num).toDouble(),
    weatherCode: (j['weatherCode'] as num).toInt(),
    isDay: j['isDay'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'time': time,
    'temperature': temperature,
    'apparentTemperature': apparentTemperature,
    'humidity': humidity,
    'windSpeed': windSpeed,
    'weatherCode': weatherCode,
    'isDay': isDay,
  };
}

class DailyWeather {
  final String date;
  final int weatherCode;
  final double temperatureMax;
  final double temperatureMin;
  final int precipitationProbability;
  final double uvIndexMax;
  final String sunrise;

  const DailyWeather({
    required this.date,
    required this.weatherCode,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitationProbability,
    required this.uvIndexMax,
    required this.sunrise,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> j) => DailyWeather(
    date: j['date'] as String,
    weatherCode: (j['weatherCode'] as num).toInt(),
    temperatureMax: (j['temperatureMax'] as num).toDouble(),
    temperatureMin: (j['temperatureMin'] as num).toDouble(),
    precipitationProbability: (j['precipitationProbability'] as num).round(),
    uvIndexMax: (j['uvIndexMax'] as num).toDouble(),
    sunrise: (j['sunrise'] as String?) ?? '',
  );

  Map<String, dynamic> toJson() => {
    'date': date,
    'weatherCode': weatherCode,
    'temperatureMax': temperatureMax,
    'temperatureMin': temperatureMin,
    'precipitationProbability': precipitationProbability,
    'uvIndexMax': uvIndexMax,
    'sunrise': sunrise,
  };
}

class WeatherSnapshot {
  final Location location;
  final CurrentWeather current;
  final List<DailyWeather> daily;
  final String timezone;
  final int utcOffsetSeconds;
  final TemperatureUnit unit;
  final DateTime fetchedAt;

  const WeatherSnapshot({
    required this.location,
    required this.current,
    required this.daily,
    required this.timezone,
    required this.utcOffsetSeconds,
    required this.unit,
    required this.fetchedAt,
  });

  factory WeatherSnapshot.fromJson(Map<String, dynamic> j) => WeatherSnapshot(
    location: Location.fromJson(j['location'] as Map<String, dynamic>),
    current: CurrentWeather.fromJson(j['current'] as Map<String, dynamic>),
    daily: (j['daily'] as List)
        .map((e) => DailyWeather.fromJson(e as Map<String, dynamic>))
        .toList(),
    timezone: j['timezone'] as String,
    utcOffsetSeconds: (j['utcOffsetSeconds'] as num?)?.toInt() ?? 0,
    unit: TemperatureUnit.values.byName(j['unit'] as String),
    fetchedAt: DateTime.parse(j['fetchedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'location': location.toJson(),
    'current': current.toJson(),
    'daily': daily.map((e) => e.toJson()).toList(),
    'timezone': timezone,
    'utcOffsetSeconds': utcOffsetSeconds,
    'unit': unit.name,
    'fetchedAt': fetchedAt.toIso8601String(),
  };
}
