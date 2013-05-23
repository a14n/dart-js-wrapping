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
  });

  test('methods', () {
    final code = r'''
@wrapper class Person extends jsw.TypedProxy {
  String m1();
  void m2();
  m3();
  Person m4();
  List<Person> m5();
}
''';
      expect(transform(code), r'''
class Person extends jsw.TypedProxy {
  static Person cast(js.Proxy proxy) => proxy == null ? null : new Person.fromProxy(proxy);
  Person.fromProxy(js.Proxy proxy) : super.fromProxy(proxy);
  String m1() => $unsafe.m1();
  void m2() { $unsafe.m2(); }
  m3() => $unsafe.m3();
  Person m4() => Person.cast($unsafe.m4());
  List<Person> m5() => jsw.JsArrayToListAdapter.castListOfSerializables($unsafe.m5(), Person.cast);
}
''');
  });
}
