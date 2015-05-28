// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

@TestOn("browser")
library js_wrapping.test.proxy_accessors_test;

import 'dart:mirrors';

import 'package:js_wrapping/js_wrapping.dart';

import 'package:test/test.dart';

part 'proxy_accessors_test.g.dart';

abstract class _Class0 implements JsInterface {
  external factory _Class0();

  final int i;
}

@JsName('Class0')
abstract class _ClassFinalField implements JsInterface {
  external factory _ClassFinalField();

  final int i;
}

@JsName('Class0')
abstract class _ClassNotFinalField implements JsInterface {
  external factory _ClassNotFinalField();

  int i;
}

@JsName('Class0')
abstract class _ClassPrivateField implements JsInterface {
  external factory _ClassPrivateField();

  int _i;
}

@JsName('Class0')
abstract class _ClassRenamedField implements JsInterface {
  external factory _ClassRenamedField();

  @JsName('i')
  int iBis;
}

@JsName('Class0')
abstract class _ClassRenamedPrivateField implements JsInterface {
  external factory _ClassRenamedPrivateField();

  @JsName('i')
  int _iBis;
}

@JsName('Class0')
abstract class _ClassWithGetter implements JsInterface {
  external factory _ClassWithGetter();

  int get i;
}

@JsName('Class0')
abstract class _ClassWithSetter implements JsInterface {
  external factory _ClassWithSetter();

  set i(int i);
}

@JsName('Class0')
abstract class _ClassWithPrivateGetter implements JsInterface {
  external factory _ClassWithPrivateGetter();

  int get _i;
}

@JsName('Class0')
abstract class _ClassWithPrivateSetter implements JsInterface {
  external factory _ClassWithPrivateSetter();

  set _i(int i);
}

@JsName('Class0')
abstract class _ClassWithRenamedGetter implements JsInterface {
  external factory _ClassWithRenamedGetter();

  @JsName('i')
  int get iBis;
}

@JsName('Class0')
abstract class _ClassWithRenamedSetter implements JsInterface {
  external factory _ClassWithRenamedSetter();

  @JsName('i')
  set iBis(int i);
}

main() {
  test('int fields are supported', () {
    final o = new Class0();
    expect(o.i, 1);
  });

  test('final fields should generate getter but not setter', () {
    final clazz = reflectClass(ClassFinalField);
    expect(clazz.declarations.keys, contains(#i));
    expect(clazz.declarations.keys, isNot(contains(const Symbol('i='))));
  });

  test('fields (not final) should generate getter and setter', () {
    final clazz = reflectClass(ClassNotFinalField);
    expect(clazz.declarations.keys, contains(#i));
    expect(clazz.declarations.keys, contains(const Symbol('i=')));
  });

  test('private field should be mapped to public name', () {
    final clazz = reflectClass(ClassPrivateField);
    expect(clazz.declarations.keys, isNot(contains(#i)));
    expect(clazz.declarations.keys, isNot(contains(const Symbol('i='))));

    final o = new ClassPrivateField();
    expect(o._i, 1);
    o._i = 2;
    expect(asJsObject(o)['i'], 2);
  });

  test('a field should call with the name provided by JsName', () {
    final clazz = reflectClass(ClassRenamedField);
    expect(clazz.declarations.keys, isNot(contains(#i)));
    expect(clazz.declarations.keys, isNot(contains(const Symbol('i='))));

    final o = new ClassRenamedField();
    expect(o.iBis, 1);
    o.iBis = 2;
    expect(asJsObject(o)['i'], 2);
    expect(asJsObject(o).hasProperty('iBis'), false);
  });

  test('a private field should call with the name provided by JsName', () {
    final clazz = reflectClass(ClassRenamedPrivateField);
    expect(clazz.declarations.keys, isNot(contains(#i)));
    expect(clazz.declarations.keys, isNot(contains(const Symbol('i='))));

    final o = new ClassRenamedPrivateField();
    expect(o._iBis, 1);
    o._iBis = 2;
    expect(asJsObject(o)['i'], 2);
  });

  test('ClassWithGetter should have getter but not setter', () {
    final clazz = reflectClass(ClassWithGetter);
    expect(clazz.declarations.keys, contains(#i));
    expect(clazz.declarations.keys, isNot(contains(const Symbol('i='))));

    final o = new ClassWithGetter();
    expect(o.i, 1);
  });

  test('ClassWithSetter should have setter but not getter', () {
    final clazz = reflectClass(ClassWithSetter);
    expect(clazz.declarations.keys, isNot(contains(#i)));
    expect(clazz.declarations.keys, contains(const Symbol('i=')));

    final o = new ClassWithSetter();
    o.i = 2;
    expect(asJsObject(o)['i'], 2);
  });

  test('private getter should be mapped to public name', () {
    final o = new ClassWithPrivateGetter();
    expect(o._i, 1);
  });

  test('private setter should be mapped to public name', () {
    final o = new ClassWithPrivateSetter();
    o._i = 2;
    expect(asJsObject(o)['i'], 2);
  });

  test('private getter should call with the name provided by JsName', () {
    final o = new ClassWithRenamedGetter();
    expect(o.iBis, 1);
  });

  test('private setter should call with the name provided by JsName', () {
    final o = new ClassWithRenamedSetter();
    o.iBis = 2;
    expect(asJsObject(o)['i'], 2);
  });
}
