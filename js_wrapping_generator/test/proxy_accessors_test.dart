// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

// ignore_for_file: avoid_setters_without_getters

@TestOn('browser')
library js_wrapping_generator.test.proxy_accessors_test;

import 'package:js_wrapping/js_wrapping.dart';
import 'package:test/test.dart';

part 'proxy_accessors_test.g.dart';

abstract class _Class0 implements JsInterface {
  factory _Class0() => null;

  final int i;
}

@JsName('Class0')
abstract class _ClassFinalField implements JsInterface {
  factory _ClassFinalField() => null;

  final int i;
}

@JsName('Class0')
abstract class _ClassNotFinalField implements JsInterface {
  factory _ClassNotFinalField() => null;

  int i;
}

@JsName('Class0')
abstract class _ClassPrivateField implements JsInterface {
  factory _ClassPrivateField() => null;

  int _i;
}

@JsName('Class0')
abstract class _ClassRenamedField implements JsInterface {
  factory _ClassRenamedField() => null;

  @JsName('i')
  int iBis;
}

@JsName('Class0')
abstract class _ClassRenamedPrivateField implements JsInterface {
  factory _ClassRenamedPrivateField() => null;

  @JsName('i')
  int _iBis;
}

@JsName('Class0')
abstract class _ClassWithGetter implements JsInterface {
  factory _ClassWithGetter() => null;

  int get i;
}

@JsName('Class0')
abstract class _ClassWithSetter implements JsInterface {
  factory _ClassWithSetter() => null;

  set i(int i);
}

@JsName('Class0')
abstract class _ClassWithPrivateGetter implements JsInterface {
  factory _ClassWithPrivateGetter() => null;

  int get _i;
}

@JsName('Class0')
abstract class _ClassWithPrivateSetter implements JsInterface {
  factory _ClassWithPrivateSetter() => null;

  set _i(int i);
}

@JsName('Class0')
abstract class _ClassWithRenamedGetter implements JsInterface {
  factory _ClassWithRenamedGetter() => null;

  @JsName('i')
  int get iBis;
}

@JsName('Class0')
abstract class _ClassWithRenamedSetter implements JsInterface {
  factory _ClassWithRenamedSetter() => null;

  @JsName('i')
  set iBis(int i);
}

void main() {
  test('int fields are supported', () {
    final o = Class0();
    expect(o.i, 1);
  });

  test('final fields should generate getter but not setter', () {
    final o = ClassFinalField();
    expect(o.i, 1);
    expect(() => (o as dynamic).i = 1, throwsNoSuchMethodError);
  });

  test('fields (not final) should generate getter and setter', () {
    final o = ClassNotFinalField()..i = 1;
    expect(o.i, 1);
  });

  test('private field should be mapped to public name', () {
    final o = ClassPrivateField();
    expect(() => (o as dynamic).i, throwsNoSuchMethodError);
    expect(() => (o as dynamic).i = 1, throwsNoSuchMethodError);
    expect(o._i, 1);
    o._i = 2;
    expect(asJsObject(o)['i'], 2);
  });

  test('a field should call with the name provided by JsName', () {
    final o = ClassRenamedField();
    expect(() => (o as dynamic).i, throwsNoSuchMethodError);
    expect(() => (o as dynamic).i = 1, throwsNoSuchMethodError);
    expect(o.iBis, 1);
    o.iBis = 2;
    expect(asJsObject(o)['i'], 2);
    expect(asJsObject(o).hasProperty('iBis'), false);
  });

  test('a private field should call with the name provided by JsName', () {
    final o = ClassRenamedPrivateField();
    expect(() => (o as dynamic).i, throwsNoSuchMethodError);
    expect(() => (o as dynamic).i = 1, throwsNoSuchMethodError);
    expect(o._iBis, 1);
    o._iBis = 2;
    expect(asJsObject(o)['i'], 2);
  });

  test('ClassWithGetter should have getter but not setter', () {
    final o = ClassWithGetter();
    expect(o.i, 1);
    expect(() => (o as dynamic).i = 1, throwsNoSuchMethodError);
  });

  test('ClassWithSetter should have setter but not getter', () {
    final o = ClassWithSetter()..i = 2;
    expect(() => (o as dynamic).i, throwsNoSuchMethodError);
    expect(asJsObject(o)['i'], 2);
  });

  test('private getter should be mapped to public name', () {
    final o = ClassWithPrivateGetter();
    expect(o._i, 1);
  });

  test('private setter should be mapped to public name', () {
    final o = ClassWithPrivateSetter().._i = 2;
    expect(asJsObject(o)['i'], 2);
  });

  test('private getter should call with the name provided by JsName', () {
    final o = ClassWithRenamedGetter();
    expect(o.iBis, 1);
  });

  test('private setter should call with the name provided by JsName', () {
    final o = ClassWithRenamedSetter()..iBis = 2;
    expect(asJsObject(o)['i'], 2);
  });
}
