import 'package:calenderr/booking_calendar.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

    List<DateTime> blocked = [
      DateTime(2024, 7, 10),
      DateTime(2024, 7, 11),
      DateTime(2024, 7, 1),
      DateTime(2024, 6, 30),
    ];


    List<DateTime> reserved = [
      DateTime(2024, 6, 25),
      DateTime(2024, 6, 26),
      DateTime(2024, 6, 27),
      DateTime(2024, 7, 2),
      DateTime(2024, 7, 3),
      DateTime(2024, 7, 4),
      DateTime(2024, 7, 5),
    ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BookingCalendar(reservedDays: reserved, blockedDays: blocked),
    );
  }
}


