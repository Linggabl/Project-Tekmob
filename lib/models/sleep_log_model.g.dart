// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SleepLogModelAdapter extends TypeAdapter<SleepLogModel> {
  @override
  final int typeId = 4;

  @override
  SleepLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SleepLogModel(
      date: fields[0] as DateTime,
      sleepTime: fields[1] as DateTime,
      wakeTime: fields[2] as DateTime,
      userEmail: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SleepLogModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.sleepTime)
      ..writeByte(2)
      ..write(obj.wakeTime)
      ..writeByte(3)
      ..write(obj.userEmail);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
