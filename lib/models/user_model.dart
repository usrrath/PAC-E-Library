class UserModel {
  final String id;
  final String name;
  final String email;
  final String level;
  final String photo;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.level,
    required this.photo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: cleanText(json['id']),
      name: cleanText(json['name']),
      email: cleanText(json['email']),
      level: cleanText(json['level'] ?? json['role'], fallback: 'user'),
      photo: cleanText(
        json['photo'] ??
            json['photo_url'] ??
            json['profile_photo'] ??
            json['avatar'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'level': level,
      'photo': photo,
    };
  }
}

class AuthorModel {
  final String id;
  final String name;
  final String email;
  final String photo;
  final String level;

  const AuthorModel({
    required this.id,
    required this.name,
    required this.email,
    required this.photo,
    required this.level,
  });

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      id: cleanText(json['id']),
      name: cleanText(json['name'], fallback: 'Unknown author'),
      email: cleanText(json['email']),
      photo: cleanText(json['photo'] ?? json['photo_url'] ?? json['avatar']),
      level: cleanText(json['level'] ?? json['role'], fallback: 'author'),
    );
  }
}

String cleanText(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty || text == 'null') return fallback;
  return text;
}