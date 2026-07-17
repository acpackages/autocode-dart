import 'dart:convert';
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
  String? executablePath;
  AcLogger logger = AcLogger(logMessages: true,logType: AcEnumLogType.text,logDirectory: "logs/html-to-pdf",envConfigTags: const["logs",'html-to-pdf']);
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
      _debug("Initializing puppeteer...");
      if (!available && !launching) {
        launching = true;
        _debug("Launching puppeteer browser...");
        browser = await puppeteer.launch(
          executablePath: executablePath,
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
      await page.emulateMediaType(MediaType.print);
      if(viewportHeight > 0 && viewportWidth > 0 ){
        // viewportHeight = 1080;
        // viewportWidth = 1920;
        // await page.setViewport(DeviceViewport(height: viewportHeight, width: viewportWidth,deviceScaleFactor:deviceScaleFactor,isLandscape: true ));
        // await page.reload();
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
            dpr: window.devicePixelRatio,
            innerWidth: window.innerWidth,
            innerHeight: window.innerHeight,
            pageWidth: getComputedStyle(el).width,
            pageHeight: getComputedStyle(el).height,
            font: getComputedStyle(document.body).fontFamily,
            media: matchMedia('print').matches ? 'print' : 'screen',
            widthPx: rect.width,
            heightPx: rect.height,
            widthIn: rect.width / 96,
            heightIn: rect.height / 96
          };
        }
        '''));
        print("Page Size : "+jsonEncode(size));
        result = await pagePdf(page, callback: callback, heightIN: size.getDouble('heightIn'), widthIN: size.getDouble('widthIn'));
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

  Future<AcResult> pagePdf(Page page,{Function? callback,AcPageFormat? pageFormat,int heightPX = 0,int widthPX = 0, double heightMM = 0,double widthMM = 0, double heightIN = 0,double widthIN = 0})async{
    AcResult result = AcResult();
    PaperFormat paperFormat=PaperFormat.a4;
    if(heightPX > 0 && widthPX > 0){
      paperFormat = PaperFormat.px(width: widthPX, height: heightPX);
    }
    else if(heightIN > 0 && widthIN > 0){
      paperFormat = PaperFormat.inches(width: widthIN, height: heightIN);
    }
    else if(heightMM > 0 && widthMM > 0){
      paperFormat = PaperFormat.mm(width: widthMM, height: heightMM);
    }
    else if(pageFormat != null){
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
    Uint8List? pdfData=await page.pdf(
        format: paperFormat,
        printBackground: true,
        preferCssPageSize: true,
      margins: PdfMargins.px(top: 0,left: 0,bottom: 0,right: 0)
    );
    if(callback!=null){
      callback(pdfData);
    }
    result.setSuccess(value: {'pdfData':pdfData,'pageFormat':AcPageFormat.instanceFromPaperFormat(format: paperFormat)});
    return result;
  }
}