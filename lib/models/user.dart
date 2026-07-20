import 'dart:convert';

class User {
  final String id;
  final String email;
  final String name;
  final String lastName;

  User({
    required this.id,
    required this.email,
    this.name = 'User',
    this.lastName = '',
  });

  User copyWith({String? id, String? email, String? name, String? lastName}) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'email': email, 'name': name, 'lastName': lastName};
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? 'Usuário',
      lastName: map['lastName'] as String? ?? '',
    );
  }

  String get fullName => '$name $lastName'.trim();

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
