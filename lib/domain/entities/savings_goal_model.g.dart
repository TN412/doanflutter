// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavingsGoalModelAdapter extends TypeAdapter<SavingsGoalModel> {
  @override
  final int typeId = 4;

  @override
  SavingsGoalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavingsGoalModel(
      name: fields[0] as String,
      targetAmount: fields[1] as double,
      currentAmount: fields[2] as double,
      deadline: fields[3] as DateTime?,
      createdAt: fields[4] as DateTime,
      iconName: fields[5] as String?,
      colorValue: fields[6] as int?,
      note: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SavingsGoalModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.targetAmount)
      ..writeByte(2)
      ..write(obj.currentAmount)
      ..writeByte(3)
      ..write(obj.deadline)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.iconName)
      ..writeByte(6)
      ..write(obj.colorValue)
      ..writeByte(7)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingsGoalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
