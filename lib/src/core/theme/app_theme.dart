import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData themeData = _buildTheme();

  static ThemeData _buildTheme() {
    return ThemeData(primarySwatch: Colors.blue, useMaterial3: true);
  }
}
