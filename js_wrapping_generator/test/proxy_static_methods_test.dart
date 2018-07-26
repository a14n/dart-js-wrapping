// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

// this disable vm tests in group section because
// Failed to load "test/proxy_static_methods_mirrors_test.dart": Unable to spawn
// isolate: dart:js:1: Error: Not found: dart:js.
@TestOn('browser')
library js_wrapping_generator.test.proxy_static_methods_test;

import 'dart:mirrors';

import 'package:js_wrapping/js_wrapping.dart';
import 'package:test/test.dart';

part 'proxy_static_methods_test.g.dart';

abstract class _Class0 implements JsInterface {
  factory _Class0() => null;
  static int getI() => $js;
  static void setI(int i) => $js;
}

@JsName('Class0')
abstract class _ClassPrivateMethod implements JsInterface {
  factory _ClassPrivateMethod() => null;
  static int _getI() => $js;
}

@JsName('Class0')
abstract class _ClassRenamedMethod implements JsInterface {
  factory _ClassRenamedMethod() => null;
  @JsName('getI')
  static int getIBis() => $js;
}

@JsName('Class0')
abstract class _ClassRenamedPrivateMethod implements JsInterface {
  factory _ClassRenamedPrivateMethod() => null;
  @JsName('getI')
  static int _getIBis() => $js;
}

void main() {
  group('on browser', () {
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
      expect(ClassPrivateMethod._getI(), 1);
    });

    test('a method should call with the name provided by JsName', () {
      expect(ClassRenamedMethod.getIBis(), 1);
    });

    test('a private method should call with the name provided by JsName', () {
      expect(ClassRenamedPrivateMethod._getIBis(), 1);
    });
  }, testOn: 'browser');

  group('on vm', () {
    test('private field should be mapped to public name', () {
      final clazz = reflectClass(ClassPrivateMethod);
      expect(clazz.declarations.keys, isNot(contains(#getI)));
    });

    test('a method should call with the name provided by JsName', () {
      final clazz = reflectClass(ClassRenamedMethod);
      expect(clazz.declarations.keys, isNot(contains(#getI)));
    });

    test('a private method should call with the name provided by JsName', () {
      final clazz = reflectClass(ClassRenamedPrivateMethod);
      expect(clazz.declarations.keys, isNot(contains(#getI)));
    });
  }, testOn: 'vm');
}
