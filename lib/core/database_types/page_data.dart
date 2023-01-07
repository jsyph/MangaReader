import 'package:hive/hive.dart';

import '../core_types/manga_search_result.dart';

part 'generated/page_data.g.dart';

@HiveType(typeId: 1)
class DataBasePageData {
  @HiveField(0)
  final int page;

  @HiveField(1)
  final DateTime time;

  @HiveField(2)
  final List<MangaSearchResult> results;

  DataBasePageData(
    this.page,
    this.time,
    this.results,
  );
}
