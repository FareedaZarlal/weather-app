import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import '../state/weather_controller.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.controller});

  final WeatherController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final weather = c.weather;

    return AppScrollView(
      children: [
        const PageIntro(
          eyebrow: 'Your places',
          title: 'Saved cities',
          subtitle: 'Switch forecasts without typing them again.',
        ),
        if (c.favorites.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.glass,
                    border: Border.all(color: AppColors.line),
                  ),
                  child: const Icon(
                    Icons.bookmark_border_rounded,
                    size: 30,
                    color: AppColors.lime,
                  ),
                ),
                const SizedBox(height: 16),
                Text('No saved cities yet', style: heading(20)),
                const SizedBox(height: 8),
                const Text(
                  'Add the places you care about for faster access, even when your connection is limited.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Find a city',
                  icon: Icons.search_rounded,
                  onTap: () => c.setTab(AppTab.search),
                ),
              ],
            ),
          )
        else ...[
          for (var i = 0; i < c.favorites.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FavoriteCard(
                index: i,
                title: c.favorites[i].name,
                subtitle: c.favorites[i].subtitle,
                detail: weather?.location.id == c.favorites[i].id
                    ? '${getWeatherDescription(weather!.current.weatherCode)} · Updated ${formatObservedTime(weather.fetchedAt)}'
                    : 'Tap to load latest weather',
                temp: weather?.location.id == c.favorites[i].id
                    ? '${weather!.current.temperature.round()}°'
                    : '—°',
                onOpen: () => c.chooseLocation(c.favorites[i]),
                onRemove: () => c.toggleFavorite(c.favorites[i]),
              ),
            ),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => c.setTab(AppTab.search),
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0x0EC9F75D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x70C9F75D)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, size: 18, color: AppColors.lime),
                  SizedBox(width: 6),
                  Text(
                    'Add another city',
                    style: TextStyle(
                      color: AppColors.lime,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.temp,
    required this.onOpen,
    required this.onRemove,
  });

  final int index;
  final String title;
  final String subtitle;
  final String detail;
  final String temp;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(7),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onOpen,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Text(
                      (index + 1).toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lime,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            detail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.normal,
                              color: Color(0xFF8FACB5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(temp, style: heading(22, weight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 19,
                      color: AppColors.muted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            tooltip: 'Remove $title',
            icon: const Icon(
              Icons.close_rounded,
              size: 17,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
