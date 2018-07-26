// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

import 'package:js_wrapping_generator/js_interface_creator.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print('You must provide one or more class names as arguments');
  }
  print(args.map(createInterfaceSkeleton).join('\n\n'));
}
