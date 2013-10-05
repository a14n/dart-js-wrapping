import 'dart:js' as js;

import 'package:js_wrapping/generator.dart';
import 'package:js_wrapping/js_wrapping.dart' as jsw;

class Enum extends jsw.IsEnum<int> {
  static final E1 = new Enum._(1);

  static final _FINDER = new jsw.EnumFinder<int, Enum>([E1]);

  static Enum find(Object o) => _FINDER.find(o);

  Enum._(int value) : super(value);
}

@wrapper abstract class Person extends jsw.TypedJsObject {
  set s1(String value);
  void set s2(Person value);
  void set s3(DateTime value);
  set s4(Enum value);
  String get g1;
  Person get g2;
  List<Person> get g3;
  List<String> get g4;
  List get g5;
  DateTime get g6;
  @isEnum Enum get g7;
  String m1();
  void m2();
  m3();
  Person m4();
  List<Person> m5();
  void m6(List l);
  void m7([List l]);
  @isEnum Enum m8();
}
