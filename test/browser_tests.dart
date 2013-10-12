library tests;

import 'dart:js' as js;
import 'package:js_wrapping/js_wrapping.dart' as jsw;
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';

abstract class _Person {
  String firstname;

  String sayHello();
}

class PersonTP extends jsw.TypedJsObject {
  static PersonTP cast(js.JsObject proxy) => proxy == null ? null :
      new PersonTP.fromJsObject(proxy);

  PersonTP(String firstname,  String lastname) :
      super(js.context['Person'], [firstname, lastname]);
  PersonTP.fromJsObject(js.JsObject proxy) : super.fromJsObject(proxy);

  set firstname(String firstname) => $unsafe['firstname'] = firstname;
  String get firstname => $unsafe['firstname'];

  List<PersonTP> get children =>
      jsw.TypedJsArray.castListOfSerializables($unsafe['children'],
          PersonTP.cast);
  set father(PersonTP father) => $unsafe['father'] = father;
  PersonTP get father => PersonTP.cast($unsafe['father']);

  String sayHello() => $unsafe.callMethod('sayHello');
}

class Color implements js.Serializable<String> {
  static final RED = new Color._("red");
  static final BLUE = new Color._("blue");

  final String _value;

  Color._(this._value);

  String toJs() => this._value;
  operator ==(Color other) => this._value == other._value;
}

main() {
  useHtmlConfiguration();

  test('TypedJsObject', () {
    final john = new PersonTP('John', 'Doe');
    expect(john.firstname, equals('John'));
    john.firstname = 'Joe';
    expect(john.firstname, equals('Joe'));
  });

  test('function call', () {
    final john = new PersonTP('John', 'Doe');
    expect(john.sayHello(), equals("Hello, I'm John Doe"));
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
          js.jsify(["e0", "e1", "e2"]));

      final iterator = m.iterator;
      iterator.moveNext();
      expect(iterator.current, equals("e0"));
      iterator.moveNext();
      expect(iterator.current, equals("e1"));
      iterator.moveNext();
      expect(iterator.current, equals("e2"));
    });

    test('get length', () {
      final m1 = new jsw.TypedJsArray<String>.fromJsObject(js.jsify([]));
      expect(m1.length, equals(0));
      final m2 = new jsw.TypedJsArray<String>.fromJsObject(
          js.jsify(["a", "b"]));
      expect(m2.length, equals(2));
    });

    test('add', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(js.jsify([]));
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
      final m = new jsw.TypedJsArray<String>.fromJsObject(js.jsify(["a", "b"]));
      expect(m.length, equals(2));
      m.clear();
      expect(m.length, equals(0));
    });

    test('remove', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(js.jsify(["a", "b"]));
      expect(m.length, equals(2));
      m.remove("a");
      expect(m.length, equals(1));
      expect(m[0], equals("b"));
    });

    test('operator []', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(js.jsify(["a", "b"]));
      expect(() => m[-1], throwsA(isRangeError));
      expect(() => m[2], throwsA(isRangeError));
      expect(m[0], equals("a"));
      expect(m[1], equals("b"));
    });

    test('operator []=', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(js.jsify(["a", "b"]));
      expect(() => m[-1] = "c", throwsA(isRangeError));
      expect(() => m[2] = "c", throwsA(isRangeError));
      m[0] = "d";
      m[1] = "e";
      expect(m[0], equals("d"));
      expect(m[1], equals("e"));
    });

    test('set length', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(js.jsify(["a", "b"]));
      m.length = 10;
      expect(m.length, equals(10));
      expect(m[5], equals(null));
      m.length = 1;
      expect(m.length, equals(1));
      expect(m[0], equals("a"));
    });

    test('sort', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(
          js.jsify(["c", "a", "b"]));
      m.sort();
      expect(m.length, equals(3));
      expect(m[0], equals("a"));
      expect(m[1], equals("b"));
      expect(m[2], equals("c"));
    });

    test('insert', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(
          js.jsify(["a", "b", "c"]));
      m.insert(1, "d");
      expect(m.length, equals(4));
      expect(m[0], equals("a"));
      expect(m[1], equals("d"));
      expect(m[2], equals("b"));
      expect(m[3], equals("c"));
    });

    test('removeAt', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(
          js.jsify(["a", "b", "c"]));
      expect(m.removeAt(1), equals("b"));
      expect(m.length, equals(2));
      expect(m[0], equals("a"));
      expect(m[1], equals("c"));
      expect(() => m.removeAt(2), throwsA(isRangeError));
    });

    test('removeLast', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(
          js.jsify(["a", "b", "c", null]));
      expect(m.removeLast(), isNull);
      expect(m.removeLast(), equals("c"));
      expect(m.removeLast(), equals("b"));
      expect(m.removeLast(), equals("a"));
      expect(m.length, equals(0));
    });

    test('sublist', () {
      final m = new jsw.TypedJsArray<String>.fromJsObject(
          js.jsify(["a", "b", "c", null]));
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
          js.jsify(["a", "b", "c", null]));
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
          js.jsify(["a", "b", "c", null]));
      m.removeRange(1, 3);
      expect(m.length, equals(2));
      expect(m[0], equals("a"));
      expect(m[1], isNull);
    });

    test('bidirectionnal serialization of Proxy', () {
      js.context['myArray'] = js.jsify([]);
      final myList = new jsw.TypedJsArray<PersonTP>.fromJsObject(
          js.context['myArray'], new jsw.TranslatorForSerializable<PersonTP>(
              (p) => new PersonTP.fromJsObject(p)));

      myList.add(new PersonTP('John', 'Doe'));
      myList.add(null);
      expect(myList[0].firstname, 'John');
      expect(myList[1], isNull);
    });

    test('family', () {
      final father = new PersonTP("John", "Doe");
      final child1 = new PersonTP("Lewis", "Doe")
        ..father = father;
      final child2 = new PersonTP("Andy", "Doe")
        ..father = father;
      father.children.addAll([child1, child2]);
      expect(father.children.length, 2);
      expect(father.children.map((p) => p.firstname).join(","), "Lewis,Andy");
      expect(child1.father.firstname, "John");
    });

    test('bidirectionnal serialization of Serializable', () {
      js.context['myArray'] = js.jsify([]);
      final myList = new jsw.TypedJsArray<Color>.fromJsObject(
          js.context['myArray'],
          new jsw.Translator<Color>(
              (e) => e != null ? new Color._(e) : null,
              (e) => e != null ? e.toJs() : null
          )
      );
      myList.add(Color.BLUE);
      myList.add(null);
      expect(myList[0], Color.BLUE);
      expect(myList[1], isNull);
    });
  });

  group('JsObjectToMapAdapter', () {
    test('get keys', () {
      final m = new jsw.TypedJsMap<int>.fromJsObject(
          js.jsify({"a": 1, "b": 2}));
      final keys = m.keys;
      expect(keys.length, equals(2));
      expect(keys, contains("a"));
      expect(keys, contains("b"));
    });

    test('containsKey', () {
      final m = new jsw.TypedJsMap.fromJsObject(js.jsify({"a": 1, "b": "c"}));
      expect(m.containsKey("a"), equals(true));
      expect(m.containsKey("d"), equals(false));
    });

    test('operator []', () {
      final m = new jsw.TypedJsMap.fromJsObject(js.jsify({"a": 1, "b": "c"}));
      expect(m["a"], equals(1));
      expect(m["b"], equals("c"));
    });

    test('operator []=', () {
      final m = new jsw.TypedJsMap.fromJsObject(js.jsify({}));
      m["a"] = 1;
      expect(m["a"], equals(1));
      expect(m.length, equals(1));
      m["b"] = "c";
      expect(m["b"], equals("c"));
      expect(m.length, equals(2));
    });

    test('remove', () {
      final m = new jsw.TypedJsMap.fromJsObject(
          js.jsify({"a": 1, "b": "c"}));
      expect(m.remove("a"), equals(1));
      expect(m["b"], equals("c"));
      expect(m.length, equals(1));
    });

    test('bidirectionnal serialization of Proxy', () {
      final myMap = new jsw.TypedJsMap<PersonTP>.fromJsObject(
          js.jsify({}), new jsw.TranslatorForSerializable<PersonTP>((p) =>
              new PersonTP.fromJsObject(p)));
      myMap["a"] = new PersonTP('John', 'Doe');
      expect(myMap["a"].firstname, 'John');
    });
  });
}
