import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeProviderNotifier extends StateNotifier<ThemeMode> {
  ThemeProviderNotifier() : super(ThemeMode.system);

  void toggleStatus(bool isOn) {
    state = isOn ? ThemeMode.dark : ThemeMode.light;
  }

  ThemeMode getMode() => state;
}

final themeModeProvider =
    StateNotifierProvider<ThemeProviderNotifier, ThemeMode>((ref) {
  return ThemeProviderNotifier();
});

class MyThemes {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade900,
    primaryColor: Colors.black,
    colorScheme: ColorScheme.dark(),
    iconTheme: IconThemeData(color: Colors.purple.shade200, opacity: 0.8),
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.white,
    colorScheme: ColorScheme.light(),
    iconTheme: IconThemeData(color: Colors.red, opacity: 0.8),
  );
}
