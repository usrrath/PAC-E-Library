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
  final String publisher;
  final double rating;
  final List<String> categories;
  final List<String> tags;
  final String description;
  final String coverUrl;
  final String fileUrl;
  final String publishYear;
  final List<BookReview> reviews;
  final bool isFavorite;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.rating,
    required this.categories,
    required this.tags,
    required this.description,
    required this.coverUrl,
    this.fileUrl = '',
    this.publishYear = '',
    this.reviews = const [],
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
      publisher: stringValue(json['publisher'], fallback: 'Unknown Publisher'),
      rating: doubleValue(json['rating']) ?? 0.0,
      categories: stringList(
        json['categories'],
        fallbackSingle: category is Map ? category['name'] : category,
      ),
      tags: stringList(json['tags']),
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
      isFavorite: boolValue(
        json['is_favorite'] ?? json['favorite'] ?? json['favorited'],
      ),
    );
  }
}

class BookReview {
  final String user;
  final double rating;
  final String comment;

  const BookReview({
    required this.user,
    required this.rating,
    required this.comment,
  });
}