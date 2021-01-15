// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

library js_wrapping_generator.util;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';

String getSourceCode(Element element) {
  final node = getNode(element);
  return element.source.contents.data.substring(node.offset, node.end);
}

AstNode getNode(Element element) => element.session
    .getParsedLibraryByElement(element.library)
    .getElementDeclaration(element)
    .node;

class SourceTransformation {
  SourceTransformation(this.begin, this.end, this.content);
  SourceTransformation.removal(this.begin, this.end) : content = '';
  SourceTransformation.insertion(int index, this.content)
      : begin = index,
        end = index;

  int begin;
  int end;
  final String content;

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

  String applyOnElement(Element element) {
    var code = getSourceCode(element);
    final initialPadding = -getNode(element).offset;
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
  String applyOn(String code, {int padding = 0}) {
    var result = code;
    for (final transformation in _transformations) {
      transformation.shift(padding);
    }
    for (var i = 0; i < _transformations.length; i++) {
      final t = _transformations[i];
      result = result.substring(0, t.begin) + t.content + result.substring(t.end);
      for (final transformation in _transformations.skip(i + 1)) {
        if (transformation.end <= t.begin) continue;
        if (t.end <= transformation.begin) {
          transformation.shift(t.content.length - (t.end - t.begin));
          continue;
        }
        throw StateError('Colision in transformations');
      }
    }
    return result;
  }
}
