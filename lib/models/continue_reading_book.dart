import '../models/library_models.dart';
import '../utils/continue_reading_utils.dart';

class ContinueReadingBook {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final int lastPage;
  final int totalPages;
  final double percent;

  const ContinueReadingBook({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.lastPage,
    required this.totalPages,
    required this.percent,
  });

  factory ContinueReadingBook.fromJson(Map<String, dynamic> json) {
    final item = itemJson(json);

    final lastPage = intAny([
      json['last_page'],
      json['lastPage'],
      json['current_page'],
      json['currentPage'],
      json['page'],
      json['last_read_page'],
      json['lastReadPage'],
      json['progress_page'],
      item['last_page'],
      item['lastPage'],
    ]);

    final totalPages = intAny([
      json['total_pages'],
      json['totalPages'],
      json['pages'],
      json['page_count'],
      json['pageCount'],
      item['total_pages'],
      item['totalPages'],
      item['pages'],
    ]);

    final rawPercent = doubleAny([
      json['percent'],
      json['progress'],
      json['percentage'],
      json['read_percent'],
      json['readPercent'],
    ]);

    final percent = rawPercent > 0
        ? rawPercent
        : totalPages > 0
        ? (lastPage / totalPages) * 100
        : 0.0;

    return ContinueReadingBook(
      id: stringValue(
        json,
        ['item_id', 'book_id', 'id'],
        fallback: stringValue(item, ['id', 'book_id', 'item_id']),
      ),
      title: stringValue(item, ['title', 'name'], fallback: 'Untitled'),
      author: authorName(item),
      coverUrl: fullUrl(
        stringValue(item, ['cover_url', 'cover', 'image', 'image_url']),
      ),
      lastPage: lastPage,
      totalPages: totalPages,
      percent: percent.clamp(0, 100).toDouble(),
    );
  }

  Book toBook() {
    return Book(
      id: id,
      title: title.trim().isEmpty ? 'Untitled' : title.trim(),
      author: author.trim().isEmpty ? 'Unknown Author' : author.trim(),
      categories: const [],
      tags: const [],
      description: 'No description available.',
      coverUrl: coverUrl,
      fileUrl: '',
      publishYear: '',
      isFavorite: false,
    );
  }
}