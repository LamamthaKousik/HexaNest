// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VisitAdapter extends TypeAdapter<Visit> {
  @override
  final int typeId = 1;

  @override
  Visit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Visit(
      id: fields[0] as String,
      patientId: fields[1] as String,
      visitDate: fields[2] as DateTime,
      symptoms: fields[3] as String?,
      bloodPressure: fields[4] as String?,
      weight: fields[5] as double?,
      height: fields[6] as double?,
      notes: fields[7] as String?,
      visitType: fields[8] as String?,
      healthStatus: fields[9] as String?,
      prescribedMedicines: fields[10] as String?,
      nextVisitDate: fields[11] as DateTime?,
      ashaWorkerNotes: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Visit obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.patientId)
      ..writeByte(2)
      ..write(obj.visitDate)
      ..writeByte(3)
      ..write(obj.symptoms)
      ..writeByte(4)
      ..write(obj.bloodPressure)
      ..writeByte(5)
      ..write(obj.weight)
      ..writeByte(6)
      ..write(obj.height)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.visitType)
      ..writeByte(9)
      ..write(obj.healthStatus)
      ..writeByte(10)
      ..write(obj.prescribedMedicines)
      ..writeByte(11)
      ..write(obj.nextVisitDate)
      ..writeByte(12)
      ..write(obj.ashaWorkerNotes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
