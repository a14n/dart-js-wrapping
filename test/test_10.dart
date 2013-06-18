import 'package:js_wrapping/generator.dart';
import 'package:js/js.dart' as js;
import 'package:js/js_wrapping.dart' as jsw;
@wrapper @forMethods abstract class Person extends jsw.TypedProxy {
  String f1;
  set s1(String value);
  Person get g1;
}