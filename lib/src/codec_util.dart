// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

library js_wrapping.src.codec_util;

import 'dart:convert';

class IdentityCodec extends Codec {
  const IdentityCodec();

  @override
  Converter get decoder => const _IdentityConverter();

  @override
  Converter get encoder => const _IdentityConverter();
}

class _IdentityConverter extends Converter {
  const _IdentityConverter();

  @override
  convert(input) => input;
}
