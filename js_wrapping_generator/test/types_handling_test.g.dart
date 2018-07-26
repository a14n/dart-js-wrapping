// GENERATED CODE - DO NOT MODIFY BY HAND

part of js_wrapping_generator.test.types_handling_test;

// **************************************************************************
// JsWrappingGenerator
// **************************************************************************

class Color extends JsEnum {
  static final values = <Color>[RED, GREEN, BLUE];
  static final RED = Color._('RED', context['Color']['RED']);
  static final GREEN = Color._('GREEN', context['Color']['GREEN']);
  static final BLUE = Color._('BLUE', context['Color']['BLUE']);
  final String _name;
  Color._(this._name, o) : super.created(o);

  @override
  String toString() => 'Color.$_name';

  // dumb code to remove analyzer hint for unused _Color
  _Color _dumbMethod1() => _dumbMethod2();
  _Color _dumbMethod2() => _dumbMethod1();
}

@GeneratedFrom(_A)
class A extends JsInterface {
  A() : this.created(JsObject(context['A']));
  A.created(JsObject o) : super.created(o);

  set b(B _b) {
    asJsObject(this)['b'] = __codec0.encode(_b);
  }

  B get b => __codec0.decode(asJsObject(this)['b']);
  set bs(List<B> _bs) {
    asJsObject(this)['bs'] = __codec1.encode(_bs);
  }

  List<B> get bs => __codec1.decode(asJsObject(this)['bs']);
  set li(List<int> _li) {
    asJsObject(this)['li'] = __codec2.encode(_li);
  }

  List<int> get li => __codec2.decode(asJsObject(this)['li']);

  String toColorString(Color c) =>
      asJsObject(this).callMethod('toColorString', [__codec4.encode(c)]);
  Color toColor(String s) =>
      __codec4.decode(asJsObject(this).callMethod('toColor', [s]));

  String execute(B f(B b)) =>
      asJsObject(this).callMethod('execute', [__codec5.encode(f)]);

  String execute2(String f(B s, [int i])) =>
      asJsObject(this).callMethod('execute2', [__codec6.encode(f)]);

  BisFunc getBisFunc() =>
      __codec5.decode(asJsObject(this).callMethod('getBisFunc'));

  set simpleFunc(SimpleFunc _simpleFunc) {
    asJsObject(this)['simpleFunc'] = __codec3.encode(_simpleFunc);
  }

  SimpleFunc get simpleFunc => __codec3.decode(asJsObject(this)['simpleFunc']);

  void executeVoidFunction(void f()) {
    asJsObject(this).callMethod('executeVoidFunction', [__codec7.encode(f)]);
  }
}

@GeneratedFrom(_B)
class B extends JsInterface {
  B(String v) : this.created(JsObject(context['B'], [v]));
  B.created(JsObject o) : super.created(o);

  @override
  String toString() => asJsObject(this).callMethod('toString');
}

/// codec for js_wrapping_generator.test.types_handling_test.B
final __codec0 = JsInterfaceCodec<B>((o) => B.created(o));

/// codec for dart.core.List<B>
final __codec1 = JsListCodec<B>(__codec0);

/// codec for dart.core.List<int>
final __codec2 = JsListCodec<int>(null);

/// codec for js_wrapping_generator.test.types_handling_test.(int) → String
final __codec3 = FunctionCodec<Function> /*<(int) → String>*/(
  (f) => f,
  (f) => (p$i) => f is JsFunction ? f.apply([p$i]) : Function.apply(f, [p$i]),
);

/// codec for js_wrapping_generator.test.types_handling_test.Color
final __codec4 = BiMapCodec<Color, dynamic>(
    Map<Color, dynamic>.fromIterable(Color.values, value: asJs));

/// codec for js_wrapping_generator.test.types_handling_test.(B) → B
final __codec5 = FunctionCodec<Function> /*<(B) → B>*/(
  (f) => (p$b) => __codec0.encode(f(__codec0.decode(p$b))),
  (f) => (p$b) => __codec0.decode(f is JsFunction
      ? f.apply([__codec0.encode(p$b)])
      : Function.apply(f, [__codec0.encode(p$b)])),
);

/// codec for js_wrapping_generator.test.types_handling_test.(B, [int]) → String
final __codec6 = FunctionCodec<Function> /*<(B, [int]) → String>*/(
  (f) => (p$s, [p$i]) => f(__codec0.decode(p$s), p$i),
  (f) => (p$s, [p$i]) => f is JsFunction
      ? f.apply([__codec0.encode(p$s), p$i])
      : Function.apply(f, [__codec0.encode(p$s), p$i]),
);

/// codec for js_wrapping_generator.test.types_handling_test.() → void
final __codec7 = FunctionCodec<Function> /*<() → void>*/(
  (f) => f,
  (f) => () {
        f is JsFunction ? f.apply([]) : Function.apply(f, []);
      },
);
