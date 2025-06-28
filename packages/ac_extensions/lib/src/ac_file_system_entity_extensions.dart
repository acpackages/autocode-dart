import 'dart:io';
import 'package:path/path.dart' as p;

extension AcFileSystemEntityExtensions on FileSystemEntity {
  String get extension => p.extension(path).replaceFirst('.', '');

  String entityName({bool includeExtension = true}) {
    return includeExtension
        ? p.basename(path)
        : p.basenameWithoutExtension(path);
  }

  bool get isDirectory =>
      FileSystemEntity.typeSync(path) == FileSystemEntityType.directory;

  bool get isFile =>
      FileSystemEntity.typeSync(path) == FileSystemEntityType.file;
}
