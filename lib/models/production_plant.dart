class ProductionPlant {
  final String id;
  final String name;
  final String type; // es. fotovoltaico, eolico
  final double capacityKW;
  final double latitude;
  final double longitude;
  // Eventuali parametri per il calcolo incentivi

  ProductionPlant({
    required this.id,
    required this.name,
    required this.type,
    required this.capacityKW,
    required this.latitude,
    required this.longitude,
  });
}
