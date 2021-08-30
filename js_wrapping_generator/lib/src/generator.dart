// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:js_wrapping_generator/src/transfomation.dart';
import 'package:source_gen/source_gen.dart';

class JsWrappingGenerator extends Generator {
  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    final transformer = Transformer();
    final definingCompilationUnitContent = library.element.source.contents.data;

    // remove  parts
    // BUG : getNode fail when the definingCompilationUnit don't have elements
    // final libraryNode = getNode(library.element.definingCompilationUnit).root
    //     as CompilationUnit;
    // libraryNode.directives
    //     .whereType<PartDirective>()
    //     .forEach(transformer.removeNode);
    RegExp(r'^part .*;$', multiLine: true)
        .allMatches(definingCompilationUnitContent)
        .forEach((e) {
      transformer.removeBetween(e.start, e.end);
    });

    final partsContent = <String>[];
    for (var element
        in library.allElements.where((element) => !element.isSynthetic)) {
      final node = getNode(element);
      if (element.thisOrAncestorOfType<CompilationUnitElement>() ==
          library.element.definingCompilationUnit) {
        if (element is ClassElement && hasJsNameAnnotation(element)) {
          transformer.replace(
              node.offset, node.end, generateForTemplate(element));
        }
      } else {
        partsContent.add(element is ClassElement && hasJsNameAnnotation(element)
            ? generateForTemplate(element)
            : getSourceCode(element));
      }
    }

    return transformer.applyOn(definingCompilationUnitContent) +
        partsContent.join('\n');
  }

  String generateForTemplate(ClassElement clazzTemplate) => clazzTemplate.isEnum
      ? generateForEnum(clazzTemplate)
      : generateForClass(clazzTemplate);

  String generateForEnum(ClassElement clazzTemplate) {
    final doc = getDoc(clazzTemplate) ?? '';
    final jsName = getJsName(clazzTemplate);
    final values = clazzTemplate.accessors
        .where((e) => e.returnType == clazzTemplate.thisType)
        .map((e) => e.name);
    final getters = values
        .map((e) => 'external static ${clazzTemplate.name} get $e;')
        .join('\n');
    final castMethod = [
      '${clazzTemplate.name}? ${clazzTemplate.name}\$cast(value) {',
      ...values.map((e) =>
          '  if (value == ${clazzTemplate.name}.$e) return ${clazzTemplate.name}.$e;'),
      '  return null;',
      '}',
    ].join('\n');
    return '''
$doc
@JS(${jsName != null ? "'$jsName'" : ""})
class ${clazzTemplate.name} {
$getters
}
$castMethod
''';
  }

  String generateForClass(ClassElement clazzTemplate) {
    final typeSystem = clazzTemplate.library.typeSystem;
    final source = clazzTemplate.source;
    final jsName = getJsName(clazzTemplate);

    final isAnonymous = hasAnonymousAnnotation(clazzTemplate);
    final doc = getDoc(clazzTemplate) ?? '';
    final classContent = StringBuffer();
    final extensionContent = StringBuffer();

    for (final constructor in clazzTemplate.constructors) {
      if (constructor.isSynthetic || constructor.name != '') {
        continue;
      }
      final node = getNode(constructor) as ConstructorDeclaration;
      final signature = constructor.source.contents.data
          .substring(node.parameters.offset, node.parameters.end);
      classContent
        ..writeln(getDoc(constructor) ?? '')
        ..write('external ')
        ..write(isAnonymous ? 'factory ' : '')
        ..writeln('${clazzTemplate.name}$signature;');
    }

    for (final field in clazzTemplate.fields) {
      if (field.isSynthetic) {
        continue;
      }
      final node = getNode(field) as VariableDeclaration;
      final type = (node.parent as VariableDeclarationList).type;
      final dartType = field.type;
      final typeAsString = field.source!.contents.data
          .substring(type!.offset, type.endToken.next!.offset);
      final jsNameMetadata = getJsName(field);
      if (field.hasInitializer) {
      } else if (jsNameMetadata != null ||
          _isCoreListWithTypeParameter(dartType) ||
          _isFunctionType(dartType)) {
        final nameDart = field.name;
        final nameJs = jsNameMetadata ?? field.name;
        final getterContent = _convertReturnValue(
          dartType,
          "getProperty(this, '$nameJs')",
          source,
          type,
          bindThisToFunction: true,
        );
        const paramName = 'value';
        final setterParam = _convertParam(dartType, typeSystem, paramName);
        extensionContent
          ..writeln(getDoc(field) ?? '')
          ..writeln('$typeAsString get $nameDart => $getterContent;')
          ..writeln(getDoc(field) ?? '')
          ..writeln('set $nameDart($typeAsString $paramName)'
              "{setProperty(this, '$nameJs', $setterParam);}");
      } else {
        classContent
          ..writeln(getDoc(field) ?? '')
          ..writeln('external $typeAsString get ${field.name};')
          ..writeln(getDoc(field) ?? '')
          ..writeln('external set ${field.name}($typeAsString value);');
      }
    }

    for (final method in clazzTemplate.accessors) {
      if (method.isSynthetic) {
        continue;
      }
      final node = getNode(method) as MethodDeclaration;
      final jsNameMetadata = getJsName(method);
      if (node.body is! EmptyFunctionBody) {
        extensionContent.writeln(
            method.source.contents.data.substring(node.offset, node.end));
      } else if (method.isOperator) {
      } else if (method.isSetter &&
          (jsNameMetadata != null ||
              method.parameters.first.type is FunctionType ||
              method.parameters.first.type.isDartCoreFunction)) {
        // name of setter end with an "=" sign
        final nameJs =
            jsNameMetadata ?? method.name.substring(0, method.name.length - 1);
        final signature = method.source.contents.data.substring(
            node.firstTokenAfterCommentAndMetadata.offset, node.body.offset);
        final param = method.parameters.first;
        final paramValue = _convertParam(param.type, typeSystem, param.name);
        extensionContent
          ..writeln(getDoc(method) ?? '')
          ..writeln(signature)
          ..writeln("{setProperty(this, '$nameJs', $paramValue);}");
      } else if (method.isGetter &&
          (jsNameMetadata != null ||
              _isCoreListWithTypeParameter(method.returnType) ||
              _isFunctionType(method.returnType))) {
        final nameJs = jsNameMetadata ?? method.name;
        final signature = method.source.contents.data.substring(
            node.firstTokenAfterCommentAndMetadata.offset, node.body.offset);
        final getterContent = _convertReturnValue(
          method.returnType,
          "getProperty(this, '$nameJs')",
          source,
          node.returnType,
          bindThisToFunction: true,
        );
        extensionContent
          ..writeln(getDoc(method) ?? '')
          ..writeln('$signature => $getterContent;');
      } else {
        final signature = method.source.contents.data.substring(
            node.firstTokenAfterCommentAndMetadata.offset, node.body.end);
        classContent.writeln(getDoc(method) ?? '');
        if (!method.isExternal) {
          classContent.write('external ');
        }
        classContent.writeln(signature);
      }
    }

    for (final method in clazzTemplate.methods) {
      if (method.isSynthetic) {
        continue;
      }
      final node = getNode(method) as MethodDeclaration;

      if (node.body is! EmptyFunctionBody) {
        extensionContent.writeln(
            method.source.contents.data.substring(node.offset, node.end));
        continue;
      }

      if (method.isOperator) {
        continue;
      }

      if (method.isPrivate ||
          method.parameters.any((p) => _isFunctionType(p.type)) ||
          _isCoreListWithTypeParameter(method.returnType) ||
          method.returnType.isDartAsyncFuture) {
        final name = getJsName(method) ?? method.name;
        final signature = method.source.contents.data.substring(
            node.firstTokenAfterCommentAndMetadata.offset, node.body.offset);
        final args = method.parameters
            .map((e) => _convertParam(e.type, typeSystem, e.name))
            .join(',');
        final content = _convertReturnValue(
          method.returnType,
          "callMethod(this, '$name', [$args])",
          source,
          node.returnType,
          bindThisToFunction: false,
        );
        extensionContent
          ..writeln(getDoc(method) ?? '')
          ..writeln(signature)
          ..writeln(
              method.returnType.isVoid ? '{ $content; }' : ' => $content;');
        continue;
      }

      final signature = method.source.contents.data.substring(
          node.firstTokenAfterCommentAndMetadata.offset, node.body.end);
      classContent.writeln(getDoc(method) ?? '');
      if (!method.isExternal) {
        classContent.write('external ');
      }
      classContent.writeln(signature);
    }

    final classNode = getNode(clazzTemplate) as ClassDeclaration;
    final classDeclaration = clazzTemplate.source.contents.data
        .substring(classNode.name.offset, classNode.leftBracket.offset);

    var result = '''
$doc
@JS(${jsName != null ? "'$jsName'" : ""})
${isAnonymous ? '@anonymous' : ''}
class $classDeclaration {
$classContent
}
''';
    if (extensionContent.isNotEmpty) {
      final typeParameters = clazzTemplate.typeParameters.isEmpty
          ? ''
          : '<${clazzTemplate.typeParameters.map((e) => e.name).join(',')}>';
      result += '''
extension ${clazzTemplate.name}\$Ext$typeParameters on ${clazzTemplate.name}$typeParameters {
$extensionContent
}
''';
    }
    //print(result);
    return result;
  }

  String _convertReturnValue(
    DartType dartType,
    String initialValue,
    Source source,
    TypeAnnotation? type, {
    required bool bindThisToFunction,
  }) =>
      _isCoreListWithTypeParameter(dartType)
          ? '$initialValue?.cast<${_getTypeParameterOfList(source, type!)}>()'
          : bindThisToFunction && _isFunctionType(dartType)
              ? "callMethod($initialValue, 'bind', [this])"
              : dartType.isDartAsyncFuture
                  ? 'promiseToFuture($initialValue)'
                  : initialValue;

  String _convertParam(
    DartType dartType,
    TypeSystem typeSystem,
    String paramName,
  ) {
    if (_isFunctionType(dartType)) {
      var function = paramName;
      bool isEnum(Element? element) =>
          element is ClassElement && element.isEnum;
      if (dartType is FunctionType &&
          dartType.parameters.map((e) => e.type.element).any(isEnum)) {
        final declarationParams = <String>[];
        final callParams = <String>[];
        for (var i = 0; i < dartType.parameters.length; i++) {
          final param = dartType.parameters[i];
          declarationParams.add('p$i');
          callParams.add(isEnum(param.type.element)
              ? '${param.type.element!.name}\$cast(p$i)'
              : 'p$i');
        }
        function =
            '(${declarationParams.join(',')}) => $paramName(${callParams.join(',')})';
      }
      if (typeSystem.isNullable(dartType)) {
        return '$paramName == null ? null : allowInterop($function)';
      } else {
        return 'allowInterop($function)';
      }
    } else {
      return paramName;
    }
  }

  bool _isCoreListWithTypeParameter(DartType dartType) =>
      dartType is InterfaceType &&
      dartType.element.library.name == 'dart.core' &&
      dartType.element.name == 'List' &&
      dartType.typeArguments.isNotEmpty;

  bool _isFunctionType(DartType dartType) =>
      dartType is FunctionType || dartType.isDartCoreFunction;

  String _getTypeParameterOfList(Source source, TypeAnnotation type) =>
      source.contents.data.substring(type.offset + 'List<'.length,
          type.end - (type.question == null ? 0 : 1) - '>'.length);
}

String? getDoc(Element element) {
  final node = getNode(element);
  if (node is AnnotatedNode) {
    final documentationComment = node.documentationComment;
    if (documentationComment != null) {
      return element.source!.contents.data
          .substring(documentationComment.offset, documentationComment.end);
    }
  }
  return null;
}

Iterable<DartObject> getAnnotations(
  LibraryElement library,
  List<ElementAnnotation> metadata,
  String libraryName,
  String className,
) =>
    metadata.map((a) => a.computeConstantValue()).whereNotNull().where((e) =>
        library.typeSystem.isAssignableTo(
            e.type!, getType(library, libraryName, className)!.thisType));

bool hasAnonymousAnnotation(ClassElement clazz) => clazz.metadata
    .where((a) =>
        a.element!.library!.name == 'js' && a.element!.name == 'anonymous')
    .isNotEmpty;

// getAnnotations(clazz.library, clazz.metadata, 'js', '_Anonymous')
//     .isNotEmpty;

Iterable<DartObject> getJsNameAnnotations(
        LibraryElement library, List<ElementAnnotation> metadata) =>
    getAnnotations(library, metadata, 'js_wrapping', 'JsName');

bool hasJsNameAnnotation(ClassElement clazz) =>
    getJsNameAnnotations(clazz.library, clazz.metadata).isNotEmpty;

String? getJsName(Element element) =>
    getJsNameAnnotations(element.library!, element.metadata)
        .firstOrNull
        ?.getField('name')
        ?.toStringValue();

ClassElement? getType(
    LibraryElement libElement, String libName, String className) {
  final lib =
      libElement.importedLibraries.firstWhereOrNull((l) => l.name == libName);
  return lib?.getType(className);
}
