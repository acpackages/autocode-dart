import 'package:ac_blueprints/ac_blueprints.dart';

class FileRenameTest{
  run() async {
    String sourceDirectory = "F:/Packages/AutoCode/Github/autocode-typescript/packages/browser/ac-data-grid/src/lib";
    await getClassListInDirectory(sourceDirectory);
  }

  getClassListInDirectory(String directoryPath) async{
    var codeParser = AcCodeParser();
    await codeParser.parseDirectoryFiles(directoryPath: directoryPath,recursive: true);
    print("\n\n<<< Classes >>>\n\n");
    for(var entity in codeParser.classes){
      print("${entity.name} >>> ${entity.filePath} >>> Line ${entity.lineNumber}");
    }
    print("\n\n<<< Interfaces >>>\n\n");
    for(var entity in codeParser.interfaces){
      print("${entity.name} >>> ${entity.filePath} >>> Line ${entity.lineNumber}");
    }
    // var acParser = AcParser();
    // await acParser.getClassListInDirectory(directoryPath: directoryPath);
  }

  renameFiles(){
    AcCliDirectoryUtils.renameFilesAndDirectoriesCasesInDirectory(directoryPath: "F:/Packages/AutoCode/Github/autocode-typescript/packages/browser/ac-data-grid/src/lib", updateCase: "");
  }
}