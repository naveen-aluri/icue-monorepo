// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_attendance.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreateAttendanceAdapter extends TypeAdapter<CreateAttendance> {
  @override
  final int typeId = 12;

  @override
  CreateAttendance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreateAttendance(
      source: fields[6] as String,
      students: (fields[8] as List).cast<AttendanceStudent>(),
      classId: fields[2] as int,
      section: fields[5] as String,
      standard: fields[7] as String,
      attendanceDate: fields[0] as String,
      attendanceTime: fields[1] as String,
      month: fields[3] as int,
      year: fields[9] as int,
      period: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CreateAttendance obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.attendanceDate)
      ..writeByte(1)
      ..write(obj.attendanceTime)
      ..writeByte(2)
      ..write(obj.classId)
      ..writeByte(3)
      ..write(obj.month)
      ..writeByte(4)
      ..write(obj.period)
      ..writeByte(5)
      ..write(obj.section)
      ..writeByte(6)
      ..write(obj.source)
      ..writeByte(7)
      ..write(obj.standard)
      ..writeByte(8)
      ..write(obj.students)
      ..writeByte(9)
      ..write(obj.year);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateAttendanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AttendanceStudentAdapter extends TypeAdapter<AttendanceStudent> {
  @override
  final int typeId = 13;

  @override
  AttendanceStudent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttendanceStudent(
      id: fields[2] as int,
      name: fields[4] as String,
      rollNo: fields[5] as String,
      admissionNumber: fields[1] as String,
      isPresent: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceStudent obj) {
    writer
      ..writeByte(5)
      ..writeByte(1)
      ..write(obj.admissionNumber)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.isPresent)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.rollNo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceStudentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
