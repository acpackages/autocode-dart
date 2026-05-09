import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:ac_web_socket/ac_web_socket.dart';
import 'package:autocode/autocode.dart';

@AcReflectable()
class AcWebOnWsParams {
  @AcBindJsonProperty(skipInFromJson: true,skipInToJson: true)
  AcWebSocket? socket;

  AcWebOnWsParams({this.socket}){

  }
}