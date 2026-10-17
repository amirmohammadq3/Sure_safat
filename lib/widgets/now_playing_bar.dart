import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../common/palette.dart';
import '../services/audio_service.dart';

class NowPlayingBar extends StatelessWidget {
  final AppPalette p;
  final AudioController audio;
  const NowPlayingBar({super.key, required this.p, required this.audio});

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final idx = audio.activeReciter;
    if (idx == null) return const SizedBox.shrink();
    final info = kReciters[idx];
    final isPlaying = audio.playerState == PlayerState.playing;
    final total = audio.duration.inMilliseconds > 0 ? audio.duration : const Duration(seconds: 1);
    final pos = audio.position.inMilliseconds.clamp(0, total.inMilliseconds).toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      decoration: BoxDecoration(
        color: p.arabicCardBg,
        border: Border(top: BorderSide(color: p.divider), bottom: BorderSide(color: p.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.graphic_eq, color: p.gold, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text('در حال پخش: ${info.name}', style: TextStyle(color: p.textPrimary, fontWeight: FontWeight.bold, fontSize: 12.5)),
              ),
              GestureDetector(
                onTap: audio.stop,
                child: Icon(Icons.close, color: p.textFaint, size: 18),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: pos,
              min: 0,
              max: total.inMilliseconds.toDouble(),
              activeColor: p.gold,
              inactiveColor: p.divider,
              onChanged: (v) => audio.seek(Duration(milliseconds: v.round())),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_fmt(audio.position), style: TextStyle(color: p.textFaint, fontSize: 10.5)),
                  Text(_fmt(audio.duration), style: TextStyle(color: p.textFaint, fontSize: 10.5)),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => audio.seekBy(const Duration(seconds: -10)),
                icon: Icon(Icons.replay_10, color: p.textSecondary, size: 26),
                tooltip: '۱۰ ثانیه عقب',
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => audio.playReciter(idx),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: p.gold),
                  alignment: Alignment.center,
                  child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 26),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () => audio.seekBy(const Duration(seconds: 10)),
                icon: Icon(Icons.forward_10, color: p.textSecondary, size: 26),
                tooltip: '۱۰ ثانیه جلو',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
