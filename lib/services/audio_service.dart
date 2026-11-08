import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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
    downloadUrl: 'https://api.skystorage.ir/download.php?s=0209caf8285358e0.8bf57b1e6352818d574a',
    fileName: 'menshavi.mp3',
  ),
  ReciterInfo(
    name: 'عبدالباسط',
    downloadUrl: 'https://api.skystorage.ir/download.php?s=0209caf8285358e0.932456637538bee0e1e9',
    fileName: 'abd_Al_base.mp3',
  ),
];

/// فایل صوتی معتبر هر قاری قطعاً بزرگ‌تر از ۱ مگابایت است؛ کوچک‌تر یعنی صفحه‌ی خطا
/// یا فایل ناقص ذخیره شده است و نباید «دانلودشده» حساب شود.
const int kMinAudioBytes = 1024 * 1024;

const String _kUserAgent =
    'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Mobile Safari/537.36';

class _BadSourceException implements Exception {
  final String reason;
  const _BadSourceException(this.reason);
}

bool _looksLikeAudio(List<int> b) {
  if (b.length < 12) return false;
  if (b[0] == 0x49 && b[1] == 0x44 && b[2] == 0x33) return true; // ID3 (mp3)
  if (b[0] == 0xFF && (b[1] & 0xE0) == 0xE0) return true; // فریم mp3/aac
  if (b[4] == 0x66 && b[5] == 0x74 && b[6] == 0x79 && b[7] == 0x70) return true; // ftyp (m4a)
  if (b[0] == 0x4F && b[1] == 0x67 && b[2] == 0x67 && b[3] == 0x53) return true; // OggS
  if (b[0] == 0x52 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x46) return true; // RIFF (wav)
  return false;
}

bool _looksLikeHtml(List<int> bytes) {
  final n = bytes.length < 200 ? bytes.length : 200;
  final head = String.fromCharCodes(bytes.sublist(0, n)).trimLeft().toLowerCase();
  return head.startsWith('<') || head.contains('<!doctype html') || head.contains('<html');
}

/// اگر سرور به‌جای خود فایل، یک صفحه‌ی HTML (صفحه‌ی دانلود) برگرداند،
/// آدرس واقعی فایل را از داخل آن پیدا می‌کند (meta refresh، جاوااسکریپت یا لینک mp3).
Uri? _extractMediaUrl(String html, Uri base) {
  String clean(String s) => s.replaceAll('&amp;', '&').replaceAll(r'\/', '/').trim();

  final patterns = <RegExp>[
    RegExp(r'''<meta[^>]+http-equiv=["']?refresh["']?[^>]*content=["'][^"']*url=([^"'>\s]+)''', caseSensitive: false),
    RegExp(r'''location(?:\.href)?\s*=\s*["']([^"']+)["']''', caseSensitive: false),
    RegExp(r'''location\.(?:replace|assign)\(\s*["']([^"']+)["']''', caseSensitive: false),
    RegExp(r'''["']((?:https?:)?[^"'\s<>]+\.mp3[^"'\s<>]*)["']''', caseSensitive: false),
    RegExp(r'''href=["']([^"']*download[^"']*)["']''', caseSensitive: false),
  ];
  for (final re in patterns) {
    for (final m in re.allMatches(html)) {
      final raw = clean(m.group(1) ?? '');
      if (raw.isEmpty || raw.startsWith('#') || raw.startsWith('javascript:')) continue;
      Uri? resolved;
      try {
        resolved = base.resolve(raw);
      } catch (_) {
        continue;
      }
      if (resolved.scheme != 'http' && resolved.scheme != 'https') continue;
      if (resolved.toString() == base.toString()) continue;
      return resolved;
    }
  }
  return null;
}

class AudioController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  PlayerState playerState = PlayerState.stopped;
  int? activeReciter; // قاری‌ای که همین الان در حال پخش/مکث است
  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  final Map<int, bool> downloaded = {0: true, 1: false, 2: false};
  /// 0..1 در حین دانلود؛ مقدار -1 یعنی حجم فایل از سرور معلوم نیست
  final Map<int, double> downloadProgress = {};
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
      final f = File(await _localPath(kReciters[i].fileName));
      var ok = false;
      if (await f.exists()) {
        if (await f.length() >= kMinAudioBytes) {
          ok = true;
        } else {
          // فایل خراب (مثلاً صفحه‌ی خطای لینک قدیمی) پاک می‌شود تا دوباره دانلود شود
          try {
            await f.delete();
          } catch (_) {}
        }
      }
      downloaded[i] = ok;
    }
    notifyListeners();
  }

  /// یک درخواست؛ اگر خود فایل بود در [tempPath] ذخیره می‌کند و null برمی‌گرداند،
  /// اگر صفحه‌ی HTML بود آدرس بعدی را برمی‌گرداند.
  Future<Uri?> _fetchOnce(HttpClient client, Uri url, String tempPath, int index) async {
    final request = await client.getUrl(url);
    request.headers.set(HttpHeaders.acceptHeader, '*/*');
    final response = await request.close();
    if (response.statusCode != 200) {
      await response.drain<void>();
      throw _BadSourceException('HTTP ${response.statusCode}');
    }
    final mime = (response.headers.contentType?.mimeType ?? '').toLowerCase();
    final htmlMime = mime == 'text/html' || mime == 'application/xhtml+xml';
    final total = response.contentLength;
    var isHtml = false;
    var decided = false;
    final head = BytesBuilder();
    final html = BytesBuilder();
    IOSink? sink;
    var received = 0;
    try {
      await for (final chunk in response.timeout(const Duration(seconds: 30))) {
        if (!decided) {
          head.add(chunk);
          if (head.length < 64) continue;
          final bytes = head.takeBytes();
          decided = true;
          // هدر ممکن است اشتباه باشد؛ محتوای واقعی تعیین‌کننده است
          isHtml = _looksLikeHtml(bytes) || (htmlMime && !_looksLikeAudio(bytes));
          if (isHtml) {
            html.add(bytes);
          } else {
            sink = File(tempPath).openWrite();
            sink.add(bytes);
            received += bytes.length;
          }
        } else if (isHtml) {
          html.add(chunk);
          if (html.length > 600000) break;
        } else {
          sink!.add(chunk);
          received += chunk.length;
        }
        if (!isHtml && sink != null) {
          downloadProgress[index] = total > 0 ? (received / total).clamp(0.0, 1.0).toDouble() : -1.0;
          notifyListeners();
        }
      }
      if (!decided) {
        // پاسخ خیلی کوتاه (کمتر از ۶۴ بایت)؛ فقط اگر یک صفحه‌ی HTML/ریدایرکت کوتاه باشد قابل استفاده است
        final bytes = head.takeBytes();
        if (bytes.isEmpty || !_looksLikeHtml(bytes)) throw const _BadSourceException('too-short');
        isHtml = true;
        html.add(bytes);
      }
      if (isHtml) {
        final text = utf8.decode(html.takeBytes(), allowMalformed: true);
        final next = _extractMediaUrl(text, url);
        if (next == null) throw const _BadSourceException('html-without-link');
        return next;
      }
      await sink!.flush();
      return null;
    } finally {
      try {
        await sink?.close();
      } catch (_) {}
    }
  }

  Future<void> downloadReciter(int index) async {
    final info = kReciters[index];
    if (info.downloadUrl == null) return;
    downloadError[index] = null;
    downloadProgress[index] = 0;
    notifyListeners();
    final tempPath = '${await _localPath(info.fileName)}.part';
    final finalPath = await _localPath(info.fileName);
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20)
      ..userAgent = _kUserAgent;
    try {
      Uri? next = Uri.parse(info.downloadUrl!);
      var hops = 0;
      while (next != null) {
        if (hops++ >= 3) throw const _BadSourceException('too-many-hops');
        next = await _fetchOnce(client, next, tempPath, index);
      }
      final tempFile = File(tempPath);
      if (!await tempFile.exists() || await tempFile.length() < kMinAudioBytes) {
        throw const _BadSourceException('too-small');
      }
      final finalFile = File(finalPath);
      if (await finalFile.exists()) {
        await finalFile.delete();
      }
      await tempFile.rename(finalPath);
      downloaded[index] = true;
      downloadProgress.remove(index);
      notifyListeners();
    } on _BadSourceException {
      downloadError[index] = 'سرور فایل صوتی معتبری برنگرداند. کمی بعد دوباره تلاش کنید.';
      await _failCleanup(index, tempPath);
    } catch (_) {
      downloadError[index] = 'دانلود با خطا مواجه شد. اینترنت را بررسی و دوباره تلاش کنید.';
      await _failCleanup(index, tempPath);
    } finally {
      client.close(force: true);
    }
  }

  Future<void> _failCleanup(int index, String tempPath) async {
    downloadProgress.remove(index);
    try {
      final f = File(tempPath);
      if (await f.exists()) await f.delete();
    } catch (_) {}
    notifyListeners();
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
    var clamped = to;
    if (clamped < Duration.zero) clamped = Duration.zero;
    if (duration > Duration.zero && clamped > duration) clamped = duration;
    try {
      await _player.seek(clamped);
      position = clamped;
      notifyListeners();
    } catch (_) {}
  }

  /// عقب/جلو رفتن نسبت به موقعیت فعلی (برای دکمه‌های ۱۰ ثانیه)
  Future<void> seekBy(Duration delta) async {
    await seek(position + delta);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
