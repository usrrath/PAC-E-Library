import 'dart:convert';

/// =======================
/// Item Model
/// =======================

ItemModel itemModelFromJson(String str) {
  return ItemModel.fromJson(jsonDecode(str));
}

String itemModelToJson(ItemModel data) {
  return jsonEncode(data.toJson());
}

class ItemModel {
  final String? message;
  final List<Item> items;

  ItemModel({
    this.message,
    required this.items,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      message: json['message']?.toString(),
      items: json['items'] == null
          ? []
          : List<Item>.from(
        (json['items'] as List).map(
              (x) => Item.fromJson(x),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'items': items.map((x) => x.toJson()).toList(),
    };
  }
}

/// =======================
/// Single Item
/// =======================

class Item {
  final String id;
  final String title;
  final String slug;

  final String? description;
  final String? coverUrl;
  final String? fileUrl;

  final String categoryId;
  final String? authorId;

  final String? publishYear;
  final int pages;

  final String? language;

  final int viewCount;
  final bool isActive;

  final String? userIdCreated;
  final String? userIdUpdated;

  final String? createdAt;
  final String? updatedAt;

  Item({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.coverUrl,
    this.fileUrl,
    required this.categoryId,
    this.authorId,
    this.publishYear,
    required this.pages,
    this.language,
    required this.viewCount,
    required this.isActive,
    this.userIdCreated,
    this.userIdUpdated,
    this.createdAt,
    this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id']?.toString() ?? '',

      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',

      description: json['description']?.toString(),

      coverUrl: json['cover_url']?.toString(),
      fileUrl: json['file_url']?.toString(),

      categoryId: json['category_id']?.toString() ?? '',

      authorId: json['author_id']?.toString(),

      publishYear: json['publish_year']?.toString(),

      pages: int.tryParse(
        json['pages']?.toString() ?? '0',
      ) ??
          0,

      language: json['language']?.toString(),

      viewCount: int.tryParse(
        json['view_count']?.toString() ?? '0',
      ) ??
          0,

      isActive: json['is_active'] == 1 ||
          json['is_active'] == true ||
          json['is_active']?.toString() == '1',

      userIdCreated: json['user_id_created']?.toString(),

      userIdUpdated: json['user_id_updated']?.toString(),

      createdAt: json['created_at']?.toString(),

      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,

      'title': title,
      'slug': slug,

      'description': description,

      'cover_url': coverUrl,
      'file_url': fileUrl,

      'category_id': categoryId,

      'author_id': authorId,

      'publish_year': publishYear,

      'pages': pages,

      'language': language,

      'view_count': viewCount,

      'is_active': isActive ? 1 : 0,

      'user_id_created': userIdCreated,

      'user_id_updated': userIdUpdated,

      'created_at': createdAt,

      'updated_at': updatedAt,
    };
  }

  /// =======================
  /// Helpers
  /// =======================

  bool get hasCover =>
      coverUrl != null && coverUrl!.trim().isNotEmpty;

  bool get hasFile =>
      fileUrl != null && fileUrl!.trim().isNotEmpty;

  String get displayLanguage =>
      language == null || language!.isEmpty
          ? 'Unknown'
          : language!;

  String get displayPublishYear =>
      publishYear == null || publishYear!.isEmpty
          ? '-'
          : publishYear!;
}