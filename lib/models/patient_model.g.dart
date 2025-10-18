// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PatientAdapter extends TypeAdapter<Patient> {
  @override
  final int typeId = 0;

  @override
  Patient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Patient(
      id: fields[0] as String,
      name: fields[1] as String,
      age: fields[2] as int,
      gender: fields[3] as String,
      village: fields[4] as String,
      healthId: fields[5] as String,
      pregnancyStatus: fields[6] as String,
      lastVisitDate: fields[7] as DateTime,
      registrationDate: fields[8] as DateTime,
      isSynced: fields[9] as bool,
      notes: fields[10] as String?,
      phoneNumber: fields[11] as String?,
      address: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Patient obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.gender)
      ..writeByte(4)
      ..write(obj.village)
      ..writeByte(5)
      ..write(obj.healthId)
      ..writeByte(6)
      ..write(obj.pregnancyStatus)
      ..writeByte(7)
      ..write(obj.lastVisitDate)
      ..writeByte(8)
      ..write(obj.registrationDate)
      ..writeByte(9)
      ..write(obj.isSynced)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.phoneNumber)
      ..writeByte(12)
      ..write(obj.address);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
