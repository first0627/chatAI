import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateProvider<ThemeModel>((ref) {
  return ThemeModel(primaryColor: Colors.blue, accentColor: Colors.green);
});

class ThemeModel {
  final Color primaryColor;
  final Color accentColor;

  const ThemeModel({required this.primaryColor, required this.accentColor});
}
