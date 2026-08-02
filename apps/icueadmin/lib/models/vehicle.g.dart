// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VehicleAdapter extends TypeAdapter<Vehicle> {
  @override
  final int typeId = 10;

  @override
  Vehicle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vehicle(
      id: fields[4] as int,
      number: fields[5] as String,
      driverId: fields[1] as num?,
      driverName: fields[2] as String,
      driverNumber: fields[3] as dynamic,
      capacity: fields[0] as dynamic,
      fuelType: fields[6] as dynamic,
      price: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Vehicle obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.capacity)
      ..writeByte(1)
      ..write(obj.driverId)
      ..writeByte(2)
      ..write(obj.driverName)
      ..writeByte(3)
      ..write(obj.driverNumber)
      ..writeByte(6)
      ..write(obj.fuelType)
      ..writeByte(4)
      ..write(obj.id)
      ..writeByte(5)
      ..write(obj.number)
      ..writeByte(7)
      ..write(obj.price);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VehicleDetailsAdapter extends TypeAdapter<VehicleDetails> {
  @override
  final int typeId = 11;

  @override
  VehicleDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VehicleDetails(
      vehicleDetailsId: fields[25] as dynamic,
      id: fields[9] as int,
      organizationId: fields[20] as int,
      zoneId: fields[28] as int,
      branchId: fields[0] as int,
      number: fields[19] as String,
      driverId: fields[6] as int,
      driverName: fields[7] as String,
      driverNumber: fields[8] as int,
      vendorId: fields[26] as dynamic,
      make: fields[17] as String,
      model: fields[18] as String,
      colour: fields[4] as String?,
      year: fields[27] as String,
      chasisNumber: fields[3] as String,
      insuranceNumber: fields[12] as String?,
      insuredDate: fields[13] as String?,
      insuranceExpiryDate: fields[11] as String?,
      insuranceCopy: fields[10] as dynamic,
      rcExpiryDate: fields[21] as String,
      serviceDate: fields[22] as String?,
      capacity: fields[1] as dynamic,
      status: fields[23] as String,
      isActive: fields[14] as bool,
      lastUpdatedOn: fields[16] as DateTime?,
      updatedBy: fields[24] as String?,
      carrierId: fields[2] as dynamic,
      dashcamId: fields[5] as dynamic,
      isEnabledBluetoothDevice: fields[15] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, VehicleDetails obj) {
    writer
      ..writeByte(29)
      ..writeByte(0)
      ..write(obj.branchId)
      ..writeByte(1)
      ..write(obj.capacity)
      ..writeByte(2)
      ..write(obj.carrierId)
      ..writeByte(3)
      ..write(obj.chasisNumber)
      ..writeByte(4)
      ..write(obj.colour)
      ..writeByte(5)
      ..write(obj.dashcamId)
      ..writeByte(6)
      ..write(obj.driverId)
      ..writeByte(7)
      ..write(obj.driverName)
      ..writeByte(8)
      ..write(obj.driverNumber)
      ..writeByte(9)
      ..write(obj.id)
      ..writeByte(10)
      ..write(obj.insuranceCopy)
      ..writeByte(11)
      ..write(obj.insuranceExpiryDate)
      ..writeByte(12)
      ..write(obj.insuranceNumber)
      ..writeByte(13)
      ..write(obj.insuredDate)
      ..writeByte(14)
      ..write(obj.isActive)
      ..writeByte(15)
      ..write(obj.isEnabledBluetoothDevice)
      ..writeByte(16)
      ..write(obj.lastUpdatedOn)
      ..writeByte(17)
      ..write(obj.make)
      ..writeByte(18)
      ..write(obj.model)
      ..writeByte(19)
      ..write(obj.number)
      ..writeByte(20)
      ..write(obj.organizationId)
      ..writeByte(21)
      ..write(obj.rcExpiryDate)
      ..writeByte(22)
      ..write(obj.serviceDate)
      ..writeByte(23)
      ..write(obj.status)
      ..writeByte(24)
      ..write(obj.updatedBy)
      ..writeByte(25)
      ..write(obj.vehicleDetailsId)
      ..writeByte(26)
      ..write(obj.vendorId)
      ..writeByte(27)
      ..write(obj.year)
      ..writeByte(28)
      ..write(obj.zoneId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
