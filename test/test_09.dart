import 'package:js_wrapping/generator.dart';
import 'package:js/js.dart' as js;
import 'package:js/js_wrapping.dart' as jsw;
@wrapper class Person extends jsw.TypedProxy {
  String f1;
  @forMethods String f2;
  String f3, f4;
  Person f5;
  List<Person> f6;
  List<String> f7;
  List f8;
}