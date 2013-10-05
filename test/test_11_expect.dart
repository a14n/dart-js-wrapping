import 'dart:js' as js;

import 'package:js_wrapping/generator.dart';
import 'package:js_wrapping/js_wrapping.dart' as jsw;

class Person extends jsw.TypedJsObject {
  set s1(String value) => $unsafe['s1'] = value;
}
