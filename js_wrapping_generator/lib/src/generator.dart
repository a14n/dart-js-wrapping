// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
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
    final content = clazzTemplate.accessors
        .where((e) => e.returnType == clazzTemplate.thisType)
        .map((e) => 'external static ${clazzTemplate.name} get ${e.name};')
        .join('\n');
    return '''
$doc
@JS(${jsName != null ? "'$jsName'" : ""})
class ${clazzTemplate.name} {
$content
}
''';
  }

  String generateForClass(ClassElement clazzTemplate) {
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
      final isCoreListWithTypeParameter =
          _isCoreListWithTypeParameter(dartType);
      final typeAsString = field.source!.contents.data
          .substring(type!.offset, type.endToken.next!.offset);
      final jsNameMetadata = getJsName(field);
      if (field.hasInitializer) {
      } else if (dartType is FunctionType ||
          dartType.isDartCoreFunction ||
          jsNameMetadata != null ||
          isCoreListWithTypeParameter) {
        final nameDart = field.name;
        final nameJs = jsNameMetadata ?? field.name;
        final cast = isCoreListWithTypeParameter
            ? '?.cast<${_getTypeParameterOfList(field.source!, type)}>()'
            : '';
        extensionContent
          ..writeln(getDoc(field) ?? '')
          ..writeln(dartType is FunctionType || dartType.isDartCoreFunction
              ? "$typeAsString get $nameDart => callMethod(getProperty(this, '$nameJs'), 'bind', [this]);"
              : "$typeAsString get $nameDart => getProperty(this, '$nameJs')$cast;")
          ..writeln(getDoc(field) ?? '')
          ..writeln('set $nameDart($typeAsString value)'
              "{setProperty(this, '$nameJs', ${dartType is FunctionType || dartType.isDartCoreFunction ? clazzTemplate.library.typeSystem.isNullable(dartType) ? 'value == null ? null : allowInterop(value)' : 'allowInterop(value)' : 'value'});}");
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
        final paramValue = param.type is FunctionType ||
                param.type.isDartCoreFunction
            ? clazzTemplate.library.typeSystem.isNullable(param.type)
                ? '${param.name} == null ? null : allowInterop(${param.name})'
                : 'allowInterop(${param.name})'
            : param.name;
        extensionContent
          ..writeln(getDoc(method) ?? '')
          ..writeln(signature)
          ..writeln("{setProperty(this, '$nameJs', $paramValue);}");
      } else if (method.isGetter &&
          (_isCoreListWithTypeParameter(method.returnType) ||
              jsNameMetadata != null)) {
        final nameJs = jsNameMetadata ?? method.name;
        final signature = method.source.contents.data.substring(
            node.firstTokenAfterCommentAndMetadata.offset, node.body.offset);
        final cast = _isCoreListWithTypeParameter(method.returnType)
            ? '?.cast<${_getTypeParameterOfList(method.source, node.returnType!)}>()'
            : '';
        extensionContent
          ..writeln(getDoc(method) ?? '')
          ..writeln(signature)
          ..writeln("=> getProperty(this, '$nameJs')$cast;");
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

      if (_isCoreListWithTypeParameter(method.returnType) ||
          method.isPrivate ||
          method.parameters.any(
              (p) => p.type is FunctionType || p.type.isDartCoreFunction) ||
          method.returnType.isDartAsyncFuture) {
        final name = getJsName(method) ?? method.name;
        final signature = method.source.contents.data.substring(
            node.firstTokenAfterCommentAndMetadata.offset, node.body.offset);
        final args = method.parameters
            .map((e) => e.type is FunctionType || e.type.isDartCoreFunction
                ? clazzTemplate.library.typeSystem.isNullable(e.type)
                    ? '${e.name} == null ? null : allowInterop(${e.name})'
                    : 'allowInterop(${e.name})'
                : e.name)
            .join(',');
        final cast = _isCoreListWithTypeParameter(method.returnType)
            ? '?.cast<${_getTypeParameterOfList(method.source, node.returnType!)}>()'
            : '';
        final content = "callMethod(this, '$name', [$args])$cast";
        extensionContent
          ..writeln(getDoc(method) ?? '')
          ..writeln(signature)
          ..writeln(method.returnType.isVoid
              ? '{ $content; }'
              : method.returnType.isDartAsyncFuture
                  ? ' => promiseToFuture($content);'
                  : ' => $content;');
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

  bool _isCoreListWithTypeParameter(DartType dartType) =>
      dartType is InterfaceType &&
      dartType.element.library.name == 'dart.core' &&
      dartType.element.name == 'List' &&
      dartType.typeArguments.isNotEmpty;

  String _getTypeParameterOfList(Source source, TypeAnnotation type) {
    return source.contents.data.substring(type.offset + 'List<'.length,
        type.end - (type.question == null ? 0 : 1) - '>'.length);
  }
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
