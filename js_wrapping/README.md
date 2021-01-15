# Dart Js Wrapping

This package allows developers to define well-typed interfaces for JavaScript
objects. Typed JavaScript Interfaces are classes
that describes a JavaScript object and have a well-defined Dart API, complete
with type annotations, constructors, even optional and named parameters.

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
@JsName()
abstract class LatLng {
  factory LatLng(num lat, num lng, [bool noWrap]) => $js;

  bool equals(LatLng other);
  num get lat => _lat();
  @JsName('lat')
  num _lat();
  num get lng => _lng();
  @JsName('lng')
  num _lng();
  String toString();
  String toUrlValue([num precision]);
}
```

Once the generator executed you will be able to use a `LatLng` that wraps a js `LatLng`.

## Configuration and Initialization

### Adding the dependency

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  js_wrapping: ^0.6.0
dev_dependencies:
  js_wrapping_generator: ^0.6.0
```

### Running the generator

See the [Running generators section of the source_gen package](https://github.com/dart-lang/source_gen#running-generators).

## Usage

**Warning: The API is still changing rapidly. Not for the faint of heart**

### Defining Typed JavaScript Interfaces

To create a Typed JavaScript Interface you will start by creating a class marked with `@JsName()`. It will be the template used to create a js interface.

```dart
@JS('google.maps')
library google_maps.sample.simple;

import 'package:js_wrapping/js_wrapping.dart';

@JsName()
abstract class LatLng {
  factory LatLng(num lat, num lng, [bool noWrap]) => $js;

  bool equals(LatLng other);
  num get lat => _lat();
  @JsName('lat')
  num _lat();
  num get lng => _lng();
  @JsName('lng')
  num _lng();
  String toString();
  String toUrlValue([num precision]);
}
```

The generator will provide a new library `mylib.g.dart` containing :

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// JsWrappingGenerator
// **************************************************************************

// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

@JS('google.maps')
library google_maps.sample.simple;

import 'package:js_wrapping/js_wrapping.dart';

@JS()
class LatLng {
  external LatLng(num lat, num lng, [bool noWrap]);

  external bool equals(LatLng other);

  external String toString();

  external String toUrlValue([num precision]);
}

extension LatLng$Ext on LatLng {
  num get lat => _lat();
  num get lng => _lng();

  num _lat() => callMethod(this, 'lat', []);

  num _lng() => callMethod(this, 'lng', []);
}
```

### Constructors to create js object

If `LatLng` is a js object/function you can create a new instance in js with
`LatLng()`. To make it possible to create such js instance from the Dart-side
you have to define a `factory` constructor:

```dart
@JsName()
abstract class LatLng {
  factory LatLng(num lat, num lng, [bool noWrap]) => $js;
}
```

This will provide:

```dart
@JS()
class LatLng {
  external LatLng(num lat, num lng, [bool noWrap]);
}
```

It's now possible to instantiate js object from Dart with `LatLng()`.

### Properties and accessors

Properties or abstract getters/setters can be added to the class and
will generate getters and setters to access to the properties of the underlying
js object.

```dart
@JsName()
abstract class Person {
  factory Person() => $js;
  String firstname, lastname;
  int get age;
  void set email(String email);
}
```

This will provide:

```dart
@JS()
class Person {
  external Person();
  external String get firstname;
  external set firstname(String value);
  external String get lastname;
  external set lastname(String value);
  external int get age;
  external void set email(String email);
}
```

### Methods

The abstract methods will be implemented the same way :

```dart
@JsName()
abstract class Person {
  factory Person() => $js;
  String sayHelloTo(String other);
  void fall();
}
```

This will provide:

```dart
@JS()
class Person {
  external Person();

  external String sayHelloTo(String other);

  external void fall();
}
```

### Names used

#### constructors

You can override this name by providing a  `JsName('MyClassName')` on the class.

```dart
@JsName('People')
abstract class Person {
  factory Person() => $js;
  String sayHelloTo(Person other);
  Person get father;
}
```

#### members

You can override this name by providing a `JsName('myMemberName')` on the member.

```dart
@JsName()
abstract class Person {
  @JsName('daddy') Person get father;
}
```

### Tips & Tricks

#### anonymous objects

It's common to instantiate anonymous Js object. If your private classe maps an
anonymous object you can add `@anonymous` on it.

```dart
@JsName()
@anonymous
abstract class Foo {
  factory Foo() => $js;
}
```

This generates:

```dart
@JS()
@anonymous
class Foo {
  external factory Foo();
}
```

#### create getter from method

If a js object as a `getXxx()` function you would like to map on the dart side
with a `get xxx` you can do something like that:

```dart
abstract class Person {
  String get firstname => _getFirstname();
  String _getFirstname();
}
@JsName()
abstract class Person {
  factory Person() => $js;

  String get firstname => _getFirstname();
  @JsName('getFirstname')
  String _getFirstname();
}
```

This can be applied to any redirection you'd like to do.
