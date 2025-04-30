import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager extends CacheManager {
  static const key = 'image_cache';
  static CustomCacheManager? _instance;
  factory CustomCacheManager() {
    _instance ??= CustomCacheManager._();
    return _instance!;
  }
  CustomCacheManager._()
      : super(
          Config(
            key,
            stalePeriod: const Duration(days: 7),
            maxNrOfCacheObjects: 100,
            fileService: HttpFileService(),
          ),
        );
  Future<String?> cacheImage(String imageUrl) async {
    try {
      final file = await getSingleFile(imageUrl);
      return file.path;
    } catch (e) {
      return null;
    }
  }
}
