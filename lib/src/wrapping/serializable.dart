// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of js_wrapping;

/// Marker class used to indicate it is serializable to js. If a class is a
/// [Serializable] the `$unsafe` method will be called and the result will be used
/// as value.
abstract class Serializable<T> {
  static $unwrap(Serializable v) => v == null ? null : v.$unsafe;

  T get $unsafe;
}
