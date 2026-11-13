import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import '../state/weather_controller.dart';
import '../widgets/common.dart';
import 'favorites_screen.dart';
import 'search_screen.dart';
import 'weather_screen.dart';

/// Layout contract (fixes the "bars must stay on screen" issue):
///  * Scaffold.appBar          → always pinned at the top
///  * Scaffold.bottomNavigationBar → always pinned at the bottom
///  * body                     → the ONLY thing that scrolls (inside each screen)
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.controller});

  final WeatherController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final c = controller;
        return Container(
          decoration: const BoxDecoration(gradient: AppColors.gradient),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            appBar: _TopBar(controller: c),
            body: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: IndexedStack(
                  index: c.tab.index,
                  children: [
                    WeatherScreen(controller: c),
                    SearchScreen(controller: c),
                    FavoritesScreen(controller: c),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _BottomBar(controller: c),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget implements PreferredSizeWidget {
  const _TopBar({required this.controller});
  final WeatherController controller;

  @override
  Size get preferredSize => const Size.fromHeight(71); // 70 toolbar + 1 divider

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 70,
      titleSpacing: 20,
      title: GestureDetector(
        onTap: () => c.setTab(AppTab.weather),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: AppColors.lime,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.cloud_outlined,
                size: 21,
                color: AppColors.onLime,
              ),
            ),
            const SizedBox(width: 10),
            Text('SkyCast', style: heading(18)),
          ],
        ),
      ),
      actions: [
        RoundIconButton(
          icon: Icons.search_rounded,
          tooltip: 'Search cities',
          onTap: () => c.setTab(AppTab.search),
        ),
        const SizedBox(width: 7),
        RoundIconButton(
          icon: c.isFavorite
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          tooltip: c.isFavorite ? 'Remove from favorites' : 'Save to favorites',
          active: c.isFavorite,
          onTap: () => c.toggleFavorite(c.location),
        ),
        const SizedBox(width: 20),
      ],
      // Hairline so it's obvious the bar is pinned above scrolling content.
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: Color(0x14FFFFFF)),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.controller});
  final WeatherController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Align(
        heightFactor: 1,
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 8, 15, 12),
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xF2031824),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x21FFFFFF)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x520A1420),
                    blurRadius: 30,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Weather',
                    active: controller.tab == AppTab.weather,
                    onTap: () => controller.setTab(AppTab.weather),
                  ),
                  _NavItem(
                    icon: Icons.search_rounded,
                    activeIcon: Icons.search_rounded,
                    label: 'Search',
                    active: controller.tab == AppTab.search,
                    onTap: () => controller.setTab(AppTab.search),
                  ),
                  _NavItem(
                    icon: Icons.bookmark_border_rounded,
                    activeIcon: Icons.bookmark_rounded,
                    label: 'Saved',
                    active: controller.tab == AppTab.favorites,
                    onTap: () => controller.setTab(AppTab.favorites),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.lime : const Color(0xFF799BA5);
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 44,
              height: 28,
              decoration: BoxDecoration(
                color: active ? const Color(0x1CC9F75D) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(active ? activeIcon : icon, size: 21, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
