import 'dart:math';
import 'package:flutter/material.dart';

class HourlyPoint {
  final DateTime time;
  final double tempC;
  final double precipMm;
  final double windKmh;
  HourlyPoint({
    required this.time,
    required this.tempC,
    required this.precipMm,
    required this.windKmh,
  });
}

class WeeklyWeatherCard extends StatefulWidget {
  final List<HourlyPoint> data; // 7*24 ore
  final String title;
  const WeeklyWeatherCard({
    Key? key,
    required this.data,
    this.title = 'Meteo settimanale (orari)',
  }) : super(key: key);
  @override
  State<WeeklyWeatherCard> createState() => _WeeklyWeatherCardState();
}

class _WeeklyWeatherCardState extends State<WeeklyWeatherCard> {
  Offset? _hover;

  List<HourlyPoint> get _series =>
      widget.data.isNotEmpty ? widget.data : _genSample();

  List<HourlyPoint> _genSample() {
    final start = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday % 7),
    );
    final out = <HourlyPoint>[];
    for (int h = 0; h < 7 * 24; h++) {
      final t = start.add(Duration(hours: h));
      final dayFrac = (h % 24) / 24.0;
      final base = 18 + 6 * sin(2 * pi * (dayFrac - 0.2));
      final temp = base + (Random(h).nextDouble() - 0.5) * 1.2;
      final precip = max(0.0, (Random(h * 17).nextDouble() - 0.8) * 5);
      final wind = 10 + Random(h * 31).nextDouble() * 20;
      out.add(
        HourlyPoint(time: t, tempC: temp, precipMm: precip, windKmh: wind),
      );
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final s = _series;
    final temps = s.map((e) => e.tempC);
    double minT = temps.reduce(min);
    double maxT = temps.reduce(max);
    final pad = (maxT - minT).clamp(4.0, 12.0);
    minT = (minT - pad / 2).floorToDouble();
    maxT = (maxT + pad / 2).ceilToDouble();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 280,
              child: LayoutBuilder(
                builder: (context, c) {
                  return MouseRegion(
                    onHover: (e) => setState(() => _hover = e.localPosition),
                    onExit: (_) => setState(() => _hover = null),
                    child: CustomPaint(
                      size: Size(c.maxWidth, 280),
                      painter: _WeatherWeekPainter(
                        data: s,
                        minT: minT,
                        maxT: maxT,
                        hover: _hover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherWeekPainter extends CustomPainter {
  final List<HourlyPoint> data;
  final double minT, maxT;
  final Offset? hover;
  _WeatherWeekPainter({
    required this.data,
    required this.minT,
    required this.maxT,
    required this.hover,
  });

  static const double marginLeft = 44;
  static const double marginRight = 14;
  static const double marginTop = 12;
  static const double marginBottom = 36;

  @override
  void paint(Canvas canvas, Size size) {
    final chartW = max(10.0, size.width - marginLeft - marginRight);
    final chartH = max(10.0, size.height - marginTop - marginBottom);
    final origin = Offset(marginLeft, marginTop + chartH);

    final axis = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1;
    canvas.drawLine(origin, Offset(marginLeft + chartW, origin.dy), axis);
    canvas.drawLine(origin, Offset(origin.dx, marginTop), axis);

    // Y grid 5 ticks (°C)
    for (int i = 0; i <= 5; i++) {
      final v = minT + (maxT - minT) * (i / 5);
      final py = origin.dy - ((v - minT) / (maxT - minT)) * chartH;
      final grid = Paint()
        ..color = Colors.black12
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(marginLeft, py),
        Offset(marginLeft + chartW, py),
        grid,
      );
      final tp = _tp('${v.toStringAsFixed(0)}°C');
      tp.paint(canvas, Offset(marginLeft - tp.width - 6, py - tp.height / 2));
    }

    // Day separators and hour ticks 06/12/18
    final start = data.first.time;
    final totalH = data.length - 1;
    for (int d = 0; d < 7; d++) {
      final h0 = d * 24.0;
      final x = marginLeft + (h0 / totalH) * chartW;
      final sep = Paint()
        ..color = Colors.black12
        ..strokeWidth = 1;
      canvas.drawLine(Offset(x, marginTop), Offset(x, origin.dy), sep);
      // label day
      final dayName = _dayLabel(start.add(Duration(days: d)));
      final tpd = _tp(dayName);
      tpd.paint(canvas, Offset(x + 4, marginTop - 2));
      for (final hh in [6, 12, 18]) {
        final xx = marginLeft + ((h0 + hh) / totalH) * chartW;
        canvas.drawLine(Offset(xx, origin.dy), Offset(xx, origin.dy + 4), axis);
        final tph = _tp(hh.toString().padLeft(2, '0'));
        tph.paint(canvas, Offset(xx - tph.width / 2, origin.dy + 6));
      }
    }

    // Temperature path
    double xFor(int i) => marginLeft + (i / totalH) * chartW;
    double yFor(int i) {
      final t = data[i].tempC;
      final norm = (t - minT) / (maxT - minT);
      return origin.dy - norm * chartH;
    }

    final path = Path()..moveTo(xFor(0), yFor(0));
    for (int i = 1; i < data.length; i++) {
      final prev = Offset(xFor(i - 1), yFor(i - 1));
      final curr = Offset(xFor(i), yFor(i));
      final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
      path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
      path.quadraticBezierTo(curr.dx, curr.dy, curr.dx, curr.dy);
    }
    final stroke = Paint()
      ..color = Colors.orangeAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final fill = Paint()
      ..color = Colors.orangeAccent.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final area = Path.from(path)
      ..lineTo(marginLeft + chartW, origin.dy)
      ..lineTo(marginLeft, origin.dy)
      ..close();
    canvas.drawPath(area, fill);
    canvas.drawPath(path, stroke);

    // Hover tooltip with time + metrics
    if (hover != null &&
        hover!.dx >= marginLeft &&
        hover!.dx <= marginLeft + chartW &&
        hover!.dy >= marginTop &&
        hover!.dy <= origin.dy) {
      final rel = ((hover!.dx - marginLeft) / chartW).clamp(0.0, 1.0);
      final idx = (rel * totalH).round().clamp(0, totalH);
      final p = data[idx];
      final x = xFor(idx);
      final cursor = Paint()
        ..color = Colors.black26
        ..strokeWidth = 1;
      canvas.drawLine(Offset(x, marginTop), Offset(x, origin.dy), cursor);

      final info =
          '${_dayShort(p.time)} ${p.time.hour.toString().padLeft(2, '0')}:00\n${p.tempC.toStringAsFixed(1)}°C • ${p.windKmh.toStringAsFixed(0)} km/h\n${p.precipMm.toStringAsFixed(1)} mm';
      final tp = _tpBox(
        info,
        const TextStyle(
          fontSize: 11,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      );
      final bx = (x + 8 + tp.width < marginLeft + chartW)
          ? x + 8
          : x - 8 - tp.width;
      final by = max(marginTop, hover!.dy - tp.height - 8);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(bx - 6, by - 4, tp.width + 12, tp.height + 8),
        const Radius.circular(8),
      );
      final bg = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final outline = Paint()
        ..color = Colors.black12
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(rect, bg);
      canvas.drawRRect(rect, outline);
      tp.paint(canvas, Offset(bx, by));
    }
  }

  static TextPainter _tp(String s) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: const TextStyle(fontSize: 10, color: Colors.black54),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    return tp;
  }

  static TextPainter _tpBox(String s, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 4,
    );
    tp.layout();
    return tp;
  }

  String _dayLabel(DateTime d) {
    const days = ['Dom', 'Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab'];
    return days[d.weekday % 7];
  }

  String _dayShort(DateTime d) => _dayLabel(d);

  @override
  bool shouldRepaint(covariant _WeatherWeekPainter old) {
    return old.data != data ||
        old.minT != minT ||
        old.maxT != maxT ||
        old.hover != hover;
  }
}
