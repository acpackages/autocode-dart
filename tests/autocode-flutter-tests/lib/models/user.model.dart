import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
class User {
  @AcBindJsonProperty(key: 'uid')
  final int id;

  final String name;

  const User({required this.id, required this.name});
}