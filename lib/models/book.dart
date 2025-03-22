import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 0)
class Book extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String imagePath;

  @HiveField(2)
  String genre;

  @HiveField(3)
  String author;

  @HiveField(4)
  String prologue;

  @HiveField(5)
  DateTime releaseDate;

  @HiveField(6)
  double rentFee;

  @HiveField(7)
  bool isRented;

  @HiveField(8)
  DateTime? rentDate;

  @HiveField(9)
  DateTime? returnDate;

  @HiveField(10)
  String? rentedBy; // Customer name

  @HiveField(11)
  bool isOverdue = false;

  @HiveField(12)
  double penalty = 0.0;

  Book({
    required this.name,
    required this.imagePath,
    required this.genre,
    required this.author,
    required this.prologue,
    required this.releaseDate,
    required this.rentFee,
    this.isRented = false,
    this.rentDate,
    this.returnDate,
  });

  Object? get id => null;

  String? get title => null;

  double getTotalRentPay() {
    if (rentDate == null || returnDate == null) return 0.0;
    final daysRented = returnDate!.difference(rentDate!).inDays;
    return daysRented * rentFee + penalty;
  }

  void markAsOverdue() {
    if (!isOverdue && isRented && returnDate != null && DateTime.now().isAfter(returnDate!)) {
      isOverdue = true;
      penalty += 25.0; // ₱25 penalty
      save();
      addNotification("Book Overdue", "$name is marked as overdue with a ₱50 penalty.");
    }
  }

  void addNotification(String title, String message) {
    final notificationBox = Hive.box('notifications');
    notificationBox.add({
      'title': title,
      'message': message,
      'date': DateTime.now().toString(),
    });
  }
} 
