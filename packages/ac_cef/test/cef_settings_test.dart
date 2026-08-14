import 'dart:io';
import 'package:ac_cef/ac_cef.dart';
import 'package:test/test.dart';

void main() {
  group('CefSettings', () {
    test('explicit browserSubprocessPath is serialized directly', () {
      final settings = CefSettings(
        browserSubprocessPath: 'C:\\custom\\path\\helper.exe',
      );
      final map = settings.toMap();
      expect(map['browser_subprocess_path'], equals('C:\\custom\\path\\helper.exe'));
    });

    test('default CefSettings serializes boolean and string flags properly', () {
      final settings = CefSettings();
      final map = settings.toMap();
      expect(map['windowless_rendering_enabled'], equals('true'));
      expect(map['command_line_args_disabled'], equals('true'));
      expect(map['no_sandbox'], equals('false'));
    });

    test('resolveDefaultSubprocessPath returns candidate if file exists', () {
      final tempDir = Directory.systemTemp.createTempSync('cef_subproc_test');
      try {
        final helperName =
            Platform.isWindows ? 'ac_cef_helper.exe' : 'ac_cef_helper';
        final mockExe = File('${tempDir.path}${Platform.pathSeparator}app.exe');
        mockExe.createSync();
        final mockHelper =
            File('${tempDir.path}${Platform.pathSeparator}$helperName');
        mockHelper.createSync();

        final resolved =
            CefSettings.resolveDefaultSubprocessPath(mockExe.path);
        expect(resolved, equals(mockHelper.path));
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('resolveDefaultSubprocessPath returns null if helper does not exist', () {
      final tempDir = Directory.systemTemp.createTempSync('cef_subproc_empty_test');
      try {
        final mockExe = File('${tempDir.path}${Platform.pathSeparator}app.exe');
        mockExe.createSync();

        final resolved =
            CefSettings.resolveDefaultSubprocessPath(mockExe.path);
        expect(resolved, isNull);
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });
}
