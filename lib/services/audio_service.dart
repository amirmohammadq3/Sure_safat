import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ReciterInfo {
  final String name;
  final String? assetPath; // فقط برای قاری همراه برنامه
  final String? downloadUrl; // فقط برای قاری‌های قابل‌دانلود
  final String fileName;
  const ReciterInfo({required this.name, this.assetPath, this.downloadUrl, required this.fileName});
}

const List<ReciterInfo> kReciters = [
  ReciterInfo(
    name: 'شهریار پرهیزگار',
    assetPath: 'audio/shahriyarPARHIZGAR.mp3',
    fileName: 'shahriyarPARHIZGAR.mp3',
  ),
  ReciterInfo(
    name: 'منشاوی',
    downloadUrl: 'https://user.skystorage.ir/0209caf8285358e0/safat%2Fmenshavi.mp3',
    fileName: 'menshavi.mp3',
  ),
  ReciterInfo(
    name: 'عبدالباسط',
    downloadUrl: 'https://user.skystorage.ir/0209caf8285358e0/safat%2Fabd_Al_base.mp3',
    fileName: 'abd_Al_base.mp3',
  ),
];

class AudioController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  PlayerState playerState = PlayerState.stopped;
  int? activeReciter; // قاری‌ای که همین الان در حال پخش/مکث است
  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  final Map<int, bool> downloaded = {0: true, 1: false, 2: false};
  final Map<int, double> downloadProgress = {}; // 0..1 در حین دانلود
  final Map<int, String?> downloadError = {};

  AudioController() {
    _player.onPlayerStateChanged.listen((s) {
      playerState = s;
      notifyListeners();
    });
    _player.onPositionChanged.listen((p) {
      position = p;
      notifyListeners();
    });
    _player.onDurationChanged.listen((d) {
      duration = d;
      notifyListeners();
    });
    _player.onPlayerComplete.listen((_) {
      playerState = PlayerState.stopped;
      position = Duration.zero;
      notifyListeners();
    });
  }

  Future<String> _localPath(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$fileName';
  }

  Future<void> checkDownloaded() async {
    for (int i = 1; i < kReciters.length; i++) {
      final path = await _localPath(kReciters[i].fileName);
      downloaded[i] = await File(path).exists();
    }
    notifyListeners();
  }

  Future<void> downloadReciter(int index) async {
    final info = kReciters[index];
    if (info.downloadUrl == null) return;
    downloadError[index] = null;
    downloadProgress[index] = 0;
    notifyListeners();
    final tempPath = '${await _localPath(info.fileName)}.part';
    final finalPath = await _localPath(info.fileName);
    IOSink? sink;
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(info.downloadUrl!));
      final response = await request.close();
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final total = response.contentLength;
      int received = 0;
      sink = File(tempPath).openWrite();
      await for (final chunk in response) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) {
          downloadProgress[index] = (received / total).clamp(0, 1).toDouble();
          notifyListeners();
        }
      }
      await sink.flush();
      await sink.close();
      sink = null;
      client.close();
      final tempFile = File(tempPath);
      if (await File(finalPath).exists()) {
        await File(finalPath).delete();
      }
      await tempFile.rename(finalPath);
      downloaded[index] = true;
      downloadProgress.remove(index);
      notifyListeners();
    } catch (_) {
      downloadError[index] = 'دانلود با خطا مواجه شد. دوباره تلاش کنید.';
      downloadProgress.remove(index);
      try {
        if (sink != null) await sink.close();
      } catch (_) {}
      try {
        final f = File(tempPath);
        if (await f.exists()) await f.delete();
      } catch (_) {}
      notifyListeners();
    }
  }

  Future<void> playReciter(int index) async {
    final info = kReciters[index];
    if (activeReciter == index && playerState == PlayerState.playing) {
      await _player.pause();
      return;
    }
    if (activeReciter == index && playerState == PlayerState.paused) {
      await _player.resume();
      return;
    }
    activeReciter = index;
    position = Duration.zero;
    notifyListeners();
    try {
      if (info.assetPath != null) {
        await _player.play(AssetSource(info.assetPath!));
      } else {
        final path = await _localPath(info.fileName);
        await _player.play(DeviceFileSource(path));
      }
    } catch (_) {
      playerState = PlayerState.stopped;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await _player.stop();
    activeReciter = null;
    position = Duration.zero;
    notifyListeners();
  }

  Future<void> seek(Duration to) async {
    await _player.seek(to);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
