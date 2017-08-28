// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

library js_wrapping.js_interface_creator;

String createInterfaceSkeleton(String name) {
  final className = '_' + name.substring(name.lastIndexOf('.') + 1);
  return '''
@JsName('$name')
abstract class $className implements JsInterface {
  factory $className() => \$js;
}''';
}
