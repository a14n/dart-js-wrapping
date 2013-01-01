// Copyright (c) 2013, Alexandre Ardhuin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library js_wrap;

import 'package:meta/meta.dart';
import 'package:js/js.dart' as js;

// TODO replace with ... see http://dartbug.com/6111
/// metadata to make editor warn on undefined methods (in a real world, not yet implemented)
const warnOnUndefinedMethod = const _WarnOnUndefinedMethod();
class _WarnOnUndefinedMethod {
  const _WarnOnUndefinedMethod();
}

class ProxyInvocationMirror extends InvocationMirror {
  final String memberName;
  List positionalArguments;
  final Map<String, dynamic> namedArguments;
  final bool isMethod;
  final bool isGetter;
  final bool isSetter;

  ProxyInvocationMirror(this.memberName, List positionalArguments, this.namedArguments, this.isMethod, this.isGetter, this.isSetter) {
    this.positionalArguments = positionalArguments != null ? positionalArguments.map(_transform) : null;
  }
  ProxyInvocationMirror.fromInvocationMirror(InvocationMirror invocation) : this(invocation.memberName, invocation.positionalArguments, invocation.namedArguments, invocation.isMethod, invocation.isGetter, invocation.isSetter);
  ProxyInvocationMirror.method(String memberName, List positionalArguments) : this(memberName, positionalArguments, {}, true, false, false);
  ProxyInvocationMirror.getter(String memberName) : this(memberName, [], {}, false, true, false);
  ProxyInvocationMirror.setter(String memberName, dynamic value) : this(memberName, [value], {}, false, false, true);

  @override invokeOn(Object receiver) { throw new UnsupportedError("Forbidden"); }
}

Object _transform(data) =>
    (data is TypedProxy) ? data.$safe._proxy :
    (data is Proxy) ? data._proxy :
    data;

class Proxy {
  final js.Proxy $jsProxy;

  Proxy([function, List args]) : this.fromJsProxy(new js.Proxy.withArgList(function != null ? function : js.context.Object, args != null ? args.map(_transform) : []));
  Proxy.fromJsProxy(this.$jsProxy);

  @override noSuchMethod(InvocationMirror invocation) {
    final proxyInvocation = new ProxyInvocationMirror.fromInvocationMirror(invocation);
    final jsResult = $jsProxy.noSuchMethod(proxyInvocation);
    //print("${invocation.memberName}(${invocation.positionalArguments}) => ${jsResult}");
    return jsResult;
  }
}

class TypedProxy {
  final Proxy $proxy;

  TypedProxy([function, List args]) : this.fromProxy(new Proxy(function, args));
  TypedProxy.fromProxy(this.$proxy);
  TypedProxy.fromJsProxy(js.Proxy jsProxy) : this.fromProxy(new Proxy.fromJsProxy(jsProxy));

  @warnOnUndefinedMethod @override noSuchMethod(InvocationMirror invocation) => $proxy.noSuchMethod(invocation);
}