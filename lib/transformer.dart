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

const _LIBRARY_NAME = 'js_wrapping';

class JsWrappingTransformer extends TransformerGroup {
  JsWrappingTransformer.asPlugin() : this(new Resolvers(dartSdkDirectory));
  JsWrappingTransformer(Resolvers resolvers) : this._(
      new _JsWrappingTransformer(resolvers));
  JsWrappingTransformer._(_JsWrappingTransformer mt) : super(
      new Iterable.generate(2, (_) => [mt]));
}

class _JsWrappingTransformer extends Transformer {
  final Resolvers resolvers;
  List<AssetId> unmodified = [];

  Map<AssetId, String> contentsPending = {};

  _JsWrappingTransformer(this.resolvers);

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
    final jsConstructor = getJsConstructor(clazz);
    final jsName = getJsName(jsConstructor);

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
          "  static final js.JsFunction _ctor = js.context[${jsName.join("][")}];\n"
          "  ${clazz.name.name}() : this.fromJsObject(new js.JsObject(_ctor));\n"));
    }

    final nodesToRemove = new Set<AstNode>();

    // generate accessors
    for (final accessor in clazz.element.accessors.where((e) => !e.isStatic)) {
      int insertionIndex;
      bool appendLn = false;

      if (accessor.variable.isSynthetic) {
        // if accessor is abstract, skip it
        if (!accessor.isAbstract) {
          continue;
        }
        final node = accessor.node;
        insertionIndex = node.offset;
        nodesToRemove.add(node);
      } else { // field
        // if field is initialized, skip it
        if (accessor.variable.initializer != null) {
          continue;
        }
        VariableDeclarationList variableDeclarationList =
            accessor.variable.node.parent;
        FieldDeclaration fieldDeclaration = variableDeclarationList.parent;
        insertionIndex = fieldDeclaration.offset;
        appendLn = !variableDeclarationList.isFinal && accessor.isGetter;
        nodesToRemove.add(fieldDeclaration);
      }

      if (accessor.isGetter) {
        transformations.add(_generateGetter(accessor, insertionIndex, appendLn)
            );
      }
      if (accessor.isSetter) {
        transformations.add(_generateSetter(accessor, insertionIndex, appendLn)
            );
      }
    }

    // generate methods
    for (final method in clazz.element.methods.where((e) => e.isAbstract &&
        !e.isStatic)) {
      nodesToRemove.add(method.node);
      transformations.add(_generateMethod(method, method.node.offset));
    }

    // remove nodes
    for (final node in nodesToRemove) {
      transformations.add(createRemoveTransformation(node));
    }
  }

  return transformations;
}

Transformation _generateGetter(PropertyAccessorElement accessor, int
    insertionIndex, bool appendLn) {
  final name = accessor.displayName;
  final returnType = accessor.returnType;
  final unionType = getAnnotation(accessor.node, 'UnionType');
  final body = _generateBody("\$unsafe['$name']", returnType, unionType);
  final signature = accessor.node != null ? accessor.node.toSource().substring(
      0, accessor.node.toSource().length - 1) : '$returnType get $name';
  return new Transformation.insertion(insertionIndex, '$signature $body' +
      (appendLn ? '\n  ' : ''));
}

Transformation _generateSetter(PropertyAccessorElement accessor, int
    insertionIndex, bool appendLn) {
  final name = accessor.displayName;
  final paramType = accessor.parameters.first.type;
  final paramName = accessor.parameters.first.displayName;
  return new Transformation.insertion(insertionIndex, 'void set $name(' +
      (paramType.isDynamic ? '' : '$paramType ') + '$paramName) '
      "{ \$unsafe['$name'] = ${_handleParameter(paramName, paramType, null)}; }" +
      (appendLn ? '\n  ' : ''));
}

Transformation _generateMethod(MethodElement method, int insertionIndex) {
  final name = method.displayName;
  final returnType = method.returnType;
  final parameters = method.parameters;
  final unionType = getAnnotation(method.node, 'UnionType');
  final body = _generateBody("\$unsafe.callMethod('$name'" + (parameters.isEmpty
      ? ")" : ", [${parameters.map((p) => p.displayName).join(', ')}])"), returnType,
      unionType);
  final signature = method.node.toSource().substring(0, method.node.toSource(
      ).length - 1);
  return new Transformation.insertion(insertionIndex, '$signature $body');
}

String _handleParameter(String name, DartType type, NodeList<Annotation>
    metadatas) => type != null ? _mayTransformParameter(name, type, metadatas) :
    "jsw.jsify($name)";

String _mayTransformParameter(String name, DartType type, List<Annotation>
    metadatas, {skipNull: false}) {
  if (_isTypeSerializable(type)) return skipNull ? "$name.\$unsafe" :
      "$name == null ? null : $name.\$unsafe";
  if (_isTypeTransferable(type)) return name;
  if (_isTypeJsObject(type)) return name;
  final filterTypesMetadata = (Annotation a) => _isElementTypedWith(a.element is
      ConstructorElement ? a.element.enclosingElement : a.element, _LIBRARY_NAME,
      'Types');
  if (metadatas != null && metadatas.any(filterTypesMetadata)) {
    final types = metadatas.firstWhere(filterTypesMetadata);
    final ListLiteral listOfTypes = types.arguments.arguments.first;
    return listOfTypes.elements.map((Identifier e) {
      final ClassElement classElement = e.staticElement;
      final value = _mayTransformParameter(name, classElement.type, [],
          skipNull: true);
      return '$name is $e ? ${(value != null ? value : name)} : ';
    }).join() + ' $name == null ? null : throw "bad type"';
  }
  return "jsw.jsify($name)";
}

/// return [true] if the type is transferable through dart:js (see https://api.dartlang.org/docs/channels/stable/latest/dart_js.html)
bool _isTypeTransferable(DartType type) {
  final transferables = <String, List<String>> {
    'dart.core': ['num', 'bool', 'String', 'DateTime'],
    'dart.dom.html': ['Blob', 'Event', 'ImageData', 'Node', 'Window'],
    'dart.dom.indexed_db': ['KeyRange'],
    'dart.typed_data': ['TypedData'],
  };
  for (final libraryName in transferables.keys) {
    if (transferables[libraryName].any((className) => _isTypeAssignableWith(
        type, libraryName, className))) {
      return true;
    }
  }
  return false;
}

bool _isTypeJsObject(DartType type) => type != null && _isTypeAssignableWith(
    type, 'dart.js', 'JsObject');

String _generateBody(String content, DartType returnType, Annotation unionType)
    {
  var wrap = (String s) => '=> $s;';
  if (returnType.isVoid) {
    wrap = (String s) => '{ $s; }';
  } else if (returnType.element != null) {
    if (_isTypeTypedWith(returnType, 'dart.core', 'List')) {
      // List<?> or List
      if (returnType is ParameterizedType && _isTypeSerializable(
          returnType.typeArguments.first)) {
        // List<T extends Serializable>
        final genericType = returnType.typeArguments.first;
        wrap = (String s) =>
            '=> jsw.TypedJsArray.\$wrapSerializables($s, $genericType.\$wrap);';
      } else {
        // List or List<T>
        wrap = (String s) => '=> jsw.TypedJsArray.\$wrap($s);';
      }
    } else if (_isTypeSerializable(returnType)) {
      wrap = (String s) => '=> ${returnType}.\$wrap($s);';
    }
  }
  if (returnType.element == null || returnType.isDynamic) {
    if (unionType != null) {
      String t = '(v0) => v0';
      int i = 1;
      final ListLiteral listOfTypes = unionType.arguments.arguments.first;
      listOfTypes.elements.reversed.forEach((Identifier e) {
        final ClassElement classElement = e.staticElement;
        if (_isTypeAssignableWith(classElement.type, _LIBRARY_NAME, 'IsEnum')) {
          t =
              '(v${i+1}) => ((v$i) => v$i != null ? v$i : ($t)(v${i+1}))($e.\$wrap(v${i+1}))';
          i += 2;
        } else if (_isTypeAssignableWith(classElement.type, _LIBRARY_NAME,
            'TypedJsObject')) {
          t = '(v$i) => $e.isInstance(v$i) ? $e.\$wrap(v$i) : ($t)(v$i)';
          i++;
        } else {
          t = '(v$i) => v$i is $e ? v$i : ($t)(v$i)';
          i++;
        }
      });
      wrap = (String s) => '=> ($t)($s);';
    }
  }
  return wrap(content);
}

bool _isTypeSerializable(DartType type) => type != null &&
    _isTypeAssignableWith(type, _LIBRARY_NAME, 'Serializable');

bool _isTypeAssignableWith(DartType type, String libraryName, String className)
    => type != null && _isElementAssignableWith(type.element, libraryName, className
    );

bool _isElementAssignableWith(Element element, String libraryName, String
    className) => _isElementTypedWith(element, libraryName, className) || (element
    is ClassElement && element.allSupertypes.any((supertype) => _isTypeTypedWith(
    supertype, libraryName, className)));

bool _isTypeTypedWith(DartType type, String libraryName, String className) =>
    type != null && _isElementTypedWith(type.element, libraryName, className);

bool _isElementTypedWith(Element element, String libraryName, String className)
    => element.library != null && element.library.name == libraryName &&
    element.name == className;

List<String> getJsName(Annotation jsConstructor) {
  if (jsConstructor == null) return null;
  final NamedExpression param = jsConstructor.arguments.arguments.firstWhere((e)
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
    if (current.element.library.name == _LIBRARY_NAME && current.displayName ==
        'TypedJsObject') {
      return true;
    }
    current = current.element.supertype;
  }
  return false;
});

Annotation getJsConstructor(ClassDeclaration clazz) {
  ClassDeclaration current = clazz;
  while (true) {
    if (current.element.library.isDartCore && current.element.displayName ==
        'Object') {
      return null;
    }
    final jsConstructor = getAnnotation(clazz, 'JsConstructor');
    if (jsConstructor != null) {
      return jsConstructor;
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

Annotation getAnnotation(Declaration declaration, String name) => declaration ==
    null ? null : declaration.metadata.firstWhere((m) => m.element.library.name ==
    _LIBRARY_NAME && m.element is ConstructorElement &&
    m.element.enclosingElement.name == name, orElse: () => null);

bool isMemberAlreadyDefined(ClassDeclaration clazz, String name) =>
    clazz.members.any((m) => (m is MethodDeclaration && m.name.name + (m.isSetter ?
    '=' : '') == name) || (m is FieldDeclaration && m.fields.variables.any((f) =>
    f.name.name == name)) || (m is ConstructorDeclaration && (m.name == null &&
    name.isEmpty || m.name != null && m.name.name == name)));
