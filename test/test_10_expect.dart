import 'dart:js' as js;

import 'package:js_wrapping/generator.dart';
import 'package:js_wrapping/wrapping.dart' as jsw;

class Person extends jsw.TypedJsObject {
  static Person cast(js.JsObject jsObject) => jsObject == null ? null : new Person.fromJsObject(jsObject);
  Person.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);
  set f1(String f1) => $unsafe.callMethod('setF1', [f1]);
  String get f1 => $unsafe.callMethod('getF1');
  set s1(String value) => $unsafe.callMethod('setS1', [value]);
  Person get g1 => Person.cast($unsafe.callMethod('getG1'));
}
