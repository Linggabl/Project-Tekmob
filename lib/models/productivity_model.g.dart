// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'productivity_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductivityModelAdapter extends TypeAdapter<ProductivityModel> {
  @override
  final int typeId = 2;

  @override
  ProductivityModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductivityModel(
      task: fields[0] as String,
      isCompleted: fields[1] as bool,
      userId: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProductivityModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.task)
      ..writeByte(1)
      ..write(obj.isCompleted)
      ..writeByte(2)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductivityModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
