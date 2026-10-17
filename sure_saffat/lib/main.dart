import 'package:flutter/material.dart';
import 'common/app_state.dart';
import 'common/palette.dart';
import 'screens/quran_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SooreSaffatApp());
}

class SooreSaffatApp extends StatefulWidget {
  const SooreSaffatApp({super.key});
  @override
  State<SooreSaffatApp> createState() => _SooreSaffatAppState();
}

class _SooreSaffatAppState extends State<SooreSaffatApp> {
  @override
  void initState() {
    super.initState();
    appState.load();
  }

  ThemeData _buildTheme(AppPalette p, bool dark) {
    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: p.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: p.gold,
        brightness: dark ? Brightness.dark : Brightness.light,
      ),
      sliderTheme: SliderThemeData(activeTrackColor: p.gold, thumbColor: p.gold),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final p = currentPalette();
        return MaterialApp(
          title: 'سوره صافات',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(p, appState.isDarkMode),
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const QuranScreen(),
        );
      },
    );
  }
}
