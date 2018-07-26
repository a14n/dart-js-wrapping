// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

library js_wrapping_generator.js_interface;

import 'dart:async';

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:js_wrapping_generator/src/incremental_generator.dart';
import 'package:source_gen/source_gen.dart';

import 'util.dart';

const String _libName = 'js_wrapping';

const _codecsPrefix = '__codec';

class JsWrappingGenerator extends IncrementalGenerator {
  @override
  Future<String> generateForLibraryElement(
          LibraryReader library, BuildStep buildStep) async =>
      _OldJsInterfaceGenerator().generate(library, buildStep);
}

class _OldJsInterfaceGenerator extends Generator {
  final codecs = <CodecSource>[];

  _OldJsInterfaceGenerator();

  @override
  Future<String> generate(LibraryReader library, _) async {
    final sections = await Future.wait(
        library.allElements.map((e) async => await generateForElement(e)));
    final sectionsOutput = sections.where((e) => e != null).join();
    final codecsOutput = codecs
        .where((c) => c.variableName != null)
        .map((c) => '/// codec for ${c.type}\n'
            'final ${c.variableName} = ${c.initializer};\n')
        .join();
    return '''
$sectionsOutput
$codecsOutput''';
  }

  Future<String> generateForElement(Element element) async {
    // JsInterface
    if (element is ClassElement) {
      if (isJsInterface(element.library, element.type) &&
          isNotGenerated(element) &&
          element.isAbstract &&
          element.isPrivate) {
        return JsInterfaceClassGenerator(element, codecs).generate();
      }

      // JsEnum
      if (hasJsEnumAnnotation(element) &&
          isNotGenerated(element) &&
          element.isPrivate) {
        return JsEnumGenerator(element).generate();
      }
    }

    return null;
  }

  bool isNotGenerated(ClassElement element) =>
      !element.unit.element.name.endsWith('.g.dart');
}

class CodecSource {
  final String type;
  final String variableName;
  final String initializer;
  CodecSource(this.type, this.variableName, this.initializer);
}

class JsEnumGenerator {
  final LibraryElement lib;
  final ClassElement clazz;

  ClassElement _jsNameClass;

  JsEnumGenerator(this.clazz) : lib = clazz.library {
    _jsNameClass = getType(lib, _libName, 'JsName');
  }

  String generate() {
    final values = getEnumValues();
    final jsPath = computeJsName(clazz, getType(lib, _libName, 'JsName'));
    final name = getPublicClassName(clazz);

    final result = StringBuffer()
      ..write('class $name extends JsEnum {')
      ..write("static final values = <$name>[${values.join(',')}];");
    for (final value in values) {
      final jsValue = "${getPath(jsPath)}['$value']";
      result
        ..write("static final $value = $name._('$value', $jsValue)")
        ..write(';');
    }
    result.write('''

  final String _name;
  $name._(this._name, o) : super.created(o);

  @override
  String toString() => '$name.\$_name';

  // dumb code to remove analyzer hint for unused _$name
  _$name _dumbMethod1() => _dumbMethod2();
  _$name _dumbMethod2() => _dumbMethod1();
}
''');
    return result.toString();
  }

  Iterable<String> getEnumValues() {
    final enumDecl = getNodeOfElement(clazz) as EnumDeclaration;
    return enumDecl.constants.map((e) => e.name.name);
  }
}

class JsInterfaceClassGenerator {
  final LibraryElement lib;
  final ClassElement clazz;
  final transformer = Transformer();
  final List<CodecSource> codecs;

  ClassElement _jsNameClass;

  JsInterfaceClassGenerator(this.clazz, this.codecs) : lib = clazz.library {
    _jsNameClass = getType(lib, _libName, 'JsName');
  }

  String generate() {
    final newClassName = getPublicClassName(clazz);

    final classNode = clazz.computeNode() as ClassDeclaration;

    // add implements to make analyzer happy
    transformer.insertAt(classNode.offset, '@GeneratedFrom(${clazz.name})');

    // remove implement JsInterface
    if (classNode.implementsClause != null) {
      var interfaceCount = classNode.implementsClause.interfaces.length;
      for (final e in classNode.implementsClause.interfaces
          .where((e) => e.name.name == 'JsInterface')) {
        interfaceCount--;
        if (classNode.implementsClause.interfaces.length == 1) {
          transformer.removeNode(e);
        } else {
          final index = classNode.implementsClause.interfaces.indexOf(e);
          int begin, end;
          if (index == 0) {
            begin = e.offset;
            end = classNode.implementsClause.interfaces[1].offset;
          } else {
            begin = classNode.implementsClause.interfaces[index - 1].end;
            end = e.end;
          }
          transformer.removeBetween(begin, end);
        }
      }
      if (interfaceCount == 0)
        transformer.removeToken(classNode.implementsClause.implementsKeyword);
    }

    // add JsInterface extension
    if (classNode.extendsClause == null) {
      transformer.insertAt(classNode.name.end, ' extends JsInterface');
    }

    transformer
      // remove abstract
      ..removeToken(classNode.abstractKeyword)
      // rename class
      ..replace(classNode.name.offset, classNode.name.end, newClassName);

    // generate the constructor .created
    if (!clazz.constructors.any((e) => e.name == 'created')) {
      final insertionIndex =
          clazz.constructors.where((e) => !e.isSynthetic).isEmpty
              ? classNode.leftBracket.end
              : clazz.constructors.last.computeNode().end;
      transformer.insertAt(insertionIndex,
          '$newClassName.created(JsObject o) : super.created(o);');
    }

    // generate constructors
    for (final constr in clazz.constructors) {
      if (constr.isSynthetic) continue;

      // rename
      transformer.replace(constr.computeNode().returnType.offset,
          constr.computeNode().returnType.end, newClassName);

      // generate only factory constructor returning null
      final body = constr.computeNode().body;
      if (!constr.isFactory || !hasToBeGenerated(body)) {
        continue;
      }

      var newJsObject = 'JsObject(';
      if (hasAnonymousAnnotations) {
        if (constr.parameters.isNotEmpty) {
          throw ArgumentError('@anonymous JsInterface '
              'can not have constructor with parameters');
        }
        newJsObject += "context['Object']";
      } else {
        final jsName = computeJsName(clazz, _jsNameClass);
        newJsObject += getPath(jsName);
        if (constr.parameters.isNotEmpty) {
          newJsObject += ', [${convertParameters(constr.parameters)}]';
        }
      }
      newJsObject += ')';

      final constructorDecl = constr.computeNode();
      transformer
        ..removeToken(constructorDecl.factoryKeyword)
        ..removeNode(constructorDecl.body)
        ..insertAt(constructorDecl.end, ' : this.created($newJsObject);');
    }

    // generate properties
    clazz.accessors.where((e) => !e.isSynthetic).forEach(transformAccessor);
    transformVariables(clazz.accessors
        .where((e) => e.isSynthetic)
        .where((e) => e.variable.initializer == null));

    // generate abstract methods
    clazz.methods.forEach(transformMethod);

    return transformer.applyOn(clazz);
  }

  String convertParameters(List<ParameterElement> parameters) {
    final nonNamedParams = parameters.where((p) => !p.isNamed);
    final namedParams = parameters.where((p) => p.isNamed);

    final parameterList = StringBuffer()
      ..write(nonNamedParams.map(convertParameterToJs).join(', '));
    if (namedParams.isNotEmpty) {
      if (nonNamedParams.isNotEmpty) parameterList.write(',');
      parameterList
        ..write('() {')
        ..write("final o = JsObject(context['Object']);");
      for (final p in namedParams) {
        parameterList
          ..write('if (${p.displayName} != null)')
          ..write(" o['${p.displayName}'] = ${convertParameterToJs(p)};");
      }
      parameterList.write('return o;} ()');
    }
    return parameterList.toString();
  }

  String convertParameterToJs(ParameterElement p) {
    final codec = getCodec(p.type);
    return codec == null ? p.displayName : '$codec.encode(${p.displayName})';
  }

  bool get hasAnonymousAnnotations => clazz
      .computeNode()
      .metadata
      .where((a) =>
          a.element.library.name == _libName && a.element.name == 'anonymous')
      .isNotEmpty;

  void transformAccessor(PropertyAccessorElement accessor) {
    if (accessor.isStatic) {
      final body = (accessor.computeNode() as MethodDeclaration).body;
      if (body is EmptyFunctionBody ||
          body is BlockFunctionBody && body.block.statements.isEmpty ||
          hasToBeGenerated(body)) {
        transformer.removeBetween(body.offset, body.end - 1);
      } else {
        return;
      }
    } else if (!accessor.isAbstract) {
      return;
    }

    final jsName = getNameAnnotation(
        accessor.computeNode() as AnnotatedNode, _jsNameClass);
    final name = jsName != null
        ? jsName
        : accessor.isPrivate
            ? accessor.displayName.substring(1)
            : accessor.displayName;

    final target = accessor.isStatic
        ? getPath(computeJsName(clazz, _jsNameClass))
        : 'asJsObject(this)';

    String newFuncDecl;
    if (accessor.isGetter) {
      final getterBody = createGetterBody(accessor.returnType, name, target);
      newFuncDecl = ' => $getterBody';
    } else if (accessor.isSetter) {
      final setterBody =
          createSetterBody(accessor.parameters.first, target, jsName: name);
      newFuncDecl = ' { $setterBody }';
    }
    transformer.replace(accessor.computeNode().end - 1,
        accessor.computeNode().end, newFuncDecl);

    getAnnotations(accessor.computeNode() as AnnotatedNode, _jsNameClass)
        .forEach(transformer.removeNode);
  }

  void transformVariables(Iterable<PropertyAccessorElement> accessors) {
    for (final accessor in accessors) {
      final varDeclList =
          accessor.variable.computeNode().parent as VariableDeclarationList;
      var jsName = getNameAnnotation(
          accessor.variable.computeNode() as AnnotatedNode, _jsNameClass);
      jsName = jsName != null
          ? jsName
          : getNameAnnotation(
              varDeclList.parent as AnnotatedNode, _jsNameClass);
      jsName = jsName != null
          ? jsName
          : accessor.isPrivate
              ? accessor.displayName.substring(1)
              : accessor.displayName;
      final name = accessor.displayName;

      final target = accessor.isStatic
          ? getPath(computeJsName(clazz, _jsNameClass))
          : 'asJsObject(this)';

      final varType =
          varDeclList.type != null ? varDeclList.type.toString() : '';
      var code = accessor.isStatic ? 'static ' : '';
      if (accessor.isGetter) {
        final getterBody =
            createGetterBody(accessor.returnType, jsName, target);
        code += '$varType get $name => $getterBody';
      } else if (accessor.isSetter) {
        final param = accessor.parameters.first;
        final setterBody = createSetterBody(param, target, jsName: jsName);
        code += ' set $name($varType ${param.displayName}){ $setterBody }';
      }
      transformer.insertAt(varDeclList.end + 1, code);
    }

    // remove variable declarations
    final variables = accessors.map((e) => e.variable.computeNode()).toSet();
    final varDeclLists = variables.map((e) => e.parent).toSet();
    for (final varDeclList in varDeclLists) {
      transformer.removeNode(varDeclList.parent);
    }
  }

  void transformMethod(MethodElement m) {
    if (m.isStatic) {
      final body = m.computeNode().body;
      if (body is EmptyFunctionBody || hasToBeGenerated(body)) {
        transformer.removeBetween(body.offset, body.end - 1);
      } else {
        return;
      }
    }
    if (!m.isStatic && !m.isAbstract) return;

    final jsName = getNameAnnotation(m.computeNode(), _jsNameClass);
    final name = jsName != null
        ? jsName
        : m.isPrivate ? m.displayName.substring(1) : m.displayName;

    final target = m.isStatic
        ? getPath(computeJsName(clazz, _jsNameClass))
        : 'asJsObject(this)';

    var call = "$target.callMethod('$name'";
    if (m.parameters.isNotEmpty) {
      final parameterList = convertParameters(m.parameters);
      call += ', [$parameterList]';
    }
    call += ')';

    if (m.returnType.isVoid) {
      transformer.replace(
          m.computeNode().end - 1, m.computeNode().end, '{ $call; }');
    } else {
      final codec = getCodec(m.returnType);
      transformer.insertAt(m.computeNode().end - 1,
          " => ${codec == null ? call : "$codec.decode($call)"}");
    }

    getAnnotations(m.computeNode(), _jsNameClass)
        .forEach(transformer.removeNode);
  }

  String createGetterBody(DartType type, String name, String target) {
    final codec = getCodec(type);
    return '${codec == null ? "$target['$name']" : "$codec.decode($target['$name'])"};';
  }

  String createSetterBody(ParameterElement param, String target,
      {String jsName}) {
    final name = param.displayName;
    final type = param.type;
    final n = jsName != null ? jsName : name;
    final codec = getCodec(type);
    return "$target['$n'] = ${codec == null ? name : "$codec.encode($name)"};";
  }

  String getCodec(DartType type) => registerCodecIfAbsent(type, () {
        if (type.isDynamic || type.isObject) {
          return 'DynamicCodec()';
        } else if (isJsInterface(lib, type)) {
          return 'JsInterfaceCodec<$type>((o) => $type.created(o))';
        } else if (isListType(type)) {
          final typeParam = (type as InterfaceType).typeArguments.first;
          return 'JsListCodec<$typeParam>(${getCodec(typeParam)})';
        } else if (isJsEnum(type)) {
          return createEnumCodec(type);
        } else if (type is FunctionType) {
          return createFunctionCodec(type);
        } else if (isMapType(type)) {
          final typeParam = (type as InterfaceType).typeArguments[1];
          return 'JsObjectAsMapCodec<$typeParam>(${getCodec(typeParam)})';
        }
        return null;
      });

  bool isJsEnum(DartType type) =>
      !type.isDynamic &&
      type.isSubtypeOf(getType(lib, _libName, 'JsEnum').type);

  String createEnumCodec(DartType type) => 'BiMapCodec<$type, dynamic>('
      'Map<$type, dynamic>.fromIterable($type.values, value: asJs)'
      ')';

  String createFunctionCodec(FunctionType type) {
    final returnCodec = getCodec(type.returnType);
    const paramPrefix = r'p$';
    var parametersDecl = type.parameters
        .where((p) => p.isNotOptional)
        .map((p) => '$paramPrefix${p.name}')
        .join(', ');
    if (type.parameters.any((p) => p.isOptionalPositional)) {
      if (parametersDecl.isNotEmpty) parametersDecl += ',';
      parametersDecl += '[';
      parametersDecl += type.parameters
          .where((p) => p.isOptionalPositional)
          .map((p) => '$paramPrefix${p.name}')
          .join(', ');
      parametersDecl += ']';
    }
    final decode = () {
      final parameters = type.parameters.map((p) {
        final codec = getCodec(p.type);
        return codec != null
            ? '$codec.encode($paramPrefix${p.name})'
            : '$paramPrefix${p.name}';
      }).join(',');
      var call = 'f is JsFunction'
          ' ? f.apply([$parameters])'
          ' : Function.apply(f, [$parameters])';
      if (returnCodec != null) {
        call = '$returnCodec.decode($call)';
      } else if (type.returnType.isVoid) {
        return '(f) => ($parametersDecl) { $call; }';
      }
      return '(f) => ($parametersDecl) => $call';
    }();

    final encode = () {
      final paramCodecs = type.parameters.map((p) => p.type).map(getCodec);
      if (returnCodec == null && paramCodecs.every((c) => c == null)) {
        return '(f) => f';
      } else {
        final parameters = type.parameters.map((p) {
          final codec = getCodec(p.type);
          return codec != null
              ? '$codec.decode($paramPrefix${p.name})'
              : '$paramPrefix${p.name}';
        }).join(',');
        var call = 'f($parameters)';
        if (returnCodec != null) {
          call = '$returnCodec.encode($call)';
        } else if (type.returnType.isVoid) {
          return '(f) => ($parametersDecl) { $call; }';
        }
        return '(f) => ($parametersDecl) => $call';
      }
    }();

    // TODO(aa) type for Function can be "int -> String" : create typedef
    return 'FunctionCodec<Function>/*<$type>*/($encode, $decode,)';
  }

  String registerCodecIfAbsent(DartType type, String getCodecInitializer()) {
    if (type.isVoid) return null;
    final typeAsString = '${type.element.library}.$type';
    var codec =
        codecs.firstWhere((cs) => cs.type == typeAsString, orElse: () => null);
    if (codec == null) {
      final initializer = getCodecInitializer();
      if (initializer == null) return null;
      codec = CodecSource(
          typeAsString, '$_codecsPrefix${codecs.length}', initializer);
      codecs.add(codec);
    }
    return codec.variableName;
  }

  bool isListType(DartType type) =>
      !type.isDynamic &&
      type.isSubtypeOf(getType(lib, 'dart.core', 'List')
          .type
          .instantiate([DynamicTypeImpl.instance]));

  bool isMapType(DartType type) =>
      !type.isDynamic &&
      type.isSubtypeOf(getType(lib, 'dart.core', 'Map').type.instantiate([
        getType(lib, 'dart.core', 'String').type,
        DynamicTypeImpl.instance
      ]));

  /// return `true` if the type is transferable through dart:js
  /// (see https://api.dartlang.org/docs/channels/stable/latest/dart_js.html)
  bool isTypeTransferable(DartType type) {
    const transferables = <String, List<String>>{
      'dart.js': ['JsObject'],
      'dart.core': ['num', 'bool', 'String', 'DateTime'],
      'dart.dom.html': ['Blob', 'Event', 'ImageData', 'Node', 'Window'],
      'dart.dom.indexed_db': ['KeyRange'],
      'dart.typed_data': ['TypedData'],
    };
    for (final libName in transferables.keys) {
      if (getLib(lib, libName) == null) continue;
      if (transferables[libName].any((className) =>
          type.isSubtypeOf(getType(lib, libName, className).type))) {
        return true;
      }
    }
    return false;
  }

  bool hasToBeGenerated(FunctionBody body) =>
      body is ExpressionFunctionBody &&
      (body.expression is NullLiteral ||
          body.expression is Identifier &&
              (body.expression as Identifier).bestElement?.name == r'$js');
}

String computeJsName(ClassElement clazz, ClassElement jsNameClass) {
  var name = '';

  final nameOfLib =
      getNameAnnotation(clazz.library.unit.directives.first, jsNameClass);
  if (nameOfLib != null) name += '$nameOfLib.';

  final nameOfClass = getNameAnnotation(getNodeOfElement(clazz), jsNameClass);
  if (nameOfClass != null) {
    name += nameOfClass;
  } else {
    name += getPublicClassName(clazz);
  }
  return name;
}

String getPublicClassName(ClassElement clazz) =>
    clazz.isPrivate ? clazz.displayName.substring(1) : clazz.displayName;

// workaround issue 23071
AnnotatedNode getNodeOfElement(Element e) {
  if (e == null || e.isSynthetic) return null;
  if (!(e is ClassElement && e.isEnum)) return e.computeNode() as AnnotatedNode;
  return e.library.units
      .expand((u) => u
          .computeNode()
          .declarations
          .where((d) => d is EnumDeclaration && d.name.name == e.name))
      .first;
}

bool hasJsEnumAnnotation(ClassElement clazz) => clazz
    .computeNode()
    .metadata
    .where(
        (a) => a.element.library.name == _libName && a.element.name == 'jsEnum')
    .isNotEmpty;

bool isJsInterface(LibraryElement lib, DartType type) =>
    !type.isDynamic &&
    type.isSubtypeOf(getType(lib, _libName, 'JsInterface').type);

String getNameAnnotation(AnnotatedNode node, ClassElement jsNameClass) {
  final jsNames = getAnnotations(node, jsNameClass);
  if (jsNames.isEmpty) return null;
  final a = jsNames.single;
  if (a.arguments.arguments.length == 1) {
    final param = a.arguments.arguments.first;
    if (param is StringLiteral) {
      return param.stringValue;
    }
  }
  return null;
}

String getPath(String path) =>
    path.split('.').fold('context', (t, p) => "$t['$p']");
