// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseTypeAdapter extends TypeAdapter<ExpenseType> {
  @override
  final int typeId = 16;

  @override
  ExpenseType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseType(
      expenseType: fields[1] as int,
      expenseTypeDesc: fields[2] as String,
      code: fields[0] as String,
      subItems: fields[6] as bool,
      expenseTypeDetails: (fields[3] as List).cast<ExpenseTypeDetail>(),
      isMode: fields[4] as bool,
      modes: (fields[5] as List?)?.cast<ExpenseMode>(),
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseType obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.expenseType)
      ..writeByte(2)
      ..write(obj.expenseTypeDesc)
      ..writeByte(3)
      ..write(obj.expenseTypeDetails)
      ..writeByte(4)
      ..write(obj.isMode)
      ..writeByte(5)
      ..write(obj.modes)
      ..writeByte(6)
      ..write(obj.subItems);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExpenseTypeDetailAdapter extends TypeAdapter<ExpenseTypeDetail> {
  @override
  final int typeId = 17;

  @override
  ExpenseTypeDetail read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseTypeDetail(
      id: fields[2] as int,
      name: fields[4] as String,
      code: fields[0] as String,
      details: (fields[1] as List?)?.cast<Detail>(),
      type: fields[6] as String,
      isRequired: fields[3] as bool,
      regexPattern: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseTypeDetail obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.details)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.isRequired)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.regexPattern)
      ..writeByte(6)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseTypeDetailAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DetailAdapter extends TypeAdapter<Detail> {
  @override
  final int typeId = 19;

  @override
  Detail read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Detail(id: fields[0] as dynamic, name: fields[1] as String?);
  }

  @override
  void write(BinaryWriter writer, Detail obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetailAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExpenseModeAdapter extends TypeAdapter<ExpenseMode> {
  @override
  final int typeId = 18;

  @override
  ExpenseMode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseMode(
      id: fields[1] as int,
      name: fields[2] as String,
      code: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseMode obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
