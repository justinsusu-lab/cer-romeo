import 'package:flutter/material.dart';
import '../../services/esp32_service.dart';

class ESP32MonitorWidget extends StatelessWidget {
  final ESP32Service _esp32Service = ESP32Service();

  ESP32MonitorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ESP32Data>(
      stream: _esp32Service.getDatiRealtime(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text('Errore: ${snapshot.error}'),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data ?? ESP32Data.empty();
        
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con stato
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Monitoraggio ESP32',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatoIndicator(data.stato),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Dati energetici
                _buildDataRow(
                  icon: Icons.wb_sunny,
                  label: 'Produzione',
                  value: data.produzione,
                  unit: 'kW',
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                _buildDataRow(
                  icon: Icons.bolt,
                  label: 'Consumo',
                  value: data.consumo,
                  unit: 'kW',
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildDataRow(
                  icon: Icons.published_with_changes,
                  label: 'Immissione',
                  value: data.immissione,
                  unit: 'kW',
                  color: Colors.blue,
                ),
                
                const SizedBox(height: 16),
                
                // Timestamp
                Text(
                  'Ultimo aggiornamento: ${_formatTimestamp(data.timestamp)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatoIndicator(String stato) {
    Color color;
    String label;
    IconData icon;

    switch (stato) {
      case 'ok':
        color = Colors.green;
        label = 'OK';
        icon = Icons.check_circle;
        break;
      case 'warning':
        color = Colors.orange;
        label = 'Attenzione';
        icon = Icons.warning;
        break;
      default:
        color = Colors.red;
        label = 'Errore';
        icon = Icons.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow({
    required IconData icon,
    required String label,
    required double value,
    required String unit,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${value.toStringAsFixed(2)} $unit',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(int timestamp) {
    if (timestamp == 0) return 'Mai';
    final now = DateTime.now();
    final seconds = now.millisecondsSinceEpoch ~/ 1000 - timestamp;
    
    if (seconds < 60) return '$seconds secondi fa';
    if (seconds < 3600) return '${seconds ~/ 60} minuti fa';
    return '${seconds ~/ 3600} ore fa';
  }
}
