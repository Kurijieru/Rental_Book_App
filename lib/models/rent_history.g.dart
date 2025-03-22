// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rent_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RentHistoryAdapter extends TypeAdapter<RentHistory> {
  @override
  final int typeId = 2;

  @override
  RentHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RentHistory(
      bookName: fields[0] as String,
      rentedBy: fields[1] as String,
      rentDate: fields[2] as DateTime,
      returnDate: fields[3] as DateTime,
      totalRentPay: fields[4] as double,
      isCompleted: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RentHistory obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.bookName)
      ..writeByte(1)
      ..write(obj.rentedBy)
      ..writeByte(2)
      ..write(obj.rentDate)
      ..writeByte(3)
      ..write(obj.returnDate)
      ..writeByte(4)
      ..write(obj.totalRentPay)
      ..writeByte(5)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RentHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
