import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import '../models/weather_snapshot.dart';
import '../state/weather_controller.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';
import '../widgets/weather_glyph.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key, required this.controller});

  final WeatherController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final weather = c.weather;

    if (c.loading && weather == null) {
      return _Skeleton(name: c.location.name);
    }

    if (weather == null) {
      return AppScrollView(
        children: [
          SizedBox(
            height: 420,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.glassStrong,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    size: 32,
                    color: AppColors.lime,
                  ),
                ),
                const SizedBox(height: 18),
                Text('Forecast unavailable', style: heading(22)),
                const SizedBox(height: 8),
                Text(
                  c.error ?? 'A connection is needed to load this city’s first forecast. Once loaded, it will be available offline.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted, height: 1.4),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Try again',
                  icon: Icons.refresh_rounded,
                  onTap: c.refresh,
                ),
              ],
            ),
          ),
        ],
      );
    }

    final current = weather.current;
    final daily = weather.daily;
    final today = daily.first;
    final cached = !c.isLive || c.offline || c.isStale;
    final exact = formatExactTime(weather.fetchedAt, weather.utcOffsetSeconds);

    return AppScrollView(
      onRefresh: c.refresh,
      children: [
        if (c.offline || c.error != null || c.isStale) ...[
          _StatusBanner(controller: c, exact: exact),
          const SizedBox(height: 14),
        ],

        // ── Hero ─────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          weather.location.country,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weather.location.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: heading(28),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _UnitToggle(unit: c.unit, onChanged: c.changeUnit),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 142,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${current.temperature.round()}',
                        style: heading(
                          86,
                          weight: FontWeight.w600,
                          spacing: -7,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Text(
                          '°',
                          style: heading(
                            30,
                            color: AppColors.lime,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    getWeatherDescription(current.weatherCode),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE8F4F5),
                    ),
                  ),
                ],
              ),
              WeatherGlyph(
                code: current.weatherCode,
                isDay: current.isDay,
                size: 124,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _muted(
              'Feels like ',
              '${current.apparentTemperature.round()}${c.unit.symbol}',
            ),
            _muted(
              'High ',
              '${today.temperatureMax.round()}°',
              tail: ' · Low ',
              tailBold: '${today.temperatureMin.round()}°',
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          color: const Color(0x33010F1B),
          radius: 17,
          padding: const EdgeInsets.fromLTRB(13, 9, 10, 9),
          child: Row(
            children: [
              _Dot(stale: cached),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cached ? 'Saved forecast' : 'Live weather',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Updated $exact',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: (c.offline || c.loading) ? null : c.refresh,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(c.loading ? 'Updating' : 'Refresh'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0x17FFFFFF),
                  minimumSize: const Size(0, 38),
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            _Metric(
              icon: Icons.water_drop_outlined,
              label: 'Humidity',
              value: '${current.humidity}%',
            ),
            const SizedBox(width: 8),
            _Metric(
              icon: Icons.air_rounded,
              label: 'Wind',
              value: '${current.windSpeed.round()} km/h',
            ),
            const SizedBox(width: 8),
            _Metric(
              icon: Icons.wb_sunny_outlined,
              label: 'Sunrise',
              value: today.sunrise.isEmpty
                  ? '—'
                  : formatLocalTime(today.sunrise),
            ),
          ],
        ),

        // ── 7-day forecast ───────────────────────────────────
        const SizedBox(height: 27),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('The week ahead'),
                  const SizedBox(height: 4),
                  Text('7-day forecast', style: heading(19)),
                ],
              ),
            ),
            if (c.loading)
              const Text(
                'Updating…',
                style: TextStyle(
                  color: AppColors.lime,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        GlassCard(
          radius: 22,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          child: Column(
            children: [
              for (var i = 0; i < daily.length && i < 7; i++) ...[
                _ForecastRow(day: daily[i], isToday: i == 0),
                if (i != daily.length - 1 && i != 6)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0x14FFFFFF),
                  ),
              ],
            ],
          ),
        ),

        // ── Saved places ─────────────────────────────────────
        const SizedBox(height: 27),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Quick switch'),
                  const SizedBox(height: 4),
                  Text('Saved places', style: heading(19)),
                ],
              ),
            ),
            TextButton(
              onPressed: () => c.setTab(AppTab.search),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.lime,
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Add city'),
                  SizedBox(width: 4),
                  Icon(Icons.add_rounded, size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (c.favorites.isEmpty)
          _DashedButton(
            label: 'Save a city for quick access',
            onTap: () => c.setTab(AppTab.search),
          )
        else
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: c.favorites.length,
              separatorBuilder: (_, _) => const SizedBox(width: 9),
              itemBuilder: (_, i) {
                final f = c.favorites[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(17),
                  onTap: () => c.chooseLocation(f),
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 132),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: AppColors.glass,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          f.country,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 22),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Dot(stale: cached),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${cached ? 'Cached' : 'Live'} · Updated ${formatObservedTime(weather.fetchedAt)} · ${weather.location.timezone.replaceAll('_', ' ')}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Weather data by Open-Meteo',
            style: TextStyle(fontSize: 10, color: AppColors.muted),
          ),
        ),
      ],
    );
  }

  static Widget _muted(
    String lead,
    String bold, {
    String? tail,
    String? tailBold,
  }) {
    const base = TextStyle(color: AppColors.muted, fontSize: 12);
    const strong = TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: lead),
          TextSpan(text: bold, style: strong),
          if (tail != null) TextSpan(text: tail),
          if (tailBold != null) TextSpan(text: tailBold, style: strong),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.stale});
  final bool stale;

  @override
  Widget build(BuildContext context) {
    final color = stale ? AppColors.amber : AppColors.lime;
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.18), spreadRadius: 4),
        ],
      ),
    );
  }
}

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({required this.unit, required this.onChanged});
  final TemperatureUnit unit;
  final ValueChanged<TemperatureUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget item(TemperatureUnit u, String label) {
      final active = unit == u;
      return GestureDetector(
        onTap: () => onChanged(u),
        child: Container(
          width: 38,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.lime : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: active ? const Color(0xFF12383D) : AppColors.muted,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0x1F000000),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          item(TemperatureUnit.celsius, '°C'),
          item(TemperatureUnit.fahrenheit, '°F'),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        radius: 18,
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.lime),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.muted),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForecastRow extends StatelessWidget {
  const _ForecastRow({required this.day, required this.isToday});
  final DailyWeather day;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? 'Today' : formatWeekdayShort(day.date),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatShortDate(day.date, omitWeekday: true)} · ${getWeatherDescription(day.weatherCode)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                ),
              ],
            ),
          ),
          WeatherGlyph(code: day.weatherCode, size: 42),
          SizedBox(
            width: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.water_drop, size: 9, color: Color(0xFF72CADD)),
                const SizedBox(width: 3),
                Text(
                  '${day.precipitationProbability}%',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFB7DCE5),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 58,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${day.temperatureMax.round()}°',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${day.temperatureMin.round()}°',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8FACB5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.controller, required this.exact});
  final WeatherController controller;
  final String exact;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final title = c.offline
        ? 'Offline · Saved forecast'
        : c.error != null
        ? 'Update paused'
        : 'Saved forecast';
    final body = (c.offline || c.error != null)
        ? 'Last updated $exact'
        : 'This forecast may be out of date.';
    return GlassCard(
      radius: 17,
      color: const Color(0x1AC9F75D),
      borderColor: const Color(0x4DC9F75D),
      padding: const EdgeInsets.fromLTRB(13, 8, 4, 8),
      child: Row(
        children: [
          const _Dot(stale: true),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEFFFCA),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFB9D4C9),
                  ),
                ),
              ],
            ),
          ),
          if (!c.offline)
            IconButton(
              onPressed: c.refresh,
              tooltip: 'Retry update',
              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
                color: AppColors.lime,
              ),
            ),
        ],
      ),
    );
  }
}

class _DashedButton extends StatelessWidget {
  const _DashedButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0x0EC9F75D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x70C9F75D)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, size: 18, color: AppColors.lime),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.lime,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.name});
  final String name;

  Widget _block(double h, {double? w, double r = 14}) => Container(
    height: h,
    width: w,
    decoration: BoxDecoration(
      color: AppColors.glassStrong,
      borderRadius: BorderRadius.circular(r),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AppScrollView(
      children: [
        _block(28, w: 160),
        const SizedBox(height: 24),
        _block(86, w: 150),
        const SizedBox(height: 12),
        _block(18, w: 110),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _block(84, r: 18)),
            const SizedBox(width: 8),
            Expanded(child: _block(84, r: 18)),
            const SizedBox(width: 8),
            Expanded(child: _block(84, r: 18)),
          ],
        ),
        const SizedBox(height: 24),
        _block(300, r: 22),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'Getting the latest forecast for $name…',
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
