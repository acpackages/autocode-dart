import 'dart:core';
import 'dart:io';
extension AcFileSystemEntityExtensions on FileSystemEntity {

  String getExtension(){
    return path.split(".").last;
  }

  String getName(){
    String result= path.split('/').last;
    result= result.split('\\').last;
    return result;
  }

}