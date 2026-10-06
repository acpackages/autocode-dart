import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:ac_patches_format/ac_patches_format.dart';

void main() {
  group('AcAssetArchive Tests', () {
    test('packs and unpacks memory files accurately', () {
      final inputFiles = {
        'images/logo.png': utf8.encode('PNG_IMAGE_BYTES_12345'),
        'data/config.json': utf8.encode('{"theme": "dark", "version": 2}'),
        'fonts/custom.ttf': utf8.encode('TTF_FONT_BYTES_ABC'),
      };

      final archiveBytes = AcAssetArchive.pack(inputFiles);
      expect(archiveBytes.length, greaterThan(20));

      final bundle = AcAssetArchive.unpack(archiveBytes);
      expect(bundle.files.length, equals(3));
      expect(utf8.decode(bundle.files['images/logo.png']!), equals('PNG_IMAGE_BYTES_12345'));
      expect(utf8.decode(bundle.files['data/config.json']!), equals('{"theme": "dark", "version": 2}'));
      expect(utf8.decode(bundle.files['fonts/custom.ttf']!), equals('TTF_FONT_BYTES_ABC'));
    });

    test('packs and unpacks directory tree', () async {
      final tempDir = Directory.systemTemp.createTempSync('ac_asset_test_');
      final targetExtractDir = Directory.systemTemp.createTempSync('ac_asset_extracted_');

      try {
        final subDir = Directory('${tempDir.path}${Platform.pathSeparator}assets${Platform.pathSeparator}images')
          ..createSync(recursive: true);
        final file1 = File('${subDir.path}${Platform.pathSeparator}banner.png');
        file1.writeAsStringSync('BANNER_CONTENT');

        final file2 = File('${tempDir.path}${Platform.pathSeparator}settings.json');
        file2.writeAsStringSync('{"key": "value"}');

        final packedBytes = await AcAssetArchive.packDirectory(tempDir);
        expect(packedBytes.isNotEmpty, isTrue);

        final bundle = AcAssetArchive.unpack(packedBytes);
        await bundle.extractToDirectory(targetExtractDir);

        final extractedFile1 = File('${targetExtractDir.path}/assets/images/banner.png'.replaceAll('/', Platform.pathSeparator));
        expect(extractedFile1.existsSync(), isTrue);
        expect(extractedFile1.readAsStringSync(), equals('BANNER_CONTENT'));

        final extractedFile2 = File('${targetExtractDir.path}/settings.json'.replaceAll('/', Platform.pathSeparator));
        expect(extractedFile2.existsSync(), isTrue);
        expect(extractedFile2.readAsStringSync(), equals('{"key": "value"}'));
      } finally {
        if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
        if (targetExtractDir.existsSync()) targetExtractDir.deleteSync(recursive: true);
      }
    });

    test('rejects corrupted header', () {
      final badBytes = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      expect(() => AcAssetArchive.unpack(badBytes), throwsA(isA<AcAssetArchiveException>()));
    });
  });
}
