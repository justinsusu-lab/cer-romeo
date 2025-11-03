import 'dart:math';
import 'package:flutter/material.dart';

class SinusWavesCard extends StatefulWidget {
  final List<double> red;
  final List<double> green;
  final List<double> yellow;
  final List<double> blue;
  final double yMax;
  final String title;
  final int bottomTicks;
  final bool showHeaderTitle;
  final double pricePerKwh; // €/kWh

  const SinusWavesCard({
    Key? key,
    required this.red,
    required this.green,
    required this.yellow,
    required this.blue,
    this.yMax = 80,
    this.title = 'Profilo orario di produzione e consumo',
    this.bottomTicks = 6,
    this.showHeaderTitle = true,
    this.pricePerKwh = 0.20,
  }) : super(key: key);

  @override
  State<SinusWavesCard> createState() => _SinusWavesCardState();
}

class _SinusWavesCardState extends State<SinusWavesCard>
    with SingleTickerProviderStateMixin {
  int _selected = 0; // 0=red,1=green,2=yellow,3=blue
  double? _hoverX; // pixel x for cursor
  late final AnimationController _ctrl;

  List<double> get _currentSeries {
    switch (_selected) {
      case 0:
        return widget.red;
      case 1:
        return widget.green;
      case 2:
        return widget.yellow;
      case 3:
      default:
        return widget.blue;
    }
  }

  Color get _currentColor {
    switch (_selected) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.green;
      case 2:
        return Colors.amber;
      case 3:
      default:
        return Colors.blue;
    }
  }

  String get _currentLabel {
    switch (_selected) {
      case 0:
        return 'Energia prodotta ma non condivisa';
      case 1:
        return 'Energia prodotta e condivisa';
      case 2:
        return 'Energia prodotta immessa in rete';
      case 3:
      default:
        return 'Energia autoconsumata reale';
    }
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onPan(Offset pos) {
    setState(() => _hoverX = pos.dx);
  }

  void _onLeave() {
    setState(() => _hoverX = null);
  }

  @override
  Widget build(BuildContext context) {
    final seriesLen = [
      widget.red.length,
      widget.green.length,
      widget.yellow.length,
      widget.blue.length,
    ].where((e) => e > 0).fold<int>(0, (p, e) => p == 0 ? e : min(p, e));
    final days = max(2, seriesLen);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.showHeaderTitle)
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  children: [
                    _SeriesChip(
                      label: 'NON CONDIVISA',
                      color: Colors.red,
                      selected: _selected == 0,
                      onTap: () => setState(() => _selected = 0),
                    ),
                    _SeriesChip(
                      label: 'PRODOTTA CONDIVISA',
                      color: Colors.green,
                      selected: _selected == 1,
                      onTap: () => setState(() => _selected = 1),
                    ),
                    _SeriesChip(
                      label: 'IMMESSA IN RETE',
                      color: Colors.amber,
                      selected: _selected == 2,
                      onTap: () => setState(() => _selected = 2),
                    ),
                    _SeriesChip(
                      label: 'AUTOCONSUMATA',
                      color: Colors.blue,
                      selected: _selected == 3,
                      onTap: () => setState(() => _selected = 3),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return MouseRegion(
                    onExit: (_) => _onLeave(),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanDown: (d) => _onPan(d.localPosition),
                      onPanUpdate: (d) => _onPan(d.localPosition),
                      onTapUp: (_) => _onLeave(),
                      child: Stack(
                        children: [
                          AnimatedBuilder(
                            animation: _ctrl,
                            builder: (context, _) {
                              return CustomPaint(
                                size: Size(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                ),
                                painter: _SinusPainter(
                                  allSeries: [
                                    widget.red,
                                    widget.green,
                                    widget.yellow,
                                    widget.blue,
                                  ],
                                  selected: _selected,
                                  color: _currentColor,
                                  yMax: widget.yMax,
                                  days: days,
                                  progress: Curves.easeOut.transform(
                                    _ctrl.value,
                                  ),
                                  bottomTicks: widget.bottomTicks,
                                  hoverX: _hoverX,
                                ),
                              );
                            },
                          ),
                          // Tooltip overlay
                          Positioned.fill(
                            child: _hoverX == null
                                ? const SizedBox.shrink()
                                : _HoverTooltipOverlay(
                                    color: _currentColor,
                                    label: _currentLabel,
                                    series: _currentSeries,
                                    yMax: widget.yMax,
                                    hoverX: _hoverX!,
                                    pricePerKwh: widget.pricePerKwh,
                                  ),
                          ),
                        ],
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

class _SeriesChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _SeriesChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : Colors.black87,
        ),
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
      selected: selected,
      selectedColor: color,
      backgroundColor: Colors.grey.shade100,
      side: BorderSide(width: 0.6, color: selected ? color : Colors.black26),
      onSelected: (_) => onTap(),
    );
  }
}

class _SinusPainter extends CustomPainter {
  final List<List<double>> allSeries;
  final int selected;
  final Color color;
  final double yMax;
  final int days;
  final double progress; // 0..1 drawing progress
  final int bottomTicks;
  final double? hoverX;

  _SinusPainter({
    required this.allSeries,
    required this.selected,
    required this.color,
    required this.yMax,
    required this.days,
    required this.progress,
    required this.bottomTicks,
    required this.hoverX,
  });

  static const double marginLeft = 44;
  static const double marginRight = 14;
  static const double marginTop = 12;
  static const double marginBottom = 28;

  @override
  void paint(Canvas canvas, Size size) {
    final chartW = max(10.0, size.width - marginLeft - marginRight);
    final chartH = max(10.0, size.height - marginTop - marginBottom);
    final origin = Offset(marginLeft, marginTop + chartH);

    // axes
    final axis = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1;
    canvas.drawLine(origin, Offset(marginLeft + chartW, origin.dy), axis);
    canvas.drawLine(origin, Offset(origin.dx, marginTop), axis);

    // grid + y labels
    final ySteps = [
      0,
      (yMax * 0.25).round(),
      (yMax * 0.5).round(),
      (yMax * 0.75).round(),
      yMax.round(),
    ];
    final grid = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1;
    final tpBuilder = (String s) {
      final tp = TextPainter(
        text: TextSpan(
          text: s,
          style: const TextStyle(fontSize: 10, color: Colors.black54),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      return tp;
    };
    for (final y in ySteps) {
      final py = origin.dy - (y / yMax) * chartH;
      canvas.drawLine(
        Offset(marginLeft, py),
        Offset(marginLeft + chartW, py),
        grid,
      );
      final tp = tpBuilder(y.toString());
      tp.paint(canvas, Offset(marginLeft - tp.width - 6, py - tp.height / 2));
    }

    // bottom ticks (days)
    final tickCount = bottomTicks.clamp(2, 10);
    for (int i = 0; i < tickCount; i++) {
      final t = i / (tickCount - 1);
      final x = marginLeft + t * chartW;
      canvas.drawLine(Offset(x, origin.dy), Offset(x, origin.dy + 4), axis);
      final day = (1 + t * (days - 1)).round();
      final tp = tpBuilder(day.toString());
      tp.paint(canvas, Offset(x - tp.width / 2, origin.dy + 6));
    }

    // Draw series fills and strokes
    for (int s = 0; s < allSeries.length; s++) {
      final series = allSeries[s];
      if (series.isEmpty) continue;
      final baseColor = _seriesColor(s);
      final alphaStroke = s == selected ? 220 : 90;
      final alphaFill = s == selected ? 60 : 24;

      final stroke = Paint()
        ..color = baseColor.withAlpha(alphaStroke)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s == selected ? 2.6 : 1.4;

      final path = _buildSmoothPath(series, chartW, chartH, origin, progress);

      // Build fill path closing to baseline
      final n = series.length;
      final maxIndex = max(1, (n * progress).floor());
      final tEnd = n <= 1 ? 1.0 : ((maxIndex - 1) / (n - 1)).clamp(0.0, 1.0);
      final xStart = marginLeft;
      final xEnd = marginLeft + tEnd * chartW;
      final area = Path.from(path)
        ..lineTo(xEnd, origin.dy)
        ..lineTo(xStart, origin.dy)
        ..close();

      final fill = Paint()
        ..color = baseColor.withAlpha((255 * (alphaFill / 255)).round())
        ..style = PaintingStyle.fill;

      canvas.drawPath(area, fill);
      canvas.drawPath(path, stroke);
    }

    // hover cursor
    if (hoverX != null) {
      final x = hoverX!.clamp(marginLeft, marginLeft + chartW);
      final cursor = Paint()
        ..color = Colors.black26
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(x, marginTop), Offset(x, origin.dy), cursor);
    }
  }

  Path _buildSmoothPath(
    List<double> series,
    double w,
    double h,
    Offset origin,
    double progress,
  ) {
    final n = series.length;
    final maxIndex = max(1, (n * progress).floor());
    final p = Path();
    double xFor(int i) => marginLeft + (i / (n - 1)) * w;
    double yFor(int i) => origin.dy - (series[i].clamp(0, yMax) / yMax) * h;

    p.moveTo(xFor(0), yFor(0));
    for (int i = 1; i < maxIndex; i++) {
      final prev = Offset(xFor(i - 1), yFor(i - 1));
      final curr = Offset(xFor(i), yFor(i));
      final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
      p.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
      p.quadraticBezierTo(curr.dx, curr.dy, curr.dx, curr.dy);
    }
    return p;
  }

  Color _seriesColor(int idx) {
    switch (idx) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.green;
      case 2:
        return Colors.amber;
      case 3:
      default:
        return Colors.blue;
    }
  }

  @override
  bool shouldRepaint(covariant _SinusPainter old) {
    return old.selected != selected ||
        old.color != color ||
        old.yMax != yMax ||
        old.days != days ||
        old.progress != progress ||
        old.hoverX != hoverX ||
        old.allSeries != allSeries;
  }
}

class _HoverTooltipOverlay extends StatelessWidget {
  final Color color;
  final String label;
  final List<double> series;
  final double yMax;
  final double hoverX;
  final double pricePerKwh;
  const _HoverTooltipOverlay({
    required this.color,
    required this.label,
    required this.series,
    required this.yMax,
    required this.hoverX,
    required this.pricePerKwh,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const left = _SinusPainter.marginLeft;
        const right = _SinusPainter.marginRight;
        const top = _SinusPainter.marginTop;
        const bottom = _SinusPainter.marginBottom;
        final w = max(10.0, constraints.maxWidth - left - right);
        final h = max(10.0, constraints.maxHeight - top - bottom);
        final n = max(2, series.length);
        final t = ((hoverX - left) / w).clamp(0, 1);
        final index = (t * (n - 1)).round();
        final value = series[index.clamp(0, n - 1)];
        final euro = value * pricePerKwh;

        final dx = hoverX.clamp(left, left + w);
        final dy = top + h * 0.15; // fixed height area for tooltip
        final bubble = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.black12),
          ),
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.w700, color: color),
                ),
                const SizedBox(height: 4),
                Text('Giorno ${index + 1}'),
                Text('€ ${euro.toStringAsFixed(2)}'),
              ],
            ),
          ),
        );

        return Stack(
          children: [Positioned(left: dx - 70, top: dy, child: bubble)],
        );
      },
    );
  }
}
