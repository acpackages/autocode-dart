import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
extension AcProcessExtensions on Process{
  void executeBatchCode(String batchScript,{String executionPath =""}) async {

    String tempFilePath = "${DateTime.now().toIso8601String()}.bat";
    while(File(tempFilePath).existsSync()){
      tempFilePath = "${DateTime.now().toIso8601String()}.bat";
    }
    if(executionPath.isNotEmpty){
      if(!executionPath.endsWith("/") && !executionPath.endsWith("\\")){
        String endChar = "/";
        if(executionPath.contains("\\")){
          endChar = "\\";
        }
        executionPath+=endChar;
      }
    }
    String batchFilePath = executionPath+tempFilePath;
    var batchFile = File(batchFilePath);
    await batchFile.writeAsString(batchScript);
    var result = await Process.run('cmd', ['/c', batchFilePath]);
    if (result.exitCode == 0) {
      print('Batch script executed successfully');
      print('Output: ${result.stdout}');
    } else {
      print('Batch script failed with exit code ${result.exitCode}');
      print('Error: ${result.stderr}');
    }
    await batchFile.delete();
  }
}