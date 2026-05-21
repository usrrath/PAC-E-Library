import 'book_mini_model.dart';

class ReadingStats {
  final int inProgress;
  final int favorites;

  const ReadingStats({
    required this.inProgress,
    required this.favorites,
  });

  factory ReadingStats.fromData({
    required List<BookMini> favorites,
    required List<BookMini> history,
  }) {
    return ReadingStats(
      inProgress: history.where((book) => book.isInProgress).length,
      favorites: favorites.length,
    );
  }
}