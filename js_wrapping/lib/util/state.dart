// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

library js_wrapping.util.state;

import 'package:js_wrapping/js_wrapping.dart';

final _state = Expando<Map<Symbol, dynamic>>();

/// Returns the dart state associated with a [JsObject] and all its
/// [JsInterface]s.
///
/// This is useful when you need to have some data on the [JsInterface]. As you
/// can have several instances of [JsInterface] for the same [JsObject] the
/// state is actually store onto the [JsObject].
///
/// It takes [JsInterface] or [JsObject] as parameter.
Map<Symbol, dynamic> getState(/*JsInterface|JsObject*/ o) {
  final object = o is JsInterface ? asJsObject(o) : o;
  return _state[object] ??= <Symbol, dynamic>{};
}
