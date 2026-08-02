// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_types.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonTypeAdapter extends TypeAdapter<PersonType> {
  @override
  final int typeId = 15;

  @override
  PersonType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonType(id: fields[1] as int, category: fields[0] as String);
  }

  @override
  void write(BinaryWriter writer, PersonType obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.category)
      ..writeByte(1)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
