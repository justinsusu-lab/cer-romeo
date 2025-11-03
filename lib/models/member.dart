import 'measurements.dart';
import 'profile.dart';

enum MemberType { consumer, prosumer }

enum MemberCategory { pubblico, privato }

class Member {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final MemberType memberType;
  final MemberCategory category;
  final String pod; // Punto di prelievo energia
  final Profile profile;
  final Measurements measurements;
  final double incentivePercentage; // percentuale incentivo assegnata

  Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.memberType,
    required this.category,
    required this.pod,
    required this.profile,
    required this.measurements,
    required this.incentivePercentage,
  });
}
