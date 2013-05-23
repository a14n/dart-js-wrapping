import 'package:js_wrapper_generator/js_wrapper_generator.dart';
import 'package:unittest/unittest.dart';

main() {
  test('non conflicting, in order edits', () {
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
}
