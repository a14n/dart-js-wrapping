// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

library js_wrapping_generator.util;

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

LibraryElement getLib(LibraryElement libElement, String name) =>
    libElement.importedLibraries
        .firstWhere((l) => l.name == name, orElse: () => null);

ClassElement getType(
    LibraryElement libElement, String libName, String className) {
  final lib = getLib(libElement, libName);
  //print('---- aa:$libElement\n$libName\n$className');
  if (lib == null) return null;
  return lib.getType(className);
}

bool isAnnotationOfType(
    ElementAnnotation annotation, ClassElement annotationClass) {
  final metaElement = annotation.element;
  dynamic exp;
  DartType type;
  if (metaElement is PropertyAccessorElement) {
    exp = metaElement.variable;
    type = exp.evaluationResult.value.type as DartType;
  } else if (metaElement is ConstructorElement) {
    exp = metaElement;
    type = metaElement.enclosingElement.type;
  } else {
    throw UnimplementedError('Unsupported annotation: $annotation');
  }
  if (exp == annotationClass) return true;
  return type.isSubtypeOf(annotationClass.type);
}

Iterable<Annotation> getAnnotations(
    AnnotatedNode node, ClassElement clazz) sync* {
  if (node == null || node.metadata == null) return;
  for (final a in node.metadata) {
    final e = a.element;
    if (e is ConstructorElement && e.type.returnType == clazz.type) {
      yield a;
    }
  }
}

String getSourceCode(Element element) => element.source.contents.data
    .substring(element.computeNode().offset, element.computeNode().end);

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
      _transformations.add(SourceTransformation.insertion(index, content));

  void removeBetween(int begin, int end) =>
      _transformations.add(SourceTransformation.removal(begin, end));

  void removeNode(AstNode node) =>
      _transformations.add(SourceTransformation.removal(node.offset, node.end));

  void removeToken(Token token) => _transformations
      .add(SourceTransformation.removal(token.offset, token.end));

  void replace(int begin, int end, String content) =>
      _transformations.add(SourceTransformation(begin, end, content));

  String applyOn(Element element) {
    var code = getSourceCode(element);
    final initialPadding = -element.computeNode().offset;
    for (final transformation in _transformations) {
      transformation.shift(initialPadding);
    }
    for (var i = 0; i < _transformations.length; i++) {
      final t = _transformations[i];
      code = code.substring(0, t.begin) + t.content + code.substring(t.end);
      for (final transformation in _transformations.skip(i + 1)) {
        if (transformation.end <= t.begin) continue;
        if (t.end <= transformation.begin) {
          transformation.shift(t.content.length - (t.end - t.begin));
          continue;
        }
        throw StateError('Colision in transformations');
      }
    }
    return code;
  }
}
