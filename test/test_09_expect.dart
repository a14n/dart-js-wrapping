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
  set f1(String f1) => $unsafe['f1'] = f1;
  String get f1 => $unsafe['f1'];
  set f2(String f2) => $unsafe.callMethod('setF2', [f2]);
  String get f2 => $unsafe.callMethod('getF2');
  set f3(String f3) => $unsafe['f3'] = f3;
  String get f3 => $unsafe['f3'];
  set f4(String f4) => $unsafe['f4'] = f4;
  String get f4 => $unsafe['f4'];
  set f5(Person f5) => $unsafe['f5'] = f5;
  Person get f5 => Person.cast($unsafe['f5']);
  set f6(List<Person> f6) => $unsafe['f6'] = f6 == null ? null : f6 is js.Serializable ? f6 : js.jsify(f6);
  List<Person> get f6 => jsw.TypedJsArray.castListOfSerializables($unsafe['f6'], Person.cast);
  set f7(List<String> f7) => $unsafe['f7'] = f7 == null ? null : f7 is js.Serializable ? f7 : js.jsify(f7);
  List<String> get f7 => jsw.TypedJsArray.cast($unsafe['f7']);
  set f8(List f8) => $unsafe['f8'] = f8 == null ? null : f8 is js.Serializable ? f8 : js.jsify(f8);
  List get f8 => jsw.TypedJsArray.cast($unsafe['f8']);
  set f9Rox(String f9Rox) => $unsafe['f9_rox'] = f9Rox;
  String get f9Rox => $unsafe['f9_rox'];
  set f10(Enum f10) => $unsafe['f10'] = f10;
  Enum get f10 => Enum.find($unsafe['f10']);
}
