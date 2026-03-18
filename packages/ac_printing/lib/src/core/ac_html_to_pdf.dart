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
        browser = await puppeteer.launch(
            args: [
          "--disable-font-subpixel-positioning",
          "--disable-lcd-text","--enable-gpu"
        ]);
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

  Future<AcResult> convertHtmlToPdf(String html,{
    Function? callback,
    AcPageFormat? pageFormat,
    String consoleCompletedMessage = "",
    int viewportHeight = 0,
    int viewportWidth = 0,
    int heightPX = 0,
    int widthPX = 0,
    double deviceScaleFactor = 1.0,
    String? pageSizeQuerySelector
  })async{
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
      if(viewportHeight > 0 && viewportWidth > 0){
        viewportHeight = 1440;
        viewportWidth = 2560;
        print("Setting viewport height: ${viewportHeight} & width:${viewportWidth} & ratio : ${deviceScaleFactor}");
        await page.setViewport(DeviceViewport(height: viewportHeight, width: viewportWidth,deviceScaleFactor:deviceScaleFactor,isLandscape: true ));
        await page.reload();
      }
      _debug("Browser page created.");
      await page.setContent(html, wait: Until.all([
        Until.domContentLoaded,
        Until.load,
        Until.networkAlmostIdle,
        Until.networkIdle
      ]));
      AcResult pdfResult = AcResult();
      if(pageSizeQuerySelector != null){
        final size = Map.from(await page.evaluate('''
        function() {
          const el = document.querySelector('${pageSizeQuerySelector}');
          if (!el) return null;
        
          const rect = el.getBoundingClientRect();
        
          return {
            width: rect.width,
            height: rect.height
          };
        }
        '''));
        result = await pagePdf(page, callback: callback, heightPX: size['height'], widthPX: size['width']);
        completed = true;
      }
      else{
        result = await pagePdf(page, callback: callback, pageFormat: pageFormat);
        completed = true;
      }
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
    }
    catch(ex,stack){
      result.setException(exception: ex,stackTrace: stack,logger: logger);
    }
    return result;
  }

  Future<AcResult> pagePdf(Page page,{Function? callback,AcPageFormat? pageFormat,int heightPX = 0,int widthPX = 0})async{
    AcResult result = AcResult();
    PaperFormat paperFormat=PaperFormat.a4;
    if(heightPX > 0 && widthPX > 0){
      print("Setting paper format from px height : ${heightPX} & width : ${widthPX}");
      paperFormat = PaperFormat.px(width: widthPX, height: heightPX);
    }
    else if(pageFormat != null){
      print("Setting paper format from page format");
      paperFormat = pageFormat.toPaperFormat();
      // print(pageFormat.toJson());
      // if(pageFormat.isPortrait){
      //   paperFormat = PaperFormat.mm(width: pageFormat.width, height: pageFormat.height);
      // }
      // else{
      //   paperFormat = PaperFormat.mm(width: pageFormat.height, height: pageFormat.width);
      // }
    }
    // else
    print("Paper format => Height : ${paperFormat.height} , Width : ${paperFormat.width}");
    Uint8List? pdfData=await page.pdf(
        format: paperFormat,
        printBackground: true,
        preferCssPageSize: true
    );
    if(callback!=null){
      callback(pdfData);
    }
    result.setSuccess(value: {'pdfData':pdfData,'pageFormat':AcPageFormat.instanceFromPaperFormat(format: paperFormat)});
    return result;
  }
}