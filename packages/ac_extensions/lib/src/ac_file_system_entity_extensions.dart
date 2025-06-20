import 'dart:core';
import 'dart:io';
extension AcFileSystemEntityExtensions on FileSystemEntity {

  String getExtension(){
    return path.split(".").last;
  }

  String getName({bool includeExtension = true}){
    String result= path.split('/').last;
    result= result.split('\\').last;
    if(!includeExtension){
      if(result.contains(".")){
        result = result.substring(0,result.lastIndexOf("."));
      }
    }
    return result;
  }

  bool get isDirectory {
    return Directory(path).existsSync();
  }

  bool get isFile {
    return File(path).existsSync();
  }

}