import 'package:js_wrapping/generator.dart';
import 'package:js/js.dart' as js;
import 'package:js/js_wrapping.dart' as jsw;
@wrapper @skipCast abstract class Person extends jsw.TypedProxy {
  static Person cast(js.Proxy proxy) => null;
}