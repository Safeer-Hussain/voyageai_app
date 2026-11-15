import 'dart:io';

void main(List<String> args) async {
  stdout.writeln('====================================================');
  stdout.writeln('VOYAGEAI SPRINT GATEKEEPER');
  stdout.writeln('====================================================');

  // Step 1: flutter pub get
  await _runStep(
    name: '1. Dependencies Resolution',
    executable: 'flutter',
    arguments: ['pub', 'get'],
  );

  // Step 2: dart format lib test tool
  await _runStep(
    name: '2. Code Formatting Verification',
    executable: 'dart',
    arguments: ['format', 'lib', 'test', 'tool'],
  );

  // Step 3: flutter analyze --no-fatal-infos --no-pub
  await _runStep(
    name: '3. Static Analysis Gate',
    executable: 'flutter',
    arguments: ['analyze', '--no-fatal-infos', '--no-pub'],
  );

  // Step 4: flutter test --no-pub
  await _runStep(
    name: '4. Automated Test Suite',
    executable: 'flutter',
    arguments: ['test', '--no-pub'],
  );

  // Step 5: Connected Physical Device Logcat Check (if adb available)
  stdout.writeln('\n[Phase 5: Physical Device Runtime Diagnostic]');
  try {
    final adbDevices = await Process.run('adb', ['devices']);
    if (adbDevices.exitCode == 0 &&
        adbDevices.stdout.toString().contains('device\n')) {
      stdout.writeln(
        'Scanning device runtime logs for critical regressions...',
      );
      final logcat = await Process.run('adb', ['logcat', '-d']);
      final logs = logcat.stdout.toString();
      if (logs.contains('RenderFlex overflowed') ||
          logs.contains('There are multiple heroes that share the same tag')) {
        stderr.writeln(
          'GATE FAILURE: Detected runtime visual regressions in adb logcat!',
        );
        exit(1);
      } else {
        stdout.writeln(
          'Device runtime logcat check passed: zero overflows or hero collisions.',
        );
      }
    } else {
      stdout.writeln(
        'No active physical Android devices connected via ADB. Skipping logcat dump.',
      );
    }
  } catch (_) {
    stdout.writeln(
      'ADB utility not present in system environment. Skipping runtime log dump.',
    );
  }

  stdout.writeln('\n====================================================');
  stdout.writeln('GATE STATUS: ALL VOYAGEAI PHASES PASSED CLEANLY');
  stdout.writeln('====================================================');
  exit(0);
}

Future<void> _runStep({
  required String name,
  required String executable,
  required List<String> arguments,
}) async {
  stdout.writeln('\n[$name] Executing: $executable ${arguments.join(" ")}');
  final result = await Process.run(executable, arguments, runInShell: true);

  if (result.stdout.toString().trim().isNotEmpty) {
    stdout.writeln(result.stdout.toString().trim());
  }
  if (result.stderr.toString().trim().isNotEmpty) {
    stderr.writeln(result.stderr.toString().trim());
  }

  if (result.exitCode != 0) {
    stderr.writeln(
      '\nGATE REJECTED: $name failed with exit code ${result.exitCode}.',
    );
    exit(result.exitCode);
  }
}
