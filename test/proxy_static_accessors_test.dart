// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

@TestOn("browser")
library js_wrapping.test.proxy_static_accessors_test;

import 'dart:mirrors';

import 'package:js_wrapping/js_wrapping.dart';

import 'package:test/test.dart';

part 'proxy_static_accessors_test.g.dart';

@JsName('Class0')
abstract class _ClassNotFinalField implements JsInterface {
  static int i;
}

@JsName('Class0')
abstract class _ClassPrivateField implements JsInterface {
  static int _i;
}

@JsName('Class0')
abstract class _ClassRenamedField implements JsInterface {
  @JsName('i')
  static int iBis;
}

@JsName('Class0')
abstract class _ClassRenamedPrivateField implements JsInterface {
  @JsName('i')
  static int _iBis;
}

@JsName('Class0')
abstract class _ClassWithGetter implements JsInterface {
  external static int get i;
}

@JsName('Class0')
abstract class _ClassWithSetter implements JsInterface {
  external static set i(int i);
}

@JsName('Class0')
abstract class _ClassWithPrivateGetter implements JsInterface {
  external static int get _i;
}

@JsName('Class0')
abstract class _ClassWithPrivateSetter implements JsInterface {
  external static set _i(int i);
}

@JsName('Class0')
abstract class _ClassWithRenamedGetter implements JsInterface {
  @JsName('i')
  external static int get iBis;
}

@JsName('Class0')
abstract class _ClassWithRenamedSetter implements JsInterface {
  @JsName('i')
  external static set iBis(int i);
}

main() {
  setUp((){
    context['Class0']['i'] = 1;
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

    expect(ClassPrivateField._i, 1);
    ClassPrivateField._i = 2;
    expect(context['Class0']['i'], 2);
  });

  test('a field should call with the name provided by JsName', () {
    final clazz = reflectClass(ClassRenamedField);
    expect(clazz.declarations.keys, isNot(contains(#i)));
    expect(clazz.declarations.keys, isNot(contains(const Symbol('i='))));

    expect(ClassRenamedField.iBis, 1);
    ClassRenamedField.iBis = 2;
    expect(context['Class0']['i'], 2);
    expect(context['Class0'].hasProperty('iBis'), false);
  });

  test('a private field should call with the name provided by JsName', () {
    final clazz = reflectClass(ClassRenamedPrivateField);
    expect(clazz.declarations.keys, isNot(contains(#i)));
    expect(clazz.declarations.keys, isNot(contains(const Symbol('i='))));

    expect(ClassRenamedPrivateField._iBis, 1);
    ClassRenamedPrivateField._iBis = 2;
    expect(context['Class0']['i'], 2);
  });

  test('ClassWithGetter should have getter but not setter', () {
    final clazz = reflectClass(ClassWithGetter);
    expect(clazz.declarations.keys, contains(#i));
    expect(clazz.declarations.keys, isNot(contains(const Symbol('i='))));

    expect(ClassWithGetter.i, 1);
  });

  test('ClassWithSetter should have setter but not getter', () {
    final clazz = reflectClass(ClassWithSetter);
    expect(clazz.declarations.keys, isNot(contains(#i)));
    expect(clazz.declarations.keys, contains(const Symbol('i=')));

    ClassWithSetter.i = 2;
    expect(context['Class0']['i'], 2);
  });

  test('private getter should be mapped to public name', () {
    expect(ClassWithPrivateGetter._i, 1);
  });

  test('private setter should be mapped to public name', () {
    ClassWithPrivateSetter._i = 2;
    expect(context['Class0']['i'], 2);
  });

  test('private getter should call with the name provided by JsName', () {
    expect(ClassWithRenamedGetter.iBis, 1);
  });

  test('private setter should call with the name provided by JsName', () {
    ClassWithRenamedSetter.iBis = 2;
    expect(context['Class0']['i'], 2);
  });
}
