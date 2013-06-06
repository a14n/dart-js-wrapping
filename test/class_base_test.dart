import 'package:js_wrapper_generator/js_wrapper_generator.dart';
import 'package:unittest/unittest.dart';

main() {
  group('@wrapper', () {
    test('with simple class', () {
      final code = r'''
@wrapper class Person {
}
''';
      expect(transform(code), r'''
class Person extends jsw.TypedProxy {
  static Person cast(js.Proxy proxy) => proxy == null ? null : new Person.fromProxy(proxy);
  Person.fromProxy(js.Proxy proxy) : super.fromProxy(proxy);
}
''');
    });

    test('with simple abstract class', () {
      final code = r'''
@wrapper abstract class Person {
}
''';
      expect(transform(code), r'''
class Person extends jsw.TypedProxy {
  static Person cast(js.Proxy proxy) => proxy == null ? null : new Person.fromProxy(proxy);
  Person.fromProxy(js.Proxy proxy) : super.fromProxy(proxy);
}
''');
    });

    test('with simple abstract class with @keepAbstract', () {
      final code = r'''
@wrapper @keepAbstract abstract class Person {
}
''';
      expect(transform(code), r'''
abstract class Person extends jsw.TypedProxy {
  static Person cast(js.Proxy proxy) => proxy == null ? null : new Person.fromProxy(proxy);
  Person.fromProxy(js.Proxy proxy) : super.fromProxy(proxy);
}
''');
    });

    test('with class already extending', () {
      final code = r'''
@wrapper class Person extends jsw.TypedProxy {
}
''';
      expect(transform(code), r'''
class Person extends jsw.TypedProxy {
  static Person cast(js.Proxy proxy) => proxy == null ? null : new Person.fromProxy(proxy);
  Person.fromProxy(js.Proxy proxy) : super.fromProxy(proxy);
}
''');
    });

    test('with class with already undefined cast', () {
      final code = r'''
@wrapper abstract class Person extends jsw.TypedProxy {
  static Person cast(js.Proxy proxy) => null;
}
''';
      expect(transform(code), r'''
class Person extends jsw.TypedProxy {
  static Person cast(js.Proxy proxy) => proxy == null ? null : new Person.fromProxy(proxy);
  Person.fromProxy(js.Proxy proxy) : super.fromProxy(proxy);
  }
''');
    });

    test('with class with already custom cast', () {
      final code = r'''
@wrapper abstract class Person extends jsw.TypedProxy {
  @customCast static Person cast(js.Proxy proxy) => null;
}
''';
      expect(transform(code), r'''
class Person extends jsw.TypedProxy {
  static Person cast(js.Proxy proxy) => null;
}
''');
    });
  });

  test('methods', () {
    final code = r'''
@wrapper class Person extends jsw.TypedProxy {
  set s1(String value);
  set s2(Person value);
  String get g1;
  Person get g2;
  List<Person> get g3;
  List<String> get g4;
  List get g5;
  String m1();
  void m2();
  m3();
  Person m4();
  List<Person> m5();
  void m6(List l);
}
''';
      expect(transform(code), r'''
class Person extends jsw.TypedProxy {
  static Person cast(js.Proxy proxy) => proxy == null ? null : new Person.fromProxy(proxy);
  Person.fromProxy(js.Proxy proxy) : super.fromProxy(proxy);
  set s1(String value) => $unsafe['s1'] = value;
  set s2(Person value) => $unsafe['s2'] = value;
  String get g1 => $unsafe['g1'];
  Person get g2 => Person.cast($unsafe['g2']);
  List<Person> get g3 => jsw.JsArrayToListAdapter.castListOfSerializables($unsafe['g3'], Person.cast);
  List<String> get g4 => jsw.JsArrayToListAdapter.cast($unsafe['g4']);
  List get g5 => jsw.JsArrayToListAdapter.cast($unsafe['g5']);
  String m1() => $unsafe.m1();
  void m2() { $unsafe.m2(); }
  m3() => $unsafe.m3();
  Person m4() => Person.cast($unsafe.m4());
  List<Person> m5() => jsw.JsArrayToListAdapter.castListOfSerializables($unsafe.m5(), Person.cast);
  void m6(List l) { $unsafe.m6(l is js.Serializable<js.Proxy> ? l : js.array(l)); }
}
''');
  });

  test('fields', () {
    final code = r'''
@wrapper class Person extends jsw.TypedProxy {
  String f1;
  @forMethods String f2;
  String f3, f4;
  Person f5;
  List<Person> f6;
  List<String> f7;
  List f8;
}
''';
      expect(transform(code), r'''
class Person extends jsw.TypedProxy {
  static Person cast(js.Proxy proxy) => proxy == null ? null : new Person.fromProxy(proxy);
  Person.fromProxy(js.Proxy proxy) : super.fromProxy(proxy);
  set f1(String f1) => $unsafe['f1'] = f1;
String get f1 => $unsafe['f1'];
set f2(String f2) => $unsafe.setF2(f2);
String get f2 => $unsafe.getF2();
set f3(String f3) => $unsafe['f3'] = f3;
String get f3 => $unsafe['f3'];
set f4(String f4) => $unsafe['f4'] = f4;
String get f4 => $unsafe['f4'];
set f5(Person f5) => $unsafe['f5'] = f5;
Person get f5 => Person.cast($unsafe['f5']);
set f6(List<Person> f6) => $unsafe['f6'] = f6 is js.Serializable<js.Proxy> ? f6 : js.array(f6);
List<Person> get f6 => jsw.JsArrayToListAdapter.castListOfSerializables($unsafe['f6'], Person.cast);
set f7(List<String> f7) => $unsafe['f7'] = f7 is js.Serializable<js.Proxy> ? f7 : js.array(f7);
List<String> get f7 => jsw.JsArrayToListAdapter.cast($unsafe['f7']);
set f8(List f8) => $unsafe['f8'] = f8 is js.Serializable<js.Proxy> ? f8 : js.array(f8);
List get f8 => jsw.JsArrayToListAdapter.cast($unsafe['f8']);
}
''');
  });

  test('@forMethods on class', () {
    final code = r'''
@wrapper @forMethods class Person extends jsw.TypedProxy {
  String f1;
  set s1(String value);
  Person get g1;
}
''';
      expect(transform(code), r'''
class Person extends jsw.TypedProxy {
  static Person cast(js.Proxy proxy) => proxy == null ? null : new Person.fromProxy(proxy);
  Person.fromProxy(js.Proxy proxy) : super.fromProxy(proxy);
  set f1(String f1) => $unsafe.setF1(f1);
String get f1 => $unsafe.getF1();
set s1(String value) => $unsafe.setS1(value);
  Person get g1 => Person.cast($unsafe.getG1());
}
''');
  });

}
