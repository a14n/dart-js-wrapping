library tests;

import 'dart:html';
import 'dart:json';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';

import 'package:js/js.dart' as js;
import 'package:js_wrap/js_wrap.dart' as jsw;

abstract class _Person {
  String get firstname;
  set firstname(String firstname);

  String sayHello();
}
class Person extends jsw.TypedProxy implements _Person {
  Person(String firstname,  String lastname) : super(js.context.Person, [firstname, lastname]);
}

main() {
  useHtmlConfiguration();

  test('attribute access', () {
    js.scoped(() {
      final john = new Person('John', 'Doe');
      expect(john.firstname, equals('John'));
      expect(john['firstname'], equals('John'));
      john.firstname = 'Joe';
      expect(john.firstname, equals('Joe'));
      expect(john['firstname'], equals('Joe'));
      john['firstname'] = 'John';
      expect(john.firstname, equals('John'));
      expect(john['firstname'], equals('John'));
    });
  });

  test('function call', () {
    js.scoped(() {
      final john = new Person('John', 'Doe');
      expect(john.sayHello(), equals("Hello, I'm John Doe"));
    });
  });
}
