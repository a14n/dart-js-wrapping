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
    new TypeChecker.fromRuntime(type).hasAnnotationOfExact(annotation.element);

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
  for (Annotation a in node.metadata) {
    if (matchAnnotation(type, a.elementAnnotation)) {
      yield a;
    }
  }
}

String formatParameter(
    ParameterElement p, Map<DartType, DartType> genericsMapping) {
  final type = substituteTypeToGeneric(genericsMapping, p.type);
  String code = type is FunctionType
      ? formatFunction(type, p.name, genericsMapping)
      : '${type} ${p.name}';
  if (p.defaultValueCode != null) {
    if (p.parameterKind == ParameterKind.POSITIONAL) code += '=';
    if (p.parameterKind == ParameterKind.NAMED) code += ':';
    code += p.defaultValueCode;
  }
  return code;
}

String formatFunction(
    FunctionType type, String name, Map<DartType, DartType> genericsMapping) {
  String result = '${type.returnType.displayName} ${name}(';

  final requiredParameters =
      type.parameters.where((p) => p.parameterKind == ParameterKind.REQUIRED);
  final optionalPositionalParameters =
      type.parameters.where((p) => p.parameterKind == ParameterKind.POSITIONAL);
  final optionalNamedParameters =
      type.parameters.where((p) => p.parameterKind == ParameterKind.NAMED);

  result += requiredParameters
      .map((p) => formatParameter(p, genericsMapping))
      .join(', ');

  if (optionalPositionalParameters.isNotEmpty) {
    if (requiredParameters.isNotEmpty) result += ', ';
    result += '[';
    result += optionalPositionalParameters
        .map((p) => formatParameter(p, genericsMapping))
        .join(', ');
    result += ']';
  }

  if (optionalNamedParameters.isNotEmpty) {
    if (requiredParameters.isNotEmpty) result += ', ';
    result += '{';
    result += optionalNamedParameters
        .map((p) => formatParameter(p, genericsMapping))
        .join(', ');
    result += '}';
  }

  result += ')';
  return result;
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

      // http://dartbug.com/19253
      //        final t = type.substitute4(argumentsTypes);
      //        return t;

      final newType = new InterfaceTypeImpl(type.element);
      newType.typeArguments = argumentsTypes;
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
      _transformations.add(new SourceTransformation.insertion(index, content));

  void removeBetween(int begin, int end) =>
      _transformations.add(new SourceTransformation.removal(begin, end));

  void removeNode(AstNode node) => _transformations
      .add(new SourceTransformation.removal(node.offset, node.end));

  void removeToken(Token token) => _transformations
      .add(new SourceTransformation.removal(token.offset, token.end));

  void replace(int begin, int end, String content) =>
      _transformations.add(new SourceTransformation(begin, end, content));

  String applyOnCode(String code, {int initialPadding: 0}) {
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
