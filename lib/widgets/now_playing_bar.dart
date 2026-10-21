import 'package:flutter/material.dart';
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

  Widget _seekButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: p.translationCardBg,
              border: Border.all(color: p.gold.withOpacity(0.5)),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: p.gold, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: p.textFaint, fontSize: 10)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final idx = audio.activeReciter;
    if (idx == null) return const SizedBox.shrink();
    final info = kReciters[idx];
    final total = audio.duration.inMilliseconds > 0 ? audio.duration : const Duration(seconds: 1);
    final pos = audio.position.inMilliseconds.clamp(0, total.inMilliseconds).toDouble();

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      decoration: BoxDecoration(
        color: p.arabicCardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, -4))],
        border: Border.all(color: p.divider),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(shape: BoxShape.circle, color: p.gold.withOpacity(0.15)),
                alignment: Alignment.center,
                child: Icon(Icons.graphic_eq, color: p.gold, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('در حال پخش', style: TextStyle(color: p.textFaint, fontSize: 10)),
                    Text(info.name, style: TextStyle(color: p.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: audio.stop,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: p.translationCardBg),
                  alignment: Alignment.center,
                  child: Icon(Icons.close, color: p.textFaint, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
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
            padding: const EdgeInsets.only(bottom: 10),
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
              _seekButton(Icons.replay_10, '۱۰ ثانیه عقب', () => audio.seekBy(const Duration(seconds: -10))),
              const SizedBox(width: 36),
              _seekButton(Icons.forward_10, '۱۰ ثانیه جلو', () => audio.seekBy(const Duration(seconds: 10))),
            ],
          ),
        ],
      ),
    );
  }
}
