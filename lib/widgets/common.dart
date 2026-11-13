import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// Translucent rounded container used across the UI.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 20,
    this.color = AppColors.glass,
    this.borderColor = AppColors.line,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      color: AppColors.lime,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.4,
    ),
  );
}

class PageIntro extends StatelessWidget {
  const PageIntro({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });
  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(eyebrow),
          const SizedBox(height: 6),
          Text(title, style: heading(28)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.lime,
        foregroundColor: AppColors.onLime,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.active = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: active ? AppColors.lime : const Color(0x0EFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: active ? AppColors.lime : AppColors.line),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              size: 22,
              color: active ? AppColors.onLime : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// A scroll view with a VISIBLE, themed scrollbar (thin lime thumb).
/// Used by every screen so the scrollbar looks identical everywhere,
/// while the app bar and bottom bar stay fixed outside of it.
class AppScrollView extends StatefulWidget {
  const AppScrollView({
    super.key,
    required this.children,
    this.onRefresh,
    this.padding = const EdgeInsets.fromLTRB(18, 14, 18, 24),
  });

  final List<Widget> children;
  final Future<void> Function()? onRefresh;
  final EdgeInsets padding;

  @override
  State<AppScrollView> createState() => _AppScrollViewState();
}

class _AppScrollViewState extends State<AppScrollView> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget list = ListView(
      controller: _controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: widget.padding,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: widget.children,
    );

    if (widget.onRefresh != null) {
      list = RefreshIndicator(
        color: AppColors.onLime,
        backgroundColor: AppColors.lime,
        onRefresh: widget.onRefresh!,
        child: list,
      );
    }

    return Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      interactive: true,
      child: list,
    );
  }
}
