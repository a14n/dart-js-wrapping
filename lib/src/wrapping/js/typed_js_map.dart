// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of js_wrapping;

// TODO use jsObject.asDartMap()
class TypedJsMap<V> extends TypedJsObject implements Map<String,V> {
  static TypedJsMap cast(JsObject jsObject, [Translator translator]) =>
      jsObject == null ? null :
          new TypedJsMap.fromJsObject(jsObject, translator);
  static TypedJsMap castMapOfSerializables(JsObject jsObject,
      Mapper<dynamic, Serializable> fromJs, {mapOnlyNotNull: false}) =>
          jsObject == null ? null : new TypedJsMap.fromJsObject(jsObject,
              new TranslatorForSerializable(fromJs,
                  mapOnlyNotNull: mapOnlyNotNull));

  final Translator<V> _translator;

  TypedJsMap.fromJsObject(JsObject jsObject, [Translator<V> translator]) :
      super.fromJsObject(jsObject), this._translator = translator;

  @override V operator [](String key) => _fromJs($unsafe[key]);
  @override void operator []=(String key, V value) {
    $unsafe[key] = _toJs(value);
  }
  @override V remove(String key) {
    final value = this[key];
    $unsafe.deleteProperty(key);
    return value;
  }
  @override Iterable<String> get keys =>
      TypedJsArray.cast(context['Object'].keys($unsafe));

  // use Maps to implement functions
  @override bool containsValue(V value) => Maps.containsValue(this, value);
  @override bool containsKey(String key) =>
      context['Object'].keys($unsafe).indexOf(key) != -1;
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

  dynamic _toJs(V e) => _translator == null ? e : _translator.toJs(e);
  V _fromJs(dynamic value) => _translator == null ? value :
      _translator.fromJs(value);
}
