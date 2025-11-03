import 'member.dart';
import 'production_plant.dart';
import 'incentive.dart';
import 'group.dart';

class Community {
  final String id;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String type;
  final String incentiveAlgorithm;
  final double managerPercentage;
  final double platformProviderPercentage;
  final DateTime createdAt;

  final List<Member> members;
  final List<ProductionPlant> plants;
  final Incentive incentive;
  final List<Group> groups;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.incentiveAlgorithm,
    required this.managerPercentage,
    required this.platformProviderPercentage,
    required this.createdAt,
    this.members = const [],
    this.plants = const [],
    required this.incentive,
    this.groups = const [],
  });
}
