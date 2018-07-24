// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

@TestOn("browser")
@JsName('a')
library js_wrapping_generator.test.namespaced_library_test;

import 'dart:js' as js;

import 'package:js_wrapping/js_wrapping.dart';
import 'package:test/test.dart';

part 'namespaced_library_test.g.dart';

abstract class _Class0 implements JsInterface {
  factory _Class0() => null;
}

@JsName('b.Class1')
abstract class _Class1 implements JsInterface {
  factory _Class1() => null;
}

main() {
  test('a.Class0 should be instantiable', () {
    final o = new Class0();
    final jsO = asJsObject(o);
    expect(jsO, const TypeMatcher<js.JsObject>());
    expect(js.context.callMethod('isClass0', [jsO]), true);
  });

  test('a.b.Class1 should be instantiable', () {
    final o = new Class1();
    final jsO = asJsObject(o);
    expect(jsO, const TypeMatcher<js.JsObject>());
    expect(js.context.callMethod('isClass1', [jsO]), true);
  });
}
