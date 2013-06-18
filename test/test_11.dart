import 'package:js_wrapping/generator.dart';
import 'package:js/js.dart' as js;
import 'package:js/js_wrapping.dart' as jsw;
@wrapper @skipCast @skipConstructor class Person extends jsw.TypedProxy {
  @generate set s1(String value) => null;
}