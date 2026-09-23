import Flutter
import UIKit

public class AcPrintingPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "plugins.autocode.run/ac_printing", binaryMessenger: registrar.messenger())
    let instance = AcPrintingPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPrinters":
      var printers: [[String: Any]] = []
      let defaultPrinter: [String: Any] = [
        "name": "AirPrint",
        "url": "airprint://",
        "location": "",
        "comment": "Apple AirPrint Spooler",
        "isDefault": true,
        "isAvailable": true
      ]
      printers.append(defaultPrinter)
      result(printers)

    case "printPdf":
      guard let args = call.arguments as? [String: Any],
            let typedData = args["bytes"] as? FlutterStandardTypedData else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Bytes must not be null", details: nil))
        return
      }

      let data = typedData.data
      let jobName = (args["jobName"] as? String) ?? "Document"
      let printerUrl = args["printerUrl"] as? String

      let isPortrait = (args["isPortrait"] as? Bool) ?? true
      let duplex = (args["duplex"] as? Bool) ?? false

      let printController = UIPrintInteractionController.shared
      let printInfo = UIPrintInfo(dictionary: nil)
      printInfo.outputType = .general
      printInfo.jobName = jobName
      printInfo.orientation = isPortrait ? .portrait : .landscape
      printInfo.duplex = duplex ? .longEdge : .none
      printController.printInfo = printInfo
      printController.printingItem = data

      if let printerUrl = printerUrl, let url = URL(string: printerUrl), let printer = UIPrinter(url: url) {
        printController.print(to: printer) { controller, completed, error in
          if let error = error {
            result(FlutterError(code: "PRINT_ERROR", message: error.localizedDescription, details: nil))
          } else {
            result(completed)
          }
        }
      } else {
        DispatchQueue.main.async {
          printController.present(animated: true) { controller, completed, error in
            if let error = error {
              result(FlutterError(code: "PRINT_ERROR", message: error.localizedDescription, details: nil))
            } else {
              result(completed)
            }
          }
        }
      }

    case "sharePdf":
      guard let args = call.arguments as? [String: Any],
            let typedData = args["bytes"] as? FlutterStandardTypedData else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Bytes must not be null", details: nil))
        return
      }

      let data = typedData.data
      let activityViewController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
      
      DispatchQueue.main.async {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
          if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = rootViewController.view
            popover.sourceRect = CGRect(x: rootViewController.view.bounds.midX, y: rootViewController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
          }
          rootViewController.present(activityViewController, animated: true) {
            result(true)
          }
        } else {
          result(false)
        }
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
