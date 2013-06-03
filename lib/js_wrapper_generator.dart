library js_wrapper_generator;

import 'package:analyzer_experimental/src/generated/ast.dart';
import 'package:analyzer_experimental/src/generated/error.dart';
import 'package:analyzer_experimental/src/generated/parser.dart';
import 'package:analyzer_experimental/src/generated/scanner.dart';

final wrapper = const _Wrapper();
class _Wrapper{
  const _Wrapper();
}

final keepAbstract = const _KeepAbstract();
class _KeepAbstract{
  const _KeepAbstract();
}

String transform(String code) {
  final unit = _parseCompilationUnit(code);
  final transformations = _buildTransformations(unit, code);
  return _applyTransformations(code, transformations);
}

List<_Transformation> _buildTransformations(CompilationUnit unit, String code) {
  final result = new List<_Transformation>();
  for (var declaration in unit.declarations) {
    if (declaration is ClassDeclaration && hasAnnotation(declaration, 'wrapper')) {
      // remove @wrapper
      declaration.metadata.where((m) => m.name.name == 'wrapper' && m.constructorName == null && m.arguments == null).forEach((m){
        result.add(new _Transformation(m.offset, m.endToken.next.offset, ''));
      });

      // remove @keepAbstract or abstract
      if (hasAnnotation(declaration, 'keepAbstract')){
        declaration.metadata.where((m) => m.name.name == 'keepAbstract' && m.constructorName == null && m.arguments == null).forEach((m){
          result.add(new _Transformation(m.offset, m.endToken.next.offset, ''));
        });
      } else if (declaration.abstractKeyword != null) {
        final abstractKeyword = declaration.abstractKeyword;
        result.add(new _Transformation(abstractKeyword.offset, abstractKeyword.next.offset, ''));
      }

      // add cast and constructor
      final name = declaration.name;
      final position = declaration.leftBracket.offset;
      final alreadyExtends = declaration.extendsClause != null;
      result.add(new _Transformation(position, position + 1,
          (alreadyExtends ? '' : 'extends jsw.TypedProxy ') + '''{
  static $name cast(js.Proxy proxy) => proxy == null ? null : new $name.fromProxy(proxy);
  $name.fromProxy(js.Proxy proxy) : super.fromProxy(proxy);'''));

      // generate member
      declaration.members.forEach((m){
        if (m is FieldDeclaration) {

        } else if (m is MethodDeclaration && m.isAbstract() && !m.isStatic() && !m.isOperator()) {
          var wrap = (String s) => ' => $s;';
          if (m.returnType != null) {
            final returnName = m.returnType;
            if (returnName.name.name == 'void') {
              wrap = (String s) => ' { $s; }';
            } else if (_isTransferableType(returnName)) {
            } else if (returnName.name.name == 'List') {
              if (m.returnType.typeArguments == null || _isTransferableType(m.returnType.typeArguments.arguments.first)) {
                wrap = (String s) => ' => jsw.JsArrayToListAdapter.cast($s);';
              } else {
                wrap = (String s) => ' => jsw.JsArrayToListAdapter.castListOfSerializables($s, ${m.returnType.typeArguments.arguments.first}.cast);';
              }
            } else {
              wrap = (String s) => ' => ${m.returnType}.cast($s);';
            }
          }
          final method = new StringBuffer();
          if (m.returnType != null) method..write(m.returnType)..write(' ');
          if (m.isSetter()) method.write("set ${m.name}${m.parameters} => \$unsafe['${m.name.name}'] = ${m.parameters.parameters.elements.first.identifier.name};");
          else if (m.isGetter()) method..write("get ")..write(m.name)..write(wrap("\$unsafe['${m.name.name}']"));
          else method..write(m.name)..write(m.parameters)..write(wrap('\$unsafe.${m.name.name}(${m.parameters.parameters.elements.map((p) => p.identifier.name).join(', ')})'));
          result.add(new _Transformation(m.offset, m.end, method.toString()));
        }
      });
    }
  }
  return result;
}

bool _isTransferableType(TypeName typeName){
  switch (typeName.name.name) {
    case 'bool':
    case 'String':
    case 'num':
    case 'int':
    case 'double':
      return true;
  }
  return false;
}

bool hasAnnotation(AnnotatedNode node, String name) {
  return node.metadata.any((m) => m.name.name == name &&
      m.constructorName == null && m.arguments == null);
}

String _applyTransformations(String code, List<_Transformation> transformations) {
  int padding = 0;
  for (final t in transformations) {
    code = code.substring(0, t.begin + padding) + t.replace + code.substring(t.end + padding);
    padding += t.replace.length - (t.end - t.begin);
  }
  return code;
}

CompilationUnit _parseCompilationUnit(String code) {
  var errorListener = new _ErrorCollector();
  var scanner = new StringScanner(null, code, errorListener);
  var token = scanner.tokenize();
  var parser = new Parser(null, errorListener);
  var unit = parser.parseCompilationUnit(token);
  return unit;
}

class _ErrorCollector extends AnalysisErrorListener {
  final errors = new List<AnalysisError>();
  onError(error) => errors.add(error);
}

class _Transformation {
  final int begin;
  final int end;
  final String replace;
  _Transformation(this.begin, this.end, this.replace);
}