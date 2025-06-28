// dart:core is always implicitly imported and can be removed.
import 'dart:io';

/* AcDoc({
  "type": "extension",
  "summary": "Adds utility methods to the core Directory class.",
  "description": "Enhances the dart:io Directory class with helpful methods for common file system operations.",
  "since": "1.0.0",
  "author": "Gemini (Documenter)",
  "group": "Core Utilities",
  "category": "File System",
  "tags": ["directory", "file system", "utility", "io"],
  "platforms": ["mobile", "desktop", "server"]
}) */
extension AcDirectoryExtensions on Directory {
  /* AcDoc({
    "type": "method",
    "summary": "Calculates the total size of all files within a directory.",
    "description": "Recursively traverses the directory and sums the sizes of all files contained within it and its subdirectories. The size is returned in bytes. This method does not follow symbolic links.",
    "remarks": [
      "If an error occurs during file system traversal (e.g., a permissions error on a subdirectory), the error and stack trace are printed to `stderr`, and the method returns the total size calculated up to that point. The exception is not re-thrown to the caller."
    ],
    "returns": "A `Future<int>` that completes with the total size of the directory's contents in bytes.",
    "returns_type": "Future<int>",
    "examples": [
      "final myDir = Directory('./documents');",
      "final totalSize = await myDir.calculateSize();",
      "print('Total size: $totalSize bytes');"
    ],
    "tags": ["size", "calculate", "recursive", "directory", "bytes"],
    "is_async": true,
    "is_pure": false,
    "security_notes": "Use with caution on very large directories or system root directories, as the recursive traversal can be resource-intensive and time-consuming."
  }) */
  Future<int> calculateSize() async {
    int totalSize = 0;
    try {
      await for (final entity in list(recursive: true, followLinks: false)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    } catch (e, stackTrace) {
      // Best practice is to also capture the stack trace for better debugging.
      stderr.writeln('Error calculating directory size: $e');
      stderr.writeln('Stack trace: $stackTrace');
    }
    return totalSize;
  }
}