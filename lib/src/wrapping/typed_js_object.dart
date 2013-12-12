// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of js_wrapping;

/// base class to wrap a [JsObject] in a strong typed object.
class TypedJsObject implements Serializable<JsObject> {
  final JsObject $unsafe;

  TypedJsObject([JsFunction function, List args])
      : this.fromJsObject(new JsObject(
            function != null ? function : context['Object'],
            args != null ? args : []));
  TypedJsObject.fromJsObject(this.$unsafe);
}
