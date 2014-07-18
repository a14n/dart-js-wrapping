// Copyright (c) 2014, Alexandre Ardhuin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library js_wrapping.transformer;

import 'dart:async' show Future, Completer;

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';

const _LIBRARY_NAME = 'js_wrapping.transformer';

/// Mark class as instantiable
class JsInterface {
  const JsInterface({List<String> jsName: const <String>['Object']});
}

class JsMapping {
  const JsMapping.useMethod();
  const JsMapping.useName(String name);
}

class UnionType {
  const UnionType(List<Type> types);
}

class JsWrappingTransformer extends TransformerGroup {
  JsWrappingTransformer.asPlugin() : this._(new _JsWrappingTransformer());
  JsWrappingTransformer._(_JsWrappingTransformer mt) : super(
      new Iterable.generate(2, (_) => [mt]));
}

class _JsWrappingTransformer extends Transformer {
  Resolvers resolvers = new Resolvers(dartSdkDirectory);
  List<AssetId> unmodified = [];

  Map<AssetId, String> contentsPending = {};

  _JsWrappingTransformer();

  String get allowedExtensions => ".dart";

  Future apply(Transform transform) {
    final id = transform.primaryInput.id;
    if (unmodified.contains(id)) return new Future.value();
    if (contentsPending.containsKey(id)) {
      transform.addOutput(new Asset.fromString(id, contentsPending.remove(id)));
      return new Future.value();
    }
    return resolvers.get(transform).then((resolver) {
      return new Future(() => applyResolver(transform, resolver)).whenComplete(
          () => resolver.release());
    });
  }

  applyResolver(Transform transform, Resolver resolver) {
    final assetId = transform.primaryInput.id;
    final lib = resolver.getLibrary(assetId);

    if (isPart(lib)) return;

    for (final unit in lib.units) {
      final id = unit.source.assetId;
      final transaction = resolver.createTextEditTransaction(unit);
      for (final t in modifyUnit(unit)) {
        transaction.edit(t.begin, t.end, t.content);
      }
      if (transaction.hasEdits) {
        final np = transaction.commit();
        np.build('');
        final newContent = np.text;
        transform.logger.fine("new content for $id : \n$newContent", asset: id);
        contentsPending[id] = newContent;
      } else {
        unmodified.add(id);
      }
    }
  }

  bool isPart(LibraryElement lib) => lib.unit.directives.any((d) => d is
      PartOfDirective);
}

List<Transformation> modifyUnit(CompilationUnitElement unit) {
  final transformations = <Transformation>[];

  final jsClasses = findJsClasses(unit);
  for (final clazz in jsClasses) {
    final jsInterfaces = getJsInterface(clazz);
    final jsName = getJsName(jsInterfaces);

    // add $wrap
    final index = clazz.end - 1;
    if (!isMemberAlreadyDefined(clazz, r'$wrap')) {
      transformations.add(new Transformation.insertion(index,
          '  static ${clazz.name.name} \$wrap(js.JsObject jsObject) => jsObject == null ? null : new ${clazz.name.name}.fromJsObject(jsObject);\n'
          ));
    }

    // add Xxx.fromJsObject
    if (!isMemberAlreadyDefined(clazz, r'fromJsObject')) {
      transformations.add(new Transformation.insertion(index,
          '  ${clazz.name.name}.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);\n'
          ));
    }

    // add default constructor
    if (jsName != null && !isMemberAlreadyDefined(clazz, '')) {
      transformations.add(new Transformation.insertion(index,
          "  ${clazz.name.name}() : this.fromJsObject(new js.JsObject(js.context[${jsName.join("][")}]));\n"));
    }
  }

  return transformations;
}

List<String> getJsName(Annotation jsInterface) {
  if (jsInterface == null) return null;
  final NamedExpression param = jsInterface.arguments.arguments.firstWhere((e)
      => e is NamedExpression && e.name.label.name == 'jsName', orElse: () => null);
  if (param != null) {
    return (param.expression as ListLiteral).elements.map((StringLiteral sl) =>
        sl.toString()).toList();
  } else {
    return ["'Object'"];
  }
}

Iterable<ClassDeclaration> findJsClasses(CompilationUnitElement unit) =>
    unit.unit.declarations.toList().where((d) => d is ClassDeclaration).where(
    (ClassDeclaration c) {
  InterfaceType current = c.element.type;
  while (true) {
    if (current.element.library.isDartCore && current.displayName == 'Object') {
      return false;
    }
    if (current.element.library.name == 'js_wrapping' && current.displayName ==
        'TypedJsObject') {
      return true;
    }
    current = current.element.supertype;
  }
  return false;
});

Annotation getJsInterface(ClassDeclaration clazz) {
  ClassDeclaration current = clazz;
  while (true) {
    if (current.element.library.isDartCore && current.element.displayName ==
        'Object') {
      return null;
    }
    final jsInterface = getAnnotation(clazz, 'JsInterface');
    if (jsInterface != null) {
      return jsInterface;
    }
    current = current.element.supertype.element.node;
  }
  return null;
}

class Transformation {
  final int begin, end;
  final String content;
  Transformation(this.begin, this.end, this.content);
  Transformation.insertion(int index, this.content)
      : begin = index,
        end = index;
  Transformation.deletation(this.begin, this.end) : content = '';
}

createRemoveTransformation(AstNode node) => new Transformation.deletation(
    node.offset, node.end);

Annotation getAnnotation(Declaration declaration, String name) =>
    declaration.metadata.firstWhere((m) => m.element.library.name == _LIBRARY_NAME
    && m.element is ConstructorElement && m.element.enclosingElement.name == name,
    orElse: () => null);

bool isMemberAlreadyDefined(ClassDeclaration clazz, String name) =>
    clazz.members.any((m) => (m is MethodDeclaration && m.name.name + (m.isSetter ?
    '=' : '') == name) || (m is FieldDeclaration && m.fields.variables.any((f) =>
    f.name.name == name)) || (m is ConstructorDeclaration && (m.name == null &&
    name.isEmpty || m.name != null && m.name.name == name)));
