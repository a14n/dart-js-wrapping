// GENERATED CODE - DO NOT MODIFY BY HAND
// 2015-05-28T14:29:32.882Z

part of js_wrapping.example.js_proxy;

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: abstract class _JsFoo
// **************************************************************************

class JsFoo extends JsInterface implements _JsFoo {
  static int get static1 => context['z']['y']['x']['JsFoo']['static1'];
  static void set static2(int _static2) {
    context['z']['y']['x']['JsFoo']['static2'] = _static2;
  }
  static int get static2 => context['z']['y']['x']['JsFoo']['static2'];
  static int staticMethod(JsFoo foo) => context['z']['y']['x']['JsFoo']
      .callMethod('staticMethod', [__codec29.encode(foo)]);

  JsFoo.created(JsObject o) : super.created(o);
  JsFoo() : this.created(new JsObject(context['z']['y']['x']['JsFoo']));

  void set l1(List _l1) {
    asJsObject(this)['l1'] = __codec27.encode(_l1);
  }
  List get l1 => __codec27.decode(asJsObject(this)['l1']);
  void set l2(List<num> _l2) {
    asJsObject(this)['l2'] = __codec28.encode(_l2);
  }
  List<num> get l2 => __codec28.decode(asJsObject(this)['l2']);
  void set l3(List<JsFoo> _l3) {
    asJsObject(this)['l3'] = __codec30.encode(_l3);
  }
  List<JsFoo> get l3 => __codec30.decode(asJsObject(this)['l3']);

  void set i(int _i) {
    asJsObject(this)['_i'] = _i;
  }
  int get i => asJsObject(this)['_i'];

  void set k2(num _k2) {
    asJsObject(this)['k'] = _k2;
  }
  num get k2 => asJsObject(this)['k'];
  void set k1(num _k1) {
    asJsObject(this)['k'] = _k1;
  }
  num get k1 => asJsObject(this)['k'];
  int j = null;
  bool get l => asJsObject(this)['l'];

  String get a => asJsObject(this)['a'];
  void set a(String a) {
    asJsObject(this)['a'] = a;
  }

  String get b => '';
  void set b(String b) {}

  m1() => __codec26.decode(asJsObject(this).callMethod('m1'));
  void m2() {
    asJsObject(this).callMethod('m2');
  }
  String m3() => asJsObject(this).callMethod('m3');
  String m4(int a) => asJsObject(this).callMethod('m4', [a]);
  int m5(int a, b) =>
      asJsObject(this).callMethod('m5', [a, __codec26.encode(b)]);

  int _m6(int a, b) =>
      asJsObject(this).callMethod('_m6', [a, __codec26.encode(b)]);
}
/// codec for null.dynamic
final __codec26 = new DynamicCodec();

/// codec for dart.core.List<dynamic>
final __codec27 = new JsListCodec<dynamic>(__codec26);

/// codec for dart.core.List<num>
final __codec28 = new JsListCodec<num>(null);

/// codec for js_wrapping.example.js_proxy.JsFoo
final __codec29 = new JsInterfaceCodec<JsFoo>((o) => new JsFoo.created(o));

/// codec for dart.core.List<JsFoo>
final __codec30 = new JsListCodec<JsFoo>(__codec29);

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: abstract class _JsBar
// **************************************************************************

@JsName('a.b.JsBar')
class JsBar extends JsInterface implements _JsBar {
  JsBar.created(JsObject o) : super.created(o) {
    getState(this).putIfAbsent(#a, () => 0);
  }

  factory JsBar() = dynamic;
  factory JsBar.named(int x, int y) = dynamic;

  JsBar m1() => __codec31.decode(asJsObject(this).callMethod('m1'));

  void set a(int a) {
    getState(this)[#a] = a;
  }
  int get a => getState(this)[#a];
}
/// codec for js_wrapping.example.js_proxy.JsBar
final __codec31 = new JsInterfaceCodec<JsBar>((o) => new JsBar.created(o));

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: abstract class _JsBaz
// **************************************************************************

class JsBaz extends JsBar implements _JsBaz {
  JsBaz.created(JsObject o) : super.created(o);
  factory JsBaz() = dynamic;
}

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: abstract class __Context
// **************************************************************************

class _Context extends JsInterface implements __Context {
  _Context.created(JsObject o) : super.created(o);

  int find(String a) => asJsObject(this).callMethod('find', [a]);

  void set a(String _a) {
    asJsObject(this)['a'] = _a;
  }
  String get a => asJsObject(this)['a'];

  String get b => asJsObject(this)['b'];

  set b(String b1) {
    asJsObject(this)['b'] = b1;
  }
}
