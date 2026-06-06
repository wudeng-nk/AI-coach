class CustomerModel {
  final String id;
  final String name;
  final String avatar;
  final String difficulty;
  final String description;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.difficulty,
    required this.description,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        id: json['id'] as String,
        name: json['name'] as String,
        avatar: json['avatar'] as String,
        difficulty: json['difficulty'] as String,
        description: json['description'] as String,
      );
}

class CustomerDetailModel {
  final String id;
  final String name;
  final String avatar;
  final String difficulty;
  final Map<String, dynamic>? persona;
  final Map<String, dynamic>? scenario;

  const CustomerDetailModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.difficulty,
    this.persona,
    this.scenario,
  });

  factory CustomerDetailModel.fromJson(Map<String, dynamic> json) =>
      CustomerDetailModel(
        id: json['id'] as String,
        name: json['name'] as String,
        avatar: json['avatar'] as String,
        difficulty: json['difficulty'] as String,
        persona: json['persona'] as Map<String, dynamic>?,
        scenario: json['scenario'] as Map<String, dynamic>?,
      );
}
