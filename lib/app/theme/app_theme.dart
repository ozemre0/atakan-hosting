import 'package:flutter/material.dart';

ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  );
}

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
  );
}


