// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RouteeAdapter extends TypeAdapter<Routee> {
  @override
  final int typeId = 7;

  @override
  Routee read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Routee(
      routeNo: fields[3] as String,
      mode: fields[1] as Mode,
      id: fields[0] as int,
      points: (fields[2] as List).cast<Point>(),
    );
  }

  @override
  void write(BinaryWriter writer, Routee obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.mode)
      ..writeByte(2)
      ..write(obj.points)
      ..writeByte(3)
      ..write(obj.routeNo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PointAdapter extends TypeAdapter<Point> {
  @override
  final int typeId = 9;

  @override
  Point read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Point(
      name: fields[0] as String,
      studentIds: (fields[1] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, Point obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.studentIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PointAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ModeAdapter extends TypeAdapter<Mode> {
  @override
  final int typeId = 8;

  @override
  Mode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Mode.DROP;
      case 1:
        return Mode.PICKUP;
      default:
        return Mode.DROP;
    }
  }

  @override
  void write(BinaryWriter writer, Mode obj) {
    switch (obj) {
      case Mode.DROP:
        writer.writeByte(0);
        break;
      case Mode.PICKUP:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
