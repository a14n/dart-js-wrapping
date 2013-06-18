import 'package:js_wrapping/generator.dart';
import 'package:js/js.dart' as js;
import 'package:js/js_wrapping.dart' as jsw;
class Person extends jsw.TypedProxy {
  Person.fromProxy(js.Proxy proxy) : super.fromProxy(proxy);
  static Person cast(js.Proxy proxy) => null;
}