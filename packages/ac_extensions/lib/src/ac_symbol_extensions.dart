import 'dart:core';

extension AcSymbolExtensions on Symbol {

  String getName(){
    return toString().split('\"')[1];
  }

}