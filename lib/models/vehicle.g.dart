// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VehicleModelAdapter extends TypeAdapter<VehicleModel> {
  @override
  final int typeId = 0;

  @override
  VehicleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VehicleModel(
      imagePaths: (fields[4] as List)
          .map((dynamic e) => (e as Map).cast<dynamic, dynamic>())
          .toList(),
      timeCreation: fields[0] as String,
      eventType: fields[1] as String,
      remoteImagePaths: (fields[5] as List?)
          ?.map((dynamic e) => (e as Map).cast<dynamic, dynamic>())
          .toList(),
      isUploaded: fields[3] as bool,
      licensePlate: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, VehicleModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.timeCreation)
      ..writeByte(1)
      ..write(obj.eventType)
      ..writeByte(2)
      ..write(obj.licensePlate)
      ..writeByte(3)
      ..write(obj.isUploaded)
      ..writeByte(4)
      ..write(obj.imagePaths)
      ..writeByte(5)
      ..write(obj.remoteImagePaths);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
