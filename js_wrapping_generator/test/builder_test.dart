@TestOn('vm')
import 'package:build_test/build_test.dart';
import 'package:js_wrapping_generator/src/generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

void main() {
  tearDown(() {
    // Increment this after each test so the next test has it's own package
    _pkgCacheCount++;
  });

  test('simple class', () async {
    await testGeneration(
      r'''
@JsName()
class A {}
''',
      r'''
@JS()
class A {}
''',
    );
  });

  test('class rename', () async {
    await testGeneration(
      r'''
@JsName('B')
class A {}
''',
      r'''
@JS('B')
class A {}
''',
    );
  });

  test('constructor', () async {
    await testGeneration(
      r'''
@JsName()
class A {
  factory A() => $js;
}
''',
      r'''
@JS()
class A {
  external A();
}
''',
    );
  });

  test('anonymous constructor', () async {
    await testGeneration(
      r'''
@JsName()
@anonymous
class A {
  factory A() => $js;
}
''',
      r'''
@JS()
@anonymous
class A {
  external factory A();
}
''',
    );
  });

  test('field to getter/setter', () async {
    await testGeneration(
      r'''
@JsName()
class A {
  int i;
}
''',
      r'''
@JS()
class A {
  external int get i;

  external set i(int value);
}
''',
    );
  });

  test('non-abstract getter', () async {
    await testGeneration(
      r'''
@JsName()
class A {
  int get i => 1;
}
''',
      r'''
@JS()
class A {}

extension A$Ext on A {
  int get i => 1;
}
''',
    );
  });

  test('non-abstract setter', () async {
    await testGeneration(
      r'''
@JsName()
class A {
  set i(int value) => throw '';
}
''',
      r'''
@JS()
class A {}

extension A$Ext on A {
  set i(int value) => throw '';
}
''',
    );
  });

  test('non-abstract method', () async {
    await testGeneration(
      r'''
@JsName()
class A {
  String m() => '';
}
''',
      r'''
@JS()
class A {}

extension A$Ext on A {
  String m() => '';
}
''',
    );
  });

  test('rename field', () async {
    await testGeneration(
      r'''
@JsName()
class A {
  @JsName('b')
  String a;
}
''',
      r'''
@JS()
class A {}

extension A$Ext on A {
  String get a => getProperty(this, 'b');

  set a(String value) {
    setProperty(this, 'b', value);
  }
}
''',
    );
  });

  test('rename getter', () async {
    await testGeneration(
      r'''
@JsName()
class A {
  @JsName('b')
  String get a;
}
''',
      r'''
@JS()
class A {}

extension A$Ext on A {
  String get a => getProperty(this, 'b');
}
''',
    );
  });

  test('rename setter', () async {
    await testGeneration(
      r'''
@JsName()
class A {
  @JsName('b')
  set a(String value);
}
''',
      r'''
@JS()
class A {}

extension A$Ext on A {
  set a(String value) {
    setProperty(this, 'b', value);
  }
}
''',
    );
  });

  test('rename method', () async {
    await testGeneration(
      r'''
@JsName()
class A {
  @JsName('f')
  String _m();
}
''',
      r'''
@JS()
class A {}

extension A$Ext on A {
  String _m() => callMethod(this, 'f', []);
}
''',
    );
  });
}

Future<void> testGeneration(String input, String output) async {
  final srcs = {
    'js|lib/js.dart':'''
library js;
export 'dart:js' show allowInterop, allowInteropCaptureThis;
class JS {
  final String name;
  const JS([this.name]);
}
class _Anonymous {
  const _Anonymous();
}
const _Anonymous anonymous = _Anonymous();
''',
    'js_wrapping|lib/js_wrapping.dart': r'''
library js_wrapping;
export 'package:js/js.dart';
export 'package:js/js_util.dart';
class JsName {
  const JsName([this.name]);
  final String name;
}
const $js = Object();
''',
    '$_pkgName|lib/test_lib.dart': '''
import 'package:js_wrapping/js_wrapping.dart';
$input
  ''',
  };
  final builder =
      LibraryBuilder(JsWrappingGenerator(), generatedExtension: '.js.g.dart');

  await testBuilder(
    builder,
    srcs,
    generateFor: {'$_pkgName|lib/test_lib.dart'},
    outputs: {
      '$_pkgName|lib/test_lib.js.g.dart': decodedMatches('''
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// JsWrappingGenerator
// **************************************************************************

import 'package:js_wrapping/js_wrapping.dart';

${output.trim()}
'''),
    },
  );
}

// Ensure every test gets its own unique package name
String get _pkgName => 'pkg$_pkgCacheCount';
int _pkgCacheCount = 1;
