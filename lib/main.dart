import 'package:flutter/material.dart';
import 'package:pdf_reader/providers/theme_provider.dart';
import 'package:pdf_reader/screens/tabs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  runApp(
      const ProviderScope(
          child: MyApp(),
      ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      title: 'PDF Reader with Syncfusion',
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      home: TabsScreen(),
    );
  }
}

