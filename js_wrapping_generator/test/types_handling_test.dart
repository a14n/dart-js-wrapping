// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

@TestOn("browser")
library js_wrapping_generator.test.types_handling_test;

import 'package:js_wrapping/js_wrapping.dart';
import 'package:test/test.dart';

part 'types_handling_test.g.dart';

@jsEnum
enum _Color { RED, GREEN, BLUE }

typedef String SimpleFunc(int i);

typedef B BisFunc(B b);

abstract class _A implements JsInterface {
  factory _A() => null;

  B b;
  List<B> bs;
  List<int> li;

  String toColorString(Color c);
  Color toColor(String s);

  String execute(B f(B b));

  String execute2(String f(B s, [int i]));

  BisFunc getBisFunc();

  SimpleFunc simpleFunc;

  void executeVoidFunction(void f());
}

abstract class _B implements JsInterface {
  factory _B(String v) => null;

  String toString();
}

main() {
  test('enum annotated with @jsEnum should be supported', () {
    final o = new A();
    expect(o.toColor('green'), Color.GREEN);
    expect(o.toColorString(Color.BLUE), 'blue');
  });

  test('JsInterface should be wrap/unwrap', () {
    final o = new A();
    expect(o.b, const TypeMatcher<B>());
    expect(o.b.toString(), 'init');

    o.b = new B('update');
    expect(asJsObject(o)['b']['v'], 'update');
  });

  test('List of JsInterface should be wrap/unwrap', () {
    final o = new A();
    expect(o.bs, const TypeMatcher<List<B>>());
    expect(o.bs.length, 2);
    expect(o.bs[0].toString(), 'b1');
    expect(o.bs[1].toString(), 'b2');

    o.bs = [new B('u1')];
    expect(asJsObject(o)['bs'], const TypeMatcher<JsArray>());
    expect(asJsObject(o)['bs'].length, 1);
    expect(asJsObject(o)['bs'][0].callMethod('toString'), 'u1');
  });

  test('List of int should be wrap/unwrap', () {
    final o = new A();
    expect(o.li, const TypeMatcher<List>());
    expect(o.li.length, 3);
    expect(o.li, [3, 4, 6]);

    o.li = [1];
    expect(asJsObject(o)['li'], const TypeMatcher<JsArray>());
    expect(asJsObject(o)['li'].length, 1);
    expect(asJsObject(o)['li'], [1]);
  });

  test('Function should be wrap/unwrap', () {
    final o = new A();
    expect(o.execute((b) => new B('t')).toString(), 't');
    expect((o.getBisFunc()(new B('a'))).toString(), 'aBis');

    o.simpleFunc = (int i) => '$i';
    expect(asJsObject(o).callMethod('simpleFunc', [4]), '4');

    asJsObject(o)['simpleFunc'] = (int i) => '$i$i';
    expect(o.simpleFunc, const TypeMatcher<Function>());
    expect(o.simpleFunc(3), '33');
  });

  test('Function with optional positional parameter should be wrap/unwrap', () {
    final o = new A();
    expect(o.execute2((b, [i]) => b.toString() + ' $i ').toString(),
        'init null init 1 init 2 ');
  });

  test('Function returning void should work', () {
    final o = new A();
    var i = 1;
    o.executeVoidFunction(() => i++);
    expect(i, 2);
  });
}
