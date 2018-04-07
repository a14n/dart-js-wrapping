# Dart Js Wrapping

This package allows developers to define well-typed interfaces for JavaScript objects. Typed JavaScript Interfaces are classes
that describes a JavaScript object and have a well-defined Dart API, complete with type annotations, constructors, even optional
and named parameters.

## Writing Js wrapper

Here's a quick example to show the package in action.

Given a JS _class_ like :

```js
LatLng = function(lat, lng) {
  this.lat = lat;
  this.lng = lng;
}
LatLng.prototype.equals = function(other) {
  return this.lat === other.lat && this.lng === other.lng;
}
```

You can create a wrapper like :

```dart
// you define a private abstract class implementing/extending JsInterface
abstract class _LatLng implements JsInterface {

  // factories to create js objects
  factory _LatLng(num lat, num lng) => null;

  // uninitialized fields to bind to properties
  num lat, lng;

  // abstract methods to call Js methods
  bool equals(LatLng other);
}
```

Once the generator executed you will be able to use a `LatLng` that wraps a js `LatLng`.

## Configuration and Initialization

### Adding the dependency

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  js_wrapping: ^0.4.5
dev_dependencies:
  js_wrapping_generator: ^0.4.5
```

### Running the generator

See the [Running generators section of the source_gen package](https://github.com/dart-lang/source_gen#running-generators).

## Usage

**Warning: The API is still changing rapidly. Not for the faint of heart**

### Defining Typed JavaScript Interfaces

To create a Typed JavaScript Interface you will start by creating a private class that extends or implements `JsInterface`. It
will be the template used to create a really class that wrap the underlying JsObject.

```dart
import 'package:js_wrapping/js_wrapping.dart';

part 'mylib.g.dart'; // assuming the current file is 'mylib.dart'

abstract class _Foo implements JsInterface {
}
```

The generator will provide the part `mylib.g.dart` containing :

```dart
// **************************************************************************
// Generator: Instance of 'JsInterfaceGenerator'
// Target: abstract class _Foo
// **************************************************************************

class Foo extends JsInterface implements _Foo {
  Foo.created(JsObject o) : super.created(o);
}
```

The contructor `created` allows to wrap existing `JsObject`.

### Constructors to create js object

If `Foo` is a js object/function you can create a new instance in js with `new Foo()`. To make it possible to create such js
instance from the Dart-side you have to define a `factory` constructor:

```dart
abstract class _Foo implements JsInterface {
  factory _Foo() => null;
}
```

This will provide:

```dart
class Foo extends JsInterface implements _Foo {
  Foo.created(JsObject o) : super.created(o);
  Foo() : this.created(new JsObject(context['Foo']));
}
```

It's now possible to instantiate js object from Dart with `new Foo()`.

NB: You can also use named constructors.

### Properties and accessors

Properties or abstract getters/setters can be added to the private class and will generate getters and setters to access to the
properties of the underlying js object.

```dart
abstract class _Person implements JsInterface {
  String firstname, lastname;
  int get age;
  void set email(String email);
}
```

This will provide:

```dart
class Person extends JsInterface implements _Person {
  Person.created(JsObject o) : super.created(o);

  void set lastname(String _lastname) {
    asJsObject(this)['lastname'] = _lastname;
  }
  String get lastname => asJsObject(this)['lastname'];
  void set firstname(String _firstname) {
    asJsObject(this)['firstname'] = _firstname;
  }
  String get firstname => asJsObject(this)['firstname'];
  int get age => asJsObject(this)['age'];
  void set email(String email) {
    asJsObject(this)['email'] = email;
  }
}
```

NB: `asJsObject(this)` is used to get the underlying JsObject and perform operations on it.

### Methods

The abstract methods will be implemented the same way :

```dart
abstract class _Person implements JsInterface {
  String sayHelloTo(String other);
  void fall();
}
```

This will provide:

```dart
class Person extends JsInterface implements _Person {
  Person.created(JsObject o) : super.created(o);

  String sayHelloTo(String other) =>
      asJsObject(this).callMethod('sayHelloTo', [other]);
  void fall() {
    asJsObject(this).callMethod('fall');
  }
}
```

### Parameters types and return types

The generation relies on the type annotations provided. If you use a JsInterface as return type the generator will automatically
wrap the underlying js object in the indicated type. You are also allowed to use JsInterface as parameters.

For instance:

```dart
abstract class _Person implements JsInterface {
  String sayHelloTo(Person other);
  Person get father;
}
```

This will provide:

```dart
class Person extends JsInterface implements _Person {
  Person.created(JsObject o) : super.created(o);

  String sayHelloTo(Person other) =>
      asJsObject(this).callMethod('sayHelloTo', [__codec2.encode(other)]);
  Person get father => __codec2.decode(asJsObject(this)['father']);
}
/// codec for Person
final __codec2 = new JsInterfaceCodec<Person>((o) => new Person.created(o));
```

Note that in `sayHelloTo` `other` is unwrapped with `toJs` automatically. In `get father` a new `Person` object is created.

NB: returning `List`s and using them as parameters are also supported.

### Names used

#### constructors

By default the names used for object instantiation are the name minus the prepended `_`. Thus a class `_Foo` will use the js
function/class `Foo`. You can override this name by providing a  `JsName('MyClassName')` on the class.

```dart
@JsName('People')
abstract class _Person implements JsInterface {
  String sayHelloTo(Person other);
  Person get father;
}
```

#### members

By default the name used for the call is the member's name if public or the name minus the prepended `_` if private. Thus the
methods `m1()` and `_m1()` will use the same js function `m1`. You can override this name by providing a `JsName('myMemberName')`
on the member.

```dart
abstract class _Person implements JsInterface {
  @JsName('daddy') Person get father;
}
```

### Tips & Tricks

#### anonymous objects

It's common to instantiate anonymous Js object. If your private classe maps an anonymous object you can add `@anonymous` on it.

```dart
@anonymous
abstract class _Foo implements JsInterface {
  factory _Foo() => null;
}
```

This generates:

```dart
@anonymous
class Foo extends JsInterface implements _Foo {
  Foo.created(JsObject o) : super.created(o);
  Foo() : this.created(new JsObject(context['Object']));
}
```

Note the `context['Object']` used on creation.

#### create getter from method

If a js object as a `getXxx()` function you would like to map on the dart side with a `get xxx` you can do something like that:

```dart
abstract class _Person implements JsInterface {
  String get firstname => _getFirstname();
  String _getFirstname();
}
```

This can be applied to any redirection you'd like to do.

#### avoid to repeat a namespace on every classes

You can add a `JsName('my.namespace')` on your library. Thus every constructor will prepend the name of the class with this name.

```dart
@JsName('my.namespace')
library familly;
abstract class _Person implements JsInterface {
  factory _Person() => null;
}
```

This generates:

```dart
class Person extends JsInterface implements _Person {
  Person.created(JsObject o) : super.created(o);
  Person() : this.created(new JsObject(context['my']['namespace']['Person']));
}
```
