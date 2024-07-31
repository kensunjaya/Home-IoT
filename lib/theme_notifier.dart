import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ThemeNotifier with ChangeNotifier {
  Color _seedColor = Colors.cyan;

  ThemeNotifier() {
    String? color = GetStorage().read('seed_color');
    if (color != null) {
      _seedColor = _getColorFromString(color);
    }
  }

  Color get seedColor => _seedColor;

  void setSeedColor(String color) {
    _seedColor = _getColorFromString(color);
    GetStorage().write('seed_color', color);
    notifyListeners();
  }

  Color _getColorFromString(String color) {
    switch (color) {
      case 'Blue':
        return Colors.blue;
      case 'Indigo':
        return Colors.indigo;
      case 'Red':
        return Colors.red;
      case 'Green':
        return Colors.green;
      case 'Yellow':
        return Colors.yellow;
      case 'Purple':
        return Colors.deepPurple;
      case 'Orange':
        return Colors.orange;
      case 'Pink':
        return Colors.pinkAccent;
      case 'Brown':
        return Colors.brown;
      case 'Teal':
        return Colors.teal;
      default:
        return Colors.cyan;
    }
  }
}
