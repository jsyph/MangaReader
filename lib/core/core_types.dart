import 'dart:convert';

/// Contains the chapter data for each chapter in the manga:
/// - __chapterNumber__: (*double*) number of chapter
/// - __releasedOn__: (*DateTime*) date the chapter is released on
/// - __chapterUrl__: (*String*) the url for the chapter
class MangaChapterData {
  final String chapterTitle;
  final DateTime releasedOn;
  final String chapterUrl;
  final String mangaSourceName;

  MangaChapterData(
    this.chapterTitle,
    this.releasedOn,
    this.chapterUrl,
    this.mangaSourceName,
  );

  @override
  String toString() {
    return '''MangaChapterData(
      chapterTitle: $chapterTitle,\n
    releasedOn: $releasedOn,\n
    chapterUrl: $chapterUrl,\n
    )''';
  }
}

enum MangaContentType {
  manhwa,
  manhua,
  manga,
  none;

  factory MangaContentType.parse(String string) {
    final lowerCaseString = string.toLowerCase();

    switch (lowerCaseString) {
      case 'manhwa':
        {
          return MangaContentType.manhwa;
        }
      case 'manhua':
        {
          return MangaContentType.manhua;
        }
      case 'manga':
        {
          return MangaContentType.manga;
        }
      default:
        {
          return MangaContentType.none;
        }
    }
  }
}

/// Contains the manga details:
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
  final String? description;
  final String coverUrl;
  final MangaStatus status;
  final double rating;
  final DateTime releasedAt;
  final List<String> tags;
  final MangaContentType contentType;
  final String mangaSourceName;

  /// sorted in descending order
  final List<MangaChapterData> chapters;

  MangaDetails(
      this.title,
      this.description,
      this.coverUrl,
      this.rating,
      this.status,
      this.releasedAt,
      this.chapters,
      this.tags,
      this.contentType,
      this.mangaSourceName);

  @override
  String toString() {
    return '''MangaDetails(\n
    title: $title,\n
    description: `$description`,\n
    coverUrl: $coverUrl,\n
    rating: $rating,\n
    status: $status,\n
    releasedAt: $releasedAt,\n
    chapters: $chapters,\n
    tags: $tags,\n
    )''';
  }

  /// Returns an empty MangaDetails object
  static MangaDetails empty() {
    return MangaDetails('', '', '', 0.0, MangaStatus.none, DateTime.now(), [],
        [], MangaContentType.none, '');
  }
}

/// Data for each manga search result
///
/// Contains:
/// - __coverUrl__: (*String*) cover url
/// - __title__: (*String*) title
/// - __latestChapter__: (*double*) latest chapter number
/// - __rating__: (*double*) rating out of 10.0
/// - __mangaUrl__: (*String*) manga url
class MangaSearchResult {
  final String coverUrl;
  final String title;
  final String? latestChapterTitle;
  final double rating;
  final String mangaUrl;
  final MangaStatus status;
  final MangaContentType? contentType;
  final String mangaSourceName;

  MangaSearchResult(
    this.coverUrl,
    this.title,
    this.latestChapterTitle,
    this.rating,
    this.mangaUrl,
    this.status,
    this.contentType,
    this.mangaSourceName,
  );

  // ─── For Storing Search Results ──────────────────────────────────────
  factory MangaSearchResult.fromJson(Map<String, dynamic> jsonData) {
    return MangaSearchResult(
      jsonData['coverUrl'],
      jsonData['title'],
      jsonData['latestChapterTitle'],
      double.parse(jsonData['rating']),
      jsonData['mangaUrl'],
      MangaStatus.parse(jsonData['status'].toString().split('.').last),
      MangaContentType.parse(
          jsonData['contentType'].toString().split('.').last),
      jsonData['mangaSourceName'],
    );
  }

  static List<MangaSearchResult> decode(String results) {
    return (json.decode(results) as List<dynamic>)
        .map((item) => MangaSearchResult.fromJson(item))
        .toList();
  }

  static String encode(List<MangaSearchResult> results) {
    return json.encode(
      results.map((result) => MangaSearchResult.toMap(result)).toList(),
    );
  }

  static Map<String, dynamic> toMap(MangaSearchResult mangaSearchResult) {
    return {
      'coverUrl': mangaSearchResult.coverUrl,
      'title': mangaSearchResult.title,
      'latestChapterTitle': mangaSearchResult.latestChapterTitle,
      'rating': mangaSearchResult.rating.toString(),
      'mangaUrl': mangaSearchResult.mangaUrl,
      'status': mangaSearchResult.status.toString(),
      'contentType': mangaSearchResult.contentType.toString(),
      'mangaSourceName': mangaSearchResult.mangaSourceName,
    };
  }
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
  none;

  factory MangaStatus.parse(String string) {
    final lowerCaseString = string.toLowerCase();

    switch (lowerCaseString) {
      case 'completed':
        {
          return MangaStatus.completed;
        }
      case 'ongoing':
        {
          return MangaStatus.ongoing;
        }
      case 'hiatus':
        {
          return MangaStatus.hiatus;
        }
      case 'cancelled':
        {
          return MangaStatus.completed;
        }

      default:
        {
          return MangaStatus.none;
        }
    }
  }
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
