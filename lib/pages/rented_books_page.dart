import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/book.dart';
import 'book_detail_page.dart';
import '../utils/theme.dart';
import '../models/rent_history.dart';
import '../utils/notification_service.dart';

class RentedBooksPage extends StatelessWidget {
  const RentedBooksPage({super.key});

  Future<Box<Book>> _openBox() async {
    return await Hive.openBox<Book>('books');
  }

  double calculateTotalRentPay(Book book) {
    if (book.rentDate == null) return 0.0;
    final returnDate = book.returnDate ?? DateTime.now();
    final daysRented = returnDate.difference(book.rentDate!).inDays;

    // Add overdue penalty if the book is overdue
    double overduePenalty = book.isOverdue ? 25.0 : 0.0;

    return (daysRented <= 0 ? 1 : daysRented) * book.rentFee + book.penalty + overduePenalty;
  }

  Future<void> _markBookAsCompleted(BuildContext context, Book book) async {
    final historyBox = await Hive.openBox<RentHistory>('rentHistory');
    final totalRentPay = calculateTotalRentPay(book);

    book.returnDate ??= DateTime.now();

    final rentHistory = RentHistory(
      bookName: book.name,
      rentedBy: book.rentedBy ?? 'Unknown',
      rentDate: book.rentDate!,
      returnDate: book.returnDate!,
      totalRentPay: totalRentPay,
      isCompleted: true,
    );

    await historyBox.add(rentHistory);

    book.isRented = false;
    book.rentedBy = null;
    book.rentDate = null;
    book.returnDate = null;
    book.isOverdue = false;
    book.penalty = 0.0;
    await book.save();

    // Schedule a reminder to notify user about the return date
    NotificationService.scheduleRentReturnNotification(
      book.key,
      book.name,
      book.returnDate!,
    );
  }

  Future<void> _markAsOverdue(BuildContext context, Book book) async {
    if (!book.isOverdue) {
      // Mark the book as overdue
      book.isOverdue = true;
      book.penalty += 25.0; // Add ₱25 overdue penalty to the book's penalty field

      await book.save(); // Save the changes to the book

      // Show a snackbar notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${book.name} marked as Overdue with a ₱50 penalty!")),
      );

      // Notify the user that the book is overdue
      NotificationService.scheduleOverdueNotification(book.key, book.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rented Books"),
        backgroundColor: AppColors.primaryColor,
      ),
      body: FutureBuilder(
        future: _openBox(),
        builder: (context, AsyncSnapshot<Box<Book>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final bookBox = snapshot.data!;

          return ValueListenableBuilder(
            valueListenable: bookBox.listenable(),
            builder: (context, Box<Book> box, _) {
              // Include books that are rented or pending
              final rentedBooks = box.values
                  .where((book) => book.isRented || (book.rentDate != null && book.rentDate!.isAfter(DateTime.now())))
                  .toList();

              if (rentedBooks.isEmpty) {
                return const Center(
                  child: Text(
                    "No books are currently rented.",
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12.0),
                itemCount: rentedBooks.length,
                itemBuilder: (context, index) {
                  final book = rentedBooks[index];
                  final totalRentPay = calculateTotalRentPay(book);
                  bool isOverdue = book.isOverdue;

                  // Check if the book is pending
                  bool isPending = book.rentDate != null && book.rentDate!.isAfter(DateTime.now());

                  return GestureDetector(
                    onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => BookDetailPage(book: book, bookId: book.key)), // Pass book.key here
  );
},

                    child: Card(
                      color: isOverdue ? Colors.red[50] : Colors.white,
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: const Icon(
                                Icons.menu_book,
                                size: 50,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book.name,
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  Text("Rented by: ${book.rentedBy ?? 'Unknown'}"),
                                  Text("Return by: ${book.returnDate?.toLocal().toString().split(' ')[0] ?? 'Unknown'}"),
                                  Text("Total Rent Pay: ₱${totalRentPay.toStringAsFixed(2)}"),
                                  if (isPending) 
                                    const Text(
                                      "Pending Rent Date",
                                      style: TextStyle(fontSize: 14, color: Colors.orange),
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    await _markBookAsCompleted(context, book);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Book marked as completed!")),
                                    );
                                  },
                                  child: const Text("Complete"),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: !isPending && !isOverdue
                                      ? () => _markAsOverdue(context, book)
                                      : null,
                                  child: Text(isOverdue ? "Overdue" : "Mark Overdue"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
