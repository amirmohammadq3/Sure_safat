import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kFontOsmani = 'نسخ عثمانی'; // ScheherazadeNew-Regular
const String kFontQurani = 'نسخ قرآنی'; // AmiriQuran

const double kMinArabicSize = 20;
const double kMaxArabicSize = 42;
const double kMinPersianSize = 12;
const double kMaxPersianSize = 24;

class AppState extends ChangeNotifier {
  bool isDarkMode = false;
  double arabicFontSize = 28;
  double persianFontSize = 16;
  String fontFamily = kFontOsmani;
  int selectedReciter = 0; // 0=شهریار پرهیزگار (همراه برنامه), 1=منشاوی, 2=عبدالباسط
  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool('is_dark') ?? false;
    arabicFontSize = prefs.getDouble('arabic_size') ?? 28;
    persianFontSize = prefs.getDouble('persian_size') ?? 16;
    fontFamily = prefs.getString('font_family') ?? kFontOsmani;
    selectedReciter = prefs.getInt('selected_reciter') ?? 0;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool v) async {
    isDarkMode = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark', v);
  }

  Future<void> setArabicSize(double v) async {
    arabicFontSize = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('arabic_size', v);
  }

  Future<void> setPersianSize(double v) async {
    persianFontSize = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('persian_size', v);
  }

  Future<void> setFontFamily(String v) async {
    fontFamily = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('font_family', v);
  }

  Future<void> setSelectedReciter(int v) async {
    selectedReciter = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_reciter', v);
  }
}

final appState = AppState();

/// برای ویجت‌های Stateful که باید با تغییرات appState بازسازی شوند
mixin AppStateListenerMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    appState.addListener(_onChange);
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    appState.removeListener(_onChange);
    super.dispose();
  }
}
