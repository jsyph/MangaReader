import 'package:hive/hive.dart';

part '../database_types/generated/manga_status_enum.g.dart';

/// Contains manga status
///
/// The status can be:
/// - completed
/// - ongoing
/// - hiatus
/// - cancelled
@HiveType(typeId: 3)
enum MangaStatus {
  @HiveField(0)
  completed,

  @HiveField(1)
  ongoing,

  @HiveField(2)
  hiatus,

  @HiveField(3)
  cancelled,

  @HiveField(4)
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
