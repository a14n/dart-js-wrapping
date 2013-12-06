// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of js_wrapping;

typedef T _Mapper<F, T>(F o);

class ToJsConverter extends Converter {
  convert(o) => o is Serializable ? o.$unsafe : o;
}

final TO_JS_CONVERTER = new ToJsConverter();

class SerializableEncoder<E extends Serializable<T>, T> extends Converter<E, T> {
  T convert(E s) => s == null ? null : s.$unsafe;
}

class SerializableDecoder<E extends Serializable<T>, T> extends Converter<T, E> {
  final _Mapper<T, E> _wrap;

  SerializableDecoder(this._wrap);

  E convert(T jsValue) => jsValue == null ? null : _wrap(jsValue);
}

class SerializableCodec<E extends Serializable<T>, T> extends Codec<E, T> {
  final Converter<E, T> encoder = new SerializableEncoder<E, T>();
  final Converter<T, E> decoder;

  SerializableCodec(_Mapper<T, E> _decode)
      : decoder = new SerializableDecoder<E, T>(_decode);
}

class TypedJsObjectCodec<E extends TypedJsObject> extends SerializableCodec<E, JsObject> {
  TypedJsObjectCodec(_Mapper<JsObject, E> _decode) : super(_decode);
}