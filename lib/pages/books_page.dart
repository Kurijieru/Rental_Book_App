import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/book.dart';
import 'book_detail_page.dart';
import '../utils/theme.dart';
import 'edit_book_page.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  late Future<Box<Book>> _bookBoxFuture;

  @override
  void initState() {
    super.initState();
    _bookBoxFuture = _openBox();
  }

  Future<Box<Book>> _openBox() async {
    return await Hive.openBox<Book>('books');
  }

  void _editBook(Book book) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditBookPage(book: book)),
    );

    if (result == true) {
      setState(() {}); // Refresh the books page on successful edit
    }
  }

  // Add confirmation dialog before deleting a book
  void _deleteBook(Book book) async {
    // Show a confirmation dialog
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this book? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Dismiss the dialog and don't delete
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Confirm deletion
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    // If the user confirmed, proceed with the deletion
    if (confirmDelete == true) {
      final bookBox = await _bookBoxFuture;
      await bookBox.delete(book.key);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book deleted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Books"),
        backgroundColor: AppColors.primaryColor,
      ),
      body: FutureBuilder(
        future: _bookBoxFuture,
        builder: (context, AsyncSnapshot<Box<Book>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final bookBox = snapshot.data!;
          final availableBooks = bookBox.values.where((book) => !book.isRented).toList();

          if (availableBooks.isEmpty) {
            return const Center(child: Text("No available books. Please add some!"));
          }

          return ListView.builder(
            itemCount: availableBooks.length,
            itemBuilder: (context, index) {
              final book = availableBooks[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 50,
                      height: 50,
                      color: AppColors.primaryColor.withOpacity(0.1),
                      child: const Icon(
                        Icons.menu_book,
                        size: 32,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  title: Text(book.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Genre: ${book.genre}", style: TextStyle(color: Colors.grey[700])),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editBook(book);
                      } else if (value == 'delete') {
                        _deleteBook(book); // Call the delete function with confirmation
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit Book')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete Book')),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BookDetailPage(book: book, bookId: book.key)), // Pass book.key here
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
