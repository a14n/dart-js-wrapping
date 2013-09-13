// Copyright (c) 2013, Alexandre Ardhuin
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

library generator;

import 'dart:io';

import 'package:analyzer_experimental/analyzer.dart';
import 'package:analyzer_experimental/src/generated/scanner.dart';
//import 'package:analyzer_experimental/src/services/formatter_impl.dart';

import 'package:path/path.dart' as p;

const wrapper = const _Wrapper();
class _Wrapper {
  const _Wrapper();
}

const keepAbstract = const _KeepAbstract();
class _KeepAbstract {
  const _KeepAbstract();
}

const skipCast = const _SkipCast();
class _SkipCast {
  const _SkipCast();
}

const skipConstructor = const _SkipConstructor();
class _SkipConstructor {
  const _SkipConstructor();
}

const forMethods = const _ForMethods();
class _ForMethods {
  const _ForMethods();
}

const generate = const _Generate();
class _Generate {
  const _Generate();
}

void transformDirectory(Directory from, Directory to) {
  from.listSync().forEach((FileSystemEntity fse){
    final name = p.basename(fse.path);
    final destination = p.join(to.path, name);
    if (fse is File) {
      transformFile(fse, new File(destination));
    } else if (fse is Directory) {
      final d = new Directory(destination);
      if (d.existsSync()) d..deleteSync(recursive: true);
      d.createSync();
      transformDirectory(fse, d);
    }
  });
}

void transformFile(File from, File to) {
  final name = p.basename(from.path);

  // reset destination
  if (to.existsSync()) to..deleteSync();
  to.createSync();

  // transform
  final unit = parseDartFile(from.path);
  final code = from.readAsStringSync();
  final transformations = _buildTransformations(unit, code);
  final source = _applyTransformations(code, transformations);
//  to.writeAsStringSync(new CodeFormatter().format(CodeKind.COMPILATION_UNIT, source));
  to.writeAsStringSync(source);
}

List<_Transformation> _buildTransformations(CompilationUnit unit, String code) {
  final result = new List<_Transformation>();
  for (final declaration in unit.declarations) {
    if (declaration is ClassDeclaration && _hasAnnotation(declaration, 'wrapper')) {
      // remove @wrapper
      _removeMetadata(result, declaration, (m) => m.name.name == 'wrapper');

      // @forMethods on class
      final forMethodsOnClass = _hasAnnotation(declaration, 'forMethods');
      _removeMetadata(result, declaration, (m) => m.name.name == 'forMethods');

      // @skipCast on class
      final skipCast = _hasAnnotation(declaration, 'skipCast');
      _removeMetadata(result, declaration, (m) => m.name.name == 'skipCast');

      // @skipConstructor on class
      final skipConstructor = _hasAnnotation(declaration, 'skipConstructor');
      _removeMetadata(result, declaration, (m) => m.name.name == 'skipConstructor');

      // remove @keepAbstract or abstract
      final keepAbstract = _hasAnnotation(declaration, 'keepAbstract');
      if (keepAbstract) {
        _removeMetadata(result, declaration, (m) => m.name.name == 'keepAbstract');
      } else if (declaration.abstractKeyword != null) {
        final abstractKeyword = declaration.abstractKeyword;
        _removeToken(result, abstractKeyword);
      }

      // add cast and constructor
      final name = declaration.name;
      final position = declaration.leftBracket.offset;
      final alreadyExtends = declaration.extendsClause != null;
      result.add(new _Transformation(position, position + 1,
          (alreadyExtends ? '' : 'extends jsw.TypedJsObject ') + '{' +
          (skipCast || keepAbstract ? '' : '\n  static $name cast(js.JsObject jsObject) => jsObject == null ? null : new $name.fromJsObject(jsObject);') +
          (skipConstructor ? '' : '\n  $name.fromJsObject(js.JsObject jsObject) : super.fromJsObject(jsObject);')
          ));

      // generate member
      declaration.members.forEach((m){
        final forMethods = forMethodsOnClass || _hasAnnotation(m, 'forMethods');
        final generate = _hasAnnotation(m, 'generate');
        _removeMetadata(result, declaration, (m) => m.name.name == 'generate');
        if (m is FieldDeclaration) {
          final content = new StringBuffer();
          final type = m.fields.type;
          for (final v in m.fields.variables) {
            final name = v.name.name;
            if (name.startsWith('_')) {
              return; // skip fieldDeclaration
            } else {
              _writeSetter(content, name, null, type, forMethods: forMethods);
              content.write('\n');
              _writeGetter(content, name, type, forMethods: forMethods);
              content.write('\n');
            }
          }
          result.add(new _Transformation(m.offset, m.endToken.next.offset, content.toString()));
        } else if (m is MethodDeclaration && m.name.name == 'cast') {
          if (!skipCast) {
            _removeNode(result, m);
          }
        } else if (m is MethodDeclaration && (m.isAbstract || generate) && !m.isStatic && !m.isOperator && !_hasAnnotation(m, 'keepAbstract')) {
          final method = new StringBuffer();
          if (m.isSetter){
            final SimpleFormalParameter param = m.parameters.parameters.first;
            _writeSetter(method, m.name.name, m.returnType, param.type, forMethods: forMethods, paramName: param.identifier.name);
          } else if (m.isGetter) {
            _writeGetter(method, m.name.name, m.returnType, forMethods: forMethods);
          } else {
            if (m.returnType != null) {
              method..write(m.returnType)..write(' ');
            }
            method..write(m.name)..write(m.parameters)..write(_handleReturn("\$unsafe.callMethod('${m.name.name}'" +
                (m.parameters.parameters.isEmpty ? ")" : ", [${m.parameters.parameters.map(_handleFormalParameter).join(', ')}])"), m.returnType));
          }
          result.add(new _Transformation(m.offset, m.end, method.toString()));
        }
      });
    }
  }
  return result;
}

void _writeSetter(StringBuffer sb, String name, TypeName returnType, TypeName paramType, {forMethods: false, paramName: null}) {
  paramName = paramName != null ? paramName : name;
  if (returnType != null) sb.write("${returnType} ");
  if (forMethods) {
    final nameCapitalized = _capitalize(name);
    sb.write("set ${name}(${paramType} ${paramName})${_handleReturn("\$unsafe.callMethod('set${nameCapitalized}', [${_handleParameter(paramName, paramType)}])", returnType)}");
  } else {
    sb.write("set ${name}(${paramType} ${paramName})${_handleReturn("\$unsafe['${name}'] = ${_handleParameter(paramName, paramType)}", returnType)}");
  }
}

void _writeGetter(StringBuffer content, String name, TypeName returnType, {forMethods: false}) {
  if (forMethods) {
    final nameCapitalized = _capitalize(name);
    content..write("${returnType} get ${name}${_handleReturn("\$unsafe.callMethod('get${nameCapitalized}')", returnType)}");
  } else {
    content..write("${returnType} get ${name}${_handleReturn("\$unsafe['${name}']", returnType)}");
  }
}

String _handleFormalParameter(FormalParameter fp) => _handleParameter(fp.identifier.name, fp is SimpleFormalParameter ? (fp as SimpleFormalParameter).type : fp is DefaultFormalParameter && (fp as DefaultFormalParameter).parameter is SimpleFormalParameter ? ((fp as DefaultFormalParameter).parameter as SimpleFormalParameter).type : null);

String _handleParameter(String name, TypeName type) {
  if (type != null) {
    if (type.name.name == 'List') {
      return "${name} == null ? null : ${name} is js.Serializable<js.JsObject> ? ${name} : js.jsify(${name})";
    } else if (type.name.name == 'Map') {
      return "${name} == null ? null : ${name} is js.Serializable<js.JsObject> ? ${name} : js.jsify(${name})";
    }
  }
  return name;
}

String _handleReturn(String content, TypeName returnType) {
  var wrap;
  if (returnType == null || _isTransferableType(returnType)) {
    wrap = (String s) => ' => $s;';
  } else if (returnType.name.name == 'void') {
    wrap = (String s) => ' { $s; }';
  } else if (returnType.name.name == 'List') {
    if (returnType.typeArguments == null || _isTransferableType(returnType.typeArguments.arguments.first)) {
      wrap = (String s) => ' => jsw.TypedJsArray.cast($s);';
    } else {
      wrap = (String s) => ' => jsw.TypedJsArray.castListOfSerializables($s, ${returnType.typeArguments.arguments.first}.cast);';
    }
  } else {
    wrap = (String s) => ' => ${returnType}.cast($s);';
  }
  return wrap(content);
}

bool _isTransferableType(TypeName typeName){
  switch (typeName.name.name) {
    case 'bool':
    case 'String':
    case 'num':
    case 'int':
    case 'double':
    case 'dynamic':
      return true;
  }
  return false;
}

void _removeMetadata(List<_Transformation> transformations, AnnotatedNode n, bool testMetadata(Annotation a)) {
  n.metadata.where(testMetadata).forEach((a){
    _removeNode(transformations, a);
  });
}
void _removeNode(List<_Transformation> transformations, ASTNode n) {
  transformations.add(new _Transformation(n.offset, n.endToken.next.offset, ''));
}
void _removeToken(List<_Transformation> transformations, Token t) {
  transformations.add(new _Transformation(t.offset, t.next.offset, ''));
}

bool _hasAnnotation(AnnotatedNode node, String name) => node.metadata.any((m) => m.name.name == name && m.constructorName == null && m.arguments == null);

String _applyTransformations(String code, List<_Transformation> transformations) {
  int padding = 0;
  for (final t in transformations) {
    code = code.substring(0, t.begin + padding) + t.replace + code.substring(t.end + padding);
    padding += t.replace.length - (t.end - t.begin);
  }
  return code;
}

String _capitalize(String s) => s.length == 0 ? '' : (s.substring(0, 1).toUpperCase() + s.substring(1));

class _Transformation {
  final int begin;
  final int end;
  final String replace;
  _Transformation(this.begin, this.end, this.replace);
}