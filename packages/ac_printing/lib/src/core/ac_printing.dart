import 'dart:typed_data';
import 'package:autocode/autocode.dart';
import 'package:printing/printing.dart';
import '../../ac_printing.dart';

class AcPrinting {
  AcPrinter? _activePrinter;

  Future<AcResult> getPrinters() async {
    AcResult result = AcResult();
    try{
      List<AcPrinter> printers = List.empty(growable: true);
      for(var printer in await Printing.listPrinters()){
        var acPrinter = AcPrinter();
        acPrinter.name = printer.name;
        acPrinter.url = printer.url;
        acPrinter.location = printer.location ?? '';
        acPrinter.comment = printer.comment ?? '';
        acPrinter.isDefault = printer.isDefault;
        acPrinter.isAvailable = printer.isAvailable;
        printers.add(acPrinter);
      }
      result.setSuccess(value: printers);
    }
    catch(ex,stack){
      result.setException(exception: ex,stackTrace: stack);
    }
    return result;
  }

  /// Shares a PDF document (opens the system share dialog, which can lead to printing).
  ///
  /// [bytes]: The PDF document as Uint8List.
  /// [name]: Optional filename for the shared PDF (defaults to 'document.pdf').
  Future<bool> sharePdf({
    required Uint8List bytes,
    String name = 'document.pdf',
  }) async {
    return await Printing.sharePdf(bytes: bytes, filename: name);
  }

  /// Convenience method to directly print a pre-loaded PDF to a specific printer.
  ///
  /// [printer]: The target printer as an AcPrinter model.
  /// [pdfBytes]: The complete PDF as Uint8List.
  /// [name]: Optional name.
  Future<AcResult> printPdf({
    required Uint8List pdfBytes,
    AcPrinter? printer,
    String? printerName,
    AcPageFormat? pageFormat,
  }) async {
    AcResult result = AcResult();
    var printers = await Printing.listPrinters();
    Printer? printerToUse;
    for(var p in printers){
      if(printerName!=null){
        if(p.name == printerName){
          printerToUse = p;
          break;
        }
      }
      else if(printer!=null){
        if(p.name == printer.name){
          printerToUse = p;
          break;
        }
      }
      else if(_activePrinter!=null){
        if(p.name == _activePrinter!.name){
          printerToUse = p;
          break;
        }
      }
      else if(p.isDefault){
        printerToUse = p;
        break;
      }
    }
    if(printerToUse!=null){
      if(printerToUse.isAvailable){
        var success = await Printing.directPrintPdf(printer: printerToUse, onLayout: (_)=>pdfBytes);
        if(success){
          result.setSuccess();
        }
        else{
          result.setFailure(message: 'could not print');
        }
      }
      else{
        result.setFailure(message: 'printer not available');
      }
    }
    else{
      result.setFailure(message: 'printer not found');
    }

    return result;
  }
}