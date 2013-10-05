import 'dart:js' as js;

import 'package:js_wrapping/generator.dart';
import 'package:js_wrapping/js_wrapping.dart' as jsw;

@wrapper @skipConstructor abstract class Person extends jsw.TypedJsObject {
  Person.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject) {
    print('init done');
  }
}
