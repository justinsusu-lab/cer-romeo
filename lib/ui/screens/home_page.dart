// lib/ui/screens/home_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../widgets/sinus_waves_card.dart';
import '../widgets/stacked_tower_toggle.dart';
import '../widgets/revenues_waves_card.dart';
import '../widgets/weather_iframe_view.dart';
import 'membri_page.dart';
import 'faq_page.dart';
import '../../routes/route_observer.dart';

class Membro {
  final String nome;
  final String ruolo;
  final String stato;
  final int? produzione;
  final int? consumo;
  Membro(this.nome, this.ruolo, this.stato, {this.produzione, this.consumo});
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, RouteAware {
  // Search UI
  bool _openSearch = false;
  String _searchText = '';

  // Blink (semaforo)
  late final AnimationController _blinkController;
  late final Animation<double> _blinkAnimation;

  // Progress animations
  late final AnimationController _prodAutoconsController;
  late final Animation<double> _prodAutoconsAnim;
  late final AnimationController _prodImessaController;
  late final Animation<double> _prodImessaAnim;
  late final AnimationController _consAutoconsController;
  late final Animation<double> _consAutoconsAnim;
  late final AnimationController _consPrelevController;
  late final Animation<double> _consPrelevAnim;

  // Sticky colors palette
  final List<Color> _stickyColors = const [
    Color(0xFFFFF9C4),
    Color(0xFFFFECB3),
    Color(0xFFC8E6C9),
    Color(0xFFB3E5FC),
    Color(0xFFFFCDD2),
    Color(0xFFD1C4E9),
  ];
  Color _pickSticky(int index) => _stickyColors[index % _stickyColors.length];

  final List<Membro> _membri = [
    Membro('Mario Rossi', 'Admin', 'Attivo'),
    Membro('Francesca Bianchi', 'Prosumer', 'Attivo', produzione: 28),
    Membro('Giuseppe Verdi', 'Consumer', 'Inattivo', consumo: 17),
    Membro('Sara Neri', 'Gruppo Obiettivo', 'Attivo'),
    Membro('Anna Blu', 'Prosumer', 'Inattivo', produzione: 33),
    Membro('Luigi Gialli', 'Consumer', 'Attivo', consumo: 9),
  ];

  String _two(int n) => n.toString().padLeft(2, '0');
  String _formatNow() {
    final now = DateTime.now();
    return '${_two(now.day)}/${_two(now.month)}/${now.year} ${_two(now.hour)}:${_two(now.minute)}';
  }

  // Data per onde sinusoidali
  static const double yMax = 80;
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  late List<double> _red;
  late List<double> _green;
  late List<double> _yellow;
  late List<double> _blue;

  int _daysInMonth(DateTime m) {
    final next = DateTime(m.year, m.month + 1, 1);
    return next.subtract(const Duration(days: 1)).day;
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _generateData();
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _generateData();
    });
  }

  void _generateData() {
    final days = _daysInMonth(_currentMonth);
    _red = _makeSine(days, phase: 0.0, amp: yMax * 0.85);
    _green = _makeSine(days, phase: pi / 3, amp: yMax * 0.75);
    _yellow = _makeSine(days, phase: 2 * pi / 3, amp: yMax * 0.65);
    _blue = _makeSine(days, phase: pi, amp: yMax * 0.55);
  }

  List<double> _makeSine(int n, {required double phase, required double amp}) {
    if (n <= 1) return List.filled(max(2, n), 0);
    final rnd = Random(_currentMonth.month + _currentMonth.year);
    final list = List<double>.generate(n, (i) {
      final t = i / (n - 1);
      final base = (sin((t * 2 * pi) + phase) + 1) / 2; // 0..1
      final noise = (rnd.nextDouble() - 0.5) * 0.1; // small jitter
      return ((base + noise).clamp(0.0, 1.0)) * amp;
    });
    return list;
  }

  String _monthLabel() =>
      '${_currentMonth.month.toString().padLeft(2, '0')}/${_currentMonth.year}';

  Color _coloreRuolo(String ruolo) {
    switch (ruolo) {
      case 'Admin':
        return Colors.red;
      case 'Prosumer':
        return Colors.blue;
      case 'Consumer':
        return Colors.green;
      case 'Gruppo Obiettivo':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _blinkAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    _prodAutoconsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _prodAutoconsAnim = CurvedAnimation(
      parent: _prodAutoconsController,
      curve: Curves.easeOut,
    );
    _prodImessaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _prodImessaAnim = CurvedAnimation(
      parent: _prodImessaController,
      curve: Curves.easeOut,
    );
    _consAutoconsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _consAutoconsAnim = CurvedAnimation(
      parent: _consAutoconsController,
      curve: Curves.easeOut,
    );
    _consPrelevController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _consPrelevAnim = CurvedAnimation(
      parent: _consPrelevController,
      curve: Curves.easeOut,
    );

    _generateData();
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _prodAutoconsController.dispose();
    _prodImessaController.dispose();
    _consAutoconsController.dispose();
    _consPrelevController.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) routeObserver.subscribe(this, route);
  }

  void _startProgressAnimations() {
    _prodAutoconsController
      ..reset()
      ..forward();
    _prodImessaController
      ..reset()
      ..forward();
    _consAutoconsController
      ..reset()
      ..forward();
    _consPrelevController
      ..reset()
      ..forward();
  }

  @override
  void didPush() => _startProgressAnimations();
  @override
  void didPopNext() => _startProgressAnimations();

  Widget _centerLogos() {
    Widget item(String asset, String value) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(asset, height: 28, fit: BoxFit.contain),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.black26, width: 1),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          item('assets/images/logo_pv.png', '100 kW'),
          const SizedBox(width: 22),
          item('assets/images/logo_accumulo.png', '- kWh'),
          const SizedBox(width: 22),
          item('assets/images/logo_ev.png', '- kWh'),
        ],
      ),
    );
  }

  void _navigateToMembri() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MembriPage()),
    );
  }

  void _navigateToFAQ() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const FAQPage()));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _searchText.isEmpty
        ? _membri.take(4).toList()
        : _membri
              .where(
                (m) => m.nome.toLowerCase().contains(_searchText.toLowerCase()),
              )
              .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: ListView(
          padding: const EdgeInsets.only(top: 24.0),
          children: [
            ListTile(
              title: const Text('Membri'),
              onTap: _navigateToMembri,
              leading: const Icon(Icons.group, color: Color(0xFF2E7D32)),
            ),
            ListTile(
              title: const Text('FAQ'),
              onTap: _navigateToFAQ,
              leading: const Icon(Icons.help_outline, color: Color(0xFF2E7D32)),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        toolbarHeight: 72,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black87, size: 28),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'CER MAGNA GRECIA',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Demo',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
            Expanded(
              child: Align(alignment: Alignment.center, child: _centerLogos()),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Sezione membri con ricerca
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 24),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InkWell(
                      onTap: () => setState(() => _openSearch = !_openSearch),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Componenti Comunità Energetica',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Icon(
                            _openSearch ? Icons.expand_less : Icons.expand_more,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    if (_openSearch) ...[
                      const SizedBox(height: 14),
                      TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 18,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 24,
                          ),
                          hintText: 'Cerca componenti Comunità Energetica',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.green.shade300,
                              width: 2,
                            ),
                          ),
                          isDense: true,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        onChanged: (v) =>
                            setState(() => _searchText = v.trim()),
                      ),
                      const SizedBox(height: 16),
                      ...filtered.map(
                        (m) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _coloreRuolo(m.ruolo),
                            child: Text(
                              m.ruolo,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            m.nome,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    m.ruolo,
                                    style: TextStyle(
                                      color: _coloreRuolo(m.ruolo),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (m.produzione != null) ...[
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Produzione:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Text(
                                      ' ${m.produzione} kWh',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                  if (m.consumo != null) ...[
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Consumo:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Text(
                                      ' ${m.consumo} kWh',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    m.stato == 'Attivo'
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    size: 16,
                                    color: m.stato == 'Attivo'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    m.stato,
                                    style: TextStyle(
                                      color: m.stato == 'Attivo'
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Tre riquadri informativi: semaforo, CO2, alberi
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 320,
                      height: 110,
                      child: Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    FadeTransition(
                                      opacity: _blinkAnimation,
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.red.withOpacity(
                                                0.6,
                                              ),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFC9C9C9),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFC2C1C1),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Center(
                                  child: Text(
                                    'Stato: Problema',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 320,
                      height: 110,
                      child: Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'CO₂ equivalente evitata',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '1,768.18 kg',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 320,
                      height: 110,
                      child: Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/tree_logo.png',
                                    fit: BoxFit.contain,
                                    width: 80,
                                    height: 80,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Alberi equivalenti',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '≈81 alberi',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Energia prodotta / consumata
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 480,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 56,
                                height: 56,
                                child: Image.asset(
                                  'assets/images/logo_pv.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Energia prodotta',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      '3,336.18 kWh',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Energia autoconsumata',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AnimatedBuilder(
                                            animation: _prodAutoconsAnim,
                                            builder: (_, __) =>
                                                LinearProgressIndicator(
                                                  value:
                                                      _prodAutoconsAnim.value *
                                                      0.3505,
                                                  minHeight: 8,
                                                  backgroundColor:
                                                      Colors.grey.shade200,
                                                  color: Colors.green,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: const [
                                            Text(
                                              '1,169.22 kWh',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              '35.05%',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Energia immessa in rete',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AnimatedBuilder(
                                            animation: _prodImessaAnim,
                                            builder: (_, __) =>
                                                LinearProgressIndicator(
                                                  value:
                                                      _prodImessaAnim.value *
                                                      0.6495,
                                                  minHeight: 8,
                                                  backgroundColor:
                                                      Colors.grey.shade200,
                                                  color: Colors.blue,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: const [
                                            Text(
                                              '2,166.97 kWh',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              '64.95%',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 480,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: Image.asset(
                                  'assets/images/bulb_logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Energia consumata',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      '7,527.74 kWh',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Energia autoconsumata',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AnimatedBuilder(
                                            animation: _consAutoconsAnim,
                                            builder: (_, __) =>
                                                LinearProgressIndicator(
                                                  value:
                                                      _consAutoconsAnim.value *
                                                      0.1553,
                                                  minHeight: 8,
                                                  backgroundColor:
                                                      Colors.grey.shade200,
                                                  color: Colors.orange,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: const [
                                            Text(
                                              '1,169.22 kWh',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              '15.53%',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Energia prelevata',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AnimatedBuilder(
                                            animation: _consPrelevAnim,
                                            builder: (_, __) =>
                                                LinearProgressIndicator(
                                                  value:
                                                      _consPrelevAnim.value *
                                                      0.8447,
                                                  minHeight: 8,
                                                  backgroundColor:
                                                      Colors.grey.shade200,
                                                  color: Colors.deepOrange,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: const [
                                            Text(
                                              '6,356.52 kWh',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              '84.47%',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Post-it KPI
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _PostIt(
                      title: 'Convenienza totale',
                      amount: '— €',
                      deltaPercent: -0.00,
                      color: _pickSticky(0),
                    ),
                    _PostIt(
                      title: 'Risparmio bolletta',
                      amount: '— €',
                      deltaPercent: 0.00,
                      color: _pickSticky(2),
                    ),
                    _PostIt(
                      title: 'Vendita energia immessa',
                      amount: '— €',
                      deltaPercent: 0.00,
                      color: _pickSticky(3),
                    ),
                    _PostIt(
                      title: 'Incentivi energia condivisa',
                      amount: '— €',
                      deltaPercent: 0.00,
                      color: _pickSticky(1),
                    ),
                  ],
                ),
              ),
            ),

            // Ultimi flussi (SVG)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                        child: Row(
                          children: [
                            const Text(
                              'Ultimi flussi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatNow(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      SizedBox(
                        height: 420,
                        width: double.infinity,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/diagrams/cer_animata.svg',
                            width: 900,
                            height: 420,
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            placeholderBuilder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Grafici affiancati: Profilo orario + Torre stacked
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 1000;
                final chartWidth = isNarrow
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 12) / 2;
                return Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: chartWidth,
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Profilo orario di produzione e consumo',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    tooltip: 'Mese precedente',
                                    onPressed: _prevMonth,
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
                                    onPressed: _nextMonth,
                                    icon: const Icon(Icons.chevron_right),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SinusWavesCard(
                                title: 'Profilo orario di produzione e consumo',
                                red: _red,
                                green: _green,
                                yellow: _yellow,
                                blue: _blue,
                                yMax: yMax,
                                bottomTicks: 6,
                                showHeaderTitle: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: chartWidth,
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Produzione totale e consumo totale',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),
                              StackedTowerToggle(
                                red: _red,
                                green: _green,
                                yellow: _yellow,
                                blue: _blue,
                                yMax: yMax,
                                monthLabel: _monthLabel(),
                                onPrevMonth: _prevMonth,
                                onNextMonth: _nextMonth,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),
            // Ricavi (onde sinusoidali piene)
            Builder(
              builder: (context) {
                final n =
                    [_red.length, _green.length, _yellow.length, _blue.length]
                        .where((e) => e > 0)
                        .fold<int>(0, (p, e) => p == 0 ? e : (e < p ? e : p));
                if (n <= 0) return const SizedBox.shrink();
                final incentives = List<double>.generate(
                  n,
                  (i) => _green[i] * 0.12,
                );
                final savings = List<double>.generate(
                  n,
                  (i) => _blue[i] * 0.20,
                );
                final revenues = List<double>.generate(
                  n,
                  (i) => _yellow[i] * 0.10 + _red[i] * 0.05,
                );
                return RevenuesWavesCard(
                  incentives: incentives,
                  savings: savings,
                  revenues: revenues,
                  title: 'Ricavi',
                  bottomTicks: 6,
                );
              },
            ),

            const SizedBox(height: 16),
            // Meteo moderno: card giornaliere orizzontali
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.cloud_outlined,
                          size: 18,
                          color: Colors.black54,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Meteo • Rossano, Cosenza, Italia',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 360,
                      child: kIsWeb
                          ? WeatherIFrameView(
                              url:
                                  'https://embed.windy.com/embed2.html?lat=39.58&lon=16.65&detailLat=39.58&detailLon=16.65&zoom=8&level=surface&overlay=rain&menu=&message=&marker=&calendar=&pressure=&type=map&location=coordinates&detail=&metricWind=km%2Fh&metricTemp=%C2%B0C',
                              width: double.infinity,
                              height: 360,
                            )
                          : Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: const Text(
                                'Mappa meteo non disponibile in questa demo',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.black54,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Meteo settimanale • Rossano, Cosenza, Italia',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 170,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 7,
                        itemBuilder: (context, d) {
                          final now = DateTime.now();
                          final dayDate = now.add(Duration(days: d));
                          const dayNames = [
                            'Dom',
                            'Lun',
                            'Mar',
                            'Mer',
                            'Gio',
                            'Ven',
                            'Sab',
                          ];
                          final dayLabel = dayNames[dayDate.weekday % 7];
                          double tempAt(int hour) {
                            final base =
                                18 + 6 * sin(2 * pi * (hour / 24.0 - 0.2));
                            return base + sin((d * 24 + hour) * 0.3) * 0.8;
                          }

                          double precipAt(int hour) =>
                              max(0.0, (sin((d * 24 + hour) * 0.2) - 0.7) * 4);
                          IconData skyIcon(double precip, int hour) {
                            if (precip > 0.8) return Icons.umbrella;
                            if (hour >= 9 && hour <= 17) return Icons.wb_sunny;
                            return Icons.cloud_queue;
                          }

                          final tMax = [
                            0,
                            6,
                            12,
                            18,
                          ].map(tempAt).reduce(max).round();
                          final tMin = [
                            0,
                            6,
                            12,
                            18,
                          ].map(tempAt).reduce(min).round();
                          final mainHour = 12;
                          final mainIcon = skyIcon(
                            precipAt(mainHour),
                            mainHour,
                          );
                          final gradient = LinearGradient(
                            colors: [
                              Colors.blue.shade100,
                              Colors.blue.shade50,
                              Colors.white,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          );
                          return AnimatedOpacity(
                            opacity: 1.0,
                            duration: Duration(milliseconds: 400 + d * 80),
                            child: Container(
                              width: 180,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: gradient,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueGrey.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.blue.shade50,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          mainIcon,
                                          size: 32,
                                          color: Colors.orangeAccent,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '$tMax°C',
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '/ $tMin°C',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      dayLabel,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _HourForecast(
                                          icon: skyIcon(precipAt(0), 0),
                                          temp: tempAt(0).round(),
                                          label: '00:00',
                                        ),
                                        _HourForecast(
                                          icon: skyIcon(precipAt(6), 6),
                                          temp: tempAt(6).round(),
                                          label: '06:00',
                                        ),
                                        _HourForecast(
                                          icon: skyIcon(precipAt(12), 12),
                                          temp: tempAt(12).round(),
                                          label: '12:00',
                                        ),
                                        _HourForecast(
                                          icon: skyIcon(precipAt(18), 18),
                                          temp: tempAt(18).round(),
                                          label: '18:00',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Post-it KPI
class _PostIt extends StatelessWidget {
  final String title;
  final String amount;
  final double deltaPercent;
  final Color color;
  const _PostIt({
    Key? key,
    required this.title,
    required this.amount,
    required this.deltaPercent,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isPositive = deltaPercent >= 0;
    final Color deltaColor = isPositive ? Colors.green : Colors.red;
    final String sign = isPositive ? '+' : '−';
    final String percentText = "$sign${deltaPercent.abs().toStringAsFixed(2)}%";
    return Transform.rotate(
      angle: 0.012,
      child: Container(
        width: 230,
        height: 130,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black12, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.north_east : Icons.south_east,
                  color: deltaColor,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  percentText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: deltaColor,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'vs anno prec.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HourForecast extends StatelessWidget {
  final IconData icon;
  final int temp;
  final String label;
  const _HourForecast({
    Key? key,
    required this.icon,
    required this.temp,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey),
        const SizedBox(height: 2),
        Text('$temp°', style: const TextStyle(fontSize: 13)),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }
}
