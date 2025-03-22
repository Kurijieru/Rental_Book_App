import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/rent_history.dart';
import '../utils/theme.dart';

class RentHistoryPage extends StatelessWidget {
  const RentHistoryPage({super.key});

  Future<Box<RentHistory>> _openHistoryBox() async {
    return await Hive.openBox<RentHistory>('rentHistory');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rent History"),
        backgroundColor: AppColors.primaryColor,
      ),
      body: FutureBuilder(
        future: _openHistoryBox(),
        builder: (context, AsyncSnapshot<Box<RentHistory>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final historyBox = snapshot.data!;
          final rentHistoryList = historyBox.values.toList();

          if (rentHistoryList.isEmpty) {
            return const Center(child: Text("No rent history available."));
          }

          return ListView.builder(
            itemCount: rentHistoryList.length,
            itemBuilder: (context, index) {
              final history = rentHistoryList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(history.bookName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Customer: ${history.rentedBy}"),
                      Text("Rent Date: ${history.rentDate.toLocal().toString().split(' ')[0]}"),
                      Text("Return Date: ${history.returnDate.toLocal().toString().split(' ')[0]}"),
                      Text("Total Rent Pay: ₱${history.totalRentPay.toStringAsFixed(2)}"),
                    ],
                  ),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
