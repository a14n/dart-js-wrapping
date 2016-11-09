// Copyright (c) 2016, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

library js_wrapping_generator.tool.phases;

import 'package:build/build.dart';
import 'package:js_wrapping_generator/js_interface_generator.dart';
import 'package:source_gen/source_gen.dart';

final PhaseGroup phases = new PhaseGroup.singleAction(
    new GeneratorBuilder([
      new JsInterfaceGenerator(),
    ]),
    new InputSet('js_wrapping_generator', const [
      'example/**/*.dart',
      'example/*.dart',
      'test/*.dart',
    ]));
