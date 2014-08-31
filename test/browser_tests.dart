library tests;

import 'dart:js' as js;

import 'package:js_wrapping/js_wrapping.dart' as jsw;
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';

class Person extends jsw.TypedJsObject {
  static Person $wrap(js.JsObject jsObject) => jsObject == null ? null : new Person.fromJsObject(jsObject);

  Person(String firstname,  String lastname) : super(js.context['Person'], [firstname, lastname]);
  Person.fromJsObject(js.JsObject proxy) : super.fromJsObject(proxy);

  set firstname(String firstname) => $unsafe['firstname'] = firstname;
  String get firstname => $unsafe['firstname'];

  List<Person> get children => jsw.TypedJsArray.$wrapSerializables($unsafe['children'], Person.$wrap);
  set father(Person father) => $unsafe['father'] = father.$unsafe;
  Person get father => Person.$wrap($unsafe['father']);

  String sayHello() => $unsafe.callMethod('sayHello');
}

class Color extends jsw.IsEnum<String> {
  static final _FINDER = new jsw.EnumFinder<String, Color>([RED, BLUE]);
  static Color $wrap(String jsValue) => _FINDER.find(jsValue);

  static final RED = new Color._("red");
  static final BLUE = new Color._("blue");

  Color._(String value) : super(value);
}

main() {
  useHtmlConfiguration();

  test('TypedJsObject', () {
    final john = new Person('John', 'Doe');
    expect(john.firstname, equals('John'));
    john.firstname = 'Joe';
    expect(john.firstname, equals('Joe'));
  });

  test('function call', () {
    final john = new Person('John', 'Doe');
    expect(john.sayHello(), equals("Hello, I'm John Doe"));
  });

  test('jsify', () {
    final john = new Person('John', 'Doe')
      ..children.add(new Person('Jack', 'Doe'));
    js.context['a'] = jsw.jsify({'b' : john, 'c': [john, {'d': Color.RED}]});
    expect(js.context['a']['b']['firstname'], equals('John'));
    expect(js.context['a']['b']['lastname'], equals('Doe'));
    expect(js.context['a']['c'][0]['firstname'], equals('John'));
    expect(js.context['a']['c'][0]['lastname'], equals('Doe'));
    expect(js.context['a']['c'][0]['children'][0]['firstname'], equals('Jack'));
    expect(js.context['a']['c'][1]['d'], equals('red'));
  });

  test('JsDateToDateTimeAdapter', () {
    final date = new DateTime.now();
    final jsDate = new jsw.JsDateToDateTimeAdapter(date);
    expect(jsDate.millisecondsSinceEpoch,
        equals(date.millisecondsSinceEpoch));
    jsDate.$unsafe.callMethod('setFullYear', [2000]);
    expect(jsDate.year, equals(2000));
  });

  group('TypedJsArray', () {
    test('iterator', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(
          new js.JsObject.jsify(["e0", "e1", "e2"]));

      final iterator = m.iterator;
      iterator.moveNext();
      expect(iterator.current, equals("e0"));
      iterator.moveNext();
      expect(iterator.current, equals("e1"));
      iterator.moveNext();
      expect(iterator.current, equals("e2"));
    });

    test('get length', () {
      final m1 = new jsw.TypedJsArray<String>.fromJsObject(new js.JsObject.jsify([]));
      expect(m1.length, equals(0));
      final m2 = new jsw.TypedJsArray<String>.fromJsObject(
          new js.JsObject.jsify(["a", "b"]));
      expect(m2.length, equals(2));
    });

    test('add', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(new js.JsObject.jsify([]));
      expect(m.length, equals(0));
      m.add("a");
      expect(m.length, equals(1));
      expect(m[0], equals("a"));
      m.add("b");
      expect(m.length, equals(2));
      expect(m[0], equals("a"));
      expect(m[1], equals("b"));
    });

    test('clear', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(new js.JsObject.jsify(["a", "b"]));
      expect(m.length, equals(2));
      m.clear();
      expect(m.length, equals(0));
    });

    test('remove', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(new js.JsObject.jsify(["a", "b"]));
      expect(m.length, equals(2));
      m.remove("a");
      expect(m.length, equals(1));
      expect(m[0], equals("b"));
    });

    test('operator []', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(new js.JsObject.jsify(["a", "b"]));
      expect(() => m[-1], throwsA(isRangeError));
      expect(() => m[2], throwsA(isRangeError));
      expect(m[0], equals("a"));
      expect(m[1], equals("b"));
    });

    test('operator []=', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(new js.JsObject.jsify(["a", "b"]));
      expect(() => m[-1] = "c", throwsA(isRangeError));
      expect(() => m[2] = "c", throwsA(isRangeError));
      m[0] = "d";
      m[1] = "e";
      expect(m[0], equals("d"));
      expect(m[1], equals("e"));
    });

    test('set length', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(new js.JsObject.jsify(["a", "b"]));
      m.length = 10;
      expect(m.length, equals(10));
      expect(m[5], equals(null));
      m.length = 1;
      expect(m.length, equals(1));
      expect(m[0], equals("a"));
    });

    test('sort', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(
          new js.JsObject.jsify(["c", "a", "b"]));
      m.sort();
      expect(m.length, equals(3));
      expect(m[0], equals("a"));
      expect(m[1], equals("b"));
      expect(m[2], equals("c"));
    });

    test('insert', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(
          new js.JsObject.jsify(["a", "b", "c"]));
      m.insert(1, "d");
      expect(m.length, equals(4));
      expect(m[0], equals("a"));
      expect(m[1], equals("d"));
      expect(m[2], equals("b"));
      expect(m[3], equals("c"));
    });

    test('removeAt', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(
          new js.JsObject.jsify(["a", "b", "c"]));
      expect(m.removeAt(1), equals("b"));
      expect(m.length, equals(2));
      expect(m[0], equals("a"));
      expect(m[1], equals("c"));
      expect(() => m.removeAt(2), throwsA(isRangeError));
    });

    test('removeLast', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(
          new js.JsObject.jsify(["a", "b", "c", null]));
      expect(m.removeLast(), isNull);
      expect(m.removeLast(), equals("c"));
      expect(m.removeLast(), equals("b"));
      expect(m.removeLast(), equals("a"));
      expect(m.length, equals(0));
    });

    test('sublist', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(
          new js.JsObject.jsify(["a", "b", "c", null]));
      final sl1 = m.sublist(2);
      expect(sl1.length, equals(2));
      expect(sl1[0], equals("c"));
      expect(sl1[1], isNull);
      final sl2 = m.sublist(1, 3);
      expect(sl2.length, equals(2));
      expect(sl2[0], equals("b"));
      expect(sl2[1], equals("c"));
    });

    test('setRange', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(
          new js.JsObject.jsify(["a", "b", "c", null]));
      m.setRange(1, 2, [null, null]);
      expect(m.length, equals(4));
      expect(m[0], equals("a"));
      expect(m[1], isNull);
      expect(m[2], isNull);
      expect(m[3], isNull);
      m.setRange(3, 1, [null, "c", null], 1);
      expect(m[0], equals("a"));
      expect(m[1], isNull);
      expect(m[2], isNull);
      expect(m[3], equals("c"));
    });

    test('removeRange', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(
          new js.JsObject.jsify(["a", "b", "c", null]));
      m.removeRange(1, 3);
      expect(m.length, equals(2));
      expect(m[0], equals("a"));
      expect(m[1], isNull);
    });

    test('bidirectionnal serialization of Proxy', () {
      js.context['myArray'] = new js.JsObject.jsify([]);
      final myList = new jsw.TypedJsArray<Person>.fromJsObject(
          js.context['myArray'], wrap: Person.$wrap, unwrap: jsw.Serializable.$unwrap);

      myList.add(new Person('John', 'Doe'));
      myList.add(null);
      expect(myList[0].firstname, 'John');
      expect(myList[1], isNull);
    });

    test('family', () {
      final father = new Person("John", "Doe");
      final child1 = new Person("Lewis", "Doe")
        ..father = father;
      final child2 = new Person("Andy", "Doe")
        ..father = father;
      father.children.addAll([child1, child2]);
      expect(father.children.length, 2);
      expect(father.children.map((p) => p.firstname).join(","), "Lewis,Andy");
      expect(child1.father.firstname, "John");
    });

    test('bidirectionnal serialization of Serializable', () {
      js.context['myArray'] = new js.JsObject.jsify([]);
      final myList = new jsw.TypedJsArray<Color>.fromJsObject(
          js.context['myArray'], wrap: Color.$wrap, unwrap: jsw.Serializable.$unwrap);
      myList.add(Color.BLUE);
      myList.add(null);
      expect(myList[0], Color.BLUE);
      expect(myList[1], isNull);
    });
  });

  group('JsObjectToMapAdapter', () {
    test('get keys', () {
      final m = new jsw.TypedJsMap<int>.fromJsObject(
          new js.JsObject.jsify({"a": 1, "b": 2}));
      final keys = m.keys;
      expect(keys.length, equals(2));
      expect(keys, contains("a"));
      expect(keys, contains("b"));
    });

    test('containsKey', () {
      final m = new jsw.TypedJsMap.fromJsObject(new js.JsObject.jsify({"a": 1, "b": "c"}));
      expect(m.containsKey("a"), equals(true));
      expect(m.containsKey("d"), equals(false));
    });

    test('operator []', () {
      final m = new jsw.TypedJsMap.fromJsObject(new js.JsObject.jsify({"a": 1, "b": "c"}));
      expect(m["a"], equals(1));
      expect(m["b"], equals("c"));
    });

    test('operator []=', () {
      final m = new jsw.TypedJsMap.fromJsObject(new js.JsObject.jsify({}));
      m["a"] = 1;
      expect(m["a"], equals(1));
      expect(m.length, equals(1));
      m["b"] = "c";
      expect(m["b"], equals("c"));
      expect(m.length, equals(2));
    });

    test('remove', () {
      final m = new jsw.TypedJsMap.fromJsObject(
          new js.JsObject.jsify({"a": 1, "b": "c"}));
      expect(m.remove("a"), equals(1));
      expect(m["b"], equals("c"));
      expect(m.length, equals(1));
    });

    test('bidirectionnal serialization of Proxy', () {
      final myMap = new jsw.TypedJsMap<Person>.fromJsObject(
          new js.JsObject.jsify({}), wrap: Person.$wrap, unwrap: jsw.Serializable.$unwrap);
      myMap["a"] = new Person('John', 'Doe');
      expect(myMap["a"].firstname, 'John');
    });

    test('toString', () {
      final m = new jsw.TypedJsMap<int>.fromJsObject(
          new js.JsObject.jsify({"a": 1, "b": 2}));
      final string = m.toString();
      expect(string, equals("{a: 1, b: 2}"));
    });
  });
}
