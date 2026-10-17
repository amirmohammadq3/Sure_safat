import 'package:flutter/material.dart';
import '../common/app_state.dart';
import '../common/palette.dart';

class AppearanceSheet extends StatefulWidget {
  final AppPalette p;
  const AppearanceSheet({super.key, required this.p});

  static void show(BuildContext context, AppPalette p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: p.sheetBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => AppearanceSheet(p: p),
    );
  }

  @override
  State<AppearanceSheet> createState() => _AppearanceSheetState();
}

class _AppearanceSheetState extends State<AppearanceSheet> {
  Widget _fontChip(String label, String family) {
    final p = widget.p;
    final selected = appState.fontFamily == family;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => appState.setFontFamily(family)),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? p.gold : p.arabicCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? p.gold : p.divider),
          ),
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(label, style: TextStyle(color: selected ? Colors.white : p.textPrimary, fontWeight: FontWeight.bold, fontSize: 12.5)),
              const SizedBox(height: 6),
              Text('بِسْمِ ٱللَّهِ', style: TextStyle(color: selected ? Colors.white : p.textSecondary, fontFamily: family, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 42, height: 4, decoration: BoxDecoration(color: p.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('ظاهر و فونت', style: TextStyle(color: p.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 18),
            Row(
              children: [
                Text('اندازه‌ی متن عربی', style: TextStyle(color: p.textSecondary, fontSize: 13)),
                const Spacer(),
              ],
            ),
            Slider(
              value: appState.arabicFontSize,
              min: kMinArabicSize,
              max: kMaxArabicSize,
              activeColor: p.gold,
              onChanged: (v) => setState(() => appState.setArabicSize(v)),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('اندازه‌ی ترجمه‌ی فارسی', style: TextStyle(color: p.textSecondary, fontSize: 13)),
                const Spacer(),
              ],
            ),
            Slider(
              value: appState.persianFontSize,
              min: kMinPersianSize,
              max: kMaxPersianSize,
              activeColor: p.gold,
              onChanged: (v) => setState(() => appState.setPersianSize(v)),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text('قلم متن عربی', style: TextStyle(color: p.textSecondary, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _fontChip('نسخ عثمانی', kFontOsmani),
                _fontChip('نسخ قرآنی', kFontQurani),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
