import 'dart:io';

class ProfileEditResult {
  final String name;
  final File? photo;

  const ProfileEditResult({
    required this.name,
    this.photo,
  });
}

class BookMini {
  final String id;
  final String title;
  final String author;
  final String category;
  final String description;
  final String coverUrl;
  final String fileUrl;
  final String publishYear;
  final double progress;
  final int lastPage;
  final int totalPages;

  const BookMini({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.description,
    required this.coverUrl,
    required this.fileUrl,
    required this.publishYear,
    required this.progress,
    required this.lastPage,
    required this.totalPages,
  });

  double get normalizedProgress {
    final value = progress > 1 ? progress / 100 : progress;
    return value.clamp(0.0, 1.0).toDouble();
  }

  int get safeLastPage => lastPage <= 0 ? 1 : lastPage;

  int get safeTotalPages => totalPages <= 0 ? 0 : totalPages;

  bool get isInProgress {
    return normalizedProgress > 0 && normalizedProgress < 1;
  }

  BookMini copyWith({
    String? id,
    String? title,
    String? author,
    String? category,
    String? description,
    String? coverUrl,
    String? fileUrl,
    String? publishYear,
    double? progress,
    int? lastPage,
    int? totalPages,
  }) {
    return BookMini(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      category: category ?? this.category,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      publishYear: publishYear ?? this.publishYear,
      progress: progress ?? this.progress,
      lastPage: lastPage ?? this.lastPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

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