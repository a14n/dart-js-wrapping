// Copyright (c) 2016, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

library js_wrapping_generator.tool.build;

import 'package:build/build.dart';

import 'phases.dart';

main() async {
  await build(phases, deleteFilesByDefault: true);
}