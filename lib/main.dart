import 'package:flutter/material.dart';
import 'package:pdf_reader/screens/tabs.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDF Reader with Syncfusion',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TabsScreen(),
    );
  }
}

