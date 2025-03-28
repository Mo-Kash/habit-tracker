import 'package:flutter/material.dart';
import 'package:habit_tracker/theme/dark_mode.dart';
import 'package:habit_tracker/theme/light_mode.dart';

class ThemeProvider extends ChangeNotifier{
  ThemeData _themeData = lightMode; // initially
  ThemeData get themeData => _themeData; // get current theme
  bool get isDarkMode => _themeData == darkMode; // check whether current theme is dark mode

  set themeData(ThemeData themeData){ //set theme data
    _themeData = themeData; // change to desired value
    notifyListeners();
  }

  void toggleTheme(){
    if(_themeData==lightMode){
      _themeData = darkMode;
    }else{
      _themeData = lightMode;
    }
    notifyListeners();
  }
}