// Copyright (c) 2014, Alexandre Ardhuin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library js_wrapping.transformer.test;

import 'package:unittest/unittest.dart';

import 'transformation.dart';

main() {
  testTransformation('inherite from TypedJsObject should define '
      r'Xxx.fromJsObject constructor and $wrap',
      r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
}
''',
      r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  static A $wrap(js.JsObject jsObject) => jsObject == null ? null : new A.fromJsObject(jsObject);
  A.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);
}
'''
      );

  testTransformation('inherite from TypedJsObject should not override '
      r'Xxx.fromJsObject constructor and $wrap',
      r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  static A $wrap(js.JsObject jsObject) => null;
  A.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject) {
    print('hello');
  }
}
''',
      r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  static A $wrap(js.JsObject jsObject) => null;
  A.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject) {
    print('hello');
  }
}
'''
      );

  testTransformation('inherite from class that inherite from TypedJsObject '
      r'should define Xxx.fromJsObject constructor and $wrap',
      r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
}
class B extends A {
}
''',
      r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  static A $wrap(js.JsObject jsObject) => jsObject == null ? null : new A.fromJsObject(jsObject);
  A.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);
}
class B extends A {
  static B $wrap(js.JsObject jsObject) => jsObject == null ? null : new B.fromJsObject(jsObject);
  B.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);
}
'''
      );


  group('members generation', () {

    testTransformation("abstract get with simple types should be generated",
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  int get i;
  double get d;
  num get n;
  bool get b;
  String get s;
}
''',
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  int get i => $unsafe['i'];
  double get d => $unsafe['d'];
  num get n => $unsafe['n'];
  bool get b => $unsafe['b'];
  String get s => $unsafe['s'];
  static A $wrap(js.JsObject jsObject) => jsObject == null ? null : new A.fromJsObject(jsObject);
  A.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);
}
'''
        );

    testTransformation("unabstract get shouldn't be erased",
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  int get i => null;
}
''',
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  int get i => null;
  static A $wrap(js.JsObject jsObject) => jsObject == null ? null : new A.fromJsObject(jsObject);
  A.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);
}
'''
        );

    testTransformation("abstract set with simple types should be generated",
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  set i(int v);
  set d(double v);
  set n(num v);
  set b(bool v);
  set s(String v);
}
''',
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  void set i(int v) { $unsafe['i'] = v; }
  void set d(double v) { $unsafe['d'] = v; }
  void set n(num v) { $unsafe['n'] = v; }
  void set b(bool v) { $unsafe['b'] = v; }
  void set s(String v) { $unsafe['s'] = v; }
  static A $wrap(js.JsObject jsObject) => jsObject == null ? null : new A.fromJsObject(jsObject);
  A.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);
}
'''
        );

    testTransformation("unabstract get shouldn't be erased",
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  set i(int v) { }
}
''',
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  set i(int v) { }
  static A $wrap(js.JsObject jsObject) => jsObject == null ? null : new A.fromJsObject(jsObject);
  A.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);
}
'''
        );

    testTransformation("field with simple types should generate get and set",
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  int i;
  double d;
  num n;
  bool b;
  String s;
}
''',
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  int get i => $unsafe['i'];
  void set i(int _i) { $unsafe['i'] = _i; }
  double get d => $unsafe['d'];
  void set d(double _d) { $unsafe['d'] = _d; }
  num get n => $unsafe['n'];
  void set n(num _n) { $unsafe['n'] = _n; }
  bool get b => $unsafe['b'];
  void set b(bool _b) { $unsafe['b'] = _b; }
  String get s => $unsafe['s'];
  void set s(String _s) { $unsafe['s'] = _s; }
  static A $wrap(js.JsObject jsObject) => jsObject == null ? null : new A.fromJsObject(jsObject);
  A.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);
}
'''
        );

    testTransformation("initialized field shouldn't generate get/set",
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  int i = null;
}
''',
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  int i = null;
  static A $wrap(js.JsObject jsObject) => jsObject == null ? null : new A.fromJsObject(jsObject);
  A.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);
}
'''
        );

    testTransformation("final field should generate only get",
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  final int i;
}
''',
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  int get i => $unsafe['i'];
  static A $wrap(js.JsObject jsObject) => jsObject == null ? null : new A.fromJsObject(jsObject);
  A.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);
}
'''
        );

    testTransformation("method with simple return types should work",
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  int m1();
  double m2();
  num m3();
  bool m4();
  String m5();
  void m6();
}
''',
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  int m1() => $unsafe.callMethod('m1');
  double m2() => $unsafe.callMethod('m2');
  num m3() => $unsafe.callMethod('m3');
  bool m4() => $unsafe.callMethod('m4');
  String m5() => $unsafe.callMethod('m5');
  void m6() { $unsafe.callMethod('m6'); }
  static A $wrap(js.JsObject jsObject) => jsObject == null ? null : new A.fromJsObject(jsObject);
  A.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);
}
'''
        );

    testTransformation("method with simple parameter types should work",
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  void m1(int i);
  void m2(double d);
  void m3(num n);
  void m4(bool b);
  void m5(String s);
}
''',
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  void m1(int i) { $unsafe.callMethod('m1', [i]); }
  void m2(double d) { $unsafe.callMethod('m2', [d]); }
  void m3(num n) { $unsafe.callMethod('m3', [n]); }
  void m4(bool b) { $unsafe.callMethod('m4', [b]); }
  void m5(String s) { $unsafe.callMethod('m5', [s]); }
  static A $wrap(js.JsObject jsObject) => jsObject == null ? null : new A.fromJsObject(jsObject);
  A.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);
}
'''
        );

  });

  group('return types', () {

    testTransformation('dynamic',
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  m1();
  dynamic m2();
}
''',
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  m1() => $unsafe.callMethod('m1');
  dynamic m2() => $unsafe.callMethod('m2');
  static A $wrap(js.JsObject jsObject) => jsObject == null ? null : new A.fromJsObject(jsObject);
  A.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);
}
'''
        );

    testTransformation('simple types',
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  int m1();
  double m2();
  num m3();
  bool m4();
  String m5();
  void m6();
}
''',
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  int m1() => $unsafe.callMethod('m1');
  double m2() => $unsafe.callMethod('m2');
  num m3() => $unsafe.callMethod('m3');
  bool m4() => $unsafe.callMethod('m4');
  String m5() => $unsafe.callMethod('m5');
  void m6() { $unsafe.callMethod('m6'); }
  static A $wrap(js.JsObject jsObject) => jsObject == null ? null : new A.fromJsObject(jsObject);
  A.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);
}
'''
        );

    testTransformation('Serializable types',
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  A m();
}
''',
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  A m() => A.$wrap($unsafe.callMethod('m'));
  static A $wrap(js.JsObject jsObject) => jsObject == null ? null : new A.fromJsObject(jsObject);
  A.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);
}
'''
        );

    testTransformation('List types',
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  List m1();
  List<int> m2();
  List<A> m3();
}
''',
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  List m1() => jsw.TypedJsArray.$wrap($unsafe.callMethod('m1'));
  List<int> m2() => jsw.TypedJsArray.$wrap($unsafe.callMethod('m2'));
  List<A> m3() => jsw.TypedJsArray.$wrapSerializables($unsafe.callMethod('m3'), A.$wrap);
  static A $wrap(js.JsObject jsObject) => jsObject == null ? null : new A.fromJsObject(jsObject);
  A.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);
}
'''
        );

    testTransformation('Union types',
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  @jsw.UnionType(const [String, A]) get g;
  @jsw.UnionType(const [String, A]) m1();
}
''',
        r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
class A extends jsw.TypedJsObject {
  @jsw.UnionType(const [String, A]) get g => ((v2) => v2 is String ? v2 : ((v1) => A.isInstance(v1) ? A.$wrap(v1) : ((v0) => v0)(v1))(v2))($unsafe['g']);
  @jsw.UnionType(const [String, A]) m1() => ((v2) => v2 is String ? v2 : ((v1) => A.isInstance(v1) ? A.$wrap(v1) : ((v0) => v0)(v1))(v2))($unsafe.callMethod('m1'));
  static A $wrap(js.JsObject jsObject) => jsObject == null ? null : new A.fromJsObject(jsObject);
  A.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);
}
'''
        );

  });

  testTransformation(
      'use @JsConstructor() should make a class instantiable and mapped on an anonymous Js Object',
      r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
@jsw.JsConstructor()
class A extends jsw.TypedJsObject {
}
''',
      r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
@jsw.JsConstructor()
class A extends jsw.TypedJsObject {
  static A $wrap(js.JsObject jsObject) => jsObject == null ? null : new A.fromJsObject(jsObject);
  A.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);
  static final js.JsFunction _ctor = js.context['Object'];
  A() : this.fromJsObject(new js.JsObject(_ctor));
}
'''
      );

  testTransformation(
      "use @JsConstructor(jsName: const ['a','b','C']) should make a class instantiable and mapped on a Js Object",
      r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
@jsw.JsConstructor(jsName: const ['a','b','C'])
class A extends jsw.TypedJsObject {
}
''',
      r'''
import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
@jsw.JsConstructor(jsName: const ['a','b','C'])
class A extends jsw.TypedJsObject {
  static A $wrap(js.JsObject jsObject) => jsObject == null ? null : new A.fromJsObject(jsObject);
  A.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);
  static final js.JsFunction _ctor = js.context['a']['b']['C'];
  A() : this.fromJsObject(new js.JsObject(_ctor));
}
'''
      );
}
