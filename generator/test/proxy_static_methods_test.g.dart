// GENERATED CODE - DO NOT MODIFY BY HAND

part of js_wrapping_generator.test.proxy_static_methods_test;

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: library js_wrapping_generator.test.proxy_static_methods_test
// **************************************************************************

@GeneratedFrom(_Class0)
class Class0 extends JsInterface {
  static int getI() => context['Class0'].callMethod('getI') as int;
  static void setI(int i) {
    context['Class0'].callMethod('setI', [i]);
  }

  Class0.created(JsObject o) : super.created(o);
  Class0() : this.created(new JsObject(context['Class0'] as JsFunction));
}

@GeneratedFrom(_ClassPrivateMethod)
@JsName('Class0')
class ClassPrivateMethod extends JsInterface {
  static int _getI() => context['Class0'].callMethod('getI') as int;
  ClassPrivateMethod.created(JsObject o) : super.created(o);
  ClassPrivateMethod()
      : this.created(new JsObject(context['Class0'] as JsFunction));
}

@GeneratedFrom(_ClassRenamedMethod)
@JsName('Class0')
class ClassRenamedMethod extends JsInterface {
  static int getIBis() => context['Class0'].callMethod('getI') as int;
  ClassRenamedMethod.created(JsObject o) : super.created(o);
  ClassRenamedMethod()
      : this.created(new JsObject(context['Class0'] as JsFunction));
}

@GeneratedFrom(_ClassRenamedPrivateMethod)
@JsName('Class0')
class ClassRenamedPrivateMethod extends JsInterface {
  static int _getIBis() => context['Class0'].callMethod('getI') as int;
  ClassRenamedPrivateMethod.created(JsObject o) : super.created(o);
  ClassRenamedPrivateMethod()
      : this.created(new JsObject(context['Class0'] as JsFunction));
}
