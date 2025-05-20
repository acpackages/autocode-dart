import 'dart:io';
import 'package:autocode/autocode.dart';

class AcLogger {
  late String logType;
  late bool logMessages;
  late String prefix;
  late String logDirectory;
  late String logFileName;
  late String logFilePath;
  late AcBackgroundFile? logFile;
  bool logFileCreated = false;

  final Map<String, String> messageColors = {
    "default": "Black",
    "debug": "Green",
    "error": "Red",
    "info": "Blue",
    "log": "Black",
    "warn": "Yellow",
    "success": "Green"
  };

  AcLogger({
    this.logMessages = true,
    this.prefix = "",
    this.logDirectory = "logs",
    this.logFileName = "",
    this.logType = AcEnumLogType.CONSOLE,
  }) {
    logFilePath = "$logDirectory/$logFileName";
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      logFile = AcBackgroundFile(logFilePath);
    }
  }

  AcLogger debug(dynamic args) {
    _loggerMessage(args, "debug");
    return this;
  }

  AcLogger error(dynamic args) {
    _loggerMessage(args, "error");
    return this;
  }

  AcLogger exception(Exception exception) {
    _loggerMessage([exception.toString()], "error");
    return this;
  }

  AcLogger info(dynamic args) {
    _loggerMessage(args, "info");
    return this;
  }

  AcLogger log(dynamic args) {
    _loggerMessage(args, "log");
    return this;
  }

  AcLogger warn(dynamic args) {
    _loggerMessage(args, "warn");
    return this;
  }

  AcLogger success(dynamic args) {
    _loggerMessage(args, "success");
    return this;
  }

  AcLogger closeLogFile() {
    if (logFileCreated && logFile != null) {
      if (logType == AcEnumLogType.HTML) {
        logFile!.writeAsString("\n\t\t</table>\n\t</body>\n</html>");
      }
      logFile!.close();
    }
    return this;
  }

  AcLogger createLogFile() {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      logFile = AcBackgroundFile(logFilePath);
      if (logType == AcEnumLogType.HTML) {
        logFile!.writeAsString("<html lang=\"eng\">\n\t<body>\n\t\t<table>");
      }
      logFileCreated = true;
    }
    return this;
  }

  AcLogger newLines({int count = 1}) {
    for (var i = 0; i < count; i++) {
      log([""]);
    }
    return this;
  }

  AcLogger _consoleMessage({required String message, required String type}) {
    String label = prefix.isNotEmpty ? "$prefix : " : "";
    print("$label$message");
    return this;
  }

  AcLogger _printMessage({required String message,required  String type}) {
    _consoleMessage(message: message,type: type);
    return this;
  }

  AcLogger _loggerMessage(dynamic args, String type) {
    if (logMessages) {
      if (args is List) {
        for (var message in args) {
          if (logType != AcEnumLogType.CONSOLE && logType != AcEnumLogType.PRINT) {
            _writeToFile(message: message.toString(), type:type);
          } else if (logType == AcEnumLogType.PRINT) {
            _printMessage(message: message.toString(), type:type);
          } else {
            _consoleMessage(message:message.toString(), type:type);
          }
        }
      }
      else{
        if (logType != AcEnumLogType.CONSOLE && logType != AcEnumLogType.PRINT) {
          _writeToFile(message: args.toString(), type:type);
        } else if (logType == AcEnumLogType.PRINT) {
          _printMessage(message: args.toString(), type:type);
        } else {
          _consoleMessage(message: args.toString(), type:type);
        }
      }
    }
    return this;
  }

  AcLogger _writeToFile({required String message,required String type}) {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      if (!logFileCreated) {
        createLogFile();
      }
      String timestamp = DateTime.now().toString();
      if (logType == AcEnumLogType.HTML) {
        _writeHtml(timestamp:timestamp, message:message, type:type);
      } else {
        _writeText(timestamp:timestamp, message:message, type:type);
      }
    } else {
      _consoleMessage(message: message,type: type);
    }
    return this;
  }

  AcLogger _writeHtml({required String timestamp, required String message, required String type}) {
    if(message.isNotEmpty){
      logFile!.writeAsString("\n\t\t\t<tr ac-logger-message logger-message-type=\"$type\"><td logger-message-data=\"timestamp\">$timestamp</td><td logger-message-data=\"message\">$message</td></tr>");
    }
    else{
      logFile!.writeAsString("\n\t\t\t<tr><td colspan=\"1000\">&nbsp;</td></tr>");
    }
    return this;
  }

  AcLogger _writeText({required String timestamp, required String message, required String type}) {
    if (logFile != null) {
      logFile!.writeAsString("\n$timestamp => $message");
    }
    return this;
  }
}
