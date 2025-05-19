import 'dart:async';
import 'dart:io';
import 'dart:isolate';

class AcBackgroundFile {
  final String filePath;
  final List<String> _buffer = [];
  late final SendPort _sendPort;
  late Isolate _isolate;
  final bool _isWriting = false;
  bool _fileWritingStarted = false;
  bool _startingThread = false;
  bool _isClosed = false;

  AcBackgroundFile(this.filePath);

  log(dynamic message){
    // Simplify.debug(message);
  }

  Future<void> _startIsolate() async {
    ReceivePort receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_writeToFile, receivePort.sendPort);
    _sendPort = await receivePort.first;
    while(_buffer.isNotEmpty){
      String content = _buffer.removeAt(0);
      _sendPort.send([filePath, content,false]);
    }
    _fileWritingStarted = true;
  }

  Future<void> _writeToFile(SendPort sendPort) async {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    await for (var message in receivePort) {
      if (message is List) {
        String filePath = message[0];
        String content = message[1];
        bool close = message[2];
        File file = File(filePath);
        if (content.isNotEmpty) {
          await file.writeAsString(content, mode: FileMode.append);
        }
        log("Writing content :$content");
        if(close){
          log("Closing");
          receivePort.close();
          Isolate.exit();
        }
      }
    }
  }

  writeAsString(String content){
    log("Content : $content");
    log("Added content to buffer.New BufferSize : ${_buffer.length}");
    if (!_fileWritingStarted) {
      if(!_startingThread){
        _startingThread = true;
        _startIsolate();
      }
      _buffer.add(content);
    }
    else{
      log("Calling Process Queue in writeAsString > Else");
      _sendPort.send([filePath, content,false]);
      // _processWriteQueue();
    }
  }

  void closeNew() {
    _isClosed = true;
    log("Close called. IsWriting: $_isWriting, Buffer.isEmpty: ${_buffer.isEmpty}");
    _sendPort.send([filePath, "",true]);
    if (!_isWriting) {
      // _processWriteQueue();
    }
  }


  close(){
    _isClosed = true;
    if (!_isWriting) {
      log("Calling Process Queue in Close Function");
    }
  }
}
