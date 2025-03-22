import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/book.dart';
import '../models/customer.dart';
import '../utils/theme.dart';
import '../utils/customer_form.dart';

class BookDetailPage extends StatefulWidget {
  final Book book;
  const BookDetailPage({super.key, required this.book, required int bookId});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  @override
  Widget build(BuildContext context) {
    bool isPending = widget.book.rentDate != null && widget.book.rentDate!.isAfter(DateTime.now());
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.name),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Icon Instead of Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100,
                  height: 150,
                  color: AppColors.primaryColor.withOpacity(0.1),
                  child: const Icon(
                    Icons.menu_book,
                    size: 50,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.book.name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.person, "Author", widget.book.author),
            _buildInfoRow(Icons.category, "Genre", widget.book.genre),
            _buildInfoRow(Icons.monetization_on, "Rent Fee", "₱${widget.book.rentFee}/day"),
            _buildInfoRow(Icons.date_range, "Release Date", "${widget.book.releaseDate.toLocal()}".split(' ')[0]),
            const SizedBox(height: 16),
            const Text(
              "Prologue: ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              widget.book.prologue,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            Center(
              child: isPending
                  ? _buildPendingActionButton()
                  : widget.book.isRented
                      ? _buildActionButton("Return This Book", AppColors.secondaryColor, _returnBook)
                      : _buildActionButton("Rent This Book", AppColors.primaryColor, _showCustomerForm),
            ),
            if (isPending) ...[
              const SizedBox(height: 8),
              const Text(
                "This book is pending until the rent date arrives.",
                style: TextStyle(fontSize: 16, color: AppColors.secondaryColor, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildPendingActionButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      ),
      onPressed: () {},
      child: const Text(
        "Pending Rent Date",
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  // Show customer form with date pickers
  void _showCustomerForm() {
    showDialog(
      context: context,
      builder: (context) => CustomerFormDialog(
        onConfirm: (customer) => _rentBook(customer),
        showDatePickers: true, // Allow selecting Rent and Return dates
      ),
    );
  }

  // Rent book with customer details
  void _rentBook(Customer customer) async {
    final customerBox = await Hive.openBox<Customer>('customers');
    await customerBox.add(customer);

    setState(() {
      widget.book.isRented = true;
      widget.book.rentedBy = customer.name;
      widget.book.rentDate = customer.rentDate;
      widget.book.returnDate = customer.returnDate;
      widget.book.save();
    });

    // Schedule notification for return date
    // Inside `onDidReceiveNotificationResponse` callback


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Book rented successfully!")),
    );
  }

  // Return the book
  void _returnBook() {
    setState(() {
      widget.book.isRented = false;
      widget.book.rentedBy = null;
      widget.book.rentDate = null;
      widget.book.returnDate = null;
      widget.book.save();
    });

    _showSnackbar("Book returned successfully!");
  }

  // Show snackbar messages
  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
