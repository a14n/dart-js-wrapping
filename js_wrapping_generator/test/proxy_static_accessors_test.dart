// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

// ignore_for_file: avoid_classes_with_only_static_members, avoid_setters_without_getters

@TestOn('browser')
library js_wrapping_generator.test.proxy_static_accessors_test;

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
  static int get i => $js;
}

@JsName('Class0')
abstract class _ClassWithSetter implements JsInterface {
  static set i(int i) {}
}

@JsName('Class0')
abstract class _ClassWithPrivateGetter implements JsInterface {
  static int get _i => $js;
}

@JsName('Class0')
abstract class _ClassWithPrivateSetter implements JsInterface {
  static set _i(int i) {}
}

@JsName('Class0')
abstract class _ClassWithRenamedGetter implements JsInterface {
  @JsName('i')
  static int get iBis => $js;
}

@JsName('Class0')
abstract class _ClassWithRenamedSetter implements JsInterface {
  @JsName('i')
  static set iBis(int i) {}
}

void main() {
  group('on browser', () {
    setUp(() {
      context['Class0']['i'] = 1;
    });

    test('private field should be mapped to public name', () {
      expect(ClassPrivateField._i, 1);
      ClassPrivateField._i = 2;
      expect(context['Class0']['i'], 2);
    });

    test('private field should be mapped to public name', () {
      expect(ClassPrivateField._i, 1);
      ClassPrivateField._i = 2;
      expect(context['Class0']['i'], 2);
    });

    test('a field should call with the name provided by JsName', () {
      expect(ClassRenamedField.iBis, 1);
      ClassRenamedField.iBis = 2;
      expect(context['Class0']['i'], 2);
      expect(context['Class0'].hasProperty('iBis'), false);
    });

    test('a private field should call with the name provided by JsName', () {
      expect(ClassRenamedPrivateField._iBis, 1);
      ClassRenamedPrivateField._iBis = 2;
      expect(context['Class0']['i'], 2);
    });

    test('ClassWithGetter should have getter but not setter', () {
      expect(ClassWithGetter.i, 1);
    });

    test('ClassWithSetter should have setter but not getter', () {
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
  }, testOn: 'browser');

  group('on vm', () {
    test('fields (not final) should generate getter and setter', () {
      final clazz = reflectClass(ClassNotFinalField);
      expect(clazz.declarations.keys, contains(#i));
      expect(clazz.declarations.keys, contains(const Symbol('i=')));
    });

    test('private field should be mapped to public name', () {
      final clazz = reflectClass(ClassPrivateField);
      expect(clazz.declarations.keys, isNot(contains(#i)));
      expect(clazz.declarations.keys, isNot(contains(const Symbol('i='))));
    });

    test('private field should be mapped to public name', () {
      final clazz = reflectClass(ClassPrivateField);
      expect(clazz.declarations.keys, isNot(contains(#i)));
      expect(clazz.declarations.keys, isNot(contains(const Symbol('i='))));
    });

    test('a field should call with the name provided by JsName', () {
      final clazz = reflectClass(ClassRenamedField);
      expect(clazz.declarations.keys, isNot(contains(#i)));
      expect(clazz.declarations.keys, isNot(contains(const Symbol('i='))));
    });

    test('a private field should call with the name provided by JsName', () {
      final clazz = reflectClass(ClassRenamedPrivateField);
      expect(clazz.declarations.keys, isNot(contains(#i)));
      expect(clazz.declarations.keys, isNot(contains(const Symbol('i='))));
    });

    test('ClassWithGetter should have getter but not setter', () {
      final clazz = reflectClass(ClassWithGetter);
      expect(clazz.declarations.keys, contains(#i));
      expect(clazz.declarations.keys, isNot(contains(const Symbol('i='))));
    });

    test('ClassWithSetter should have setter but not getter', () {
      final clazz = reflectClass(ClassWithSetter);
      expect(clazz.declarations.keys, isNot(contains(#i)));
      expect(clazz.declarations.keys, contains(const Symbol('i=')));
    });
  }, testOn: 'vm');
}
