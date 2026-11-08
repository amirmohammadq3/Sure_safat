import 'package:flutter/material.dart';
import '../common/palette.dart';
import '../services/audio_service.dart';

/// نوار باریک پخش، چسبیده به نوار پایین. با شروع پخش با انیمیشن از پایین بالا می‌آید
/// و با بستن یا توقف کامل، دوباره با انیمیشن جمع می‌شود.
class NowPlayingBar extends StatefulWidget {
  final AppPalette p;
  final AudioController audio;
  const NowPlayingBar({super.key, required this.p, required this.audio});

  @override
  State<NowPlayingBar> createState() => _NowPlayingBarState();
}

class _NowPlayingBarState extends State<NowPlayingBar> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  double? _dragMs; // موقعیت نوار هنگام کشیدن (میلی‌ثانیه)

  bool get _wantVisible => widget.audio.activeReciter != null;

  @override
  void initState() {
    super.initState();
    widget.audio.addListener(_syncVisibility);
    if (_wantVisible) _ctrl.value = 1;
  }

  void _syncVisibility() {
    if (!mounted) return;
    if (_wantVisible) {
      if (_ctrl.status != AnimationStatus.completed && _ctrl.status != AnimationStatus.forward) {
        _ctrl.forward();
      }
    } else {
      if (_ctrl.status != AnimationStatus.dismissed && _ctrl.status != AnimationStatus.reverse) {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    widget.audio.removeListener(_syncVisibility);
    _ctrl.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  Widget _iconButton(IconData icon, double size, Color color, VoidCallback? onTap) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, size: size, color: onTap == null ? color.withOpacity(0.35) : color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final audio = widget.audio;
    return AnimatedBuilder(
      animation: Listenable.merge([_ctrl, audio]),
      builder: (context, _) {
        if (_ctrl.isDismissed) return const SizedBox.shrink();

        final hasDuration = audio.duration > Duration.zero;
        final maxMs = hasDuration ? audio.duration.inMilliseconds.toDouble() : 1.0;
        final shownMs = (_dragMs ?? audio.position.inMilliseconds.toDouble()).clamp(0.0, maxMs).toDouble();
        final timeStyle = TextStyle(
          color: p.textFaint,
          fontSize: 10.5,
          fontFeatures: const [FontFeature.tabularFigures()],
        );

        final bar = Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: p.headerBg,
            border: Border(top: BorderSide(color: p.divider)),
          ),
          // زمان و نوار پیشرفت همیشه چپ‌به‌راست (مثل پخش‌کننده‌های معمول)
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                _iconButton(Icons.replay_10_rounded, 22, p.gold, hasDuration ? () => audio.seekBy(const Duration(seconds: -10)) : null),
                SizedBox(width: 38, child: Text(_fmt(Duration(milliseconds: shownMs.round())), textAlign: TextAlign.center, style: timeStyle)),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2.5,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.5, elevation: 0, pressedElevation: 0),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      activeTrackColor: p.gold,
                      inactiveTrackColor: p.divider,
                      thumbColor: p.gold,
                      disabledThumbColor: p.divider,
                      disabledActiveTrackColor: p.divider,
                      disabledInactiveTrackColor: p.divider,
                    ),
                    child: Slider(
                      value: shownMs,
                      min: 0,
                      max: maxMs,
                      onChanged: hasDuration ? (v) => setState(() => _dragMs = v) : null,
                      onChangeEnd: hasDuration
                          ? (v) async {
                              await audio.seek(Duration(milliseconds: v.round()));
                              if (mounted) setState(() => _dragMs = null);
                            }
                          : null,
                    ),
                  ),
                ),
                SizedBox(width: 38, child: Text(_fmt(audio.duration), textAlign: TextAlign.center, style: timeStyle)),
                _iconButton(Icons.forward_10_rounded, 22, p.gold, hasDuration ? () => audio.seekBy(const Duration(seconds: 10)) : null),
                _iconButton(Icons.close_rounded, 16, p.textFaint, audio.stop),
              ],
            ),
          ),
        );

        // باز شدن از پایین به بالا + محو شدن
        return ClipRect(
          child: Align(
            alignment: Alignment.bottomCenter,
            heightFactor: _curve.value,
            child: Opacity(opacity: _curve.value.clamp(0.0, 1.0), child: bar),
          ),
        );
      },
    );
  }
}
