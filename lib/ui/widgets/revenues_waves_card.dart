import 'dart:math';
import 'package:flutter/material.dart';

class RevenuesWavesCard extends StatefulWidget {
  final List<double> incentives; // base € series
  final List<double> savings; // base € series
  final List<double> revenues; // base € series
  final String title;
  final int bottomTicks;
  final double? yMax; // optional max in € (will be rounded to 100)

  const RevenuesWavesCard({
    super.key,
    required this.incentives,
    required this.savings,
    required this.revenues,
    this.title = 'Ricavi',
    this.bottomTicks = 6,
    this.yMax,
  });

  @override
  State<RevenuesWavesCard> createState() => _RevenuesWavesCardState();
}

class _RevenuesWavesCardState extends State<RevenuesWavesCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  double? _hoverX;
  late DateTime _month;
  late List<double> _inc, _sav, _rev;
  late double _yMaxR;
  bool _showInc = true, _showSav = true, _showRev = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _month = DateTime(DateTime.now().year, DateTime.now().month);
    _rebuildData();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _prev() {
    setState(() {
      _month = DateTime(_month.year, _month.month - 1);
      _rebuildData();
    });
  }

  void _next() {
    setState(() {
      _month = DateTime(_month.year, _month.month + 1);
      _rebuildData();
    });
  }

  int _daysInMonth(DateTime m) {
    final next = DateTime(m.year, m.month + 1, 1);
    return next.subtract(const Duration(days: 1)).day;
  }

  String _monthLabel() =>
      '${_month.month.toString().padLeft(2, '0')}/${_month.year}';

  void _rebuildData() {
    final n = _daysInMonth(_month);
    _inc = _resample(widget.incentives, n);
    _sav = _resample(widget.savings, n);
    _rev = _resample(widget.revenues, n);
    // month-based gentle scaling 0.9..1.1
    final seed = _month.month + _month.year;
    final f1 = 0.9 + 0.2 * (sin(seed));
    final f2 = 0.9 + 0.2 * (cos(seed * 0.7));
    final f3 = 0.9 + 0.2 * (sin(seed * 0.37 + 1.2));
    for (int i = 0; i < n; i++) {
      _inc[i] *= f1;
      _sav[i] *= f2;
      _rev[i] *= f3;
    }
    _yMaxR = _roundUp100(widget.yMax ?? _autoMax());
  }

  List<double> _resample(List<double> src, int n) {
    if (src.isEmpty) return List.filled(n, 0);
    if (src.length == n) return List<double>.from(src);
    final out = List<double>.filled(n, 0);
    for (int i = 0; i < n; i++) {
      final t = i / max(1, n - 1);
      final x = t * (src.length - 1);
      final i0 = x.floor();
      final i1 = min(src.length - 1, i0 + 1);
      final frac = x - i0;
      out[i] = src[i0] * (1 - frac) + src[i1] * frac;
    }
    return out;
  }

  double _autoMax() {
    double m = 0.0;
    for (final v in _inc) {
      m = max(m, v);
    }
    for (final v in _sav) {
      m = max(m, v);
    }
    for (final v in _rev) {
      m = max(m, v);
    }
    return max(100.0, m * 1.2);
  }

  double _roundUp100(double v) {
    return (v <= 0) ? 100 : (100 * (v / 100).ceilToDouble());
  }

  @override
  Widget build(BuildContext context) {
    final days = _inc.isEmpty ? 0 : _inc.length;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Mese precedente',
                  onPressed: _prev,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  _monthLabel(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  tooltip: 'Mese successivo',
                  onPressed: _next,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: LayoutBuilder(
                builder: (context, c) {
                  return MouseRegion(
                    onExit: (_) => setState(() => _hoverX = null),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanDown: (d) =>
                          setState(() => _hoverX = d.localPosition.dx),
                      onPanUpdate: (d) =>
                          setState(() => _hoverX = d.localPosition.dx),
                      onTapUp: (_) => setState(() => _hoverX = null),
                      child: Stack(
                        children: [
                          AnimatedBuilder(
                            animation: _ctrl,
                            builder: (_, __) => CustomPaint(
                              size: Size(c.maxWidth, c.maxHeight),
                              painter: _RevenuesPainter(
                                incentives: _inc,
                                savings: _sav,
                                revenues: _rev,
                                yMax: _yMaxR,
                                days: days,
                                progress: Curves.easeOut.transform(_ctrl.value),
                                bottomTicks: widget.bottomTicks,
                                hoverX: _hoverX,
                                showInc: _showInc,
                                showSav: _showSav,
                                showRev: _showRev,
                              ),
                            ),
                          ),
                          if (_hoverX != null)
                            Positioned.fill(
                              child: _RevenuesTooltip(
                                incentives: _inc,
                                savings: _sav,
                                revenues: _rev,
                                hoverX: _hoverX!,
                                showInc: _showInc,
                                showSav: _showSav,
                                showRev: _showRev,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _LegendChip(
                  color: Colors.green,
                  label: 'Incentivi',
                  enabled: _showInc,
                  onTap: () => setState(() => _showInc = !_showInc),
                ),
                _LegendChip(
                  color: Colors.blue,
                  label: 'Risparmi',
                  enabled: _showSav,
                  onTap: () => setState(() => _showSav = !_showSav),
                ),
                _LegendChip(
                  color: Colors.amber,
                  label: 'Ricavi',
                  enabled: _showRev,
                  onTap: () => setState(() => _showRev = !_showRev),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenuesPainter extends CustomPainter {
  final List<double> incentives, savings, revenues;
  final double yMax;
  final int days;
  final double progress;
  final int bottomTicks;
  final double? hoverX;
  final bool showInc, showSav, showRev;
  _RevenuesPainter({
    required this.incentives,
    required this.savings,
    required this.revenues,
    required this.yMax,
    required this.days,
    required this.progress,
    required this.bottomTicks,
    required this.hoverX,
    required this.showInc,
    required this.showSav,
    required this.showRev,
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

    final axis = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1;
    canvas.drawLine(origin, Offset(marginLeft + chartW, origin.dy), axis);
    canvas.drawLine(origin, Offset(origin.dx, marginTop), axis);

    // grid + Y labels every 100€
    for (int i = 0; i <= 10; i++) {
      final v = (yMax / 10) * i;
      final py = origin.dy - (v / yMax) * chartH;
      final grid = Paint()
        ..color = Colors.black12
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(marginLeft, py),
        Offset(marginLeft + chartW, py),
        grid,
      );
      final tp = _tp('€ ${v.round()}');
      tp.paint(canvas, Offset(marginLeft - tp.width - 6, py - tp.height / 2));
    }

    // bottom ticks
    final tickCount = bottomTicks.clamp(2, 10);
    for (int i = 0; i < tickCount; i++) {
      final t = i / (tickCount - 1);
      final x = marginLeft + t * chartW;
      canvas.drawLine(Offset(x, origin.dy), Offset(x, origin.dy + 4), axis);
      final day = (1 + t * (days - 1)).round();
      final tp = _tp(day.toString());
      tp.paint(canvas, Offset(x - tp.width / 2, origin.dy + 6));
    }

    // series drawing order
    if (showInc) {
      drawSeries(
        canvas,
        incentives,
        Colors.green,
        false,
        chartW,
        chartH,
        origin,
      );
    }
    if (showSav) {
      drawSeries(canvas, savings, Colors.blue, false, chartW, chartH, origin);
    }
    if (showRev) {
      drawSeries(canvas, revenues, Colors.amber, true, chartW, chartH, origin);
    }

    if (hoverX != null) {
      final x = hoverX!.clamp(marginLeft, marginLeft + chartW);
      final cursor = Paint()
        ..color = Colors.black26
        ..strokeWidth = 1;
      canvas.drawLine(Offset(x, marginTop), Offset(x, origin.dy), cursor);
    }
  }

  void drawSeries(
    Canvas canvas,
    List<double> s,
    Color baseColor,
    bool emphasize,
    double chartW,
    double chartH,
    Offset origin,
  ) {
    if (s.isEmpty) return;
    final alphaStroke = emphasize ? 220 : 120;
    final alphaFill = emphasize ? 70 : 36;
    final stroke = Paint()
      ..color = baseColor.withAlpha(alphaStroke)
      ..style = PaintingStyle.stroke
      ..strokeWidth = emphasize ? 2.6 : 1.6;
    final fill = Paint()
      ..color = baseColor.withAlpha(alphaFill)
      ..style = PaintingStyle.fill;
    final path = _buildPath(s, chartW, chartH, origin);

    // close area
    final n = s.length;
    final maxIndex = max(1, (n * progress).floor());
    final tEnd = n <= 1 ? 1.0 : ((maxIndex - 1) / (n - 1)).clamp(0.0, 1.0);
    final xStart = marginLeft;
    final xEnd = marginLeft + tEnd * chartW;
    final area = Path.from(path)
      ..lineTo(xEnd, origin.dy)
      ..lineTo(xStart, origin.dy)
      ..close();

    canvas.drawPath(area, fill);
    canvas.drawPath(path, stroke);
  }

  Path _buildPath(List<double> series, double w, double h, Offset origin) {
    final n = max(2, series.length);
    final maxIndex = max(1, (n * progress).floor());
    final p = Path();
    double xFor(int i) => marginLeft + (i / (n - 1)) * w;
    double yFor(int i) => origin.dy - ((series[i].clamp(0, yMax)) / yMax) * h;
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

  @override
  bool shouldRepaint(covariant _RevenuesPainter old) {
    return old.incentives != incentives ||
        old.savings != savings ||
        old.revenues != revenues ||
        old.yMax != yMax ||
        old.days != days ||
        old.progress != progress ||
        old.hoverX != hoverX ||
        old.bottomTicks != bottomTicks ||
        old.showInc != showInc ||
        old.showSav != showSav ||
        old.showRev != showRev;
  }
}

class _RevenuesTooltip extends StatelessWidget {
  final List<double> incentives, savings, revenues;
  final double hoverX;
  final bool showInc, showSav, showRev;
  const _RevenuesTooltip({
    super.key,
    required this.incentives,
    required this.savings,
    required this.revenues,
    required this.hoverX,
    required this.showInc,
    required this.showSav,
    required this.showRev,
  });
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const left = _RevenuesPainter.marginLeft;
        const right = _RevenuesPainter.marginRight;
        const top = _RevenuesPainter.marginTop;
        final w = max(10.0, c.maxWidth - left - right);
        final n = [
          incentives.length,
          savings.length,
          revenues.length,
        ].where((e) => e > 0).reduce(min);
        final t = ((hoverX - left) / w).clamp(0.0, 1.0);
        final idx = (t * (n - 1)).round().clamp(0, n - 1);
        final inc = incentives[idx];
        final sav = savings[idx];
        final rev = revenues[idx];
        final dx = hoverX.clamp(left, left + w);
        final dy = top + 12;
        return Stack(
          children: [
            Positioned(
              left: dx - 90,
              top: dy,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Giorno'),
                      const SizedBox(height: 4),
                      if (showInc) ...[
                        Row(
                          children: const [
                            Icon(Icons.circle, size: 8, color: Colors.green),
                            SizedBox(width: 6),
                            Text('Incentivi:'),
                          ],
                        ),
                        Text('€ ${inc.toStringAsFixed(2)}'),
                      ],
                      if (showSav) ...[
                        Row(
                          children: const [
                            Icon(Icons.circle, size: 8, color: Colors.blue),
                            SizedBox(width: 6),
                            Text('Risparmi:'),
                          ],
                        ),
                        Text('€ ${sav.toStringAsFixed(2)}'),
                      ],
                      if (showRev) ...[
                        Row(
                          children: const [
                            Icon(Icons.circle, size: 8, color: Colors.amber),
                            SizedBox(width: 6),
                            Text('Ricavi:'),
                          ],
                        ),
                        Text('€ ${rev.toStringAsFixed(2)}'),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  const _LegendChip({
    required this.color,
    required this.label,
    required this.enabled,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final bg = enabled ? Colors.white : Colors.grey.shade200;
    final txt = enabled ? Colors.black87 : Colors.black45;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled ? color.withOpacity(0.6) : Colors.black26,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.circle,
              size: 10,
              color: color.withOpacity(enabled ? 1.0 : 0.3),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: txt,
                decoration: enabled
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
