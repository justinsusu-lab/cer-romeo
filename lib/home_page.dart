import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CER Romeo - Dashboard ESP32'),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance.ref('cer_data/current').onValue,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Errore
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text('Errore: ${snapshot.error}'),
                ],
              ),
            );
          }

          // Nessun dato
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 64),
                  SizedBox(height: 16),
                  Text('ESP32 non connesso'),
                ],
              ),
            );
          }

          // Leggi i dati
          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final double produzione = (data['produzione'] ?? 0).toDouble();
          final double consumo = (data['consumo'] ?? 0).toDouble();
          final double immissione = (data['immissione'] ?? 0).toDouble();
          final String stato = data['stato'] ?? 'error';

          // Mostra i dati
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Stato
                Card(
                  color: stato == 'ok' ? Colors.green[100] : Colors.orange[100],
                  child: ListTile(
                    leading: Icon(
                      stato == 'ok' ? Icons.check_circle : Icons.warning,
                      color: stato == 'ok' ? Colors.green : Colors.orange,
                      size: 40,
                    ),
                    title: Text(
                      stato == 'ok' ? 'Sistema OK' : 'Attenzione',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text('Dati ESP32 in tempo reale'),
                  ),
                ),
                const SizedBox(height: 16),

                // Produzione
                Card(
                  color: Colors.green[50],
                  child: ListTile(
                    leading: const Icon(Icons.wb_sunny, size: 40, color: Colors.green),
                    title: const Text('PRODUZIONE'),
                    subtitle: Text(
                      '${produzione.toStringAsFixed(2)} kW',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Consumo
                Card(
                  color: Colors.orange[50],
                  child: ListTile(
                    leading: const Icon(Icons.bolt, size: 40, color: Colors.orange),
                    title: const Text('CONSUMO'),
                    subtitle: Text(
                      '${consumo.toStringAsFixed(2)} kW',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Immissione
                Card(
                  color: Colors.blue[50],
                  child: ListTile(
                    leading: const Icon(Icons.publish, size: 40, color: Colors.blue),
                    title: const Text('IMMISSIONE'),
                    subtitle: Text(
                      '${immissione.toStringAsFixed(2)} kW',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
