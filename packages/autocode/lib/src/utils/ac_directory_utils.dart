import 'dart:io';

/* AcDoc({
  "description": "Utility class for managing and copying directories within the file system.",
  "author": "Sanket Patel"
}) */
class AcDirectoryUtils {
  /* AcDoc({
    "description": "Checks if a directory exists at the given path and creates it recursively if not."
  }) */
  static Future<void> checkAndCreateDirectory(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  /* AcDoc({
    "description": "Recursively copies all files and directories from the source path to the destination path."
  }) */
  static void copyDirectory({
    required String sourcePath,
    required String destinationPath,
  }) {
    final source = Directory(sourcePath);
    final destination = Directory(destinationPath);

    if (!destination.existsSync()) {
      destination.createSync(recursive: true);
    }

    final files = source.listSync(recursive: true);

    for (final entity in files) {
      final relativePath = entity.path.replaceFirst(source.path, '').replaceFirst(RegExp(r'^[/\\]'), '');
      final newPath = '${destination.path}${Platform.pathSeparator}$relativePath';

      if (entity is File) {
        final newFile = File(newPath);
        newFile.createSync(recursive: true);
        newFile.writeAsBytesSync(entity.readAsBytesSync());
      } else if (entity is Directory) {
        Directory(newPath).createSync(recursive: true);
      }
    }
  }
}
