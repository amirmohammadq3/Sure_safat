import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'ayah_model.dart';

class SaffatRepository {
  static SurahData? _cached;

  static Future<SurahData> load() async {
    if (_cached != null) return _cached!;
    final raw = await rootBundle.loadString('assets/saffat.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final surahJson = json['surah'] as Map<String, dynamic>;
    final ayahsJson = json['ayahs'] as List<dynamic>;
    final ayahs = ayahsJson
        .map((e) => Ayah(
              number: (e as Map<String, dynamic>)['n'] as int,
              arabic: e['ar'] as String,
              persian: e['fa'] as String,
            ))
        .toList();
    final data = SurahData(
      number: surahJson['number'] as int,
      nameAr: surahJson['nameAr'] as String,
      nameFa: surahJson['nameFa'] as String,
      basmala: surahJson['basmala'] as String,
      translator: surahJson['translator'] as String,
      ayahs: ayahs,
    );
    _cached = data;
    return data;
  }
}
