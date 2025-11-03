class Profile {
  final String role; // es. 'Utente', 'Amministratore'
  final String phoneNumber;
  final String address; // indirizzo o altre info

  Profile({
    required this.role,
    required this.phoneNumber,
    required this.address,
  });
}
