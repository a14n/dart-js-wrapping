// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

library js_wrapping.util.codec;

import 'dart:convert';

import 'package:js_wrapping/js_wrapping.dart';

export 'dart:convert' show Codec;

/// Determines a true or false value for a given input.
typedef Predicate<T> = bool Function(T o);

/// Provides a [T] object from [S].
typedef Factory<S, T> = T Function(S o);

/// A [Codec] that provides additionnal functions to ensure the encoded/decoded
/// values are supported.
class ConditionalCodec<S, T> extends Codec<S, T> {
  ConditionalCodec(
    Converter<S, T> encoder,
    Converter<T, S> decoder, {
    Predicate acceptEncodedValue,
    Predicate acceptDecodedValue,
  }) : this._(
          encoder,
          decoder,
          acceptEncodedValue != null ? acceptEncodedValue : (o) => o is T,
          acceptDecodedValue != null ? acceptDecodedValue : (o) => o is S,
        );

  ConditionalCodec._(
    this.encoder,
    this.decoder,
    this.acceptEncodedValue,
    this.acceptDecodedValue,
  ) //: assert(encoder != null),
  //assert(decoder != null),
  //assert(acceptEncodedValue != null),
  //assert(acceptDecodedValue != null)
  ;

  ConditionalCodec.fromFactories(
    Factory<S, T> encode,
    Factory<T, S> decode, {
    Predicate acceptEncodedValue,
    Predicate acceptDecodedValue,
  }) :
        //assert(encode != null),
        //assert(decode != null),
        this(
          _Converter<S, T>(encode),
          _Converter<T, S>(decode),
          acceptEncodedValue: acceptEncodedValue,
          acceptDecodedValue: acceptDecodedValue,
        );

  @override
  final Converter<S, T> encoder;
  @override
  final Converter<T, S> decoder;

  /// Only use by ChainedCodec to know if the value need to go to the next codec
  final Predicate<Object> acceptEncodedValue;

  /// Only use by ChainedCodec to know if the value need to go to the next codec
  final Predicate<Object> acceptDecodedValue;
}

class _Converter<S, T> extends Converter<S, T> {
  final Factory<S, T> _factory;

  _Converter(this._factory);

  @override
  T convert(S input) => input == null ? null : _factory(input);
}

/// A [ConditionalCodec] that accepts only [T] values and does not do any
/// transformations.
class IdentityCodec<T> extends ConditionalCodec<T, T> {
  IdentityCodec() : super.fromFactories((o) => o, (o) => o);
}

/// A [ConditionalCodec] that accepts any values and apply [asJs] for encoding.
class DynamicCodec extends ConditionalCodec {
  DynamicCodec()
      : super.fromFactories(
          asJs,
          (o) => o,
          acceptEncodedValue: (o) => true,
          acceptDecodedValue: (o) => true,
        );
}

/// A [ConditionalCodec] that handles a given kind of [JsInterface].
class JsInterfaceCodec<T extends JsInterface>
    extends ConditionalCodec<T, JsObject> {
  JsInterfaceCodec(
    Factory<JsObject, T> decode, [
    Predicate acceptEncodedValue,
  ]) : super.fromFactories(
          asJsObject,
          decode,
          acceptEncodedValue: acceptEncodedValue,
        );
}

/// A [ConditionalCodec] that handles [List].
class JsListCodec<T> extends ConditionalCodec<List<T>, JsArray> {
  JsListCodec(ConditionalCodec<T, dynamic> codec)
      : super.fromFactories(
          (o) => o is JsArray
              ? o
              : o is JsInterface
                  ? asJsObject(o as JsInterface)
                  : asJsObject(JsList(codec)..addAll(o)),
          (o) => JsList.created(o, codec),
        );
}

/// A [ConditionalCodec] that handles [Map]<[String], dynamic>
class JsObjectAsMapCodec<T> extends ConditionalCodec<Map<String, T>, JsObject> {
  JsObjectAsMapCodec(ConditionalCodec<T, dynamic> codec)
      : super.fromFactories(
          (o) => o is JsObject
              ? o
              : o is JsInterface
                  ? asJsObject(o as JsInterface)
                  : asJsObject(JsObjectAsMap(codec)..addAll(o)),
          (o) => JsObjectAsMap.created(o, codec),
        );
}

/// A [ConditionalCodec] used for union types.
class BiMapCodec<S, T> extends ConditionalCodec<S, T> {
  BiMapCodec(Map<S, T> map)
      : this._(
          map,
          Map<T, S>.fromIterables(map.values, map.keys),
        );
  BiMapCodec._(
    Map<S, T> encode,
    Map<T, S> decode,
  ) : super.fromFactories(
          (o) => encode[o],
          (o) => decode[o],
        );
}

/// A [ConditionalCodec] that handles function.
class FunctionCodec<T extends Function>
    extends ConditionalCodec<T, dynamic /*JsFunction|Function*/ > {
  FunctionCodec(
    Factory<T, dynamic /*JsFunction|Function*/ > encode,
    Factory<dynamic /*JsFunction|Function*/, T> decode,
  ) : super.fromFactories(
          encode,
          decode,
          acceptEncodedValue: (o) => o is JsFunction || o is Function,
        );
}

class ChainedCodec extends ConditionalCodec {
  final List<ConditionalCodec> _codecs;

  ChainedCodec() : this._(<ConditionalCodec>[]);

  ChainedCodec._(List<ConditionalCodec> _codecs)
      : _codecs = _codecs,
        super(
          _ChainedConverter(_codecs, encoder: true),
          _ChainedConverter(_codecs, encoder: false),
        );

  void add(ConditionalCodec codec) {
    _codecs.add(codec);
  }
}

class _ChainedConverter extends Converter {
  final List<ConditionalCodec> _codecs;
  final bool encoder;

  _ChainedConverter(this._codecs, {this.encoder});

  @override
  dynamic convert(input) {
    for (final codec in _codecs) {
      dynamic value;
      if (encoder && codec.acceptDecodedValue(input)) {
        value = codec.encode(input);
      }
      if (!encoder && codec.acceptEncodedValue(input)) {
        value = codec.decode(input);
      }
      if (value != null) {
        return value;
      }
    }
    return input;
  }
}
