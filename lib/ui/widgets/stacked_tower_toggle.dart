import 'dart:math';
import 'package:flutter/material.dart';

class StackedTowerToggle extends StatefulWidget {
  final List<double> red;
  final List<double> green;
  final List<double> yellow;
  final List<double> blue;
  final double yMax;
  final String?
  monthLabel; // optional: if null, widget manages month internally
  final VoidCallback? onPrevMonth; // optional
  final VoidCallback? onNextMonth; // optional
  final double pricePerKwh; // €/kWh

  const StackedTowerToggle({
    Key? key,
    required this.red,
    required this.green,
    required this.yellow,
    required this.blue,
    required this.yMax,
    this.monthLabel,
    this.onPrevMonth,
    this.onNextMonth,
    this.pricePerKwh = 0.20,
  }) : super(key: key);

  @override
  State<StackedTowerToggle> createState() => _StackedTowerToggleState();
}

class _StackedTowerToggleState extends State<StackedTowerToggle> {
  bool _isProduction = true; // true=Produzione, false=Consumo
  Offset? _hover; // local hover position

  // Independent month state and data when callbacks/label not provided
  late final bool _independent;
  late DateTime _month;
  late List<double> _r, _g, _y, _b;

  @override
  void initState() {
    super.initState();
    _independent =
        widget.onPrevMonth == null ||
        widget.onNextMonth == null ||
        widget.monthLabel == null;
    _month = DateTime(DateTime.now().year, DateTime.now().month);
    if (_independent) {
      _generateLocalData();
    }
  }

  void _prevLocal() {
    setState(() {
      _month = DateTime(_month.year, _month.month - 1);
      _generateLocalData();
    });
  }

  void _nextLocal() {
    setState(() {
      _month = DateTime(_month.year, _month.month + 1);
      _generateLocalData();
    });
  }

  int _daysInMonth(DateTime m) {
    final next = DateTime(m.year, m.month + 1, 1);
    return next.subtract(const Duration(days: 1)).day;
  }

  void _generateLocalData() {
    final days = _daysInMonth(_month);
    _r = _makeSine(days, phase: 0.0, amp: widget.yMax * 0.85);
    _g = _makeSine(days, phase: pi / 3, amp: widget.yMax * 0.75);
    _y = _makeSine(days, phase: 2 * pi / 3, amp: widget.yMax * 0.65);
    _b = _makeSine(days, phase: pi, amp: widget.yMax * 0.55);
  }

  List<double> _makeSine(int n, {required double phase, required double amp}) {
    if (n <= 1) return List.filled(max(2, n), 0);
    final rnd = Random(_month.month + _month.year);
    return List<double>.generate(n, (i) {
      final t = i / (n - 1);
      final base = (sin((t * 2 * pi) + phase) + 1) / 2; // 0..1
      final noise = (rnd.nextDouble() - 0.5) * 0.1;
      return ((base + noise).clamp(0.0, 1.0)) * amp;
    });
  }

  String _monthLabelLocal() =>
      '${_month.month.toString().padLeft(2, '0')}/${_month.year}';

  int _daysCount(
    List<double> r,
    List<double> g,
    List<double> y,
    List<double> b,
  ) {
    final lens = [r.length, g.length, y.length, b.length].where((e) => e > 0);
    if (lens.isEmpty) return 0;
    return lens.reduce(min);
  }

  @override
  Widget build(BuildContext context) {
    // Choose data source
    final r = _independent ? _r : widget.red;
    final g = _independent ? _g : widget.green;
    final y = _independent ? _y : widget.yellow;
    final b = _independent ? _b : widget.blue;

    final days = _daysCount(r, g, y, b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Spacer(),
            IconButton(
              tooltip: 'Mese precedente',
              onPressed: _independent ? _prevLocal : widget.onPrevMonth,
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              _independent ? _monthLabelLocal() : (widget.monthLabel ?? ''),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            IconButton(
              tooltip: 'Mese successivo',
              onPressed: _independent ? _nextLocal : widget.onNextMonth,
              icon: const Icon(Icons.chevron_right),
            ),
            const SizedBox(width: 8),
            ToggleButtons(
              isSelected: [_isProduction, !_isProduction],
              onPressed: (i) => setState(() => _isProduction = i == 0),
              borderRadius: BorderRadius.circular(8),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('Produzione'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('Consumo'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 300,
          child: LayoutBuilder(
            builder: (context, c) => MouseRegion(
              onHover: (e) => setState(() => _hover = e.localPosition),
              onExit: (_) => setState(() => _hover = null),
              child: CustomPaint(
                size: Size(c.maxWidth, 300),
                painter: _TowerPainterMulti(
                  yMax: widget.yMax,
                  days: days,
                  red: r,
                  green: g,
                  yellow: y,
                  blue: b,
                  isProduction: _isProduction,
                  hover: _hover,
                  pricePerKwh: widget.pricePerKwh,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: const [
            _LegendItem(color: Colors.red, label: 'NON CONDIVISA'),
            _LegendItem(color: Colors.green, label: 'PRODOTTA CONDIVISA'),
            _LegendItem(color: Colors.amber, label: 'IMMESSA IN RETE'),
            _LegendItem(color: Colors.blue, label: 'AUTOCONSUMATA'),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class _TowerPainterMulti extends CustomPainter {
  final double yMax;
  final int days;
  final List<double> red, green, yellow, blue;
  final bool isProduction;
  final Offset? hover;
  final double pricePerKwh;
  _TowerPainterMulti({
    required this.yMax,
    required this.days,
    required this.red,
    required this.green,
    required this.yellow,
    required this.blue,
    required this.isProduction,
    this.hover,
    this.pricePerKwh = 0.20,
  });

  static const double marginLeft = 56;
  static const double marginRight = 12;
  static const double marginTop = 12;
  static const double marginBottom = 36;

  @override
  void paint(Canvas canvas, Size size) {
    final chartW = max(10.0, size.width - marginLeft - marginRight);
    final chartH = max(10.0, size.height - marginTop - marginBottom);
    final origin = Offset(marginLeft, marginTop + chartH);

    // axes and grid
    final axis = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1;
    canvas.drawLine(origin, Offset(marginLeft + chartW, origin.dy), axis);
    canvas.drawLine(origin, Offset(origin.dx, marginTop), axis);

    final steps = [
      0,
      (yMax * 0.25).round(),
      (yMax * 0.5).round(),
      (yMax * 0.75).round(),
      yMax.round(),
    ];
    final grid = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1;
    for (final v in steps) {
      final py = origin.dy - (v / yMax) * chartH;
      canvas.drawLine(
        Offset(marginLeft, py),
        Offset(marginLeft + chartW, py),
        grid,
      );
      final tp = _tp(v.toString());
      tp.paint(canvas, Offset(marginLeft - tp.width - 8, py - tp.height / 2));
    }

    if (days <= 0) return;

    // bar geometry
    final double gap = 4.0;
    final double barW = max(3.0, min(14.0, (chartW - gap * (days - 1)) / days));

    // x ticks
    final labelCount = 6;
    final step = max(1, (days / labelCount).round());
    for (int i = 0; i < days; i += step) {
      final xTick = marginLeft + i * (barW + gap) + barW / 2;
      canvas.drawLine(
        Offset(xTick, origin.dy),
        Offset(xTick, origin.dy + 4),
        axis,
      );
      final tp = _tp('${i + 1}');
      tp.paint(canvas, Offset(xTick - tp.width / 2, origin.dy + 6));
    }

    // Determine hovered bar index
    int? hoverIndex;
    if (hover != null &&
        hover!.dx >= marginLeft &&
        hover!.dx <= marginLeft + chartW &&
        hover!.dy >= marginTop &&
        hover!.dy <= origin.dy) {
      final relX = hover!.dx - marginLeft;
      final slot = (barW + gap);
      final idx = (relX / slot).floor();
      if (idx >= 0 && idx < days) hoverIndex = idx;
    }

    // Pass 1: draw all bars
    for (int i = 0; i < days; i++) {
      final yVal = isProduction ? yellow[i] : red[i];
      final gVal = green[i];
      final bVal = blue[i];
      final total = (yVal + gVal + bVal);
      if (total <= 0) continue;

      final hScale = min(total, yMax) / yMax; // cap to yMax
      final fullH = chartH * hScale;
      final yH = (yVal / total) * fullH;
      final gH = (gVal / total) * fullH;
      final bH = (bVal / total) * fullH;

      final x = marginLeft + i * (barW + gap);
      double yCursor = origin.dy;

      void seg(double h, Color c) {
        if (h <= 0) return;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, yCursor - h, barW, h),
          const Radius.circular(3),
        );
        final p = Paint()..color = c.withOpacity(0.92);
        canvas.drawRRect(rect, p);
        yCursor -= h;
      }

      final yColor = isProduction ? Colors.amber : Colors.red;
      seg(yH, yColor);
      seg(gH, Colors.green);
      seg(bH, Colors.blue);
    }

    // Pass 2: hover overlay on top
    if (hoverIndex != null) {
      final i = hoverIndex;
      final yVal = isProduction ? yellow[i] : red[i];
      final gVal = green[i];
      final bVal = blue[i];
      final total = (yVal + gVal + bVal);
      if (total > 0) {
        final hScale = min(total, yMax) / yMax;
        final fullH = chartH * hScale;
        final parts = [
          (yVal / total) * fullH,
          (gVal / total) * fullH,
          (bVal / total) * fullH,
        ];
        final values = [yVal, gVal, bVal];
        final x = marginLeft + i * (barW + gap);

        double yTop = origin.dy;
        for (int s = 0; s < 3; s++) {
          final h = parts[s];
          final segTop = yTop - h;
          if (hover!.dy >= segTop && hover!.dy <= yTop) {
            final r = RRect.fromRectAndRadius(
              Rect.fromLTWH(x, segTop, barW, h),
              const Radius.circular(3),
            );
            final border = Paint()
              ..color = Colors.black.withOpacity(0.65)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1;
            canvas.drawRRect(r, border);

            final perc = (values[s] / total) * 100;
            final euro = values[s] * pricePerKwh;
            final labelIn =
                '${perc.toStringAsFixed(0)}% • € ${euro.toStringAsFixed(2)}';
            final tpIn = _tpStyled(
              labelIn,
              const TextStyle(
                fontSize: 9,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            );
            if (h > tpIn.height + 4 && barW >= tpIn.width + 4) {
              tpIn.paint(
                canvas,
                Offset(
                  x + (barW - tpIn.width) / 2,
                  segTop + (h - tpIn.height) / 2,
                ),
              );
            } else {
              final bubbleText =
                  '${perc.toStringAsFixed(1)}% • € ${euro.toStringAsFixed(2)}';
              final bubble = _tpStyled(
                bubbleText,
                const TextStyle(
                  fontSize: 10,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              );
              final chartRight = marginLeft + chartW;
              final preferRight = x + barW + 12 + bubble.width <= chartRight;
              final bx = preferRight
                  ? (x + barW + 6)
                  : (x - 6 - bubble.width + 0 - 10);
              final by = max(marginTop, segTop - 18);
              final rect = RRect.fromRectAndRadius(
                Rect.fromLTWH(bx, by, bubble.width + 10, bubble.height + 6),
                const Radius.circular(6),
              );
              final bg = Paint()
                ..color = Colors.white
                ..style = PaintingStyle.fill;
              final outline = Paint()
                ..color = Colors.black26
                ..style = PaintingStyle.stroke;
              canvas.drawRRect(rect, bg);
              canvas.drawRRect(rect, outline);
              final cx1 = preferRight ? (x + barW) : (x);
              final cx2 = preferRight ? bx : (bx + bubble.width + 10);
              final cy = segTop + h / 2;
              final conn = Paint()
                ..color = Colors.black26
                ..strokeWidth = 1;
              canvas.drawLine(
                Offset(cx1, cy),
                Offset(cx2, by + (bubble.height + 6) / 2),
                conn,
              );
              bubble.paint(canvas, Offset(bx + 5, by + 3));
            }
            break;
          }
          yTop = segTop;
        }
      }
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

  static TextPainter _tpStyled(String s, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: style),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    return tp;
  }

  @override
  bool shouldRepaint(covariant _TowerPainterMulti old) {
    return old.yMax != yMax ||
        old.days != days ||
        old.isProduction != isProduction ||
        old.red != red ||
        old.green != green ||
        old.yellow != yellow ||
        old.blue != blue ||
        old.hover != hover;
  }
}
