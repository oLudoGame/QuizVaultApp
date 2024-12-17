class QzUser {
  String id;
  String email;
  String name;

  QzUser({
    required this.id,
    required this.email,
    required this.name,
  });

  factory QzUser.fromJson(Map<String, dynamic> json) {
    return QzUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }
}
