import 'core_types.dart';

/// Base class that all manhwa sources must implement
abstract class ManhwaSource {
  /// returns chapter image urls from chapterUrl.
  Future<List<String>> getChapterImages(String chapterUrl) async {
    throw UnimplementedError();
  }

  /// Gets manga details from manga page url
  Future<MangaDetails> getMangaDetails(String mangaUrl) async {
    throw UnimplementedError();
  }

  /// Gets all popular manga on manhwa site
  ///
  ///  __page__ (int): defaults to 1
  Future<List<MangaSearchResult>> popular({int page = 1}) async {
    throw UnimplementedError();
  }

  /// Searches for a query on manhwa site
  Future<List<MangaSearchResult>> search(String query) async {
    throw UnimplementedError();
  }

  /// Searches for a query on manhwa site
  Future<List<MangaSearchResult>> updates({int page = 1}) async {
    throw UnimplementedError();
  }
}
