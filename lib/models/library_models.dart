import '../services/library_detail_service.dart';
import '../utils/library_utils.dart';

class CategoryModel {
  final int id;
  final String name;

  const CategoryModel({
    required this.id,
    required this.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: intValue(json['id']) ?? 0,
      name: stringValue(
        json['name'] ?? json['title'] ?? json['category_name'],
        fallback: 'Unknown',
      ),
    );
  }
}

class Book {
  final String id;
  final String title;
  final String author;
  final List<String> categories;
  final List<String> tags;
  final String description;
  final String coverUrl;
  final String fileUrl;
  final String publishYear;
  final int viewCount;
  final bool isFavorite;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.categories,
    required this.tags,
    required this.description,
    required this.coverUrl,
    this.fileUrl = '',
    this.publishYear = '',
    this.viewCount = 0,
    this.isFavorite = false,
  });

  factory Book.fromJson(
      Map<String, dynamic> json, [
        LibraryDetailService? service,
      ]) {
    final category = json['category'];
    final authorJson = json['author'];
    final user = json['user'];

    return Book(
      id: stringValue(json['id'] ?? json['book_id'] ?? json['item_id']),
      title: stringValue(json['title'] ?? json['name'], fallback: 'Untitled'),
      author: authorName(authorJson, user, json),
      categories: stringList(
        json['categories'] ?? json['category'],
        fallbackSingle: json['category_name'] ??
            json['category_title'] ??
            (category is Map ? category['name'] : category),
      ),
      tags: stringList(
        json['tags'] ?? json['book_tags'] ?? json['tag'] ?? json['tag_names'],
        fallbackSingle: json['tag_name'],
      ),
      description: stringValue(
        json['description'] ?? json['summary'],
        fallback: 'No description available.',
      ),
      coverUrl: assetUrl(
        stringValue(
          json['cover_url'] ??
              json['cover'] ??
              json['image'] ??
              json['thumbnail'],
        ),
        service,
      ),
      fileUrl: assetUrl(
        stringValue(json['file_url'] ?? json['file'] ?? json['pdf']),
        service,
      ),
      publishYear: stringValue(
        json['publish_year'] ?? json['year'] ?? json['published_at'],
      ),
      viewCount: viewCountValue(json),
      isFavorite: boolValue(
        json['is_favorite'] ?? json['favorite'] ?? json['favorited'],
      ),
    );
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    List<String>? categories,
    List<String>? tags,
    String? description,
    String? coverUrl,
    String? fileUrl,
    String? publishYear,
    int? viewCount,
    bool? isFavorite,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      publishYear: publishYear ?? this.publishYear,
      viewCount: viewCount ?? this.viewCount,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  String get categoryText {
    return categories.isEmpty ? 'No Category' : categories.join(', ');
  }

  String get tagText {
    return tags.isEmpty ? 'No Tags' : tags.join(', ');
  }
}