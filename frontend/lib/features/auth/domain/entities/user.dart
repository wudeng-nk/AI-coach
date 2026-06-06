class User {
  final String id;
  final String phone;
  final String name;
  final String? avatar;
  final String role;

  const User({
    required this.id,
    required this.phone,
    required this.name,
    this.avatar,
    required this.role,
  });
}
