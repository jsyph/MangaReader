import 'package:hive/hive.dart';
import 'package:manga_reader/core/core.dart';

part 'generated/bookmark_data.g.dart';

@HiveType(typeId: 7)
class DataBaseBookmarkData {
  @HiveField(0)
  final MangaDetails details;

  @HiveField(1)
  List<MangaChapterData> readChapters;

  @HiveField(2)
  DateTime lastTimeRead;

  DataBaseBookmarkData(
    this.details,
    this.readChapters,
    this.lastTimeRead
  );
}
