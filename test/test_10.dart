import 'dart:js' as js;

import 'package:js_wrapping/generator.dart';
import 'package:js_wrapping/wrapping.dart' as jsw;

@wrapper @forMethods abstract class Person extends jsw.TypedJsObject {
  String f1;
  set s1(String value);
  Person get g1;
}