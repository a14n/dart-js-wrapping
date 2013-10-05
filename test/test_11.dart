import 'dart:js' as js;

import 'package:js_wrapping/generator.dart';
import 'package:js_wrapping/js_wrapping.dart' as jsw;

@wrapper @skipCast @skipConstructor class Person extends jsw.TypedJsObject {
  @generate set s1(String value) => null;
}