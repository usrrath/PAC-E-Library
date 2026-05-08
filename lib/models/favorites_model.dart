import 'dart:convert';

/// =======================
/// User Favorite Book Model
/// =======================

UserFavoriteBookModel userFavoriteBookModelFromJson(String str) {
  return UserFavoriteBookModel.fromJson(jsonDecode(str));
}

String userFavoriteBookModelToJson(UserFavoriteBookModel data) {
  return jsonEncode(data.toJson());
}

class UserFavoriteBookModel {
  final String? message;
  final List<UserFavoriteBook> favorites;

  UserFavoriteBookModel({
    this.message,
    required this.favorites,
  });

  factory UserFavoriteBookModel.fromJson(Map<String, dynamic> json) {
    return UserFavoriteBookModel(
      message: json['message']?.toString(),
      favorites: json['favorites'] == null
          ? []
          : List<UserFavoriteBook>.from(
        (json['favorites'] as List).map(
              (x) => UserFavoriteBook.fromJson(x),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'favorites': favorites.map((x) => x.toJson()).toList(),
    };
  }
}

/// =======================
/// Single Favorite Book
/// =======================

class UserFavoriteBook {
  final String id;

  final String userId;

  final String bookId;

  final String? createdAt;

  UserFavoriteBook({
    required this.id,
    required this.userId,
    required this.bookId,
    this.createdAt,
  });

  factory UserFavoriteBook.fromJson(Map<String, dynamic> json) {
    return UserFavoriteBook(
      id: json['id']?.toString() ?? '',

      userId: json['user_id']?.toString() ?? '',

      bookId: json['book_id']?.toString() ?? '',

      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,

      'user_id': userId,

      'book_id': bookId,

      'created_at': createdAt,
    };
  }

  /// =======================
  /// Helpers
  /// =======================

  bool get isValid =>
      id.isNotEmpty &&
          userId.isNotEmpty &&
          bookId.isNotEmpty;
}