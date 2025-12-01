import 'package:firebase_database/firebase_database.dart';

class ESP32Data {
  final double produzione;
  final double consumo;
  final double immissione;
  final int timestamp;
  final String stato;

  ESP32Data({
    required this.produzione,
    required this.consumo,
    required this.immissione,
    required this.timestamp,
    required this.stato,
  });

  factory ESP32Data.fromMap(Map<dynamic, dynamic> map) {
    return ESP32Data(
      produzione: (map['produzione'] ?? 0).toDouble(),
      consumo: (map['consumo'] ?? 0).toDouble(),
      immissione: (map['immissione'] ?? 0).toDouble(),
      timestamp: map['timestamp'] ?? 0,
      stato: map['stato'] ?? 'error',
    );
  }

  factory ESP32Data.empty() {
    return ESP32Data(
      produzione: 0,
      consumo: 0,
      immissione: 0,
      timestamp: 0,
      stato: 'error',
    );
  }
}

class ESP32Service {
  final DatabaseReference _dbRef = 
    FirebaseDatabase.instance.ref('cer_data/current');

  Stream<ESP32Data> getDatiRealtime() {
    return _dbRef.onValue.map((event) {
      if (event.snapshot.value != null && event.snapshot.value is Map) {
        return ESP32Data.fromMap(event.snapshot.value as Map);
      }
      return ESP32Data.empty();
    });
  }

  Future<ESP32Data> getDatiAttuali() async {
    final snapshot = await _dbRef.get();
    if (snapshot.exists && snapshot.value is Map) {
      return ESP32Data.fromMap(snapshot.value as Map);
    }
    return ESP32Data.empty();
  }
}
