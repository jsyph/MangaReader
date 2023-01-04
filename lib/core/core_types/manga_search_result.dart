import 'dart:convert';

import 'package:hive/hive.dart';

import 'core_types.dart';

part '../database_types/generated/manga_search_result.g.dart';

/// Data for each manga search result
///
/// Contains:
/// - __coverUrl__: (*String*) cover url
/// - __title__: (*String*) title
/// - __latestChapter__: (*double*) latest chapter number
/// - __rating__: (*double*) rating out of 10.0
/// - __mangaUrl__: (*String*) manga url
@HiveType(typeId: 2)
class MangaSearchResult {
  @HiveField(0)
  final String coverUrl;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? latestChapterTitle;
  @HiveField(3)
  final double rating;
  @HiveField(4)
  final String mangaUrl;
  @HiveField(5)
  final MangaStatus status;
  @HiveField(6)
  final MangaContentType? contentType;
  @HiveField(7)
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
