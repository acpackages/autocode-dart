import 'package:unique_device_identifier/unique_device_identifier.dart';

class AutocodeFlutter{
  static Future<String?> deviceUniqueId() async {
    // return Autocode.uuid();
    return await UniqueDeviceIdentifier.getUniqueIdentifier();
  }
}