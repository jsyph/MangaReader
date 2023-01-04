import 'package:hive/hive.dart';

part '../database_types/generated/manga_content_type_enum.g.dart';

@HiveType(typeId: 4)
enum MangaContentType {
  @HiveField(0)
  manhwa,
  
  @HiveField(1)
  manhua,

@HiveField(2)
  manga,

@HiveField(3)
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