import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:rentbookapp/pages/book_detail_page.dart'; // Correct path to BookDetailPage

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Add a GlobalKey to access the navigator context globally
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static get book => null;

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          // Handle the notification click and navigate using the navigator key
          navigateToBookDetails(response.payload!); // Safe unwrap
        }
      },
    );
  }

  // Show a simple notification
  static Future<void> showNotification(int id, String title, String body, String payload) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'book_channel', // Channel ID
        'Book Notifications', // Channel name
        importance: Importance.high, // High priority
        priority: Priority.high, // High priority
        playSound: true, // Play sound when notification is shown
        styleInformation: DefaultStyleInformation(true, true), // Default style
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
      );

      await _notificationsPlugin.show(
        id, // Unique ID for the notification
        title, // Title of the notification
        body, // Body of the notification
        details, // Notification details
        payload: payload, // Add payload here to pass data
      );
    } catch (e) {
      print("Error showing notification: $e");
    }
  }

  // Schedule a notification for a specific time
  static Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    DateTime dateTime,
    String payload,
  ) async {
    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(dateTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'book_channel',
            'Book Notifications',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            styleInformation: DefaultStyleInformation(true, true),
          ),
        ),
        androidAllowWhileIdle: true, // Required parameter
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      print("Error scheduling notification: $e");
    }
  }

  // Handle navigating to book details or another page upon clicking the notification
  static void navigateToBookDetails(String payload) {
    final bookId = int.tryParse(payload);
    if (bookId != null) {
      // Navigate to the book's detail page using the global navigator key
      print("Navigating to book details with ID: $bookId");

      // Use the navigatorKey to push a new route
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => BookDetailPage(book: book, bookId: bookId), // Corrected to pass bookId
        ),
      );
    }
  }

  // Schedule a rent return reminder notification
  static Future<void> scheduleRentReturnNotification(int bookId, String bookName, DateTime returnDate) async {
    await scheduleNotification(
      bookId,
      "Book Return Reminder",
      "Reminder: Please return the rented book: $bookName.",
      returnDate,
      bookId.toString(), // Passing the book ID as the payload
    );
  }

  // Schedule a pending rent reminder notification
  static Future<void> schedulePendingRentNotification(int bookId, String bookName, DateTime rentDate) async {
    await scheduleNotification(
      bookId,
      "Pending Rent Available",
      "The book '$bookName' is now available for rent starting from $rentDate.",
      rentDate,
      bookId.toString(), // Passing the book ID as the payload
    );
  }

  // Schedule an overdue reminder notification
  static Future<void> scheduleOverdueNotification(int bookId, String bookName) async {
    await showNotification(
      bookId,
      "Overdue Book Reminder",
      "The book '$bookName' is overdue. Please return it as soon as possible to avoid additional penalties.",
      bookId.toString(), // Passing the book ID as the payload
    );
  }
}
