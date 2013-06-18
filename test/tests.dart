import 'dart:io';

import 'package:js_wrapping/generator.dart';
import 'package:unittest/unittest.dart';

main() {
  group('@wrapper', () {
    test('with simple class', () => _runTest('01'));
    test('with simple abstract class', () => _runTest('02'));
    test('with simple abstract class with @keepAbstract', () => _runTest('03'));
    test('with class already extending', () => _runTest('04'));
    test('with class with already undefined cast', () => _runTest('05'));
    test('with class with already custom cast', () => _runTest('06'));
    test('with class with already custom constructor', () => _runTest('07'));
  });

  test('methods', () => _runTest('08'));
  test('fields', () => _runTest('09'));
  test('@forMethods on class', () => _runTest('10'));
  test('@generate', () => _runTest('11'));
}

_runTest(String name) {
  final result = new File("test_${name}_result.dart");
  try {
    if (result.existsSync()) result.deleteSync();
    result.createSync();
    transformFile(new File("test_${name}.dart"), result);
    expect(result.readAsStringSync(), new File("test_${name}_expect.dart").readAsStringSync());
  } finally {
    if (result.existsSync()) result.deleteSync();
  }
}