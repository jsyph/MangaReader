// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../page_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DataBasePageDataAdapter extends TypeAdapter<DataBasePageData> {
  @override
  final int typeId = 1;

  @override
  DataBasePageData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataBasePageData(
      fields[0] as int,
      fields[1] as DateTime,
      (fields[2] as List).cast<MangaSearchResult>(),
    );
  }

  @override
  void write(BinaryWriter writer, DataBasePageData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.page)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.results);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataBasePageDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
