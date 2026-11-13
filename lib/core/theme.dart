import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const navy = Color(0xFF071F33);
  static const lime = Color(0xFFC9F75D);
  static const white = Color(0xFFF7FBFF);
  static const muted = Color(0xFFA9C1CB);
  static const amber = Color(0xFFFFC96B);
  static const onLime = Color(0xFF123C42);

  static const glass = Color(0x13FFFFFF); // ~7.5% white
  static const glassStrong = Color(0x1DFFFFFF); // ~11.5% white
  static const line = Color(0x1FFFFFFF); // ~12% white

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF071E34), Color(0xFF0A3847), Color(0xFF0A5B5E)],
    stops: [0.0, 0.54, 1.0],
  );
}

TextStyle heading(
  double size, {
  FontWeight weight = FontWeight.w800,
  Color? color,
  double? spacing,
}) {
  return GoogleFonts.manrope(
    fontSize: size,
    fontWeight: weight,
    color: color ?? AppColors.white,
    letterSpacing: spacing ?? -size * 0.035,
    height: 1.1,
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.navy,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.lime,
      onPrimary: AppColors.onLime,
      surface: AppColors.navy,
    ),
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.white,
      displayColor: AppColors.white,
    ),
    // Visible, themed scroll bar used by every scrollable screen.
    scrollbarTheme: ScrollbarThemeData(
      thumbVisibility: WidgetStateProperty.all(true),
      thickness: WidgetStateProperty.all(4),
      radius: const Radius.circular(8),
      thumbColor: WidgetStateProperty.all(
        AppColors.lime.withValues(alpha: 0.6),
      ),
      trackVisibility: WidgetStateProperty.all(false),
      crossAxisMargin: 3,
      mainAxisMargin: 6,
    ),
  );
}
