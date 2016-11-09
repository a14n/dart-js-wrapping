// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

@TestOn("browser")
library js_wrapping_generator.test.proxy_methods_test;

import 'dart:mirrors';

import 'package:js_wrapping/js_wrapping.dart';
import 'package:test/test.dart';

part 'proxy_methods_test.g.dart';

abstract class _Class0 implements JsInterface {
  external factory _Class0();

  int getI();
  void setI(int i);
}

@JsName('Class0')
abstract class _ClassPrivateMethod implements JsInterface {
  external factory _ClassPrivateMethod();

  int _getI();
}

@JsName('Class0')
abstract class _ClassRenamedMethod implements JsInterface {
  external factory _ClassRenamedMethod();

  @JsName('getI')
  int getIBis();
}

@JsName('Class0')
abstract class _ClassRenamedPrivateMethod implements JsInterface {
  external factory _ClassRenamedPrivateMethod();

  @JsName('getI')
  int _getIBis();
}

abstract class _Class1 implements JsInterface {
  external factory _Class1();

  void set1(String s);
  void set2(String s, [int i]);
  void set3(String s, {int i, bool j});
}

main() {
  test('int are supported as return value', () {
    final o = new Class0();
    expect(o.getI(), 1);
  });

  test('int are supported as method param', () {
    final o = new Class0();
    o.setI(2);
    expect(asJsObject(o)['i'], 2);
  });

  test('private field should be mapped to public name', () {
    final clazz = reflectClass(ClassPrivateMethod);
    expect(clazz.declarations.keys, isNot(contains(#getI)));

    final o = new ClassPrivateMethod();
    expect(o._getI(), 1);
  });

  test('a method should call with the name provided by JsName', () {
    final clazz = reflectClass(ClassRenamedMethod);
    expect(clazz.declarations.keys, isNot(contains(#getI)));

    final o = new ClassRenamedMethod();
    expect(o.getIBis(), 1);
  });

  test('a private method should call with the name provided by JsName', () {
    final clazz = reflectClass(ClassRenamedPrivateMethod);
    expect(clazz.declarations.keys, isNot(contains(#getI)));

    final o = new ClassRenamedPrivateMethod();
    expect(o._getIBis(), 1);
  });

  test('Class1.set1 should be instantiable with 1 argument', () {
    var o = new Class1()..set1('test');
    expect(asJsObject(o)['s'], 'test');
  });

  test(
      'Class1.set2 should be instantiable with 1 argument and '
      '1 optional positional argument', () {
    var o = new Class1()..set2('test1');
    expect(asJsObject(o)['s'], 'test1');
    expect(asJsObject(o)['i'], isNull);
    o = new Class1()..set2('test2', 2);
    expect(asJsObject(o)['s'], 'test2');
    expect(asJsObject(o)['i'], 2);
  });

  test(
      'Class1.set3 should be instantiable with 1 argument and '
      '2 optional named arguments (mapped on an anonymous object)', () {
    var o = new Class1()..set3('test1');
    expect(asJsObject(o)['s'], 'test1');
    expect(asJsObject(o)['i'], isNull);
    expect(asJsObject(o)['j'], isNull);
    o = new Class1()..set3('test2', i: 1);
    expect(asJsObject(o)['s'], 'test2');
    expect(asJsObject(o)['i'], 1);
    expect(asJsObject(o)['j'], isNull);
    o = new Class1()..set3('test3', j: true, i: 4);
    expect(asJsObject(o)['s'], 'test3');
    expect(asJsObject(o)['i'], 4);
    expect(asJsObject(o)['j'], true);
  });
}
