class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  // final int roleId;
  final String role;
  final String profileStatus;
  final String? photoUrl;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    // required this.roleId,
    required this.role,
    required this.profileStatus,
    this.photoUrl,
  });
}