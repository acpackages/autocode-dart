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

  AcLogger _consoleMessage(String message, String type) {
    String label = prefix.isNotEmpty ? "$prefix : " : "";
    print("$label$message");
    return this;
  }

  AcLogger _printMessage(String message, String type) {
    String color = messageColors[type] ?? "Black";
    String label = prefix.isNotEmpty ? "$prefix : " : "";
    print('<p style="color:$color;">$label$message</p>');
    return this;
  }

  AcLogger _loggerMessage(dynamic args, String type) {
    if (logMessages) {
      if (args is List) {
        for (var message in args) {
          if (logType != AcEnumLogType.CONSOLE && logType != AcEnumLogType.PRINT) {
            _writeToFile(message.toString(), type);
          } else if (logType == AcEnumLogType.PRINT) {
            _printMessage(message.toString(), type);
          } else {
            _consoleMessage(message.toString(), type);
          }
        }
      }
      else{
        if (logType != AcEnumLogType.CONSOLE && logType != AcEnumLogType.PRINT) {
          _writeToFile(args.toString(), type);
        } else if (logType == AcEnumLogType.PRINT) {
          _printMessage(args.toString(), type);
        } else {
          _consoleMessage(args.toString(), type);
        }
      }
    }
    return this;
  }

  AcLogger _writeToFile(String message, String type) {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      if (!logFileCreated) {
        createLogFile();
      }
      String timestamp = DateTime.now().toString();
      if (logType == AcEnumLogType.HTML) {
        _writeHtml(timestamp, message, type);
      } else {
        _writeText(timestamp, message, type);
      }
    } else {
      _consoleMessage(message, type);
    }
    return this;
  }

  AcLogger _writeHtml(String timestamp, String message, String type) {
    if (logFile != null) {
      logFile!.writeAsString("\n\t<tr><td>$timestamp</td><td>$message</td></tr>");
    }
    return this;
  }

  AcLogger _writeText(String timestamp, String message, String type) {
    if (logFile != null) {
      logFile!.writeAsString("\n$timestamp => $message");
    }
    return this;
  }
}
