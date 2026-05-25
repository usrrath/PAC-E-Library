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
    final id = item.id.trim();
    final title = item.title.trim();
    final author = item.author.trim();
    final description = item.description.trim();

    return Book(
      id: id,
      title: title.isNotEmpty ? title : untitled,
      author: author.isNotEmpty ? author : unknownAuthor,
      categories: item.categories,
      tags: item.tags,
      description: description.isNotEmpty ? description : noDescription,
      coverUrl: service.fullUrl(item.coverUrl),
      fileUrl: service.fullUrl(item.fileUrl),
      publishYear: item.year.trim(),
      viewCount: 0,
      isFavorite: false,
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