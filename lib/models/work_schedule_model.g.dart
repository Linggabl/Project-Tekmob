// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_schedule_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkScheduleModelAdapter extends TypeAdapter<WorkScheduleModel> {
  @override
  final int typeId = 3;

  @override
  WorkScheduleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkScheduleModel(
      day: fields[0] as String,
      time: fields[1] as String,
      activity: fields[2] as String,
      userEmail: fields[3] as String,
      date: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WorkScheduleModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.activity)
      ..writeByte(3)
      ..write(obj.userEmail)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkScheduleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
