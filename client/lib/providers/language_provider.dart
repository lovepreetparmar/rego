import 'package:flutter/material.dart';
import '../utils/app_enums.dart';

class LanguageProvider extends ChangeNotifier {
  Language _currentLanguage = Language.en;

  Language get currentLanguage => _currentLanguage;

  void setLanguage(Language language) {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      notifyListeners();
    }
  }
}
