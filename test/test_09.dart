import 'dart:js' as js;

import 'package:js_wrapping/generator.dart';
import 'package:js_wrapping/js_wrapping.dart' as jsw;

class Enum extends jsw.IsEnum<int> {
  static final E1 = new Enum._(1);

  static final _FINDER = new jsw.EnumFinder<int, Enum>([E1]);

  static Enum find(Object o) => _FINDER.find(o);

  Enum._(int value) : super(value);
}

@wrapper class Person extends jsw.TypedJsObject {
  String f1;
  @forMethods String f2;
  String f3, f4;
  Person f5;
  List<Person> f6;
  List<String> f7;
  List f8;
  @namesWithUnderscores String f9Rox;
  @isEnum Enum f10;
}