import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/book.dart';
import 'rented_books_page.dart';
import 'add_book_page.dart';
import 'customers_page.dart';
import 'rent_history_page.dart';
import 'books_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool hasOverdueBooks = false;

  @override
  void initState() {
    super.initState();
    _checkOverdueBooks();
  }

  void _checkOverdueBooks() async {
    final box = await Hive.openBox<Book>('books');
    final overdueBooks = box.values.where((book) {
      return book.isRented && book.returnDate != null && book.returnDate!.isBefore(DateTime.now());
    }).toList();

    setState(() {
      hasOverdueBooks = overdueBooks.isNotEmpty;
    });
  }

  void _refreshOverdueStatus() {
    setState(() {
      _checkOverdueBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Rental Book Management App",
          style: TextStyle(fontSize: 22),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6200EE), Color(0xFF3700B3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications, color: Colors.white),
                if (hasOverdueBooks)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.8),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              _showOverdueNotification(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.1,
          children: [
            _buildNavigationBox(Icons.book, "Books", () => _navigateToBooks(context)),
            _buildNavigationBox(Icons.library_books, "Rented Books", () => _navigateToRentedBooks(context)),
            _buildNavigationBox(Icons.history, "Rent History", () => _navigateToRentHistory(context)),
            _buildNavigationBox(Icons.people, "Customers", () => _navigateToCustomers(context)),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -10),
        child: Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6200EE), Color(0xFF3700B3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 3,
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.library_add_outlined, color: Colors.white, size: 34),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddBookPage()),
              ).then((_) {
                _refreshOverdueStatus();
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationBox(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF9E9E9E), Color(0xFFE0E0E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 58, color: const Color.fromARGB(255, 45, 5, 138)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToBooks(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const BooksPage()))
        .then((_) => _refreshOverdueStatus());
  }

  void _navigateToRentedBooks(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const RentedBooksPage()))
        .then((_) => _refreshOverdueStatus());
  }

  void _navigateToRentHistory(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const RentHistoryPage()))
        .then((_) => _refreshOverdueStatus());
  }

  void _navigateToCustomers(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomersPage()))
        .then((_) => _refreshOverdueStatus());
  }

  void _showOverdueNotification(BuildContext context) async {
    final box = await Hive.openBox<Book>('books');
    final overdueBooks = box.values.where((book) {
      return book.isRented && book.returnDate != null && book.returnDate!.isBefore(DateTime.now());
    }).toList();

    if (overdueBooks.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Overdue Books"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: overdueBooks.map((book) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(book.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No overdue books!")),
      );
    }
  }
}
