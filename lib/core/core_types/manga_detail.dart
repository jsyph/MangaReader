import 'package:hive/hive.dart';

import 'core_types.dart';

part '../database_types/generated/manga_detail.g.dart';

/// Contains the manga details:
/// - __title__: (*String*) manga tile
/// - __description__: (*String*) manga description
/// - __coverUrl__: (*String*) manga cover url
/// - __status__: (*MangaStatus*) manga status
/// - __rating__: (*double*) manga rating out of 10.0
/// - __followedByCount__: (*int*) number of followers to the manga series
/// - __yearReleased__: (*int*) year the manga was released
/// - __chapters__: (*List<MangaChapterData>*) chapters of the manga
@HiveType(typeId: 5)
class MangaDetails {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String? description;

  @HiveField(2)
  final String coverUrl;

  @HiveField(3)
  final MangaStatus status;

  @HiveField(4)
  final double rating;

  @HiveField(5)
  final DateTime releasedAt;

  @HiveField(6)
  final List<String> tags;

  @HiveField(7)
  final MangaContentType contentType;

  @HiveField(8)
  final String mangaSourceName;

  /// sorted in descending order
  @HiveField(9)
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
    this.mangaSourceName,
  );

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
