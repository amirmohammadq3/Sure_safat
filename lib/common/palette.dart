import 'package:flutter/material.dart';
import 'app_state.dart';

class AppPalette {
  final Color bg;
  final Color headerBg;
  final Color arabicCardBg;
  final Color translationCardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color textFaint;
  final Color gold;
  final Color divider;
  final Color sheetBg;

  const AppPalette({
    required this.bg,
    required this.headerBg,
    required this.arabicCardBg,
    required this.translationCardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.textFaint,
    required this.gold,
    required this.divider,
    required this.sheetBg,
  });
}

const AppPalette kLightPalette = AppPalette(
  bg: Color(0xFFF2E9DA),
  headerBg: Color(0xFFF2E9DA),
  arabicCardBg: Color(0xFFFFFFFF),
  translationCardBg: Color(0xFFF7ECD9),
  textPrimary: Color(0xFF221A10),
  textSecondary: Color(0xFF6B5A3E),
  textFaint: Color(0xFF9C8D72),
  gold: Color(0xFFC9A250),
  divider: Color(0xFFE3D5B8),
  sheetBg: Color(0xFFFBF5E9),
);

const AppPalette kDarkPalette = AppPalette(
  bg: Color(0xFF14110C),
  headerBg: Color(0xFF14110C),
  arabicCardBg: Color(0xFF1F1A12),
  translationCardBg: Color(0xFF231D14),
  textPrimary: Color(0xFFF1E7D4),
  textSecondary: Color(0xFFC9B894),
  textFaint: Color(0xFF8A7A5C),
  gold: Color(0xFFD9B35C),
  divider: Color(0xFF332A1C),
  sheetBg: Color(0xFF1C170F),
);

AppPalette currentPalette() => appState.isDarkMode ? kDarkPalette : kLightPalette;
