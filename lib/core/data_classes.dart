/// Contains the chapter data for each chapter in the manga:
/// - __chapterNumber__: (*double*) number of chapter
/// - __releasedOn__: (*DateTime*) date the chapter is released on
/// - __chapterUrl__: (*String*) the url for the chapter
class MangaChapterData {
  final double chapterNumber;
  final DateTime releasedOn;
  final String chapterUrl;

  MangaChapterData(
    this.chapterNumber,
    this.releasedOn,
    this.chapterUrl,
  );
}

/// Contains manga status
///
/// The status can be:
/// - completed
/// - ongoing
/// - hiatus
/// - cancelled
enum MangaStatus {
  completed,
  ongoing,
  hiatus,
  cancelled,
  none,
}

/// Conatins the manga details:
/// - __title__: (*String*) manga tile
/// - __description__: (*String*) manga description
/// - __coverUrl__: (*String*) manga cover url
/// - __status__: (*MangaStatus*) manga status
/// - __rating__: (*double*) manga rating out of 10.0
/// - __followedByCount__: (*int*) number of followers to the manga series
/// - __yearReleased__: (*int*) year the manga was released
/// - __chapters__: (*List<MangaChapterData>*) chapters of the manga
class MangaDetails {
  final String title;
  final String description;
  final String coverUrl;

  final MangaStatus status;

  final double rating;
  final int followedByCount;
  final DateTime releasedAt;

  /// sorted in ascending order
  final List<MangaChapterData> chapters;
  final List<String> tags;

  MangaDetails(
    this.title,
    this.description,
    this.coverUrl,
    this.followedByCount,
    this.rating,
    this.status,
    this.releasedAt,
    this.chapters,
    this.tags,
  );

  /// Returns an empty MangaDetails object
  static MangaDetails empty() {
    return MangaDetails(
      '',
      '',
      '',
      0,
      0.0,
      MangaStatus.none,
      DateTime.now(),
      [],
      [],
    );
  }

  @override
  String toString() {
    return '''MangaDetails(\n
    title: $title,\n
    description: `$description`,\n
    coverUrl: $coverUrl,\n
    followedByCount: $followedByCount,\n
    rating: $rating,\n
    status: $status,\n
    releasedAt: $releasedAt,\n
    number of chapters: ${chapters.length},\n
    tags: $tags,\n
    )''';
  }
}

/// Data for each manga search result
///
/// Conatins:
/// - __coverUrl__: (*String*) cover url
/// - __title__: (*String*) title
/// - __latestChapter__: (*double*) latest chapter number
/// - __rating__: (*double*) rating out of 10.0
/// - __mangaUrl__: (*String*) manga url
class MangaSearchResult {
  final String coverUrl;
  final String title;
  final double latestChapterNumber;
  final double rating;
  final String mangaUrl;

  MangaSearchResult(
    this.coverUrl,
    this.title,
    this.latestChapterNumber,
    this.rating,
    this.mangaUrl,
  );
}

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
  Future<List<MangaSearchResult>> popular() async {
    throw UnimplementedError();
  }

  /// Searches for a query on manhwa site
  Future<List<MangaSearchResult>> search(String query) async {
    throw UnimplementedError();
  }
}
