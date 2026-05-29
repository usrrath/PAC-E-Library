import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/favorite_helpers.dart';
import '../models/library_models.dart';
import '../services/library_detail_service.dart';
import '../services/profile_service.dart';
import '../services/user_service.dart';
import '../utils/favorites_utils.dart';

class FavoritesService {
  final UserService _userService = UserService();
  final LibraryDetailService _detailService = LibraryDetailService();

  String _token = '';

  Future<Map<String, String>> _headers() async {
    _token = (await ProfileService.getToken())?.trim() ?? '';

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (_token.isNotEmpty) 'Authorization': 'Bearer $_token',
    };
  }

  Future<FavoritesResult> loadFavorites() async {
    final headers = await _headers();

    final response = await http.get(
      Uri.parse(_userService.apiUrl('/api/users/favorites')),
      headers: headers,
    );

    if (!_success(response.statusCode)) {
      throw Exception('Failed to load favorites');
    }

    final decoded = jsonDecode(response.body);
    final favorites = extractFavorites(decoded);

    final books = <Book>[];
    final categories = <String, List<String>>{};
    final tags = <String, List<String>>{};

    for (final item in favorites) {
      if (item is! Map) continue;

      final wrapper = Map<String, dynamic>.from(item);
      final bookJson = extractBook(wrapper);

      final bookId = clean(
        bookJson['id'] ??
            bookJson['book_id'] ??
            bookJson['item_id'] ??
            wrapper['book_id'] ??
            wrapper['item_id'] ??
            wrapper['id'],
      );

      if (bookId.isEmpty) continue;

      final categoryList = await _loadBookCategories(bookId);
      final tagList = listFromValue(
        bookJson['tags'] ??
            wrapper['tags'] ??
            bookJson['tag'] ??
            wrapper['tag'] ??
            bookJson['book_tags'] ??
            wrapper['book_tags'],
      );

      bookJson['id'] = bookId;
      bookJson['categories'] = categoryList;
      bookJson['category'] = categoryList.isNotEmpty ? categoryList.first : '';
      bookJson['category_name'] =
      categoryList.isNotEmpty ? categoryList.first : '';
      bookJson['tags'] = tagList;

      final book = Book.fromJson(bookJson, _detailService);
      if (book.id.trim().isEmpty) continue;

      final viewCount = await _loadViewCount(book);

      final fixedBook = book.copyWith(
        viewCount: viewCount > 0 ? viewCount : book.viewCount,
      );

      books.add(fixedBook);
      categories[fixedBook.id] = categoryList;
      tags[fixedBook.id] = tagList;
    }

    books.sort((a, b) {
      final viewCompare = b.viewCount.compareTo(a.viewCount);
      if (viewCompare != 0) return viewCompare;
      return yearValue(b.publishYear).compareTo(yearValue(a.publishYear));
    });

    return FavoritesResult(
      books: books,
      categories: categories,
      tags: tags,
    );
  }

  Future<List<String>> _loadBookCategories(String bookId) async {
    try {
      final detail = await _detailService.getBookDetail(bookId);

      return detail.categories
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .where((e) => !invalidCategory(e))
          .toSet()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<int> _loadViewCount(Book book) async {
    try {
      final response = await _userService.getBookViewsCount(
        token: _token,
        bookId: book.id,
      );

      return extractViewCount(response);
    } catch (_) {
      return book.viewCount;
    }
  }

  Future<void> removeFavorite(String id) async {
    final response = await http.delete(
      Uri.parse(_userService.apiUrl('/api/books/$id/favorite')),
      headers: await _headers(),
    );

    if (!_success(response.statusCode)) {
      throw Exception('Remove failed');
    }
  }

  bool _success(int code) {
    return code >= 200 && code < 300;
  }
}