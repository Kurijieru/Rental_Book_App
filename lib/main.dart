import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/book.dart';
import 'models/rent_history.dart';
import 'pages/home_page.dart';
import 'models/customer.dart';
import 'utils/theme.dart';
import 'utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(BookAdapter());
  Hive.registerAdapter(CustomerAdapter());
  Hive.registerAdapter(RentHistoryAdapter());

  // Initialize Notification Service (if applicable)
  await NotificationService.initialize();

  // Open Hive Boxes
  await Hive.openBox<Book>('books');
  await Hive.openBox<Customer>('customers');
  await Hive.openBox<RentHistory>('rentHistory'); // Ensure consistent naming

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      navigatorKey: NotificationService.navigatorKey, // Pass the navigatorKey here
      home: const HomePage(),
    );
  }
}
