class UserModel {
  final String id;
  final String phone;
  final String name;
  final String? avatar;
  final String role;
  final String? organization;

  UserModel({
    required this.id,
    required this.phone,
    required this.name,
    this.avatar,
    required this.role,
    this.organization,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        phone: json['phone'],
        name: json['name'],
        avatar: json['avatar'],
        role: json['role'],
        organization: json['organization'],
      );
}
