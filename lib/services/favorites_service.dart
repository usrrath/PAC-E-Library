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

  static FavoritesResult? _cache;

  String _token = '';

  Future<Map<String, String>> _headers() async {
    _token = (await ProfileService.getToken())?.trim() ?? '';

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (_token.isNotEmpty) 'Authorization': 'Bearer $_token',
    };
  }

  Future<FavoritesResult> loadFavorites({bool refresh = false}) async {
    if (!refresh && _cache != null) return _cache!;

    final response = await http
        .get(
      Uri.parse(_userService.apiUrl('/api/users/favorites')),
      headers: await _headers(),
    )
        .timeout(const Duration(seconds: 15));

    if (!_success(response.statusCode)) {
      throw Exception('Failed to load favorites');
    }

    final decoded = response.body.trim().isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);

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

      final categoryList = _extractCategories(bookJson, wrapper);
      final tagList = _extractTags(bookJson, wrapper);

      bookJson['id'] = bookId;
      bookJson['categories'] = categoryList;
      bookJson['category'] = categoryList.isNotEmpty ? categoryList.first : '';
      bookJson['category_name'] =
      categoryList.isNotEmpty ? categoryList.first : '';
      bookJson['tags'] = tagList;

      final book = Book.fromJson(bookJson, _detailService);
      if (book.id.trim().isEmpty) continue;

      books.add(book);
      categories[book.id] = categoryList;
      tags[book.id] = tagList;
    }

    books.sort((a, b) {
      final viewCompare = b.viewCount.compareTo(a.viewCount);
      if (viewCompare != 0) return viewCompare;
      return yearValue(b.publishYear).compareTo(yearValue(a.publishYear));
    });

    final result = FavoritesResult(
      books: books,
      categories: categories,
      tags: tags,
    );

    _cache = result;
    return result;
  }

  List<String> _extractCategories(
      Map<String, dynamic> bookJson,
      Map<String, dynamic> wrapper,
      ) {
    final raw = bookJson['categories'] ??
        wrapper['categories'] ??
        bookJson['category'] ??
        wrapper['category'] ??
        bookJson['category_name'] ??
        wrapper['category_name'];

    return listFromValue(raw)
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .where((e) => !invalidCategory(e))
        .toSet()
        .toList();
  }

  List<String> _extractTags(
      Map<String, dynamic> bookJson,
      Map<String, dynamic> wrapper,
      ) {
    final raw = bookJson['tags'] ??
        wrapper['tags'] ??
        bookJson['tag'] ??
        wrapper['tag'] ??
        bookJson['book_tags'] ??
        wrapper['book_tags'];

    return listFromValue(raw)
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  Future<void> removeFavorite(String id) async {
    final response = await http
        .delete(
      Uri.parse(_userService.apiUrl('/api/books/$id/favorite')),
      headers: await _headers(),
    )
        .timeout(const Duration(seconds: 15));

    if (!_success(response.statusCode)) {
      throw Exception('Remove failed');
    }

    _cache = null;
  }

  static void clearCache() {
    _cache = null;
  }

  bool _success(int code) => code >= 200 && code < 300;
}