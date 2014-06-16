# Dart Js Wrapping

This project provides some base classes to simplify the creation of Dart libraries that wraps JS libraries.

Wrappers are based on _dart:js_. The main class is `TypedJsObject`.

## Example

Given a JS _class_ like :

```js
Person = function(name) {
  this.name = name;
}
Person.prototype.setAge = function(age) {
  this.age = age;
}
Person.prototype.getAge = function() {
  return this.age;
}
```

You can create a wrapper like :

```dart
import 'dart:js' as js;
class Person extends TypedJsObject {
  Person(String name) : super(js.context['Person'], [name]);

  set name(String name) => $unsafe['name'] = name;
  String get name => $unsafe['name'];
  set age(int age) => $unsafe.callMethod('setAge', [age]);
  int get age => $unsafe.callMethod('getAge');
}
```

## Generating wrappers

The [Dart Js Wrapping Generator](http://pub.dartlang.org/packages/js_wrapping_generator) can be used
to help generating the wrapper classes.

## License ##
Apache 2.0
