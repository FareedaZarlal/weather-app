import 'package:material_ui/material_ui.dart';

/// Port of the SVG weather glyph (96×96 viewBox) using a CustomPainter.
class WeatherGlyph extends StatelessWidget {
  const WeatherGlyph({
    super.key,
    required this.code,
    this.isDay = true,
    this.size = 72,
  });

  final int code;
  final bool isDay;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GlyphPainter(code, isDay)),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.code, this.isDay);

  final int code;
  final bool isDay;

  static const _rainCodes = [51, 53, 55, 61, 63, 65, 80, 81, 82];
  static const _snowCodes = [56, 57, 66, 67, 71, 73, 75, 77, 85, 86];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 96, size.height / 96);

    final rainy = _rainCodes.contains(code);
    final snowy = _snowCodes.contains(code);
    final stormy = code >= 95;
    final cloudy = code >= 2;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if ((!cloudy || code <= 3) && isDay) {
      final center = cloudy ? const Offset(57, 35) : const Offset(48, 45);
      canvas.drawCircle(
        center,
        cloudy ? 16 : 21,
        Paint()..color = const Color(0xFFF8D378),
      );
      stroke
        ..color = const Color(0xFFF4C563)
        ..strokeWidth = 4;
      final rays = cloudy
          ? const [
              [57, 10, 57, 18],
              [57, 52, 57, 60],
              [32, 35, 40, 35],
              [74, 35, 82, 35],
              [39, 17, 45, 23],
              [69, 47, 75, 53],
              [75, 17, 69, 23],
            ]
          : const [
              [48, 10, 48, 18],
              [48, 72, 48, 80],
              [13, 45, 21, 45],
              [75, 45, 83, 45],
              [23, 20, 29, 26],
              [67, 64, 73, 70],
              [73, 20, 67, 26],
              [23, 70, 29, 64],
            ];
      for (final r in rays) {
        canvas.drawLine(
          Offset(r[0] * 1.0, r[1] * 1.0),
          Offset(r[2] * 1.0, r[3] * 1.0),
          stroke,
        );
      }
    }

    // Clear night: a simple crescent so the glyph is never empty.
    if (!cloudy && !isDay) {
      final moon = Path()
        ..addOval(Rect.fromCircle(center: const Offset(48, 46), radius: 20));
      final cut = Path()
        ..addOval(Rect.fromCircle(center: const Offset(58, 38), radius: 17));
      canvas.drawPath(
        Path.combine(PathOperation.difference, moon, cut),
        Paint()..color = const Color(0xFFF8D378),
      );
    }

    if (cloudy) {
      final cloud = Path()
        ..moveTo(27, 70)
        ..lineTo(69, 70)
        ..cubicTo(78, 70, 85, 63.5, 85, 55.5)
        ..cubicTo(85, 47.5, 78.2, 41, 69.5, 41)
        ..cubicTo(66.7, 30.5, 56.7, 23, 45.2, 24.6)
        ..cubicTo(35.4, 26, 28, 34, 27.5, 43.5)
        ..cubicTo(18.2, 43.8, 11, 49.7, 11, 57)
        ..cubicTo(11, 64.5, 17.7, 70, 27, 70)
        ..close();
      canvas.drawPath(cloud, Paint()..color = Colors.white);
      canvas.drawPath(
        cloud,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFD9E1E7),
      );
    }

    if (rainy) {
      stroke
        ..color = const Color(0xFF5E8FC1)
        ..strokeWidth = 4;
      for (final x in [30.0, 47.0, 64.0]) {
        canvas.drawLine(Offset(x, 78), Offset(x - 3, 84), stroke);
      }
    }

    if (snowy) {
      final p = Paint()..color = const Color(0xFF77A6D2);
      for (final x in [30.0, 48.0, 66.0]) {
        canvas.drawCircle(Offset(x, 82), 3, p);
      }
    }

    if (stormy) {
      final bolt = Path()
        ..moveTo(48, 68)
        ..lineTo(40, 81)
        ..lineTo(48, 81)
        ..lineTo(45, 91)
        ..lineTo(58, 75)
        ..lineTo(50, 75)
        ..lineTo(55, 68)
        ..close();
      canvas.drawPath(bolt, Paint()..color = const Color(0xFFE8B957));
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.code != code || old.isDay != isDay;
}
