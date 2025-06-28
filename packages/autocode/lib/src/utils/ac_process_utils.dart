import 'dart:io';
import 'package:path/path.dart' as p;
/* AcDoc({
  "description": "Utility class for executing temporary batch (.bat) scripts in a Windows environment. It creates a temporary file, writes the provided batch script to it, runs it, and then cleans up.",
  "methods": {
    "executeBatchCode": "Creates and runs a temporary .bat file from the given script string. Outputs stdout and stderr, and deletes the file after execution."
  },
  "parameters": {
    "batchScript": "The raw batch code to be executed.",
    "executionPath": "Optional path where the temporary .bat file should be created. Defaults to the current working directory."
  },
  "platform": "Windows-only (relies on 'cmd' command and .bat file execution).",
  "safety": "Cleans up the temporary batch file after execution to avoid clutter or security risks."
}) */


class AcProcessUtils {
  static Future<void> executeBatchCode(String batchScript, {String executionPath = ""}) async {
    String timestamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '_');
    String tempFileName = "$timestamp.bat";

    if (executionPath.isNotEmpty) {
      executionPath = p.normalize(executionPath);
    }

    String batchFilePath = p.join(executionPath, tempFileName);
    final batchFile = File(batchFilePath);

    try {
      await batchFile.writeAsString(batchScript);
      final result = await Process.run('cmd', ['/c', batchFilePath]);

      if (result.exitCode == 0) {
        print('Batch script executed successfully');
        print('Output: ${result.stdout}');
      } else {
        print('Batch script failed with exit code ${result.exitCode}');
        print('Error: ${result.stderr}');
      }
    } catch (e) {
      print('Failed to execute batch script: $e');
    } finally {
      if (await batchFile.exists()) {
        await batchFile.delete();
      }
    }
  }
}
