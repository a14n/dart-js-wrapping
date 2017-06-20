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
  external static int getI();
  external static void setI(int i);
  factory _Class0() => null;
}

@JsName('Class0')
abstract class _ClassPrivateMethod implements JsInterface {
  external static int _getI();
  factory _ClassPrivateMethod() => null;
}

@JsName('Class0')
abstract class _ClassRenamedMethod implements JsInterface {
  @JsName('getI')
  external static int getIBis();
  factory _ClassRenamedMethod() => null;
}

@JsName('Class0')
abstract class _ClassRenamedPrivateMethod implements JsInterface {
  @JsName('getI')
  external static int _getIBis();
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
