// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookAdapter extends TypeAdapter<Book> {
  @override
  final int typeId = 0;

  @override
  Book read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Book(
      name: fields[0] as String,
      imagePath: fields[1] as String,
      genre: fields[2] as String,
      author: fields[3] as String,
      prologue: fields[4] as String,
      releaseDate: fields[5] as DateTime,
      rentFee: fields[6] as double,
      isRented: fields[7] as bool,
      rentDate: fields[8] as DateTime?,
      returnDate: fields[9] as DateTime?,
    )..rentedBy = fields[10] as String?;
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.genre)
      ..writeByte(3)
      ..write(obj.author)
      ..writeByte(4)
      ..write(obj.prologue)
      ..writeByte(5)
      ..write(obj.releaseDate)
      ..writeByte(6)
      ..write(obj.rentFee)
      ..writeByte(7)
      ..write(obj.isRented)
      ..writeByte(8)
      ..write(obj.rentDate)
      ..writeByte(9)
      ..write(obj.returnDate)
      ..writeByte(10)
      ..write(obj.rentedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
