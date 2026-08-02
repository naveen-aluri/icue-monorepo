// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_storage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StorageAdapter extends TypeAdapter<Storage> {
  @override
  final int typeId = 20;

  @override
  Storage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Storage(
      type: fields[1] as String,
      items: (fields[0] as List).cast<StorageItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, Storage obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.items)
      ..writeByte(1)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StorageItemAdapter extends TypeAdapter<StorageItem> {
  @override
  final int typeId = 21;

  @override
  StorageItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StorageItem(
      name: fields[3] as String,
      capacity: fields[0] as int,
      fuelType: fields[2] as String?,
      fuelPrice: fields[1] as String?,
      type: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StorageItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.capacity)
      ..writeByte(1)
      ..write(obj.fuelPrice)
      ..writeByte(2)
      ..write(obj.fuelType)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
