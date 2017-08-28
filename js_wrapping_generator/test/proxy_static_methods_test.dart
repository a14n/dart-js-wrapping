// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

@TestOn("browser")
library js_wrapping_generator.test.proxy_static_methods_test;

import 'dart:mirrors';

import 'package:js_wrapping/js_wrapping.dart';
import 'package:test/test.dart';

part 'proxy_static_methods_test.g.dart';

abstract class _Class0 implements JsInterface {
  static int getI() => $js;
  static void setI(int i) => $js;
  factory _Class0() => null;
}

@JsName('Class0')
abstract class _ClassPrivateMethod implements JsInterface {
  static int _getI() => $js;
  factory _ClassPrivateMethod() => null;
}

@JsName('Class0')
abstract class _ClassRenamedMethod implements JsInterface {
  @JsName('getI')
  static int getIBis() => $js;
  factory _ClassRenamedMethod() => null;
}

@JsName('Class0')
abstract class _ClassRenamedPrivateMethod implements JsInterface {
  @JsName('getI')
  static int _getIBis() => $js;
  factory _ClassRenamedPrivateMethod() => null;
}

main() {
  setUp(() {
    context['Class0']['i'] = 1;
  });

  test('int are supported as return value', () {
    expect(Class0.getI(), 1);
  });

  test('int are supported as method param', () {
    Class0.setI(2);
    expect(context['Class0']['i'], 2);
  });

  test('private field should be mapped to public name', () {
    final clazz = reflectClass(ClassPrivateMethod);
    expect(clazz.declarations.keys, isNot(contains(#getI)));

    expect(ClassPrivateMethod._getI(), 1);
  });

  test('a method should call with the name provided by JsName', () {
    final clazz = reflectClass(ClassRenamedMethod);
    expect(clazz.declarations.keys, isNot(contains(#getI)));

    expect(ClassRenamedMethod.getIBis(), 1);
  });

  test('a private method should call with the name provided by JsName', () {
    final clazz = reflectClass(ClassRenamedPrivateMethod);
    expect(clazz.declarations.keys, isNot(contains(#getI)));

    expect(ClassRenamedPrivateMethod._getIBis(), 1);
  });
}
