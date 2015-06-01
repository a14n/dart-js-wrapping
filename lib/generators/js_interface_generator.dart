// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

library js_wrapping.generator.js_interface;

import 'dart:async';

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';

import 'package:source_gen/source_gen.dart';

import 'util.dart';

const _LIB_NAME = 'js_wrapping';

const _CODECS_PREFIX = '__codec';

int _codecId = 1;

class JsInterfaceGenerator extends Generator {
  final codecs = <LibraryElement, List<CodecSource>>{};
  final codecsAlreadyEmitted = <LibraryElement, List<CodecSource>>{};

  JsInterfaceGenerator();

  Future<String> generate(Element element) async {
    codecs.putIfAbsent(element.library, () => <CodecSource>[]);
    codecsAlreadyEmitted.putIfAbsent(element.library, () => <CodecSource>[]);

    // JsInterface
    if (element is ClassElement &&
        isJsInterface(element.library, element.type) &&
        isNotGenerated(element) &&
        element.isAbstract &&
        element.isPrivate) {
      final codecsOfLib = codecs[element.library];

      String output =
          new JsInterfaceClassGenerator(element, codecsOfLib).generate();

      // generate new codecs
      final emitedCodecsOfLib = codecsAlreadyEmitted[element.library];
      if (codecsOfLib.length > emitedCodecsOfLib.length) {
        for (int i = emitedCodecsOfLib.length; i < codecsOfLib.length; i++) {
          final codec = codecsOfLib[i];
          emitedCodecsOfLib.add(codec);
          if (codec.variableName != null) {
            output += '\n/// codec for ${codec.type}\n';
            output += 'final ${codec.variableName} = ${codec.initializer};\n';
          }
        }
      }

      return output;
    }

    // JsEnum
    if (element is ClassElement &&
        hasJsEnumAnnotation(element) &&
        isNotGenerated(element) &&
        element.isPrivate) {
      return new JsEnumGenerator(element).generate();
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

  JsEnumGenerator(ClassElement clazz)
      : lib = clazz.library,
        clazz = clazz {
    _jsNameClass = getType(lib, _LIB_NAME, 'JsName');
  }

  String generate() {
    final values = getEnumValues();
    final jsPath = computeJsName(clazz, getType(lib, _LIB_NAME, 'JsName'));
    final name = getPublicClassName(clazz);

    String result = '';

    result += 'class $name extends JsEnum {';
    result += "static final values = <$name>[${values.join(',')}];";
    for (final value in values) {
      final jsValue = "${getPath(jsPath)}['$value']";
      result += "static final $value = new $name._('$value', $jsValue)";
      result += ";\n";
    }
    result += '''

  final String _name;
  $name._(this._name, o) : super.created(o);

  String toString() => '$name.\$_name';

  // dumb code to remove analyzer hint for unused _$name
  _$name _dumbMethod1() => _dumbMethod2();
  _$name _dumbMethod2() => _dumbMethod1();
}
''';
    return result;
  }

  Iterable<String> getEnumValues() {
    EnumDeclaration enumDecl = getNodeOfElement(clazz);
    return enumDecl.constants.map((e) => e.name.name);
  }
}

class JsInterfaceClassGenerator {
  final LibraryElement lib;
  final ClassElement clazz;
  final transformer = new Transformer();
  final List<CodecSource> codecs;

  ClassElement _jsNameClass;

  JsInterfaceClassGenerator(ClassElement clazz, this.codecs)
      : lib = clazz.library,
        clazz = clazz {
    _jsNameClass = getType(lib, _LIB_NAME, 'JsName');
  }

  String generate() {
    final newClassName = getPublicClassName(clazz);

    final ClassDeclaration classNode = clazz.node;

    // add implements to make analyzer happy
    if (classNode.implementsClause == null) {
      transformer.insertAt(
          classNode.leftBracket.offset, ' implements ${clazz.displayName}');
    } else {
      var interfaceCount = classNode.implementsClause.interfaces.length;
      // remove implement JsInterface
      classNode.implementsClause.interfaces
          .where((e) => e.name.name == 'JsInterface')
          .forEach((e) {
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
      });

      transformer.insertAt(classNode.implementsClause.end,
          (interfaceCount > 0 ? ', ' : '') + clazz.displayName);
    }

    // add JsInterface extension
    if (classNode.extendsClause == null) {
      transformer.insertAt(classNode.name.end, ' extends JsInterface');
    }

    // remove abstract
    transformer.removeToken(classNode.abstractKeyword);

    // rename class
    transformer.replace(
        classNode.name.offset, classNode.name.end, newClassName);

    // generate constructors
    for (final constr in clazz.constructors) {
      if (constr.isSynthetic) continue;

      // rename
      transformer.replace(constr.node.returnType.offset,
          constr.node.returnType.end, newClassName);

      // generate only external factory constructor
      if (!constr.isFactory ||
          constr.node.externalKeyword == null ||
          constr.node.initializers.isNotEmpty) {
        continue;
      }

      var newJsObject = "new JsObject(";
      if (hasAnonymousAnnotations) {
        if (constr.parameters.isNotEmpty) {
          throw '@anonymous JsInterface can not have constructor with '
              'parameters';
        }
        newJsObject += "context['Object']";
      } else {
        final jsName = computeJsName(clazz, _jsNameClass);
        newJsObject += getPath(jsName);
        if (constr.parameters.isNotEmpty) {
          final parameterList = convertParameters(constr.parameters);
          newJsObject += ", [$parameterList]";
        }
      }
      newJsObject += ")";

      transformer.removeToken(constr.node.factoryKeyword);
      transformer.removeToken(constr.node.externalKeyword);
      transformer.insertAt(
          constr.node.end - 1, " : this.created($newJsObject)");
    }

    // generate the constructor .created
    if (!clazz.constructors.any((e) => e.name == 'created')) {
      final insertionIndex = clazz.constructors
              .where((e) => !e.isSynthetic).isEmpty
          ? classNode.leftBracket.end
          : clazz.constructors.first.node.offset;
      transformer.insertAt(insertionIndex,
          '$newClassName.created(JsObject o) : super.created(o);\n');
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
    final nonNamedParams =
        parameters.where((p) => p.parameterKind != ParameterKind.NAMED);
    final namedParams =
        parameters.where((p) => p.parameterKind == ParameterKind.NAMED);

    String parameterList = nonNamedParams.map(convertParameterToJs).join(', ');
    if (namedParams.isNotEmpty) {
      if (nonNamedParams.isNotEmpty) parameterList += ',';
      parameterList += '() {';
      parameterList += "final o = new JsObject(context['Object']);";
      for (final p in namedParams) {
        parameterList +=
            "if (${p.displayName} != null) o['${p.displayName}'] = " +
                convertParameterToJs(p) +
                ';';
      }
      parameterList += 'return o;';
      parameterList += '} ()';
    }
    return parameterList;
  }

  String convertParameterToJs(ParameterElement p) {
    final codec = getCodec(p.type);
    return codec == null ? p.displayName : '$codec.encode(${p.displayName})';
  }

  bool get hasAnonymousAnnotations => clazz.node.metadata.where(
      (a) => a.element.library.name == _LIB_NAME &&
          a.element.name == 'anonymous').isNotEmpty;

  void transformAccessor(PropertyAccessorElement accessor) {
    if (accessor.isStatic &&
        (accessor.node as MethodDeclaration).externalKeyword == null) return;
    if (!accessor.isStatic && !accessor.isAbstract) return;

    if (accessor.isStatic &&
        (accessor.node as MethodDeclaration).externalKeyword != null) {
      transformer
          .removeToken((accessor.node as MethodDeclaration).externalKeyword);
    }

    final jsName = getNameAnnotation(accessor.node, _jsNameClass);
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
      newFuncDecl = " => $getterBody";
    } else if (accessor.isSetter) {
      final setterBody =
          createSetterBody(accessor.parameters.first, target, jsName: name);
      newFuncDecl = " { $setterBody }";
    }
    transformer.replace(accessor.node.end - 1, accessor.node.end, newFuncDecl);

    getAnnotations(accessor.node, _jsNameClass).forEach(transformer.removeNode);
  }

  void transformVariables(Iterable<PropertyAccessorElement> accessors) {
    accessors.forEach((accessor) {
      final VariableDeclarationList varDeclList = accessor.variable.node.parent;
      var jsName = getNameAnnotation(accessor.variable.node, _jsNameClass);
      jsName = jsName != null
          ? jsName
          : getNameAnnotation(varDeclList.parent, _jsNameClass);
      jsName = jsName != null
          ? jsName
          : accessor.isPrivate
              ? accessor.displayName.substring(1)
              : accessor.displayName;
      var name = accessor.displayName;

      final target = accessor.isStatic
          ? getPath(computeJsName(clazz, _jsNameClass))
          : 'asJsObject(this)';

      final varType =
          varDeclList.type != null ? varDeclList.type.toString() : '';
      var code = accessor.isStatic ? 'static ' : '';
      if (accessor.isGetter) {
        final getterBody =
            createGetterBody(accessor.returnType, jsName, target);
        code += "$varType get $name => $getterBody";
      } else if (accessor.isSetter) {
        final param = accessor.parameters.first;
        final setterBody = createSetterBody(param, target, jsName: jsName);
        code += accessor.returnType.displayName +
            " set $name($varType ${param.displayName})"
            "{ $setterBody }";
      }
      transformer.insertAt(varDeclList.end + 1, code);
    });

    // remove variable declarations
    final Set<VariableDeclaration> variables =
        accessors.map((e) => e.variable.node).toSet();
    final Set<VariableDeclarationList> varDeclLists =
        variables.map((e) => e.parent).toSet();
    varDeclLists.forEach((varDeclList) {
      transformer.removeNode(varDeclList.parent);
    });
  }

  void transformMethod(MethodElement m) {
    if (m.isStatic && m.node.externalKeyword == null) return;
    if (!m.isStatic && !m.isAbstract) return;

    if (m.isStatic && m.node.externalKeyword != null) {
      transformer.removeToken(m.node.externalKeyword);
    }

    final jsName = getNameAnnotation(m.node, _jsNameClass);
    final name = jsName != null
        ? jsName
        : m.isPrivate ? m.displayName.substring(1) : m.displayName;

    final target = m.isStatic
        ? getPath(computeJsName(clazz, _jsNameClass))
        : 'asJsObject(this)';

    var call = "$target.callMethod('$name'";
    if (m.parameters.isNotEmpty) {
      final parameterList = convertParameters(m.parameters);
      call += ", [$parameterList]";
    }
    call += ")";

    if (m.returnType.isVoid) {
      transformer.replace(m.node.end - 1, m.node.end, "{ $call; }");
    } else {
      final codec = getCodec(m.returnType);
      transformer.insertAt(m.node.end - 1, " => ${codec == null
          ? call
          : "$codec.decode($call)"}");
    }

    getAnnotations(m.node, _jsNameClass).forEach(transformer.removeNode);
  }

  String createGetterBody(DartType type, String name, String target) {
    final codec = getCodec(type);
    return (codec == null
            ? "$target['$name']"
            : "$codec.decode($target['$name'])") +
        ';';
  }

  String createSetterBody(ParameterElement param, String target,
      {String jsName}) {
    final name = param.displayName;
    final type = param.type;
    jsName = jsName != null ? jsName : name;
    final codec = getCodec(type);
    return "$target['$jsName'] = " +
        (codec == null ? name : "$codec.encode($name)") +
        ';';
  }

  String getCodec(DartType type) => registerCodecIfAbsent(type, () {
    if (isJsInterface(lib, type)) {
      return 'new JsInterfaceCodec<$type>((o) => new $type.created(o))';
    } else if (isListType(type)) {
      final typeParam = (type as InterfaceType).typeArguments.first;
      return 'new JsListCodec<$typeParam>(${getCodec(typeParam)})';
    } else if (isJsEnum(type)) {
      return createEnumCodec(type);
    } else if (type is FunctionType) {
      return createFunctionCodec(type);
    } else if (isMapType(type)) {
      final typeParam = (type as InterfaceType).typeArguments[1];
      return 'new JsObjectAsMapCodec<$typeParam>(${getCodec(typeParam)})';
    }
    return null;
  });

  bool isJsEnum(DartType type) => !type.isDynamic &&
      type.isSubtypeOf(getType(lib, _LIB_NAME, 'JsEnum').type);

  String createEnumCodec(DartType type) => 'new BiMapCodec<$type, dynamic>('
      'new Map<$type, dynamic>.fromIterable($type.values, value: asJs)'
      ')';

  String createFunctionCodec(FunctionType type) {
    final returnCodec = getCodec(type.returnType);

    final parameters = type.parameters.map((p) => 'p_' + p.name).join(', ');
    String parametersDecl = type.parameters
        .where((p) => p.parameterKind == ParameterKind.REQUIRED)
        .map((p) => 'p_' + p.name)
        .join(', ');
    if (type.parameters
        .any((p) => p.parameterKind == ParameterKind.POSITIONAL)) {
      if (parametersDecl.isNotEmpty) parametersDecl += ',';
      parametersDecl += '[';
      parametersDecl += type.parameters
          .where((p) => p.parameterKind == ParameterKind.POSITIONAL)
          .map((p) => 'p_' + p.name)
          .join(', ');
      parametersDecl += ']';
    }

    final decode = () {
      var paramChanges = '';
      type.parameters.forEach((p) {
        final codec = getCodec(p.type);
        if (codec != null) {
          paramChanges += 'p_${p.name} = $codec.encode(p_${p.name});';
        }
      });
      var call = 'f.apply([$parameters])';
      if (returnCodec != null) {
        call = 'final result = $call; return $returnCodec.decode(result);';
      } else if (!type.returnType.isVoid) {
        call = 'return $call;';
      } else {
        call = '$call;';
      }
      return '(JsFunction f) => ($parametersDecl) { $paramChanges $call }';
    }();

    final encode = () {
      final paramCodecs = type.parameters.map((p) => p.type).map(getCodec);
      if (returnCodec == null && paramCodecs.every((c) => c == null)) {
        return '(f) => f';
      } else {
        var paramChanges = '';
        type.parameters.forEach((p) {
          final codec = getCodec(p.type);
          if (codec != null) {
            paramChanges += 'p_${p.name} = $codec.decode(p_${p.name});';
          }
        });
        var call = 'f($parameters)';
        if (returnCodec != null) {
          call = 'final result = $call; return $returnCodec.encode(result);';
        } else if (!type.returnType.isVoid) {
          call = 'return $call;';
        } else {
          call = '$call;';
        }
        return '(f) => ($parametersDecl) { $paramChanges $call }';
      }
    }();

    // TODO(aa) type for Function can be "int -> String" : create typedef
    return 'new FunctionCodec/*<$type>*/($encode, $decode)';
  }

  String registerCodecIfAbsent(DartType type, String getCodecInitializer()) {
    if (type.isVoid) return null;
    final typeAsString =
        type.element.library.toString() + '.' + type.toString();
    CodecSource codec =
        codecs.firstWhere((cs) => cs.type == typeAsString, orElse: () => null);
    if (codec == null) {
      final initializer = getCodecInitializer();
      if (initializer == null) return null;
      codec = new CodecSource(
          typeAsString, '$_CODECS_PREFIX${_codecId++}', initializer);
      codecs.add(codec);
    }
    return codec.variableName;
  }

  bool isListType(DartType type) => !type.isDynamic &&
      type.isSubtypeOf(getType(lib, 'dart.core', 'List').type
          .substitute4([DynamicTypeImpl.instance]));

  bool isMapType(DartType type) => !type.isDynamic &&
      type.isSubtypeOf(getType(lib, 'dart.core', 'Map').type.substitute4([
    getType(lib, 'dart.core', 'String').type,
    DynamicTypeImpl.instance
  ]));

  /// return [true] if the type is transferable through dart:js
  /// (see https://api.dartlang.org/docs/channels/stable/latest/dart_js.html)
  bool isTypeTransferable(DartType type) {
    final transferables = const <String, List<String>>{
      'dart.js': const ['JsObject'],
      'dart.core': const ['num', 'bool', 'String', 'DateTime'],
      'dart.dom.html': const ['Blob', 'Event', 'ImageData', 'Node', 'Window'],
      'dart.dom.indexed_db': const ['KeyRange'],
      'dart.typed_data': const ['TypedData'],
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
}

String computeJsName(ClassElement clazz, ClassElement jsNameClass) {
  var name = "";

  final nameOfLib =
      getNameAnnotation(clazz.library.unit.directives.first, jsNameClass);
  if (nameOfLib != null) name += nameOfLib + '.';

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
  if (!(e is ClassElement && e.isEnum)) return e.node;
  return e.library.units.expand((u) => u.node.declarations
      .where((d) => d is EnumDeclaration && d.name.name == e.name)).first;
}

bool hasJsEnumAnnotation(ClassElement clazz) => clazz.node.metadata.where(
    (a) => a.element.library.name == _LIB_NAME &&
        a.element.name == 'jsEnum').isNotEmpty;

bool isJsInterface(LibraryElement lib, DartType type) => !type.isDynamic &&
    type.isSubtypeOf(getType(lib, _LIB_NAME, 'JsInterface').type);

String getNameAnnotation(AnnotatedNode node, ClassElement jsNameClass) {
  final jsNames = getAnnotations(node, jsNameClass);
  if (jsNames.isEmpty) return null;
  final a = jsNames.single;
  if (a.arguments.arguments.length == 1) {
    var param = a.arguments.arguments.first;
    if (param is StringLiteral) {
      return param.stringValue;
    }
  }
  return null;
}

String getPath(String path) =>
    path.split('.').fold('context', (String t, p) => "$t['$p']");
