// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of js_wrapping;

// TODO use jsObject.asDartMap()
class TypedJsMap<V> extends TypedJsObject implements Map<String,V> {
  static TypedJsMap $wrap(JsObject jsObject, {wrap(js), unwrap(dart)}) => jsObject == null ? null : new TypedJsMap.fromJsObject(jsObject, wrap: wrap, unwrap: unwrap);

  static TypedJsMap $wrapSerializables(JsObject jsObject, wrap(js)) => jsObject == null ? null : new TypedJsMap.fromJsObject(jsObject, wrap: wrap, unwrap: Serializable.$unwrap);

  final Mapper<V, dynamic> _unwrap;
  final Mapper<dynamic, V> _wrap;

  TypedJsMap.fromJsObject(JsObject jsObject, {Mapper<dynamic, V> wrap, Mapper<V, dynamic> unwrap})
      : _wrap = ((e) => wrap == null ? e : wrap(e)),
        _unwrap = ((e) => unwrap == null ? e : unwrap(e)),
        super.fromJsObject(jsObject);


  @override V operator [](String key) => _wrap($unsafe[key]);
  @override void operator []=(String key, V value) {
    $unsafe[key] = _unwrap(value);
  }
  @override V remove(String key) {
    final value = this[key];
    $unsafe.deleteProperty(key);
    return value;
  }
  @override Iterable<String> get keys =>
      context['Object'].callMethod('keys', [$unsafe]);

  // use Maps to implement functions
  @override bool containsValue(V value) => Maps.containsValue(this, value);
  @override bool containsKey(String key) => keys.contains(key);
  @override V putIfAbsent(String key, V ifAbsent()) =>
      Maps.putIfAbsent(this, key, ifAbsent);
  @override void addAll(Map<String, V> other) {
    if (other != null) {
      other.forEach((k,v) => this[k] = v);
    }
  }
  @override void clear() => Maps.clear(this);
  @override void forEach(void f(String key, V value)) => Maps.forEach(this, f);
  @override Iterable<V> get values => Maps.getValues(this);
  @override int get length => Maps.length(this);
  @override bool get isEmpty => Maps.isEmpty(this);
  @override bool get isNotEmpty => Maps.isNotEmpty(this);
  @override String toString() => Maps.mapToString(this);
}
