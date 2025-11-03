import 'dart:math';
import 'package:flutter/material.dart';

class MembriPage extends StatefulWidget {
  const MembriPage({Key? key}) : super(key: key);

  @override
  State<MembriPage> createState() => _MembriPageState();
}

class _Membro {
  final String nome;
  final String ruolo;
  final String stato;
  final int? produzione; // Solo se Prosumer
  final int? consumo; // Solo se Consumer

  _Membro(this.nome, this.ruolo, this.stato, {this.produzione, this.consumo});
}

class _MembriPageState extends State<MembriPage> {
  final List<_Membro> _membri = [];

  @override
  void initState() {
    super.initState();

    // Demo membri già presenti con stato/ruolo random e qualche produzione/consumo
    _membri.addAll([
      _Membro('Mario Rossi', 'Admin', 'Attivo'),
      _Membro(
        'Francesca Bianchi',
        'Prosumer',
        'Attivo',
        produzione: _randomProduzione(),
      ),
      _Membro(
        'Giuseppe Verdi',
        'Consumer',
        'Inattivo',
        consumo: _randomConsumo(),
      ),
      _Membro('Sara Neri', 'Gruppo Obiettivo', 'Attivo'),
      _Membro(
        'Anna Blu',
        'Prosumer',
        'Inattivo',
        produzione: _randomProduzione(),
      ),
      _Membro('Luigi Gialli', 'Consumer', 'Attivo', consumo: _randomConsumo()),
    ]);
  }

  static int _randomProduzione() {
    // Demo: impianto 100kW, assegna tra 10 e 40 kWh (per es.)
    return 10 + Random().nextInt(31);
  }

  static int _randomConsumo() {
    // Demo: assegna tra 5 e 30 kWh
    return 5 + Random().nextInt(26);
  }

  void _apriDialogAggiungiMembro() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String? nome = '';
        String? ruolo = 'Admin';
        String? stato = 'Attivo';
        int? produzione;
        int? consumo;

        return Padding(
          padding: MediaQuery.of(context).viewInsets, // feel safe with keyboard
          child: StatefulBuilder(
            builder: (context, setInnerState) => Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Aggiungi nuovo membro",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      onChanged: (v) => nome = v.trim(),
                      decoration: const InputDecoration(
                        labelText: "Nome e Cognome",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: ruolo,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: "Ruolo",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(child: Text("Admin"), value: "Admin"),
                        DropdownMenuItem(
                          child: Text("Prosumer"),
                          value: "Prosumer",
                        ),
                        DropdownMenuItem(
                          child: Text("Consumer"),
                          value: "Consumer",
                        ),
                        DropdownMenuItem(
                          child: Text("Gruppo Obiettivo"),
                          value: "Gruppo Obiettivo",
                        ),
                      ],
                      onChanged: (v) {
                        ruolo = v!;
                        setInnerState(
                          () {},
                        ); // forza refresh del dialog, per mostrare fields dinamici
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: stato,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: "Stato",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          child: Text("Attivo"),
                          value: "Attivo",
                        ),
                        DropdownMenuItem(
                          child: Text("Inattivo"),
                          value: "Inattivo",
                        ),
                      ],
                      onChanged: (v) {
                        stato = v!;
                        setInnerState(() {});
                      },
                    ),
                    const SizedBox(height: 16),

                    // Produzione solo per Prosumer
                    if (ruolo == "Prosumer") ...[
                      TextFormField(
                        // ignore: dead_code
                        initialValue:
                            // ignore: dead_code
                            produzione?.toString() ??
                            _randomProduzione().toString(),
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: "Produzione (kWh, demo auto-calcolata)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    // Consumo solo per Consumer
                    if (ruolo == "Consumer") ...[
                      TextFormField(
                        initialValue:
                            // ignore: dead_code
                            consumo?.toString() ?? _randomConsumo().toString(),
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: "Consumo (kWh, demo auto-calcolato)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () {
                              if ((nome?.isNotEmpty ?? false) &&
                                  ruolo != null &&
                                  stato != null) {
                                Navigator.pop(context);
                                setState(() {
                                  _membri.add(
                                    _Membro(
                                      nome!,
                                      ruolo!,
                                      stato!,
                                      produzione: ruolo == "Prosumer"
                                          ? _randomProduzione()
                                          : null,
                                      consumo: ruolo == "Consumer"
                                          ? _randomConsumo()
                                          : null,
                                    ),
                                  );
                                });
                              }
                            },
                            child: const Text("Salva"),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Annulla"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _ruoloColore(String ruolo) {
    switch (ruolo) {
      case "Admin":
        return Colors.red;
      case "Prosumer":
        return Colors.blue;
      case "Consumer":
        return Colors.green;
      case "Gruppo Obiettivo":
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _statoIcona(String stato) {
    return stato == 'Attivo' ? Icons.check_circle : Icons.cancel;
  }

  Color _statoColore(String stato) {
    return stato == 'Attivo' ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestione Membri"),
        backgroundColor: const Color(0xFF43AA8B),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _apriDialogAggiungiMembro,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, size: 30),
        tooltip: 'Aggiungi membro',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 8),
            // Elenco membri
            ..._membri.map(
              (membro) => Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _ruoloColore(membro.ruolo),
                    child: Text(
                      membro.ruolo[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    membro.nome,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            membro.ruolo,
                            style: TextStyle(
                              color: _ruoloColore(membro.ruolo),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (membro.ruolo == 'Prosumer' &&
                              membro.produzione != null) ...[
                            const SizedBox(width: 14),
                            Text(
                              "Produzione: ${membro.produzione} kWh",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                          if (membro.ruolo == 'Consumer' &&
                              membro.consumo != null) ...[
                            const SizedBox(width: 14),
                            Text(
                              "Consumo: ${membro.consumo} kWh",
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
                            _statoIcona(membro.stato),
                            color: _statoColore(membro.stato),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            membro.stato,
                            style: TextStyle(
                              color: _statoColore(membro.stato),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
