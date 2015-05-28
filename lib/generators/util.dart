// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

library js_wrapping.generator.util;

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/scanner.dart';

LibraryElement getLib(LibraryElement libElement, String name) =>
    libElement.visibleLibraries.firstWhere((l) => l.name == name,
        orElse: () => null);

ClassElement getType(
    LibraryElement libElement, String libName, String className) {
  final lib = getLib(libElement, libName);
  if (lib == null) return null;
  return lib.getType(className);
}

bool isAnnotationOfType(
    ElementAnnotation annotation, ClassElement annotationClass) {
  var metaElement = annotation.element;
  var exp;
  var type;
  if (metaElement is PropertyAccessorElement) {
    exp = metaElement.variable;
    type = exp.evaluationResult.value.type;
  } else if (metaElement is ConstructorElement) {
    exp = metaElement;
    type = metaElement.enclosingElement.type;
  } else {
    throw new UnimplementedError('Unsupported annotation: ${annotation}');
  }
  if (exp == annotationClass) return true;
  return type.isSubtypeOf(annotationClass.type);
}

Iterable<Annotation> getAnnotations(
    AnnotatedNode node, ClassElement clazz) sync* {
  if (node == null || node.metadata == null) return;
  for (Annotation a in node.metadata) {
    var e = a.element;
    if (e is ConstructorElement && e.type.returnType == clazz.type) {
      yield a;
    }
  }
}

String getSourceCode(Element element) => element.source.contents.data.substring(
    element.node.offset, element.node.end);

class SourceTransformation {
  int begin;
  int end;
  final String content;

  SourceTransformation(this.begin, this.end, this.content);
  SourceTransformation.removal(this.begin, this.end) : content = '';
  SourceTransformation.insertion(int index, this.content)
      : begin = index,
        end = index;

  void shift(int value) {
    begin += value;
    end += value;
  }
}

class Transformer {
  final _transformations = <SourceTransformation>[];

  void insertAt(int index, String content) =>
      _transformations.add(new SourceTransformation.insertion(index, content));

  void removeBetween(int begin, int end) =>
      _transformations.add(new SourceTransformation.removal(begin, end));

  void removeNode(AstNode node) => _transformations
      .add(new SourceTransformation.removal(node.offset, node.end));

  void removeToken(Token token) => _transformations
      .add(new SourceTransformation.removal(token.offset, token.end));

  void replace(int begin, int end, String content) =>
      _transformations.add(new SourceTransformation(begin, end, content));

  String applyOn(Element element) {
    var code = getSourceCode(element);
    final initialPadding = -element.node.offset;
    _transformations.forEach((e) => e.shift(initialPadding));
    for (var i = 0; i < _transformations.length; i++) {
      final t = _transformations[i];
      code = code.substring(0, t.begin) + t.content + code.substring(t.end);
      _transformations.skip(i + 1).forEach((e) {
        if (e.end <= t.begin) return;
        if (t.end <= e.begin) {
          e.shift(t.content.length - (t.end - t.begin));
          return;
        }
        throw 'Colision in transformations';
      });
    }
    return code;
  }
}
