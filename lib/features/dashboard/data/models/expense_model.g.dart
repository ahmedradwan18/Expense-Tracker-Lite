// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseModelAdapter extends TypeAdapter<ExpenseModel> {
  @override
  final int typeId = 0;

  @override
  ExpenseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseModel(
      hiveId: fields[0] as String,
      hiveCategory: fields[1] as String,
      hiveAmount: fields[2] as double,
      hiveCurrency: fields[3] as String,
      hiveAmountInUSD: fields[4] as double,
      hiveDate: fields[5] as DateTime,
      hiveDescription: fields[6] as String?,
      hiveReceiptPath: fields[7] as String?,
      hiveCreatedAt: fields[8] as DateTime,
      hiveUpdatedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.hiveId)
      ..writeByte(1)
      ..write(obj.hiveCategory)
      ..writeByte(2)
      ..write(obj.hiveAmount)
      ..writeByte(3)
      ..write(obj.hiveCurrency)
      ..writeByte(4)
      ..write(obj.hiveAmountInUSD)
      ..writeByte(5)
      ..write(obj.hiveDate)
      ..writeByte(6)
      ..write(obj.hiveDescription)
      ..writeByte(7)
      ..write(obj.hiveReceiptPath)
      ..writeByte(8)
      ..write(obj.hiveCreatedAt)
      ..writeByte(9)
      ..write(obj.hiveUpdatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
