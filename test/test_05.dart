import 'package:js_wrapper_generator/js_wrapper_generator.dart';
import 'package:js/js.dart' as js;
import 'package:js/js_wrapping.dart' as jsw;
@wrapper abstract class Person extends jsw.TypedProxy {
  static Person cast(js.Proxy proxy) => null;
}