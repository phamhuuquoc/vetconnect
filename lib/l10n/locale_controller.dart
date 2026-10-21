import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appLocale = LocaleController();

class LocaleController extends ChangeNotifier {
  static const preferenceKey = 'app_language';
  static const supportedLocales = [Locale('vi'), Locale('en')];
  Locale _locale = const Locale('vi');
  Locale get locale => _locale;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final code = preferences.getString(preferenceKey);
    _locale = supportedLocales.firstWhere(
        (locale) => locale.languageCode == code,
        orElse: () => const Locale('vi'));
    notifyListeners();
  }

  Future<void> select(Locale locale) async {
    if (_locale == locale) return;
    if (!supportedLocales.contains(locale)) {
      throw ArgumentError('Unsupported locale');
    }
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setString(preferenceKey, locale.languageCode)) {
      throw StateError('Could not save language preference');
    }
    _locale = locale;
    notifyListeners();
  }
}
