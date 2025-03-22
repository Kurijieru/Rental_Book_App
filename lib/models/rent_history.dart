import 'package:hive_flutter/hive_flutter.dart';

part 'rent_history.g.dart';

@HiveType(typeId: 2)
class RentHistory {
  @HiveField(0)
  String bookName;

  @HiveField(1)
  String rentedBy;

  @HiveField(2)
  DateTime rentDate;

  @HiveField(3)
  DateTime returnDate;

  @HiveField(4)
  double totalRentPay;

  @HiveField(5)
  bool isCompleted;

  RentHistory({
    required this.bookName,
    required this.rentedBy,
    required this.rentDate,
    required this.returnDate,
    required this.totalRentPay,
    this.isCompleted = false,
  });

  get bookId => null;
}
