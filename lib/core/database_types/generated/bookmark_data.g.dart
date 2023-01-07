// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../bookmark_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DataBaseBookmarkDataAdapter extends TypeAdapter<DataBaseBookmarkData> {
  @override
  final int typeId = 7;

  @override
  DataBaseBookmarkData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataBaseBookmarkData(
      fields[0] as MangaDetails,
      (fields[1] as List).cast<MangaChapterData>(),
      fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DataBaseBookmarkData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.details)
      ..writeByte(1)
      ..write(obj.readChapters)
      ..writeByte(2)
      ..write(obj.lastTimeRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataBaseBookmarkDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
