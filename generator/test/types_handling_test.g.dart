// GENERATED CODE - DO NOT MODIFY BY HAND

part of js_wrapping_generator.test.types_handling_test;

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: library js_wrapping_generator.test.types_handling_test
// **************************************************************************

class Color extends JsEnum {
  static final values = <Color>[RED, GREEN, BLUE];
  static final RED = new Color._('RED', context['Color']['RED']);
  static final GREEN = new Color._('GREEN', context['Color']['GREEN']);
  static final BLUE = new Color._('BLUE', context['Color']['BLUE']);

  final String _name;
  Color._(this._name, o) : super.created(o);

  String toString() => 'Color.$_name';

  // dumb code to remove analyzer hint for unused _Color
  _Color _dumbMethod1() => _dumbMethod2();
  _Color _dumbMethod2() => _dumbMethod1();
}

/// codec for js_wrapping_generator.test.types_handling_test.(B, [int]) → String
final __codec11 = new FunctionCodec/*<(B, [int]) → String>*/(
    (f) => (B p_s, [p_i]) => f(__codec7.decode(p_s as JsObject), p_i) as String,
    (JsFunction f) =>
        (B p_s, [p_i]) => f.apply([__codec7.encode(p_s), p_i]) as String);

/// codec for js_wrapping_generator.test.types_handling_test.(B) → B
final __codec10 = new FunctionCodec/*<(B) → B>*/(
    (f) => (B p_b) => __codec7.encode(f(__codec7.decode(p_b as JsObject)) as B),
    (JsFunction f) => (B p_b) =>
        __codec7.decode(f.apply([__codec7.encode(p_b)]) as JsObject));

/// codec for js_wrapping_generator.test.types_handling_test.Color
final __codec9 = new BiMapCodec<Color, dynamic>(
    new Map<Color, dynamic>.fromIterable(Color.values, value: asJs));

/// codec for dart.core.List<B>
final __codec8 = new JsListCodec<B>(__codec7);

/// codec for js_wrapping_generator.test.types_handling_test.B
final __codec7 = new JsInterfaceCodec<B>((o) => new B.created(o));

/// codec for js_wrapping_generator.test.types_handling_test.() → void
final __codec6 = new FunctionCodec/*<() → void>*/(
    (f) => f,
    (JsFunction f) => () {
          f.apply([]);
        });

/// codec for js_wrapping_generator.test.types_handling_test.(dynamic, [int]) → String
final __codec5 = new FunctionCodec/*<(dynamic, [int]) → String>*/(
    (f) => (dynamic p_s, [p_i]) =>
        f(__codec0.decode(p_s as JsObject), p_i) as String,
    (JsFunction f) =>
        (dynamic p_s, [p_i]) => f.apply([__codec0.encode(p_s), p_i]) as String);

/// codec for js_wrapping_generator.test.types_handling_test.(dynamic) → dynamic
final __codec4 = new FunctionCodec/*<(dynamic) → dynamic>*/(
    (f) => (dynamic p_b) =>
        __codec0.encode(f(__codec0.decode(p_b as JsObject)) as dynamic),
    (JsFunction f) => (dynamic p_b) =>
        __codec0.decode(f.apply([__codec0.encode(p_b)]) as JsObject));

/// codec for js_wrapping_generator.test.types_handling_test.(int) → String
final __codec3 = new FunctionCodec/*<(int) → String>*/(
    (f) => f, (JsFunction f) => (int p_i) => f.apply([p_i]) as String);

/// codec for dart.core.List<int>
final __codec2 = new JsListCodec<int>(null);

/// codec for dart.core.List<dynamic>
final __codec1 = new JsListCodec<dynamic>(__codec0);

/// codec for null.dynamic
final __codec0 = new DynamicCodec();

@GeneratedFrom(_A)
class A extends JsInterface {
  A.created(JsObject o) : super.created(o);
  A() : this.created(new JsObject(context['A'] as JsFunction));

  void set b(B _b) {
    asJsObject(this)['b'] = __codec7.encode(_b);
  }

  B get b => __codec7.decode(asJsObject(this)['b'] as JsObject);
  void set bs(List<B> _bs) {
    asJsObject(this)['bs'] = __codec8.encode(_bs);
  }

  List<B> get bs => __codec8.decode(asJsObject(this)['bs'] as JsArray);
  void set li(List<int> _li) {
    asJsObject(this)['li'] = __codec2.encode(_li);
  }

  List<int> get li => __codec2.decode(asJsObject(this)['li'] as JsArray);

  String toColorString(Color c) =>
      asJsObject(this).callMethod('toColorString', [__codec9.encode(c)])
      as String;
  Color toColor(String s) =>
      __codec9.decode(asJsObject(this).callMethod('toColor', [s]) as JsObject);

  String execute(B f(B b)) =>
      asJsObject(this).callMethod('execute', [__codec10.encode(f)]) as String;

  String execute2(String f(B s, [int i])) =>
      asJsObject(this).callMethod('execute2', [__codec11.encode(f)]) as String;

  BisFunc getBisFunc() =>
      __codec10.decode(asJsObject(this).callMethod('getBisFunc') as JsObject);

  void set simpleFunc(SimpleFunc _simpleFunc) {
    asJsObject(this)['simpleFunc'] = __codec3.encode(_simpleFunc);
  }

  SimpleFunc get simpleFunc =>
      __codec3.decode(asJsObject(this)['simpleFunc'] as JsObject);

  void executeVoidFunction(void f()) {
    asJsObject(this).callMethod('executeVoidFunction', [__codec6.encode(f)]);
  }
}

@GeneratedFrom(_B)
class B extends JsInterface {
  B.created(JsObject o) : super.created(o);
  B(String v) : this.created(new JsObject(context['B'] as JsFunction, [v]));

  String toString() => asJsObject(this).callMethod('toString') as String;
}
