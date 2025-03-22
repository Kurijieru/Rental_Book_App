import 'package:flutter/material.dart';
import '../models/book.dart';
import '../utils/theme.dart';

class EditBookPage extends StatefulWidget {
  final Book book;

  const EditBookPage({super.key, required this.book});

  @override
  _EditBookPageState createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  late TextEditingController _nameController;
  late TextEditingController _authorController;
  late TextEditingController _rentFeeController;
  late TextEditingController _prologueController;
  DateTime? _selectedDate;
  late String _selectedGenre;

  final List<String> genres = [
    "Non-Fiction",
    "Mystery",
    "Sci-Fi",
    "Romance",
    "Historical",
    "Fantasy",
    "Action",
    "Thriller/Horror"
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.book.name);
    _authorController = TextEditingController(text: widget.book.author);
    _rentFeeController = TextEditingController(text: widget.book.rentFee.toString());
    _prologueController = TextEditingController(text: widget.book.prologue);
    _selectedDate = widget.book.releaseDate;
    _selectedGenre = widget.book.genre.isNotEmpty ? widget.book.genre : "Romance";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _authorController.dispose();
    _rentFeeController.dispose();
    _prologueController.dispose();
    super.dispose();
  }

  Future<void> _saveBook() async {
    widget.book
      ..name = _nameController.text
      ..author = _authorController.text
      ..genre = _selectedGenre
      ..rentFee = double.parse(_rentFeeController.text)
      ..prologue = _prologueController.text
      ..releaseDate = _selectedDate!;
    
    await widget.book.save();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Book updated successfully')),
    );
    Navigator.pop(context, true);
  }

  void _pickReleaseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Book"),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField("Book Name", _nameController),
            _buildTextField("Author", _authorController),
            
            const SizedBox(height: 16),
            const Text("Genre", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedGenre,
              isExpanded: true,
              onChanged: (value) {
                setState(() => _selectedGenre = value!);
              },
              items: genres.map((genre) {
                return DropdownMenuItem<String>(
                  value: genre,
                  child: Text(genre),
                );
              }).toList(),
            ),

            _buildTextField("Rent Fee (₱)", _rentFeeController, keyboardType: TextInputType.number),
            
            const SizedBox(height: 16),
            const Text("Release Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Text(_selectedDate != null
                    ? "${_selectedDate!.toLocal()}".split(' ')[0]
                    : "Select Date"),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _pickReleaseDate,
                  child: const Text("Pick Date"),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildTextField("Prologue", _prologueController, maxLines: 5),

            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _saveBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
