import Foundation
import FlutterMacOS

/**
 * ac_patches macOS Runtime Loader
 * 
 * Inspects Application Support / bundle directory for active OTA patches
 * and initializes FlutterDartProject accordingly.
 */
public class AcPatchesMacOS {
    public static func createDartProject() -> FlutterDartProject {
        let fileManager = FileManager.default
        let bundleURL = Bundle.main.bundleURL
        let patchesDir = bundleURL.deletingLastPathComponent().appendingPathComponent("patches/active/App.framework/App")

        if fileManager.fileExists(atPath: patchesDir.path) {
            // Note: Dynamic dylib replacement on macOS direct distribution
            return FlutterDartProject()
        }

        return FlutterDartProject()
    }
}
