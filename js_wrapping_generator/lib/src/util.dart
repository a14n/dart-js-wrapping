// Copyright (c) 2016, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

bool matchAnnotation(Type type, ElementAnnotation annotation) =>
    TypeChecker.fromRuntime(type).hasAnnotationOfExact(annotation.element);

LibraryElement getLib(LibraryElement library, String name) =>
    library.importedLibraries
        .firstWhere((l) => l.name == name, orElse: () => null);

ClassElement getType(
        LibraryElement library, String libName, String className) =>
    getLib(library, libName)?.getType(className);

bool hasAnnotation(Element element, Type type) =>
    element.metadata.any((e) => matchAnnotation(type, e));

Iterable<Annotation> getAnnotations(AnnotatedNode node, Type type) sync* {
  if (node == null || node.metadata == null) return;
  for (final a in node.metadata) {
    if (matchAnnotation(type, a.elementAnnotation)) {
      yield a;
    }
  }
}

String formatParameter(
    ParameterElement p, Map<DartType, DartType> genericsMapping) {
  final type = substituteTypeToGeneric(genericsMapping, p.type);
  var code = type is FunctionType
      ? formatFunction(type, p.name, genericsMapping)
      : '$type ${p.name}';
  if (p.defaultValueCode != null) {
    code += '=${p.defaultValueCode}';
  }
  return code;
}

String formatFunction(
    FunctionType type, String name, Map<DartType, DartType> genericsMapping) {
  final requiredParameters = type.parameters.where((p) => p.isNotOptional);
  final optionalPositionalParameters =
      type.parameters.where((p) => p.isOptionalPositional);
  final optionalNamedParameters = type.parameters.where((p) => p.isNamed);

  var params = '';
  params += requiredParameters
      .map((p) => formatParameter(p, genericsMapping))
      .join(', ');

  if (optionalPositionalParameters.isNotEmpty) {
    if (requiredParameters.isNotEmpty) params += ', ';
    params += '[';
    params += optionalPositionalParameters
        .map((p) => formatParameter(p, genericsMapping))
        .join(', ');
    params += ']';
  }

  if (optionalNamedParameters.isNotEmpty) {
    if (requiredParameters.isNotEmpty) params += ', ';
    params += '{';
    params += optionalNamedParameters
        .map((p) => formatParameter(p, genericsMapping))
        .join(', ');
    params += '}';
  }

  return '${type.returnType.displayName} $name($params)';
}

/// Returns the [name] or the [name] prefixed by `this.` if a parameter has this
/// [name].
String mayPrefixByThis(String name, List<ParameterElement> parameters) =>
    parameters.map((p) => p.displayName).any((n) => n == name)
        ? 'this.$name'
        : name;

DartType substituteTypeToGeneric(
    Map<DartType, DartType> genericsMapping, DartType type) {
  if (type is InterfaceType) {
    if (type.typeParameters.isNotEmpty) {
      final argumentsTypes = type.typeArguments
          .map((e) => substituteTypeToGeneric(genericsMapping, e))
          .toList();
      final newType = type.instantiate(argumentsTypes);
      return newType;
    } else {
      return type;
    }
  }
  if (type is FunctionType) {
    return type.instantiate(type.typeArguments
        .map((e) => substituteTypeToGeneric(genericsMapping, e))
        .toList());
  }
  if (type is TypeParameterType) {
    if (genericsMapping.containsKey(type)) return genericsMapping[type];
    if (type.element.bound == null) return DynamicTypeImpl.instance;
    return type.element.bound;
  }
  return type;
}

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

  bool get hasTransformations => _transformations.isNotEmpty;

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

  String applyOnCode(String code, {int initialPadding = 0}) {
    var result = code;
    for (final transformation in _transformations) {
      transformation.shift(initialPadding);
    }
    for (var i = 0; i < _transformations.length; i++) {
      final t = _transformations[i];
      result =
          result.substring(0, t.begin) + t.content + result.substring(t.end);
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
