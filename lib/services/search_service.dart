import '../models/search_models.dart';
import '../services/user_service.dart';
import '../utils/search_utils.dart';

class SearchService {
  final UserService _userService = UserService();

  Future<List<BookItem>> getBooks() async {
    final response = await _userService.getItems(
      page: 1,
      perPage: 200,
      filter: 'all',
    );

    return extractBooks(response);
  }

  Future<List<BookItem>> getSuggestedBooks() async {
    final response = await _userService.getSuggestedBooks(limit: 50);
    return extractBooks(response);
  }

  Future<List<String>> getTrendingSearches() async {
    final response = await _userService.getTrendingSearches(limit: 10);
    return extractTrending(response);
  }

  Future<void> loadBookViews(List<BookItem> books) async {
    await Future.wait(
      books.map((book) async {
        final id = book.id.trim();
        if (id.isEmpty) return;

        try {
          final response = await _userService.getBookViewsCount(bookId: id);
          book.viewsCount = readViewCount(response);
        } catch (_) {
          // Keep existing value from item API.
        }
      }),
    );
  }

  int readViewCount(Map<String, dynamic> response) {
    final direct = intValue(response, const [
      'views_count',
      'view_count',
      'views',
      'total_views',
      'total_reads',
      'count',
    ]);

    if (direct > 0) return direct;

    final data = response['data'];

    if (data is Map) {
      return intValue(Map<String, dynamic>.from(data), const [
        'views_count',
        'view_count',
        'views',
        'total_views',
        'total_reads',
        'count',
      ]);
    }

    return 0;
  }

  List<BookItem> extractBooks(Map<String, dynamic> json) {
    dynamic data = json['items'] ??
        json['books'] ??
        json['data'] ??
        json['results'] ??
        json['suggested'] ??
        json['recommended'] ??
        [];

    if (data is Map) {
      data = data['data'] ??
          data['items'] ??
          data['books'] ??
          data['results'] ??
          data['suggested'] ??
          data['recommended'] ??
          [];
    }

    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map((e) => BookItem.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => e.id.trim().isNotEmpty)
        .toList();
  }

  List<String> extractTrending(Map<String, dynamic> json) {
    dynamic data = json['data'] ??
        json['trending'] ??
        json['searches'] ??
        json['keywords'] ??
        json['items'] ??
        [];

    if (data is Map && data['data'] is List) {
      data = data['data'];
    }

    if (data is! List) return [];

    return data
        .map((e) {
      if (e is String) return e.trim();

      if (e is Map) {
        return strValue(e, const [
          'keyword',
          'query',
          'search',
          'term',
          'title',
          'name',
        ]);
      }

      return e.toString().trim();
    })
        .where((e) => e.isNotEmpty && e != 'null')
        .toSet()
        .toList();
  }
}