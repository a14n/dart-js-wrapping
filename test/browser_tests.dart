library tests;

import 'dart:html';
import 'dart:json';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';

import 'package:js/js.dart' as js;
import 'package:js_wrap/js_wrap.dart' as jsw;


abstract class _Person {
  String firstname;

  String sayHello();
}
class Person extends jsw.TypedProxy implements _Person {
  Person(String firstname,  String lastname) : super(js.context.Person, [firstname, lastname]);
  Person.fromJsProxy(js.Proxy jsProxy) : super.fromJsProxy(jsProxy);
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

  test('JsDate', () {
    js.scoped(() {
      final date = new Date.now();
      final jsDate = new jsw.JsDate(date);
      expect(jsDate.millisecondsSinceEpoch, equals(date.millisecondsSinceEpoch));
      jsDate.$proxy.setFullYear(2000);
      expect(jsDate.year, equals(2000));
    });
  });

  group('jsArray', () {
    test('operations', () {
      js.scoped(() {
        js.context.myArray = js.array([]);

        final myArray = new jsw.JsArray<String>.fromJsProxy(js.context.myArray);
        expect(myArray.length, equals(0));
        // []

        myArray.add("e0");
        expect(myArray.length, equals(1));
        expect(myArray[0], equals("e0"));
        // ["e0"]

        myArray.addAll(["e1", "e2"]);
        expect(myArray.length, equals(3));
        expect(myArray[0], equals("e0"));
        expect(myArray[1], equals("e1"));
        expect(myArray[2], equals("e2"));
        expect(myArray.first, equals("e0"));
        expect(myArray.last, equals("e2"));
        // ["e0", "e1", "e2"]

        myArray.length = 5;
        expect(myArray.length, equals(5));
        expect(myArray[0], equals("e0"));
        expect(myArray[1], equals("e1"));
        expect(myArray[2], equals("e2"));
        expect(myArray[3], isNull);
        expect(myArray[4], isNull);
        // ["e0", "e1", "e2", null, null]

        // TODO temporary disable : ".length=" is not call on MyArray :/
        //expect(() => myArray.length = 0, throws);
        expect(myArray.length, equals(5));
        // ["e0", "e1", "e2", null, null]

        myArray[3] = "e4";
        myArray[4] = "e3";
        expect(myArray.length, equals(5));
        expect(myArray[3], equals("e4"));
        expect(myArray[4], equals("e3"));
        // ["e0", "e1", "e2", "e4", "e3"]

        myArray.sort((String a, String b) => a.compareTo(b));
        expect(myArray.length, equals(5));
        expect(myArray[0], equals("e0"));
        expect(myArray[1], equals("e1"));
        expect(myArray[2], equals("e2"));
        expect(myArray[3], equals("e3"));
        expect(myArray[4], equals("e4"));
        // ["e0", "e1", "e2", "e3", "e4"]

        expect(myArray.removeAt(4), equals("e4"));
        expect(myArray.length, equals(4));
        expect(myArray[0], equals("e0"));
        expect(myArray[1], equals("e1"));
        expect(myArray[2], equals("e2"));
        expect(myArray[3], equals("e3"));
        // ["e0", "e1", "e2", "e3"]

        expect(myArray.removeLast(), equals("e3"));
        expect(myArray.length, equals(3));
        expect(myArray[0], equals("e0"));
        expect(myArray[1], equals("e1"));
        expect(myArray[2], equals("e2"));
        // ["e0", "e1", "e2"]

        final iterator = myArray.iterator;
        iterator.moveNext();
        expect(iterator.current, equals("e0"));
        iterator.moveNext();
        expect(iterator.current, equals("e1"));
        iterator.moveNext();
        expect(iterator.current, equals("e2"));

        myArray.clear();
        expect(myArray.length, equals(0));
        // []
      });
    });

    test('typing', () {
      js.scoped(() {
        js.context.myArray = js.array([]);
        js.context.myArray.push(new Person('John', 'Doe').$proxy.$jsProxy);

        final myArray = new jsw.JsArray<Person>.fromJsProxy(js.context.myArray, (e) => jsw.transformIfNotNull(e, (e) => new Person.fromJsProxy(e)));
        expect(myArray[0].firstname, 'John');
      });
    });
  });

  test('retain/release', () {
    Person john;
    js.scoped(() {
      john = new Person('John', 'Doe');
    });
    js.scoped((){
      expect(() => john.sayHello(), throws);
    });
    js.scoped(() {
      john = new Person('John', 'Doe');
      jsw.retain(john);
    });
    js.scoped((){
      expect(() => john.sayHello(), returnsNormally);
      jsw.release(john);
    });
    js.scoped((){
      expect(() => john.sayHello(), throws);
    });
  });

  test('callback', () {
    js.scoped(() {
      final context = new jsw.Proxy.fromJsProxy(js.context);
      context.myCallback = new jsw.Callback.once((String firstname, String lastname) => new Person(firstname, lastname));

      expect(new Person.fromJsProxy(context.myCallback('John', 'Doe')).firstname, 'John');
    });
  });
}
