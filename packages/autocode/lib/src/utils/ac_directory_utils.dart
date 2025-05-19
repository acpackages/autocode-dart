import 'dart:io';

class AcDirectoryUtils{
  static checkAndCreateDirectory(String path) async {
    final directory = Directory(path);
    directory.exists().then((isThere) {
      if (!isThere) {
        directory.create(recursive: true);
      }
    });
  }

  static void copyDirectory({required String sourcePath,required String destinationPath}) {
    Directory source = Directory(sourcePath);
    Directory destination = Directory(destinationPath);
    if (!destination.existsSync()) {
      destination.createSync(recursive: true);
    }
    List<FileSystemEntity> files =  source.listSync(recursive: true);
    for (var entity in files) {
      if (entity is File) {
        File newFile = File('${destination.path}/${entity.uri.pathSegments.last}');
        newFile.writeAsBytesSync(File(entity.path).readAsBytesSync());
      } else if (entity is Directory) {
        copyDirectory(sourcePath:entity.path,destinationPath: '${destination.path}/${entity.uri.pathSegments.last}');
      }
    }
  }
}