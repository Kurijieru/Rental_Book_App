import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/book.dart';
import '../utils/theme.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _prologueController = TextEditingController();
  final TextEditingController _rentFeeController = TextEditingController();
  DateTime? _releaseDate;
  String _selectedGenre = "Romance";

  final List<String> genres = [
    "Non-Fiction", "Mystery", "Sci-Fi", "Romance", 
    "Historical", "Fantasy", "Action", "Thriller/Horror"
  ];

  void _addBook() {
    if (_formKey.currentState!.validate() && _releaseDate != null) {
      final Box<Book> bookBox = Hive.box('books');

      final newBook = Book(
        name: _nameController.text,
        imagePath: "assets/default_book.png", // Default image
        genre: _selectedGenre,
        author: _authorController.text,
        prologue: _prologueController.text,
        releaseDate: _releaseDate!,
        rentFee: double.parse(_rentFeeController.text),
      );

      bookBox.add(newBook);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Book"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Book Name", _nameController, "Enter book name"),
              const SizedBox(height: 16),
              _buildTextField("Author", _authorController, "Enter author"),
              const SizedBox(height: 16),
              _buildTextField("Prologue", _prologueController, null, maxLines: 3),
              const SizedBox(height: 16),
              
              _buildDropdownField(),
              const SizedBox(height: 16),
              
              _buildTextField("Rent Fee (per day)", _rentFeeController, "Enter rent fee", isNumber: true),
              const SizedBox(height: 24),
              
              _buildDatePickerInput(),
              const SizedBox(height: 24),
              
              Center(
                child: ElevatedButton(
                  onPressed: _addBook,
                  child: const Text("Add Book"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String? errorText, {int maxLines = 1, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryColor,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.secondaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: errorText != null ? (value) => value!.isEmpty ? errorText : null : null,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedGenre,
      decoration: InputDecoration(
        labelText: "Genre",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryColor,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.secondaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: genres.map((genre) {
        return DropdownMenuItem(value: genre, child: Text(genre));
      }).toList(),
      onChanged: (value) => setState(() => _selectedGenre = value!),
    );
  }

  Widget _buildDatePickerInput() {
    return InkWell(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            _releaseDate = pickedDate;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: "Select Release Date",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primaryColor,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.secondaryColor,
              width: 2,
            ),
          ),
          suffixIcon: const Icon(Icons.calendar_today, color: AppColors.primaryColor),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        child: Text(
          _releaseDate == null
              ? "Select a Date"
              : "${_releaseDate!.toLocal()}".split(' ')[0],
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
