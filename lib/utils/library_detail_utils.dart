import '../models/library_detail_model.dart';
import '../models/library_models.dart';
import '../services/library_detail_service.dart';

class LibraryDetailUtils {
  const LibraryDetailUtils._();

  static Book toBook({
    required LibraryDetailModel item,
    required LibraryDetailService service,
    required String untitled,
    required String unknownAuthor,
    required String noDescription,
  }) {
    return Book(
      id: item.id.trim(),
      title: item.title.trim().isNotEmpty ? item.title.trim() : untitled,
      author: item.author.trim().isNotEmpty
          ? item.author.trim()
          : unknownAuthor,
      publisher: '',
      rating: 0,
      categories: item.categories,
      tags: item.tags,
      description: item.description.trim().isNotEmpty
          ? item.description.trim()
          : noDescription,
      coverUrl: service.fullUrl(item.coverUrl),
      reviews: const [],
    );
  }

  static String cleanError({
    required Object error,
    required String fallback,
  }) {
    final text = error.toString().replaceFirst('Exception: ', '').trim();
    return text.isEmpty ? fallback : text;
  }

  static String cleanYear(
      String? value, {
        required String unknown,
      }) {
    final year = value?.trim() ?? '';
    return year.isEmpty ? unknown : year;
  }
}