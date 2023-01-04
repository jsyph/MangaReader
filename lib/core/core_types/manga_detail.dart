import 'core_types.dart';

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