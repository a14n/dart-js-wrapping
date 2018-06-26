// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

library js_wrapping.adapter.list;

import 'dart:convert';
import 'dart:collection';
import 'dart:js';

import 'package:js_wrapping/js_wrapping.dart' show JsInterface;

import '../util/codec.dart';

/// A [List] interface wrapper for [JsArray]s.
///
/// Elements of this list are automatically converted to JavaScript with the
/// [Codec] provided when building the instance.
class JsList<E> extends JsInterface with ListMixin<E> {
  final JsArray _o;
  final Codec<E, dynamic> _codec;

  /// Creates an instance backed by a new JavaScript Array.
  JsList(Codec<E, dynamic> codec) : this.created(new JsArray(), codec);

  /// Creates an instance backed by the JavaScript object [o].
  JsList.created(JsArray o, Codec<E, dynamic> codec)
      : _o = o,
        _codec = codec ?? new IdentityCodec(),
        super.created(o);

  @override
  int get length => _o.length;

  @override
  void set length(int length) {
    _o.length = length;
  }

  @override
  E operator [](index) => _codec.decode(_o[index]);

  @override
  void operator []=(int index, E value) {
    _o[index] = _codec.encode(value);
  }

  @override
  void add(E value) {
    _o.add(_codec.encode(value));
  }

  @override
  void addAll(Iterable<E> iterable) {
    _o.addAll(iterable.map(_codec.encode));
  }

  @override
  void sort([int compare(E a, E b)]) {
    final sortedList = toList()..sort(compare);
    setRange(0, sortedList.length, sortedList);
  }

  @override
  void insert(int index, E element) {
    _o.insert(index, _codec.encode(element));
  }

  @override
  E removeAt(int index) => _codec.decode(_o.removeAt(index));

  @override
  E removeLast() => _codec.decode(_o.removeLast());

  @override
  void setRange(int start, int end, Iterable<E> iterable, [int startFrom = 0]) {
    _o.setRange(start, end, iterable.map(_codec.encode), startFrom);
  }

  @override
  void removeRange(int start, int end) {
    _o.removeRange(start, end);
  }
}
