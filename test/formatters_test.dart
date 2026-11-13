import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/utils/formatters.dart';

void main() {
  group('weather model helpers', () {
    test('maps WMO weather codes to readable conditions', () {
      expect(getWeatherDescription(0), 'Clear sky');
      expect(getWeatherDescription(63), 'Rain');
      expect(getWeatherDescription(95), 'Thunderstorms');
    });

    test('falls back safely for an unknown weather code', () {
      expect(getWeatherDescription(1000), 'Mixed conditions');
    });

    test('formats a fresh cache timestamp transparently', () {
      expect(formatObservedTime(DateTime.now()), 'just now');
    });

    test("keeps API-local sunrise time in the city's clock", () {
      expect(formatLocalTime('2026-04-15T06:24'), '6:24 AM');
    });
  });
}
