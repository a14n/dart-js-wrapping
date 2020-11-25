// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:build/build.dart';
import 'package:js_wrapping_generator/src/transfomation.dart';
import 'package:source_gen/source_gen.dart';

class JsWrappingGenerator extends Generator {
  @override
  String generate(LibraryReader library, BuildStep buildStep) {
    final templates = library.allElements
        .whereType<ClassElement>()
        .where((clazz) => clazz.isPrivate)
        .where(hasJsNameAnnotation)
        .toList();
    return templates.map(generateForTemplate).join('\n');
  }

  String generateForTemplate(ClassElement clazzTemplate) => clazzTemplate.isEnum
      ? generateForEnum(clazzTemplate)
      : generateForClass(clazzTemplate);

  String generateForEnum(ClassElement clazzTemplate) {
    final newName = getPublicClassName(clazzTemplate);
    final doc = getDoc(clazzTemplate) ?? '';
    final jsName = getJsName(clazzTemplate);
    final content = clazzTemplate.accessors
        .where((e) => e.returnType == clazzTemplate.thisType)
        .map((e) => 'external static $newName get ${e.name};')
        .join('\n');
    return '''
$doc
@GeneratedFrom(${clazzTemplate.name})
@JS(${jsName != null ? "'$jsName'" : ""})
class $newName {
$content
}
''';
  }

  String generateForClass(ClassElement clazzTemplate) {
    final newName = getPublicClassName(clazzTemplate);
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
        ..writeln('$newName$signature;');
    }

    for (final field in clazzTemplate.fields) {
      if (field.isSynthetic) {
        continue;
      }
      final node = getNode(field) as VariableDeclaration;
      final dartType = field.type;
      final isCoreListWithTypeParameter =
          _isCoreListWithTypeParameter(dartType);
      final type = field.source.contents.data.substring(
          (node.parent as VariableDeclarationList).type.offset,
          (node.parent as VariableDeclarationList).type.end);
      final jsNameMetadata = getJsName(field);
      if (field.hasInitializer) {
      } else if (dartType is FunctionType ||
          jsNameMetadata != null ||
          isCoreListWithTypeParameter) {
        final nameDart = field.name;
        final nameJs = jsNameMetadata ?? field.name;
        final cast = isCoreListWithTypeParameter
            ? '.cast<${_getTypeParameterOfList(field.source, (node.parent as VariableDeclarationList).type)}>()'
            : '';
        extensionContent
          ..writeln(getDoc(field) ?? '')
          ..writeln("$type get $nameDart => getProperty(this, '$nameJs')$cast;")
          ..writeln(getDoc(field) ?? '')
          ..writeln('set $nameDart($type value)'
              "{setProperty(this, '$nameJs', ${dartType is FunctionType ? 'allowInterop(value)' : 'value'});}");
      } else {
        classContent
          ..writeln(getDoc(field) ?? '')
          ..writeln('external $type get ${field.name};')
          ..writeln(getDoc(field) ?? '')
          ..writeln('external set ${field.name}($type value);');
      }
    }

    for (final method in clazzTemplate.accessors) {
      if (method.isSynthetic) {
        continue;
      }
      final node = getNode(method) as MethodDeclaration;
      final jsNameMetadata = getJsName(method);
      final returnType = method.returnType;
      final isCoreListWithTypeParameter =
          _isCoreListWithTypeParameter(returnType);
      if (node.body is! EmptyFunctionBody) {
        extensionContent.writeln(
            method.source.contents.data.substring(node.offset, node.end));
      } else if (method.isOperator) {
      } else if (isCoreListWithTypeParameter || jsNameMetadata != null) {
        final nameJs = jsNameMetadata;
        final signature = method.source.contents.data.substring(
            node.firstTokenAfterCommentAndMetadata.offset, node.body.offset);
        final args = method.parameters.map((e) => e.name).join(',');
        final cast = isCoreListWithTypeParameter
            ? '.cast<${_getTypeParameterOfList(method.source, node.returnType)}>()'
            : '';
        extensionContent
          ..writeln(getDoc(method) ?? '')
          ..writeln(signature)
          ..writeln("=> callMethod(this, '$nameJs', [$args])$cast;");
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
      final returnType = method.returnType;
      final isCoreListWithTypeParameter =
          _isCoreListWithTypeParameter(returnType);
      if (node.body is! EmptyFunctionBody) {
        extensionContent.writeln(
            method.source.contents.data.substring(node.offset, node.end));
      } else if (method.isOperator) {
      } else if (isCoreListWithTypeParameter || method.isPrivate) {
        final name = method.name;
        final publicName = method.isPrivate ? name.substring(1) : name;
        final signature = method.source.contents.data.substring(
            node.firstTokenAfterCommentAndMetadata.offset, node.body.offset);
        final args = method.parameters.map((e) => e.name).join(',');
        final cast = isCoreListWithTypeParameter
            ? '.cast<${_getTypeParameterOfList(method.source, node.returnType)}>()'
            : '';
        extensionContent
          ..writeln(getDoc(method) ?? '')
          ..writeln(signature)
          ..writeln("=> callMethod(this, '$publicName', [$args])$cast;");
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

    final classNode = getNode(clazzTemplate) as ClassDeclaration;
    final classDeclaration = clazzTemplate.source.contents.data
        .substring(classNode.name.offset + 1, classNode.leftBracket.offset);

    var result = '''
$doc
@GeneratedFrom(${clazzTemplate.name})
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
@GeneratedFrom(${clazzTemplate.name})
extension $newName\$Ext$typeParameters on $newName$typeParameters {
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
    return source.contents.data
        .substring(type.offset + 'List<'.length, type.end - '>'.length);
  }
}

String getDoc(Element element) {
  final node = getNode(element);
  if (node is AnnotatedNode && node.documentationComment != null) {
    return element.source.contents.data.substring(
        node.documentationComment.offset, node.documentationComment.end);
  } else {
    return null;
  }
}

String getPublicClassName(ClassElement clazz) => clazz.displayName.substring(1);

Iterable<DartObject> getAnnotations(
  LibraryElement library,
  List<ElementAnnotation> metadata,
  String libraryName,
  String className,
) =>
    metadata.map((a) => a.computeConstantValue()).where((e) =>
        e != null &&
        library.typeSystem.isAssignableTo(
            e.type, getType(library, libraryName, className).thisType));

bool hasAnonymousAnnotation(ClassElement clazz) => clazz.metadata
    .where(
        (a) => a.element.library.name == 'js' && a.element.name == 'anonymous')
    .isNotEmpty;

// getAnnotations(clazz.library, clazz.metadata, 'js', '_Anonymous')
//     .isNotEmpty;

Iterable<DartObject> getJsNameAnnotations(
        LibraryElement library, List<ElementAnnotation> metadata) =>
    getAnnotations(library, metadata, 'js_wrapping', 'JsName');

bool hasJsNameAnnotation(ClassElement clazz) =>
    getJsNameAnnotations(clazz.library, clazz.metadata).isNotEmpty;

String getJsName(Element element) =>
    getJsNameAnnotations(element.library, element.metadata)
        .firstWhere((e) => true, orElse: () => null)
        ?.getField('name')
        ?.toStringValue();

ClassElement getType(
    LibraryElement libElement, String libName, String className) {
  final lib = libElement.importedLibraries
      .firstWhere((l) => l.name == libName, orElse: () => null);
  if (lib == null) return null;
  return lib.getType(className);
}
