import 'dart:js' as js;

import 'package:js_wrapping/generator.dart';
import 'package:js_wrapping/wrapping.dart' as jsw;
import 'package:js_wrapping/utils.dart';

class Enum extends IsEnum<int> {
  static final E1 = new Enum._(1);

  static final _FINDER = new EnumFinder<int, Enum>([E1]);

  static Enum find(Object o) => _FINDER.find(o);

  Enum._(int value) : super(value);
}

@wrapper @forMethods abstract class Person extends jsw.TypedJsObject {
  String f1;
  set s1(String value);
  Person get g1;
  @isEnum Enum get g2;
}