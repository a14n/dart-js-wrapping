import 'package:js_wrapping/generator.dart';
import 'package:js/js.dart' as js;
import 'package:js/js_wrapping.dart' as jsw;
class Person extends jsw.TypedProxy {
  static Person cast(js.Proxy proxy) => proxy == null ? null : new Person.fromProxy(proxy);
  Person.fromProxy(js.Proxy proxy) : super.fromProxy(proxy);
  set s1(String value) => $unsafe['s1'] = value;
  set s2(Person value) => $unsafe['s2'] = value;
  String get g1 => $unsafe['g1'];
  Person get g2 => Person.cast($unsafe['g2']);
  List<Person> get g3 => jsw.JsArrayToListAdapter.castListOfSerializables($unsafe['g3'], Person.cast);
  List<String> get g4 => jsw.JsArrayToListAdapter.cast($unsafe['g4']);
  List get g5 => jsw.JsArrayToListAdapter.cast($unsafe['g5']);
  String m1() => $unsafe.m1();
  void m2() { $unsafe.m2(); }
  m3() => $unsafe.m3();
  Person m4() => Person.cast($unsafe.m4());
  List<Person> m5() => jsw.JsArrayToListAdapter.castListOfSerializables($unsafe.m5(), Person.cast);
  void m6(List l) { $unsafe.m6(l is js.Serializable<js.Proxy> ? l : js.array(l)); }
}