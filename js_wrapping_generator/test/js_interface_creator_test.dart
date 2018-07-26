// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

library js_wrapping_generator.test.proxy_creator_test;

import 'package:test/test.dart';
import 'package:js_wrapping_generator/js_interface_creator.dart';

void main() {
  group('JsInterface creation', () {
    test('should accept simple name', () {
      expect(
          createInterfaceSkeleton('MyClass'),
          '''
@JsName('MyClass')
abstract class _MyClass implements JsInterface {
  factory _MyClass() => \$js;
}''');
    });

    test('should accept qualified name', () {
      expect(
          createInterfaceSkeleton('a.b.MyClass'),
          '''
@JsName('a.b.MyClass')
abstract class _MyClass implements JsInterface {
  factory _MyClass() => \$js;
}''');
    });
  });
}
