// GENERATED CODE - DO NOT MODIFY BY HAND

part of js_wrapping_generator.example.js_proxy;

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: library js_wrapping_generator.example.js_proxy
// **************************************************************************

/// codec for js_wrapping_generator.example.js_proxy.JsBar
final __codec4 = new JsInterfaceCodec<JsBar>((o) => new JsBar.created(o));

/// codec for dart.core.List<JsFoo>
final __codec3 = new JsListCodec<JsFoo>(__codec2);

/// codec for js_wrapping_generator.example.js_proxy.JsFoo
final __codec2 = new JsInterfaceCodec<JsFoo>((o) => new JsFoo.created(o));

/// codec for dart.core.List<num>
final __codec1 = new JsListCodec<num>(null);

/// codec for dart.core.List<dynamic>
final __codec0 = new JsListCodec<dynamic>(null);

class JsFoo extends JsInterface implements _JsFoo {
  static int get static1 => context['z']['y']['x']['JsFoo']['static1'] as int;
  static void set static2(int _static2) {
    context['z']['y']['x']['JsFoo']['static2'] = _static2;
  }

  static int get static2 => context['z']['y']['x']['JsFoo']['static2'] as int;
  static int staticMethod(JsFoo foo) => context['z']['y']['x']['JsFoo']
      .callMethod('staticMethod', [__codec2.encode(foo)]) as int;

  JsFoo.created(JsObject o) : super.created(o);
  JsFoo()
      : this.created(
            new JsObject(context['z']['y']['x']['JsFoo'] as JsFunction));

  void set l1(List _l1) {
    asJsObject(this)['l1'] = __codec0.encode(_l1);
  }

  List get l1 => __codec0.decode(asJsObject(this)['l1'] as JsArray);
  void set l2(List<num> _l2) {
    asJsObject(this)['l2'] = __codec1.encode(_l2);
  }

  List<num> get l2 => __codec1.decode(asJsObject(this)['l2'] as JsArray);
  void set l3(List<JsFoo> _l3) {
    asJsObject(this)['l3'] = __codec3.encode(_l3);
  }

  List<JsFoo> get l3 => __codec3.decode(asJsObject(this)['l3'] as JsArray);

  void set i(int _i) {
    asJsObject(this)['_i'] = _i;
  }

  int get i => asJsObject(this)['_i'] as int;

  void set k2(num _k2) {
    asJsObject(this)['k'] = _k2;
  }

  num get k2 => asJsObject(this)['k'] as num;
  void set k1(num _k1) {
    asJsObject(this)['k'] = _k1;
  }

  num get k1 => asJsObject(this)['k'] as num;
  int j = null;
  bool get l => asJsObject(this)['l'] as bool;

  String get a => asJsObject(this)['a'] as String;
  void set a(String a) {
    asJsObject(this)['a'] = a;
  }

  String get b => '';
  void set b(String b) {}

  m1() => asJsObject(this).callMethod('m1');
  void m2() {
    asJsObject(this).callMethod('m2');
  }

  String m3() => asJsObject(this).callMethod('m3') as String;
  String m4(int a) => asJsObject(this).callMethod('m4', [a]) as String;
  int m5(int a, b) => asJsObject(this).callMethod('m5', [a, b]) as int;

  int _m6(int a, b) => asJsObject(this).callMethod('_m6', [a, b]) as int;
}

@JsName('a.b.JsBar')
class JsBar extends JsInterface implements _JsBar {
  JsBar.created(JsObject o) : super.created(o) {
    getState(this).putIfAbsent(#a, () => 0);
  }

  factory JsBar() = dynamic;
  factory JsBar.named(int x, int y) = dynamic;

  JsBar m1() => __codec4.decode(asJsObject(this).callMethod('m1') as JsObject);

  void set a(int a) {
    getState(this)[#a] = a;
  }

  int get a => getState(this)[#a] as int;
}

class JsBaz extends JsBar implements _JsBaz {
  JsBaz.created(JsObject o) : super.created(o);
  factory JsBaz() = dynamic;
}

class _Context extends JsInterface implements __Context {
  _Context.created(JsObject o) : super.created(o);

  int find(String a) => asJsObject(this).callMethod('find', [a]) as int;

  void set a(String _a) {
    asJsObject(this)['a'] = _a;
  }

  String get a => asJsObject(this)['a'] as String;

  String get b => asJsObject(this)['b'] as String;

  set b(String b1) {
    asJsObject(this)['b'] = b1;
  }
}
