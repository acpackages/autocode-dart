
import 'dart:io';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_mirrors/annotations.dart';
import 'package:autocode/autocode.dart';
import 'package:image/image.dart';

import '../../ac_web.dart';

@AcReflectable()
class AcFilesController {
  late AcLogger logger;
  AcWebConfig acWebConfig = AcWebConfig();

  @AcWebRoute(path: '/upload', method: 'POST')
  Future<AcWebResponse> upload(AcWebRequest request,AcLogger requestLogger) async {
    logger = requestLogger;
    AcWebApiResponse apiResponse = AcWebApiResponse();
    if(request.files.containsKey(acWebConfig.filesControllerConfig.uploadFormKey)){
      AcResult<AcSavedFileDetails> result = await saveFile(webFile: request.files[acWebConfig.filesControllerConfig.uploadFormKey]!);
      apiResponse.setFromResult(result: result,logger: logger);
    }
    else{
      apiResponse.setFailure(message: "${acWebConfig.filesControllerConfig.uploadFormKey} parameter missing",logger: logger);
    }
    return apiResponse.toWebResponse();
  }

  Future<AcResult<AcSavedFileDetails>> generateAllSizeImages({required File file,required AcSavedFileDetails fileDetails})async{
    AcResult<AcSavedFileDetails> result = AcResult();
    logger.log("Generating different size images from original image");
    try{
      var sourceImage = decodeImage(file.readAsBytesSync())!;
      int sourceImageHeight=sourceImage.height;
      int sourceImageWidth=sourceImage.width;
      fileDetails.height = sourceImageHeight;
      fileDetails.width = sourceImageWidth;

      int originalPx=sourceImageHeight;
      if(sourceImageWidth>sourceImageHeight){
        originalPx=sourceImageWidth;
      }
      
      bool continueOperation=true;

      if(continueOperation && originalPx > acWebConfig.filesControllerConfig.imageLgPx){
        AcResult<AcSavedFileDetails> fileSaveResult =await generateResizedImage(original: file,directoryName: "lg",imagePx: acWebConfig.filesControllerConfig.imageLgPx);
        if(fileSaveResult.isSuccess()){
          fileDetails.otherSizes["lg"]=fileSaveResult.value!;
        }
        else{
          continueOperation=false;
          result.setFromResult(result: fileSaveResult,logger: logger);
        }
      }

      if(continueOperation && originalPx > acWebConfig.filesControllerConfig.imageMdPx){
        AcResult<AcSavedFileDetails> fileSaveResult =await generateResizedImage(original: file,directoryName: "md",imagePx: acWebConfig.filesControllerConfig.imageMdPx);
        if(fileSaveResult.isSuccess()){
          fileDetails.otherSizes["md"]=fileSaveResult.value!;
        }
        else{
          continueOperation=false;
          result.setFromResult(result: fileSaveResult,logger: logger);
        }
      }

      if(continueOperation && originalPx > acWebConfig.filesControllerConfig.imageSmPx){
        AcResult<AcSavedFileDetails> fileSaveResult =await generateResizedImage(original: file,directoryName: "sm",imagePx: acWebConfig.filesControllerConfig.imageSmPx);
        if(fileSaveResult.isSuccess()){
          fileDetails.otherSizes["sm"]=fileSaveResult.value!;
        }
        else{
          continueOperation=false;
          result.setFromResult(result: fileSaveResult,logger: logger);
        }
      }

      if(continueOperation && originalPx > acWebConfig.filesControllerConfig.imageXsPx){
        AcResult<AcSavedFileDetails> fileSaveResult =await generateResizedImage(original: file,directoryName: "xs",imagePx: acWebConfig.filesControllerConfig.imageXsPx);
        if(fileSaveResult.isSuccess()){
          fileDetails.otherSizes["xs"]=fileSaveResult.value!;
        }
        else{
          continueOperation=false;
          result.setFromResult(result: fileSaveResult,logger: logger);
        }
      }

      if(continueOperation){
        result.setSuccess(value: fileDetails,logger: logger);
      }
    }catch(ex,stack){
      result.setException(exception: ex,stackTrace: stack,logger: logger);
    }
    return result;
  }

  Future<AcResult<AcSavedFileDetails>> generateResizedImage({required File original,required String directoryName,required int imagePx, bool preserveRatio=true})async{
    AcResult<AcSavedFileDetails> result =AcResult();
    try{
      String destinationPath="${original.parent.path}/$directoryName";
      Directory destinationDirectory=Directory(destinationPath);
      destinationDirectory.create(recursive: false);
      destinationPath+="/${original.fileName}";

      File destinationImageFile=File(destinationPath);
      destinationDirectory.create(recursive: false);
      result=await resizeImage(original:original,resized:destinationImageFile,size: imagePx,preserveRatio: preserveRatio);

    }catch(ex,stack){
      result.setException(exception: ex,stackTrace: stack,logger: logger);
    }
    return result;
  }

  Future<AcResult<AcSavedFileDetails>> saveFile({required AcWebFile webFile})async{
    AcResult<AcSavedFileDetails> result = AcResult();
    try{
      String fileName=webFile.fileName!.replaceAll(RegExp(r'\s+'), '');
      String targetFile=fileName;
      String savePath=acWebConfig.filesControllerConfig.uploadDirectory;
      String fileExtension = File(fileName).extension;
      bool generateAllSizes = acWebConfig.filesControllerConfig.generateDifferentSizeImages;
      if(!["jpg","jpeg","png"].contains(fileExtension) && generateAllSizes){
        generateAllSizes = false;
      }
      String newPath="$savePath/${DateTime.now().millisecondsSinceEpoch}";
      Directory newDirectory=Directory(newPath);
      while(await newDirectory.exists()){
        newPath="$savePath/${DateTime.now().millisecondsSinceEpoch}";
        newDirectory=Directory(newPath);
      }
      await newDirectory.create(recursive: true);
      targetFile="$newPath/$fileName";
      logger.log("Writing file to path : $targetFile");
      AcResult<File> fileResult =await webFile.writeTo(path: targetFile);
      if(fileResult.isSuccess()){
        File savedFile = fileResult.value!;
        AcSavedFileDetails fileDetails = AcSavedFileDetails(
          path:savedFile.path,
          height: 0,
          type: savedFile.extension,
          width: 0,
          size: savedFile.lengthSync()
        );
        if(generateAllSizes){
          result = await generateAllSizeImages(file:savedFile,fileDetails:fileDetails);
        }
        else{
          result.setSuccess(value: fileDetails,logger: logger);
        }
      }
      else{
        result.setFromResult(result: fileResult,logger: logger);
      }
    }catch(ex,stack){
      result.setException(exception: ex,stackTrace: stack,logger: logger);
    }
    return result;
  }

  Future<AcResult<AcSavedFileDetails>> resizeImage({required File original,required File resized,required int size,required bool preserveRatio})async{
    AcResult<AcSavedFileDetails> result = AcResult();
    try {
      var originalImage = decodeImage(original.readAsBytesSync())!;
      String extension = original.extension;
      int originalHeight=originalImage.height;
      int originalWidth=originalImage.width;
      int newHeight=size;
      int newWidth=size;
      double sourceAspectRatio=originalWidth/originalHeight;
      if(sourceAspectRatio<1){
        newWidth=(newWidth*sourceAspectRatio).toInt();
      }
      else{
        newHeight=newHeight~/sourceAspectRatio;
      }
      var resizedImage=copyResize(originalImage,width:newWidth,height:newHeight);
      if(extension.equalsIgnoreCase("png")){
        resized.writeAsBytesSync(encodePng(resizedImage));
      }
      else if(extension.equalsIgnoreCase("jpg")||extension.equalsIgnoreCase("jpeg")){
        resized.writeAsBytesSync(encodeJpg(resizedImage,quality: 50));
      }
      else if(extension.equalsIgnoreCase("bmp")){
        resized.writeAsBytesSync(encodeBmp(resizedImage));
      }
      else if(extension.equalsIgnoreCase("gif")){
        resized.writeAsBytesSync(encodeGif(resizedImage));
      }
      AcSavedFileDetails savedFileDetails = AcSavedFileDetails(height: newHeight,width: newWidth,size: resized.lengthSync(),path: resized.path,type: resized.extension);
      result.setSuccess(value:savedFileDetails,logger: logger);
    } catch (ex,stack) {
      result.setException(exception: ex,stackTrace: stack,logger: logger);
    }
    return result;
  }
}

@AcReflectable()
class AcSavedFileDetails {

  static const String keyHeight = 'height';
  static const String keyPath = 'path';
  static const String keySize = 'size';
  static const String keyType = 'type';
  static const String keyWidth = 'width';
  static const String keyOtherSizes = 'otherSizes';

  @AcBindJsonProperty(key: keyHeight)
  late int height;

  @AcBindJsonProperty(key: keyPath)
  late String path;

  @AcBindJsonProperty(key: keySize)
  late int size;

  @AcBindJsonProperty(key: keyType)
  late String type;

  @AcBindJsonProperty(key: keyWidth)
  late int width;

  @AcBindJsonProperty(key: keyOtherSizes)
  late Map<String,dynamic> otherSizes;

  AcSavedFileDetails({
    this.height = 0,
    this.path = "",
    this.size = 0,
    this.type = "",
    this.width = 0,
    this.otherSizes = const {}
  });

  factory AcSavedFileDetails.instanceFromJson({required Map<String, dynamic> jsonData}) {
    var instance = AcSavedFileDetails();
    return instance.fromJson(jsonData: jsonData);
  }

  AcSavedFileDetails fromJson({Map<String, dynamic> jsonData = const {}}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency with other classes.
    return AcJsonUtils.prettyEncode(toJson());
  }
}