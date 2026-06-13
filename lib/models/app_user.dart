class AppUser {
  final String id;
  final String name;
  final String? email;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppUser({required this.id, required this.name, this.email, required this.createdAt, required this.updatedAt});

  AppUser copyWith({String? id, String? name, String? email, DateTime? createdAt, DateTime? updatedAt}) => AppUser(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: (json['id'] ?? '').toString(),
    name: (json['name'] ?? '').toString(),
    email: json['email']?.toString(),
    createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ?? DateTime.now(),
    updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()) ?? DateTime.now(),
  );
}
