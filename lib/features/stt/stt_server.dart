import 'dart:async';
import 'dart:convert';
import 'dart:io';

class SttServer {
  SttServer._();
  static final SttServer instance = SttServer._();

  Process? _process;

  Future<void> _installRequirementsIfNeeded() async {
    final sentinel = File('python_stt_server/.deps_installed');
    if (await sentinel.exists()) return;
    try {
      final install = await Process.start(
        'python',
        ['-m', 'pip', 'install', '-r', 'requirements.txt'],
        workingDirectory: 'python_stt_server',
        runInShell: true,
      );
      unawaited(install.stdout.transform(utf8.decoder).forEach(print));
      unawaited(install.stderr.transform(utf8.decoder).forEach(print));
      final code = await install.exitCode;
      if (code == 0) {
        await sentinel.writeAsString('ok');
      }
    } catch (e) {
      print('Failed to install STT requirements: $e');
    }
  }

  Future<void> start() async {
    if (_process != null) return;
    try {
      await _installRequirementsIfNeeded();
      _process = await Process.start(
        'python',
        ['whisper_server.py'],
        workingDirectory: 'python_stt_server',
        runInShell: true,
        mode: ProcessStartMode.detachedWithStdio,
      );
      unawaited(_process!.stdout.transform(utf8.decoder).forEach(print));
      unawaited(_process!.stderr.transform(utf8.decoder).forEach(print));
    } catch (e) {
      print('Failed to start STT server: $e');
    }
  }

  Future<void> stop() async {
    if (_process == null) return;
    try {
      _process!.kill();
      await _process!.exitCode;
    } catch (e) {
      print('Failed to stop STT server: $e');
    } finally {
      _process = null;
    }
  }
}
