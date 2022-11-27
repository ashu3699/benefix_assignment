import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'pages/calendar_page.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Benefix Assignment',
      debugShowCheckedModeBanner: false,
      home: CalendarPage(),
    );
  }
}
