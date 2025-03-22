import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer.dart';
import '../utils/theme.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  late Box<Customer> _customerBox;

  @override
  void initState() {
    super.initState();
    _customerBox = Hive.box<Customer>('customers');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customers"),
        backgroundColor: AppColors.primaryColor,
      ),
      body: ValueListenableBuilder(
        valueListenable: _customerBox.listenable(),
        builder: (context, Box<Customer> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No customers added.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final customer = box.getAt(index)!;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryColor.withOpacity(0.8),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    customer.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    customer.phoneNumber,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
