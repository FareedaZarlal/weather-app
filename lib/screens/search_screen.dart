import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import '../models/location.dart';
import '../state/weather_controller.dart';
import '../widgets/common.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.controller});

  final WeatherController controller;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _text = TextEditingController();

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    widget.controller.search(_text.text);
  }

  void _choose(Location location) {
    _text.clear();
    widget.controller.chooseLocation(location);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return AppScrollView(
      children: [
        const PageIntro(
          eyebrow: 'Find your forecast',
          title: 'Search cities',
          subtitle: 'See live conditions anywhere in the world.',
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 5, 5, 5),
          decoration: BoxDecoration(
            color: const Color(0x17FFFFFF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x29FFFFFF)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                size: 21,
                color: AppColors.muted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _text,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _submit(),
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  cursorColor: AppColors.lime,
                  decoration: const InputDecoration(
                    hintText: 'City or town',
                    hintStyle: TextStyle(color: Color(0xFF86A4AD)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (_text.text.isNotEmpty)
                IconButton(
                  onPressed: () {
                    _text.clear();
                    c.clearSearch();
                  },
                  tooltip: 'Clear search',
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.muted,
                  ),
                ),
              FilledButton(
                onPressed: c.searching ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.lime,
                  foregroundColor: AppColors.onLime,
                  disabledBackgroundColor: const Color(0x80C9F75D),
                  minimumSize: const Size(0, 46),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(c.searching ? 'Searching' : 'Search'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (c.searching)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.lime,
                ),
              ),
            ),
          ),
        if (c.searchMessage != null)
          GlassCard(
            radius: 18,
            child: Row(
              children: [
                const Icon(Icons.cloud_outlined, color: AppColors.lime),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    c.searchMessage!,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (!c.searching && c.searchMessage == null && c.results.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                _GlobeMark(icon: Icons.location_on_outlined),
                const SizedBox(height: 16),
                Text(
                  'Weather, wherever you are',
                  textAlign: TextAlign.center,
                  style: heading(20),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Search by city name to get a current reading and a seven-day outlook.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                if (c.favorites.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  const Text(
                    'Recent & saved',
                    style: TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final f in c.favorites.take(3))
                        ActionChip(
                          label: Text(f.name),
                          onPressed: () => _choose(f),
                          backgroundColor: AppColors.glass,
                          side: const BorderSide(color: AppColors.line),
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        if (c.results.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 2),
            child: Text(
              '${c.results.length} ${c.results.length == 1 ? 'result' : 'results'}',
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ),
          for (final r in c.results)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _ResultRow(
                name: r.name,
                subtitle: r.subtitle,
                saved: c.favorites.any((f) => f.id == r.id),
                onOpen: () => _choose(r),
                onToggle: () => c.toggleFavorite(r),
              ),
            ),
        ],
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.name,
    required this.subtitle,
    required this.saved,
    required this.onOpen,
    required this.onToggle,
  });

  final String name;
  final String subtitle;
  final bool saved;
  final VoidCallback onOpen;
  final VoidCallback onToggle;

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
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.glassStrong,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        size: 19,
                        color: AppColors.lime,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
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
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: AppColors.muted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: onToggle,
            tooltip: saved ? 'Remove $name from saved cities' : 'Save $name',
            style: IconButton.styleFrom(
              backgroundColor: saved ? AppColors.lime : const Color(0x14FFFFFF),
              minimumSize: const Size(40, 40),
            ),
            icon: Icon(
              saved ? Icons.check_rounded : Icons.add_rounded,
              size: 18,
              color: saved ? AppColors.onLime : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlobeMark extends StatelessWidget {
  const _GlobeMark({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.glass,
        border: Border.all(color: AppColors.line),
      ),
      child: Icon(icon, size: 30, color: AppColors.lime),
    );
  }
}
