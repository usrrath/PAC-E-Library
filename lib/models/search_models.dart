import '../models/library_models.dart';
import '../utils/search_utils.dart';

class BookItem {
  final String id;
  final String title;
  final String author;
  final String category;
  final String language;
  final String coverUrl;
  final String description;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int publishYear;

  int viewsCount;

  BookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.language,
    required this.coverUrl,
    required this.description,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.publishYear,
    required this.viewsCount,
  });

  factory BookItem.fromJson(Map<String, dynamic> json) {
    final authorMap = json['author'];
    final categoryMap = json['category'];

    return BookItem(
      id: strValue(json, const ['id', 'book_id', 'item_id']),
      title: strValue(json, const ['title', 'name']),
      author: authorMap is Map
          ? strValue(authorMap, const ['name', 'username', 'full_name'])
          : strValue(json, const ['author_name', 'author', 'writer']),
      category: categoryMap is Map
          ? strValue(categoryMap, const ['name', 'title'])
          : strValue(json, const ['category_name', 'category']),
      language: strValue(json, const ['language', 'lang']),
      coverUrl: strValue(json, const [
        'cover_url',
        'cover',
        'image',
        'image_url',
        'thumbnail',
        'photo',
      ]),
      description: strValue(json, const [
        'description',
        'summary',
        'content',
        'short_description',
      ]),
      tags: tagsValue(json),
      createdAt: parseDateValue(json, const [
        'created_at',
        'createdAt',
      ]),
      updatedAt: parseDateValue(json, const [
        'updated_at',
        'updatedAt',
      ]),
      publishYear: intValue(json, const [
        'publish_year',
        'publishYear',
        'year',
      ]),
      viewsCount: intValue(json, const [
        'views_count',
        'view_count',
        'views',
        'total_views',
        'total_reads',
        'reads_count',
        'popularity',
      ]),
    );
  }

  String get displayTitle => title.trim().isEmpty ? 'Untitled' : title.trim();

  String get displayAuthor =>
      author.trim().isEmpty ? 'Unknown Author' : author.trim();

  int get dateValue {
    final date = updatedAt ?? createdAt;

    if (date != null) {
      return date.millisecondsSinceEpoch;
    }

    if (publishYear > 0) {
      return DateTime(publishYear).millisecondsSinceEpoch;
    }

    return 0;
  }

  Book toBook() {
    return Book(
      id: id.trim(),
      title: displayTitle,
      author: displayAuthor,
      categories: category.trim().isEmpty ? const [] : [category.trim()],
      tags: tags,
      description: description.trim(),
      coverUrl: coverUrl.trim(),
      publishYear: publishYear > 0 ? publishYear.toString() : '',
      viewCount: viewsCount,
    );
  }
}