import 'dart:js' as js;

import 'package:js_wrapping/generator.dart';
import 'package:js_wrapping/wrapping.dart' as jsw;

@wrapper class Person extends jsw.TypedJsObject {
  String f1;
  @forMethods String f2;
  String f3, f4;
  Person f5;
  List<Person> f6;
  List<String> f7;
  List f8;
  @namesWithUnderscores String f9Rox;
}