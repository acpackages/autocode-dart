import 'dart:core';
import 'dart:io';
extension AcDirectoryExtensions on Directory{
  Future<int> getDirectorySize() async {
    int totalSize = 0;
    try {
      await for (var entity in list(recursive: true, followLinks: false)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    } catch (e) {
      print('Error calculating directory size: $e');
    }
    return totalSize;
  }
}