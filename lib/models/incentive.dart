class Incentive {
  final String id;
  final String type; // Tipo incentivo
  final int year;
  final double totalValue;

  // Mappa membroId -> valore incentivo assegnato
  final Map<String, double> distribution;

  Incentive({
    required this.id,
    required this.type,
    required this.year,
    required this.totalValue,
    required this.distribution,
  });
}
