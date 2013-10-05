import 'dart:js' as js;

import 'package:js_wrapping/generator.dart';
import 'package:js_wrapping/js_wrapping.dart' as jsw;

class Enum extends jsw.IsEnum<int> {
  static final E1 = new Enum._(1);

  static final _FINDER = new jsw.EnumFinder<int, Enum>([E1]);

  static Enum find(Object o) => _FINDER.find(o);

  Enum._(int value) : super(value);
}

class Person extends jsw.TypedJsObject {
  static Person cast(js.JsObject jsObject) => jsObject == null ? null : new Person.fromJsObject(jsObject);
  Person.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);
  set f1(String f1) => $unsafe.callMethod('setF1', [f1]);
  String get f1 => $unsafe.callMethod('getF1');
  set s1(String value) => $unsafe.callMethod('setS1', [value]);
  Person get g1 => Person.cast($unsafe.callMethod('getG1'));
  Enum get g2 => Enum.find($unsafe.callMethod('getG2'));
}
