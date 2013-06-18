import 'package:js_wrapping/generator.dart';
import 'package:js/js.dart' as js;
import 'package:js/js_wrapping.dart' as jsw;
class Person extends jsw.TypedProxy {
  static Person cast(js.Proxy proxy) => proxy == null ? null : new Person.fromProxy(proxy);
  Person.fromProxy(js.Proxy proxy) : super.fromProxy(proxy);
  set f1(String f1) => $unsafe.setF1(f1);
String get f1 => $unsafe.getF1();
set s1(String value) => $unsafe.setS1(value);
  Person get g1 => Person.cast($unsafe.getG1());
}