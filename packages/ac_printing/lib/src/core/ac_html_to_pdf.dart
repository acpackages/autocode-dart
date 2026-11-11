import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:autocode/autocode.dart';
import 'package:puppeteer/puppeteer.dart';
import '../../ac_printing.dart';

class AcHtmlToPdf {
  Browser? _browser;
  Browser get browser => _browser!;
  set browser(Browser value) {
    _browser = value;
    available = value.isConnected;
  }

  bool available = false;
  Future<AcResult>? _launchingFuture;
  bool get launching => _launchingFuture != null;
  String? executablePath;
  Timer? _idleTimer;
  Duration idleTimeout = const Duration(minutes: 30);

  AcLogger logger = AcLogger(
    logMessages: true,
    logType: AcEnumLogType.text,
    logDirectory: "logs/html-to-pdf",
    envConfigTags: const ["logs", 'html-to-pdf'],
  );

  _debug(dynamic message) {
    logger.log(message);
  }

  bool get isBrowserHealthy {
    try {
      return _browser != null && available && _browser!.isConnected;
    } catch (_) {
      return false;
    }
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    if (idleTimeout.inSeconds > 0) {
      _idleTimer = Timer(idleTimeout, () {
        if (available) {
          _debug("Auto-closing idle Puppeteer browser after inactivity...");
          destroy();
        }
      });
    }
  }

  Future<void> destroy() async {
    _idleTimer?.cancel();
    _idleTimer = null;
    available = false;
    try {
      if (_browser != null) {
        await _browser!.close();
      }
    } catch (_) {}
    _browser = null;
  }

  Future<AcResult> init() async {
    if (isBrowserHealthy) {
      final res = AcResult();
      res.setSuccess();
      return res;
    }

    if (_launchingFuture != null) {
      return await _launchingFuture!;
    }

    final completer = Completer<AcResult>();
    _launchingFuture = completer.future;

    final result = AcResult();
    try {
      _debug("Initializing puppeteer...");
      try {
        if (_browser != null) {
          try {
            await _browser!.close();
          } catch (_) {}
          _browser = null;
        }
      } catch (_) {}

      _debug("Launching puppeteer browser...");
      final launchedBrowser = await puppeteer.launch(
        executablePath: executablePath,
        args: [
          "--disable-font-subpixel-positioning",
          "--disable-lcd-text",
          "--enable-gpu",
          "--no-sandbox",
          "--disable-setuid-sandbox",
        ],
      );
      _browser = launchedBrowser;
      available = true;
      result.setSuccess();
      try {
        String version = await launchedBrowser.version;
        result.value = {'version:': version};
        _debug("Puppeteer browser launched ($version).");
      } catch (_) {}
      _resetIdleTimer();
      _debug("Puppeteer initialized.");
      completer.complete(result);
    } catch (ex, stack) {
      available = false;
      _browser = null;
      result.setException(exception: ex, stackTrace: stack, logger: logger);
      completer.complete(result);
    } finally {
      _launchingFuture = null;
    }
    return result;
  }

  Future<void> _ensureBrowser() async {
    if (!isBrowserHealthy) {
      available = false;
      await init();
    }
  }

  Future<AcResult> convertHtmlToPdf(
    String html, {
    Function? callback,
    AcPageFormat? pageFormat,
    String consoleCompletedMessage = "",
    int viewportHeight = 0,
    int viewportWidth = 0,
    int heightPX = 0,
    int widthPX = 0,
    double deviceScaleFactor = 1.0,
    String? pageSizeQuerySelector,
    bool saveHtmlDebugLog = false,
  }) async {
    _debug("Generating pdf from html");
    _resetIdleTimer();
    AcResult result = AcResult();
    try {
      if (saveHtmlDebugLog) {
        try {
          Directory fileDirectory = Directory("logs/puppeteer-html");
          if (!fileDirectory.existsSync()) {
            fileDirectory.createSync(recursive: true);
          }
          String timestamp = DateTime.now().format("YYYY-MM-DD-HH-mm-ss-SSSSSS");
          String filePath = "${fileDirectory.path}/$timestamp.html";
          AcBackgroundFile htmlFile = AcBackgroundFile(filePath);
          htmlFile.write(html);
          _debug("HTML written to debug file $filePath");
        } catch (_) {}
      }

      await _ensureBrowser();

      _debug("Creating browser page...");
      Page page;
      try {
        page = await browser.newPage();
      } catch (ex) {
        _debug("Failed to create page on current browser instance ($ex). Re-initializing Puppeteer...");
        await destroy();
        await init();
        page = await browser.newPage();
      }
      try {
        await page.emulateMediaType(MediaType.print);
        _debug("Browser page created.");

        await page.setContent(
          html,
          wait: Until.domContentLoaded,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            _debug("page.setContent timed out, continuing with current DOM state");
          },
        );

        if (pageSizeQuerySelector != null) {
          final size = Map.from(await page.evaluate('''
          function() {
            const el = document.querySelector('$pageSizeQuerySelector');
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
          result = await pagePdf(
            page,
            callback: callback,
            heightIN: size.getDouble('heightIn'),
            widthIN: size.getDouble('widthIn'),
          );
        } else {
          result = await pagePdf(page, callback: callback, pageFormat: pageFormat);
        }
      } finally {
        _debug("Closing browser page...");
        try {
          await page.close(runBeforeUnload: false);
        } catch (_) {}
        _debug("Closed browser page.");
      }
      _debug("Returning PDF Data");
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack, logger: logger);
    }
    return result;
  }

  Future<AcResult> pagePdf(
    Page page, {
    Function? callback,
    AcPageFormat? pageFormat,
    int heightPX = 0,
    int widthPX = 0,
    double heightMM = 0,
    double widthMM = 0,
    double heightIN = 0,
    double widthIN = 0,
  }) async {
    AcResult result = AcResult();
    PaperFormat paperFormat = PaperFormat.a4;
    if (heightPX > 0 && widthPX > 0) {
      paperFormat = PaperFormat.px(width: widthPX, height: heightPX);
    } else if (heightIN > 0 && widthIN > 0) {
      paperFormat = PaperFormat.inches(width: widthIN, height: heightIN);
    } else if (heightMM > 0 && widthMM > 0) {
      paperFormat = PaperFormat.mm(width: widthMM, height: heightMM);
    } else if (pageFormat != null) {
      paperFormat = pageFormat.toPaperFormat();
    }

    Uint8List? pdfData = await page.pdf(
      format: paperFormat,
      printBackground: true,
      preferCssPageSize: true,
      margins: PdfMargins.px(top: 0, left: 0, bottom: 0, right: 0),
    );

    if (callback != null) {
      callback(pdfData);
    }
    result.setSuccess(value: {
      'pdfData': pdfData,
      'pageFormat': AcPageFormat.instanceFromPaperFormat(format: paperFormat)
    });
    return result;
  }
}
