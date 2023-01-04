// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../core_types/manga_status_enum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MangaStatusAdapter extends TypeAdapter<MangaStatus> {
  @override
  final int typeId = 3;

  @override
  MangaStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MangaStatus.completed;
      case 1:
        return MangaStatus.ongoing;
      case 2:
        return MangaStatus.hiatus;
      case 3:
        return MangaStatus.cancelled;
      case 4:
        return MangaStatus.none;
      default:
        return MangaStatus.completed;
    }
  }

  @override
  void write(BinaryWriter writer, MangaStatus obj) {
    switch (obj) {
      case MangaStatus.completed:
        writer.writeByte(0);
        break;
      case MangaStatus.ongoing:
        writer.writeByte(1);
        break;
      case MangaStatus.hiatus:
        writer.writeByte(2);
        break;
      case MangaStatus.cancelled:
        writer.writeByte(3);
        break;
      case MangaStatus.none:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MangaStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
