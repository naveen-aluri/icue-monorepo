// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branches.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BranchAdapter extends TypeAdapter<Branch> {
  @override
  final int typeId = 22;

  @override
  Branch read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Branch(
      id: fields[0] as int,
      schoolName: fields[1] as String,
      schoolShortName: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Branch obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.schoolName)
      ..writeByte(2)
      ..write(obj.schoolShortName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BranchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
