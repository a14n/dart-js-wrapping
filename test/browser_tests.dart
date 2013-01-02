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

  group('jsList', () {
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

        expect(() => myArray.length = 0, throws);
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

        final iterator = myArray.iterator();
        expect(iterator.next(), equals("e0"));
        expect(iterator.next(), equals("e1"));
        expect(iterator.next(), equals("e2"));

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

//    test('from dart list', () {
//      js.scoped(() {
//        final list = [new Date.now(), new Date.now(), new Date.now()];
//        final myArray = new jsw.JsArray<Date>(list);
//        js.context.console.log(myArray.$proxy.$jsProxy[0]);
//        print(myArray.$proxy.$jsProxy[0]);
//        expect(myArray.length, 3);
//        for (int i = 0; i < list.length; i++) {
//          expect(myArray[i], list[i]);
//        }
//      });
//    });
  });
}
