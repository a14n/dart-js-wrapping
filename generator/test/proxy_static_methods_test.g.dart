// GENERATED CODE - DO NOT MODIFY BY HAND

part of js_wrapping_generator.test.proxy_static_methods_test;

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: library js_wrapping_generator.test.proxy_static_methods_test
// **************************************************************************

class Class0 extends JsInterface implements _Class0 {
  static int getI() => context['Class0'].callMethod('getI');
  static void setI(int i) {
    context['Class0'].callMethod('setI', [i]);
  }

  Class0.created(JsObject o) : super.created(o);
  Class0() : this.created(new JsObject(context['Class0']));
}

@JsName('Class0')
class ClassPrivateMethod extends JsInterface implements _ClassPrivateMethod {
  static int _getI() => context['Class0'].callMethod('getI');
  ClassPrivateMethod.created(JsObject o) : super.created(o);
  ClassPrivateMethod() : this.created(new JsObject(context['Class0']));
}

@JsName('Class0')
class ClassRenamedMethod extends JsInterface implements _ClassRenamedMethod {
  static int getIBis() => context['Class0'].callMethod('getI');
  ClassRenamedMethod.created(JsObject o) : super.created(o);
  ClassRenamedMethod() : this.created(new JsObject(context['Class0']));
}

@JsName('Class0')
class ClassRenamedPrivateMethod extends JsInterface
    implements _ClassRenamedPrivateMethod {
  static int _getIBis() => context['Class0'].callMethod('getI');
  ClassRenamedPrivateMethod.created(JsObject o) : super.created(o);
  ClassRenamedPrivateMethod() : this.created(new JsObject(context['Class0']));
}
