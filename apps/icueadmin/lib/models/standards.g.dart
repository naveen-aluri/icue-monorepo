// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standards.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StandardsAdapter extends TypeAdapter<Standards> {
  @override
  final int typeId = 5;

  @override
  Standards read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Standards(
      id: fields[0] as int,
      name: fields[1] as String,
      sections: (fields[2] as List).cast<Section>(),
      standardType: fields[3] as String?,
      subjects: (fields[4] as List?)?.cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Standards obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.sections)
      ..writeByte(3)
      ..write(obj.standardType)
      ..writeByte(4)
      ..write(obj.subjects);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StandardsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SectionAdapter extends TypeAdapter<Section> {
  @override
  final int typeId = 6;

  @override
  Section read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Section(
      name: fields[1] as String,
      id: fields[0] as int?,
      uid: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Section obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.uid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
