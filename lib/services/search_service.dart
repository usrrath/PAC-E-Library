import '../models/search_models.dart';
import '../services/user_service.dart';
import '../utils/search_utils.dart';

class SearchService {
  final UserService _userService = UserService();

  Future<List<BookItem>> getBooks() async {
    final response = await _userService.getItems(
      page: 1,
      perPage: 200,
    );

    return extractBooks(response);
  }

  Future<List<BookItem>> getSuggestedBooks() async {
    final response = await _userService.getSuggestedBooks(
      limit: 50,
    );

    return extractBooks(response);
  }

  Future<List<String>> getTrendingSearches() async {
    final response = await _userService.getTrendingSearches(
      limit: 10,
    );

    return extractTrending(response);
  }

  Future<void> loadBookViews(List<BookItem> books) async {
    await Future.wait(
      books.map((book) async {
        try {
          final response = await _userService.getBookViewsCount(
            bookId: book.id,
          );

          final data = extractData(response);

          if (data is Map) {
            book.viewsCount = intValue(data, const [
              'views_count',
              'view_count',
              'views',
              'total_views',
              'total_reads',
              'count',
            ]);
          }
        } catch (_) {}
      }),
    );
  }

  List<BookItem> extractBooks(Map<String, dynamic> json) {
    dynamic data = json['items'] ??
        json['books'] ??
        json['data'] ??
        json['results'] ??
        json['suggested'] ??
        json['recommended'] ??
        [];

    if (data is Map && data['data'] is List) {
      data = data['data'];
    }

    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map(
          (e) => BookItem.fromJson(
        Map<String, dynamic>.from(e),
      ),
    )
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

    if (data is! List) {
      return [];
    }

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