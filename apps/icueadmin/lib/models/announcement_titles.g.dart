// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_titles.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnnouncementTitleAdapter extends TypeAdapter<AnnouncementTitle> {
  @override
  final int typeId = 4;

  @override
  AnnouncementTitle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnnouncementTitle(
      type: fields[5] as int,
      title: fields[4] as String,
      descHeader: fields[2] as String,
      descBody: fields[0] as String,
      descFooter: fields[1] as String,
      vars: (fields[6] as List).cast<String>(),
      isActive: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AnnouncementTitle obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.descBody)
      ..writeByte(1)
      ..write(obj.descFooter)
      ..writeByte(2)
      ..write(obj.descHeader)
      ..writeByte(3)
      ..write(obj.isActive)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.vars);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnnouncementTitleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
