import 'dart:js' as js;

import 'package:js_wrapping/generator.dart';
import 'package:js_wrapping/wrapping.dart' as jsw;

@wrapper abstract class Person extends jsw.TypedJsObject {
  set s1(String value);
  void set s2(Person value);
  String get g1;
  Person get g2;
  List<Person> get g3;
  List<String> get g4;
  List get g5;
  String m1();
  void m2();
  m3();
  Person m4();
  List<Person> m5();
  void m6(List l);
  void m7([List l]);
}
