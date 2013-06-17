import 'package:js_wrapper_generator/js_wrapper_generator.dart';
import 'package:js/js.dart' as js;
import 'package:js/js_wrapping.dart' as jsw;
class Person extends jsw.TypedProxy {
  static Person cast(js.Proxy proxy) => proxy == null ? null : new Person.fromProxy(proxy);
  Person.fromProxy(js.Proxy proxy) : super.fromProxy(proxy);
  set f1(String f1) => $unsafe['f1'] = f1;
String get f1 => $unsafe['f1'];
set f2(String f2) => $unsafe.setF2(f2);
String get f2 => $unsafe.getF2();
set f3(String f3) => $unsafe['f3'] = f3;
String get f3 => $unsafe['f3'];
set f4(String f4) => $unsafe['f4'] = f4;
String get f4 => $unsafe['f4'];
set f5(Person f5) => $unsafe['f5'] = f5;
Person get f5 => Person.cast($unsafe['f5']);
set f6(List<Person> f6) => $unsafe['f6'] = f6 is js.Serializable<js.Proxy> ? f6 : js.array(f6);
List<Person> get f6 => jsw.JsArrayToListAdapter.castListOfSerializables($unsafe['f6'], Person.cast);
set f7(List<String> f7) => $unsafe['f7'] = f7 is js.Serializable<js.Proxy> ? f7 : js.array(f7);
List<String> get f7 => jsw.JsArrayToListAdapter.cast($unsafe['f7']);
set f8(List f8) => $unsafe['f8'] = f8 is js.Serializable<js.Proxy> ? f8 : js.array(f8);
List get f8 => jsw.JsArrayToListAdapter.cast($unsafe['f8']);
}