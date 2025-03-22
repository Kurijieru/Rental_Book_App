import 'package:flutter/material.dart';
import '../models/customer.dart';

class CustomerFormDialog extends StatefulWidget {
  final Function(Customer) onConfirm;
  final bool showDatePickers;

  const CustomerFormDialog({
    super.key,
    required this.onConfirm,
    this.showDatePickers = false,
  });

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  DateTime? _rentDate;
  DateTime? _returnDate;

  // Select Date Helper
  Future<void> _selectDate(BuildContext context, bool isRentDate) async {
    final DateTime initialDate = isRentDate ? DateTime.now() : _rentDate ?? DateTime.now();
    final DateTime firstDate = isRentDate ? DateTime.now() : _rentDate ?? DateTime.now();
    final DateTime lastDate = DateTime(2100);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isRentDate) {
          _rentDate = picked;
          _returnDate = null; // Reset return date if rent date changes
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  // Submit the customer form
  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (widget.showDatePickers) {
        if (_rentDate == null || _returnDate == null || _returnDate!.isBefore(_rentDate!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select valid rent and return dates.")),
          );
          return;
        }
      }

      final customer = Customer(
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text,
        rentDate: _rentDate,
        returnDate: _returnDate,
      );

      widget.onConfirm(customer);
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Customer Information'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Please enter a phone number' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email (Optional)'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              if (widget.showDatePickers) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _selectDate(context, true),
                        child: Text(_rentDate == null
                            ? "Select Rent Date"
                            : "Rent Date: ${_rentDate!.toLocal()}".split(' ')[0]),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _rentDate != null ? () => _selectDate(context, false) : null,
                        child: Text(_returnDate == null
                            ? "Select Return Date"
                            : "Return Date: ${_returnDate!.toLocal()}".split(' ')[0]),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
