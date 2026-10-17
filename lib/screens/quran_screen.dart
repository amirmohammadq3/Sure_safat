import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../common/ayah_mark.dart';
import '../common/app_state.dart';
import '../common/palette.dart';
import '../data/ayah_model.dart';
import '../data/pagination.dart';
import '../data/saffat_repository.dart';
import '../services/audio_service.dart';
import '../widgets/appearance_sheet.dart';
import '../widgets/dashed_divider.dart';
import '../widgets/now_playing_bar.dart';
import '../widgets/reciters_sheet.dart';
import 'about_sheet.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});
  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> with AppStateListenerMixin {
  SurahData? _data;
  List<List<Ayah>> _pages = [];
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;
  late final AudioController _audio = AudioController();

  @override
  void initState() {
    super.initState();
    _audio.addListener(_onAudioChange);
    _audio.checkDownloaded();
    SaffatRepository.load().then((d) {
      if (!mounted) return;
      setState(() {
        _data = d;
        _pages = buildPages(d.ayahs);
      });
    });
  }

  void _onAudioChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _audio.removeListener(_onAudioChange);
    _audio.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  Widget _header(AppPalette p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => AboutSheet.show(context, p),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: p.gold)),
              alignment: Alignment.center,
              child: Text('؟', style: TextStyle(color: p.gold, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('سوره صافات', style: TextStyle(color: p.gold, fontWeight: FontWeight.bold, fontSize: 19)),
                  const SizedBox(width: 8),
                  Icon(Icons.menu_book_outlined, color: p.gold, size: 20),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => appState.setDarkMode(!appState.isDarkMode),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: p.gold)),
              alignment: Alignment.center,
              child: Icon(appState.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined, color: p.gold, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ayahBlock(AppPalette p, Ayah a) {
    final arabicWithMark = '${a.arabic} ${ayahEndMark(a.number)}';
    // یک کادر واحد برای هر آیه: متن عربی + خط‌چین + ترجمه، همه داخل همین کادر
    // تا معلوم باشد این ترجمه دقیقاً مال همین آیه است و با آیه‌ی دیگری قاطی نشود.
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: p.arabicCardBg, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              arabicWithMark,
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: p.textPrimary,
                fontFamily: appState.fontFamily,
                fontSize: appState.arabicFontSize,
                height: 1.9,
              ),
            ),
            DashedDivider(p: p),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: p.translationCardBg, borderRadius: BorderRadius.circular(12)),
              child: Text(
                a.persian,
                textAlign: TextAlign.right,
                style: TextStyle(color: p.textSecondary, fontSize: appState.persianFontSize, height: 1.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بعد از آخرین آیه‌ی سوره (آیه ۱۸۲) نمایش داده می‌شود
  Widget _closingBlock(AppPalette p) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Column(
        children: [
          Text(
            'صَدَقَ ٱللَّهُ ٱلْعَلِيُّ ٱلْعَظِيمُ',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(color: p.gold, fontFamily: appState.fontFamily, fontWeight: FontWeight.bold, fontSize: appState.arabicFontSize + 2),
          ),
          const SizedBox(height: 14),
          Text(
            'منبع متن عربی و ترجمه‌ی فارسی: دانشنامه‌ی قرآن کریم (QuranEnc.com)، ترجمه‌ی فارسی تهیه‌شده زیر نظر مرکز رواد الترجمة. '
            'متن بدون هیچ تغییری بازنشر شده و طبق شرایط بازنشر این سایت، نام ناشر و منبع در اینجا ذکر می‌شود.',
            textAlign: TextAlign.center,
            style: TextStyle(color: p.textFaint, fontSize: 10.5, height: 1.8),
          ),
        ],
      ),
    );
  }

  Widget _pageView(AppPalette p, int pageIndex) {
    final ayahs = _pages[pageIndex];
    final isLastPage = pageIndex == _pages.length - 1;
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      children: [
        if (pageIndex == 0) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Text(
              _data!.basmala,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(color: p.gold, fontFamily: appState.fontFamily, fontSize: appState.arabicFontSize + 2, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        for (final a in ayahs) _ayahBlock(p, a),
        if (isLastPage) _closingBlock(p),
      ],
    );
  }

  Widget _bottomToolbar(AppPalette p) {
    final reciter = kReciters[appState.selectedReciter];
    final isPlaying = _audio.activeReciter == appState.selectedReciter && _audio.playerState == PlayerState.playing;
    final isDownloaded = _audio.downloaded[appState.selectedReciter] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: p.headerBg,
        border: Border(top: BorderSide(color: p.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _toolbarIcon(p, Icons.tune, 'ظاهر', () => AppearanceSheet.show(context, p)),
              GestureDetector(
                onTap: () {
                  if (!isDownloaded) {
                    RecitersSheet.show(context, p, _audio);
                    return;
                  }
                  _audio.playReciter(appState.selectedReciter);
                },
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: p.gold),
                  alignment: Alignment.center,
                  child: Icon(
                    !isDownloaded ? Icons.download_outlined : (isPlaying ? Icons.pause : Icons.play_arrow),
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              _toolbarIcon(p, Icons.headphones_outlined, 'قاری: ${reciter.name}', () => RecitersSheet.show(context, p, _audio)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolbarIcon(AppPalette p, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: p.gold)),
            alignment: Alignment.center,
            child: Icon(icon, color: p.gold, size: 20),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 92,
            child: Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.textFaint, fontSize: 9.5)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = currentPalette();
    if (_data == null || _pages.isEmpty) {
      return Scaffold(
        backgroundColor: p.bg,
        body: Center(child: CircularProgressIndicator(color: p.gold)),
      );
    }
    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(p),
            Divider(color: p.divider, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'ورق ${_currentPage + 1} از ${_pages.length}',
                style: TextStyle(color: p.textFaint, fontSize: 11),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => _pageView(p, i),
              ),
            ),
            if (_audio.activeReciter != null) NowPlayingBar(p: p, audio: _audio),
          ],
        ),
      ),
      bottomNavigationBar: _bottomToolbar(p),
    );
  }
}
