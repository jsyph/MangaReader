// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../core_types/manga_detail.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MangaDetailsAdapter extends TypeAdapter<MangaDetails> {
  @override
  final int typeId = 5;

  @override
  MangaDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MangaDetails(
      fields[0] as String,
      fields[1] as String?,
      fields[2] as String,
      fields[4] as double,
      fields[3] as MangaStatus,
      fields[5] as DateTime,
      (fields[9] as List).cast<MangaChapterData>(),
      (fields[6] as List).cast<String>(),
      fields[7] as MangaContentType,
      fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MangaDetails obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.coverUrl)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.rating)
      ..writeByte(5)
      ..write(obj.releasedAt)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.contentType)
      ..writeByte(8)
      ..write(obj.mangaSourceName)
      ..writeByte(9)
      ..write(obj.chapters);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MangaDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
