// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

/// The js library allows Dart library authors to define Dart interfaces for
/// JavaScript objects.
library js_wrapping;

export 'package:js/js.dart';
export 'package:js/js_util.dart';

/// A metadata annotation that allows to customize the name used for method call
/// or attribute access on the javascript side.
///
/// You can use it on libraries, classes, members.
class JsName {
  const JsName([this.name]);
  final String? name;
}

/// A placeholder for generation of factory contructors and static members.
T $js<T>() => const Object() as T;
