import 'package:js_wrapping/generator.dart';
import 'package:js/js.dart' as js;
import 'package:js/js_wrapping.dart' as jsw;
class Person extends jsw.TypedProxy {
  static Person cast(js.Proxy proxy) => proxy == null ? null : new Person.fromProxy(proxy);
  Person.fromProxy(js.Proxy proxy) : super.fromProxy(proxy);
}