// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecurringTransactionModelAdapter
    extends TypeAdapter<RecurringTransactionModel> {
  @override
  final int typeId = 3;

  @override
  RecurringTransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurringTransactionModel(
      description: fields[0] as String,
      amount: fields[1] as double,
      categoryIndex: fields[2] as int,
      isIncome: fields[3] as bool,
      frequency: fields[4] as String,
      nextDate: fields[5] as DateTime,
      isActive: fields[6] as bool,
      createdAt: fields[7] as DateTime,
      note: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RecurringTransactionModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.description)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.categoryIndex)
      ..writeByte(3)
      ..write(obj.isIncome)
      ..writeByte(4)
      ..write(obj.frequency)
      ..writeByte(5)
      ..write(obj.nextDate)
      ..writeByte(6)
      ..write(obj.isActive)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringTransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
