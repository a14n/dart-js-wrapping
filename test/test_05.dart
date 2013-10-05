import 'dart:js' as js;

import 'package:js_wrapping/generator.dart';
import 'package:js_wrapping/js_wrapping.dart' as jsw;

@wrapper abstract class Person extends jsw.TypedJsObject {
  static Person cast(js.JsObject jsObject) => null;
}
