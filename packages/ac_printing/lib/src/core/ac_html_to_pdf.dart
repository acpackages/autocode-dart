import 'dart:io';
import 'dart:typed_data';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_printing/ac_printing.dart';
import 'package:autocode/autocode.dart';
import 'package:pdf/pdf.dart';
import 'package:puppeteer/puppeteer.dart';
class AcHtmlToPdf {
  late Browser browser;
  bool available=false;
  bool launching=false;
  AcLogger logger = AcLogger(logMessages: true,logType: AcEnumLogType.text,logDirectory: "logs/html-to-pdf",envConfigTags: ['html-to-pdf']);
  _debug(dynamic message){
    logger.log(message);
  }
  destroy() async {
    available=false;
    await browser.close();
  }
  Future<AcResult> init() async{
    AcResult result = AcResult();
    try {
      print("Initializing puppeteer");
      _debug("Initializing puppeteer...");
      if (!available && !launching) {
        launching = true;
        _debug("Launching puppeteer browser...");
        browser = await puppeteer.launch();
        result.setSuccess();
        String version = await browser.version;
        result.value = {'version:': version};
        _debug("Puppeteer browser launched.");
        available = true;
        launching = false;
      }
      _debug("Puppeteer initialized.");
    }
    catch(ex,stack){
      result.setException(exception: ex,stackTrace: stack,logger: logger);
    }
    return result;
  }

  Future<AcResult> convertHtmlToPdf(String html,{Function? callback,AcPageFormat? pageFormat,String consoleCompletedMessage = ""})async{
    _debug("Generating pdf from html with completed message : $consoleCompletedMessage");
    AcResult result = AcResult();
    try {
      Uint8List? pdfData;
      DateTime startTime = DateTime.now();
      bool completed = false;
      if (consoleCompletedMessage.isEmpty) {
        consoleCompletedMessage = "report_generated";
        html = html.replaceAll("</body>",
            '<script>console.log("report_generated");</script></body>');
      }
      Directory fileDirectory = Directory("logs/puppeteer-html");
      if (!fileDirectory.existsSync()) {
        fileDirectory.createSync(recursive: true);
      }
      String timestamp = DateTime.now().format("YYYY-MM-DD-HH-mm-ss-SSSSSS");
      String filePath = "${fileDirectory.path}/$timestamp.html";
      while (File(filePath).existsSync()) {
        timestamp = DateTime.now().format("YYYY-MM-DD-HH-mm-ss-SSSSSS");
        filePath = "${fileDirectory.path}/$timestamp.html";
      }
      _debug("HTML is written in file $filePath");
      AcBackgroundFile htmlFile = AcBackgroundFile(filePath);
      htmlFile.write(html);
      _debug("Creating browser page...");
      Page page = await browser.newPage();
      _debug("Browser page created.");
      page.onConsole.listen((event) async {
        _debug("Message from Console");
        _debug(event.text);
        if (event.text != null) {
          if ([consoleCompletedMessage].contains(event.text)) {
            _debug("Generating PDF Page");
            await Future.delayed(Duration(microseconds: 500));
            pdfData = await pagePdf(page, callback: callback, pageFormat: pageFormat);
            _debug("Generated PDF Page : ${pdfData == null}");
            completed = true;
          }
        }
      });
      // _debug("Setting Html");
      await page.setContent(html, wait: Until.networkIdle);
      // _debug("Html Set");
      while (!completed) {
        await Future.delayed(Duration(microseconds: 500));
        if (startTime.isBefore(startTime.addTime(seconds: 10))) {
          _debug("Completing because 10 seconds has elapsed");
          completed = true;
        }
      }
      _debug("Closing browser page...");
      await page.close(runBeforeUnload: false);
      _debug("Closed browser page.");
      _debug("Returning PDF Data");
      result.setSuccess(value: pdfData);
    }
    catch(ex,stack){
      result.setException(exception: ex,stackTrace: stack,logger: logger);
    }
    return result;
  }

  Future<Uint8List?> pagePdf(Page page,{Function? callback,AcPageFormat? pageFormat})async{
    PaperFormat paperFormat=PaperFormat.a4;
    if(pageFormat != null){
      if(pageFormat.isPortrait){
        paperFormat = PaperFormat.mm(width: pageFormat.width, height: pageFormat.height);
      }
      else{
        paperFormat = PaperFormat.mm(width: pageFormat.height, height: pageFormat.width);
      }
    }
    print("Paper format => Height : ${paperFormat.height} , Width : ${paperFormat.width}");
    Uint8List? pdfData=await page.pdf(format: paperFormat,printBackground: true);
    if(callback!=null){
      callback(pdfData);
    }
    return pdfData;
  }
}