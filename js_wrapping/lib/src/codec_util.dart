// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

library js_wrapping.src.codec_util;

import 'dart:convert';

class IdentityCodec<E> extends Codec<E, E> {
  const IdentityCodec();

  @override
  Converter<E, E> get decoder => const _IdentityConverter();

  @override
  Converter<E, E> get encoder => const _IdentityConverter();
}

class _IdentityConverter<E> extends Converter<E, E> {
  const _IdentityConverter();

  @override
  E convert(E input) => input;
}
