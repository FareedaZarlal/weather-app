import 'package:intl/intl.dart';

String getWeatherDescription(int code) {
  const table = <String, List<int>>{
    'Clear sky': [0],
    'Mainly clear': [1],
    'Partly cloudy': [2],
    'Overcast': [3],
    'Foggy': [45, 48],
    'Light drizzle': [51, 53, 55, 56, 57],
    'Rain': [61, 63, 65, 66, 67],
    'Snow': [71, 73, 75, 77, 85, 86],
    'Rain showers': [80, 81, 82],
    'Thunderstorms': [95, 96, 99],
  };
  for (final entry in table.entries) {
    if (entry.value.contains(code)) return entry.key;
  }
  return 'Mixed conditions';
}

String _clock(int hour, int minute) {
  final h = hour % 12 == 0 ? 12 : hour % 12;
  final m = minute.toString().padLeft(2, '0');
  return '$h:$m ${hour < 12 ? 'AM' : 'PM'}';
}

/// "2026-04-15" → "Apr 15" (or "Wednesday, Apr 15" unless [omitWeekday]).
String formatShortDate(String isoDate, {bool omitWeekday = false}) {
  final date = DateTime.parse(isoDate);
  return omitWeekday
      ? DateFormat('MMM d').format(date)
      : DateFormat('EEEE, MMM d').format(date);
}

String formatWeekdayShort(String isoDate) =>
    DateFormat('EEE').format(DateTime.parse(isoDate));

String formatObservedTime(DateTime value, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final minutes = current.difference(value).inMinutes;
  if (minutes < 1) return 'just now';
  if (minutes < 60) return '$minutes min ago';
  final hours = minutes ~/ 60;
  if (hours < 24) return '$hours hr${hours == 1 ? '' : 's'} ago';
  final local = value.toLocal();
  return '${DateFormat('MMM d').format(local)}, ${_clock(local.hour, local.minute)}';
}

/// Formats [value] on the city's clock using the API's UTC offset.
String formatExactTime(DateTime value, int utcOffsetSeconds) {
  final cityTime = value.toUtc().add(Duration(seconds: utcOffsetSeconds));
  return '${DateFormat('MMM d').format(cityTime)}, ${_clock(cityTime.hour, cityTime.minute)}';
}

/// "2026-04-15T06:24" → "6:24 AM" (the API already returns city-local time).
String formatLocalTime(String isoLocal) {
  final parts = isoLocal.split('T');
  if (parts.length < 2) return '—';
  final hm = parts[1].split(':');
  if (hm.length < 2) return '—';
  final hour = int.tryParse(hm[0]);
  final minute = int.tryParse(hm[1]);
  if (hour == null || minute == null) return '—';
  return _clock(hour, minute);
}
