// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library js_wrapping;

import 'dart:async';
import 'dart:collection';
import 'dart:html' show Blob, Event, ImageData, Node, Window;
import 'dart:js';
import 'dart:indexed_db' show KeyRange;
import 'dart:typed_data' show TypedData;

part 'src/wrapping/enum.dart';
part 'src/wrapping/serializable.dart';
part 'src/wrapping/typed_js_object.dart';
part 'src/wrapping/utils.dart';
part 'src/wrapping/js/date_to_datetime_adapter.dart';
part 'src/wrapping/js/typed_js_array.dart';
part 'src/wrapping/js/typed_js_map.dart';
