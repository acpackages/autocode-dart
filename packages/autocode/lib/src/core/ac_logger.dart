import 'dart:io';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:autocode/autocode.dart';
import 'package:autocode/src/utils/ac_string_utils.dart';

/* AcDoc({
  "description": "Defines a comprehensive logger that supports multiple log output formats including console, print, HTML, and plain text."
}) */

class AcLogger {
  /* AcDoc({"description": "The logging output type, e.g., console, file, html, etc."}) */
  late AcEnumLogType logType;

  /* AcDoc({"description": "Indicates if logging messages should be printed or written."}) */
  late bool logMessages;

  /* AcDoc({"description": "Optional prefix used in each log entry."}) */
  late String prefix;

  /* AcDoc({"description": "Directory where log files will be stored."}) */
  late String logDirectory;

  /* AcDoc({"description": "The filename for the log output."}) */
  late String logFileName;

  /* AcDoc({"description": "Full path of the log file."}) */
  late String logFilePath;

  /* AcDoc({"description": "The background file object used to write logs."}) */
  late AcBackgroundFile? logFile;

  /* AcDoc({"description": "Flag to track if the log file has been created."}) */
  bool logFileCreated = false;

  bool addTimestampToFileName = true;

  /* AcDoc({"description": "Mapping of message types to their associated color."}) */
  final Map<String, String> messageColors = {
    "default": "Black",
    "debug": "Green",
    "error": "Red",
    "info": "Blue",
    "log": "Black",
    "warn": "Yellow",
    "success": "Green"
  };

  String logFileNameTimestampPrefix = " [ ";
  String logFileNameTimestampSuffix = " ]";

  /* AcDoc({"description": "Initializes the logger with optional configurations."}) */
  AcLogger({
    this.logMessages = true,
    this.prefix = "",
    this.logDirectory = "logs",
    this.logFileName = "",
    this.logType = AcEnumLogType.console,
    this.addTimestampToFileName = true
  }) {
    logFilePath = "$logDirectory/$logFileName";
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      logFile = AcBackgroundFile(logFilePath);
    }
  }

  AcLogger debug(dynamic args) => _loggerMessage(args, "debug");
  AcLogger error(dynamic args) => _loggerMessage(args, "error");
  AcLogger exception(Exception exception) => _loggerMessage([exception.toString()], "error");
  AcLogger info(dynamic args) => _loggerMessage(args, "info");
  AcLogger log(dynamic args) => _loggerMessage(args, "log");
  AcLogger warn(dynamic args) => _loggerMessage(args, "warn");
  AcLogger success(dynamic args) => _loggerMessage(args, "success");

  /* AcDoc({"description": "Closes the log file and writes any final data if needed."}) */
  AcLogger closeLogFile() {
    if (logFileCreated && logFile != null) {
      if (logType == AcEnumLogType.html) {
        logFile!.write("\n\t\t</table>\n\t</body>\n</html>");
      }
      logFile!.close();
    }
    return this;
  }

  /* AcDoc({"description": "Creates a new log file and writes opening headers if HTML type."}) */
  AcLogger createLogFile() {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      String logFileDirectory = File("$logDirectory/$logFileName").parent.path;
      String fileExtension = File(logFileName).extension;
      String fileName = File(logFileName).fileName.replaceAll(".$fileExtension", "");
      String filePath = "$logFileDirectory/$fileName${logFileNameTimestampPrefix}${DateTime.now().toIso8601String().replaceAll(":", "-")}${logFileNameTimestampSuffix}.$fileExtension";

      while(File(filePath).existsSync()){
        filePath = "$logFileDirectory/$fileName${logFileNameTimestampPrefix}[${DateTime.now().toIso8601String().replaceAll(":", "-")}${logFileNameTimestampSuffix}.$fileExtension";
      }
      logFilePath = filePath;
      logFileDirectory = logFileDirectory;
      logFile = AcBackgroundFile(logFilePath);
      if (logType == AcEnumLogType.html) {
        logFile!.write("<html lang=\"eng\">\n\t<body>\n\t\t<table>");
      }
      logFileCreated = true;
    }
    return this;
  }

  /* AcDoc({"description": "Prints multiple blank lines in the log output."}) */
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

  AcLogger _printMessage({required String message, required String type}) {
    _consoleMessage(message: message, type: type);
    return this;
  }

  AcLogger _loggerMessage(dynamic args, String type) {
    if (logMessages) {
      if (args is List) {
        for (var message in args) {
          if (logType != AcEnumLogType.console && logType != AcEnumLogType.print_) {
            _writeToFile(message: message.toString(), type: type);
          } else if (logType == AcEnumLogType.print_) {
            _printMessage(message: message.toString(), type: type);
          } else {
            _consoleMessage(message: message.toString(), type: type);
          }
        }
      } else {
        if (logType != AcEnumLogType.console && logType != AcEnumLogType.print_) {
          _writeToFile(message: args.toString(), type: type);
        } else if (logType == AcEnumLogType.print_) {
          _printMessage(message: args.toString(), type: type);
        } else {
          _consoleMessage(message: args.toString(), type: type);
        }
      }
    }
    return this;
  }

  AcLogger _writeToFile({required String message, required String type}) {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      if (!logFileCreated) {
        createLogFile();
      }
      String timestamp = DateTime.now().toString();
      if (logType == AcEnumLogType.html) {
        _writeHtml(timestamp: timestamp, message: message, type: type);
      } else {
        _writeText(timestamp: timestamp, message: message, type: type);
      }
    } else {
      _consoleMessage(message: message, type: type);
    }
    return this;
  }

  AcLogger _writeHtml({required String timestamp, required String message, required String type}) {
    if (message.isNotEmpty) {
      logFile!.write("\n\t\t\t<tr ac-logger-message logger-message-type=\"$type\"><td logger-message-data=\"timestamp\">$timestamp</td><td logger-message-data=\"message\">$message</td></tr>");
    } else {
      logFile!.write("\n\t\t\t<tr><td colspan=\"1000\">&nbsp;</td></tr>");
    }
    return this;
  }

  AcLogger _writeText({required String timestamp, required String message, required String type}) {
    if (logFile != null) {
      logFile!.write("\n$timestamp => $message");
    }
    return this;
  }
}
