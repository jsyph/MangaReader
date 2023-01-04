// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../core_types/manga_content_type_enum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MangaContentTypeAdapter extends TypeAdapter<MangaContentType> {
  @override
  final int typeId = 4;

  @override
  MangaContentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MangaContentType.manhwa;
      case 1:
        return MangaContentType.manhua;
      case 2:
        return MangaContentType.manga;
      case 3:
        return MangaContentType.none;
      default:
        return MangaContentType.manhwa;
    }
  }

  @override
  void write(BinaryWriter writer, MangaContentType obj) {
    switch (obj) {
      case MangaContentType.manhwa:
        writer.writeByte(0);
        break;
      case MangaContentType.manhua:
        writer.writeByte(1);
        break;
      case MangaContentType.manga:
        writer.writeByte(2);
        break;
      case MangaContentType.none:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MangaContentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
