import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AppCacheManager {
  static const String key = 'pacELibraryImageCache';

  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 14),
      maxNrOfCacheObjects: 300,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

  static Future<void> clearImageCache() async {
    await instance.emptyCache();
  }
}