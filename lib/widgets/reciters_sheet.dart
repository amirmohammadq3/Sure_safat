import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../common/app_state.dart';
import '../common/palette.dart';
import '../services/audio_service.dart';

class RecitersSheet extends StatelessWidget {
  final AppPalette p;
  final AudioController audio;
  const RecitersSheet({super.key, required this.p, required this.audio});

  static void show(BuildContext context, AppPalette p, AudioController audio) {
    showModalBottomSheet(
      context: context,
      backgroundColor: p.sheetBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => AnimatedBuilder(
        animation: audio,
        builder: (ctx, _) => RecitersSheet(p: p, audio: audio),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 42, height: 4, decoration: BoxDecoration(color: p.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('انتخاب قاری', style: TextStyle(color: p.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 14),
            for (int i = 0; i < kReciters.length; i++) _reciterRow(context, i),
          ],
        ),
      ),
    );
  }

  Widget _reciterRow(BuildContext context, int index) {
    final info = kReciters[index];
    final isDownloaded = audio.downloaded[index] ?? false;
    final progress = audio.downloadProgress[index];
    final error = audio.downloadError[index];
    final selected = appState.selectedReciter == index;
    final isPlaying = audio.activeReciter == index && audio.playerState == PlayerState.playing;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? p.gold.withOpacity(0.12) : p.arabicCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? p.gold : p.divider),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              appState.setSelectedReciter(index);
            },
            child: Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? p.gold : p.textFaint, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info.name, style: TextStyle(color: p.textPrimary, fontWeight: FontWeight.bold, fontSize: 13.5)),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(error, style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
                  ),
              ],
            ),
          ),
          if (!isDownloaded && progress == null)
            IconButton(
              onPressed: () => audio.downloadReciter(index),
              icon: Icon(Icons.download_outlined, color: p.gold),
              tooltip: 'دانلود',
            )
          else if (progress != null)
            SizedBox(
              width: 34,
              height: 34,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(value: progress, strokeWidth: 3, color: p.gold, backgroundColor: p.divider),
                  Text('${(progress * 100).round()}', style: TextStyle(color: p.textSecondary, fontSize: 8)),
                ],
              ),
            )
          else
            IconButton(
              onPressed: () => audio.playReciter(index),
              icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle, color: p.gold, size: 28),
            ),
        ],
      ),
    );
  }
}
