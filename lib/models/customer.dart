import 'package:hive/hive.dart';

part 'customer.g.dart';

@HiveType(typeId: 1)
class Customer extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String phoneNumber;

  @HiveField(2)
  String email;
  
  @HiveField(3)
  DateTime? rentDate;

  @HiveField(4)
  DateTime? returnDate;

  Customer({required this.name, required this.phoneNumber, required this.email, required this.rentDate, required this.returnDate});
}
