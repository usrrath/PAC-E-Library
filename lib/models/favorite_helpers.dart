import '../models/library_models.dart';

class FavoritesResult {
  final List<Book> books;
  final Map<String, List<String>> categories;
  final Map<String, List<String>> tags;

  const FavoritesResult({
    required this.books,
    required this.categories,
    required this.tags,
  });
}