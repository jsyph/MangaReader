// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../core_types/manga_search_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MangaSearchResultAdapter extends TypeAdapter<MangaSearchResult> {
  @override
  final int typeId = 2;

  @override
  MangaSearchResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MangaSearchResult(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String?,
      fields[3] as double,
      fields[4] as String,
      fields[5] as MangaStatus,
      fields[6] as MangaContentType?,
      fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MangaSearchResult obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.coverUrl)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.latestChapterTitle)
      ..writeByte(3)
      ..write(obj.rating)
      ..writeByte(4)
      ..write(obj.mangaUrl)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.contentType)
      ..writeByte(7)
      ..write(obj.mangaSourceName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MangaSearchResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
