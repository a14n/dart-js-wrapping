// GENERATED CODE - DO NOT MODIFY BY HAND

part of js_wrapping_generator.test.proxy_static_methods_test;

// **************************************************************************
// JsWrappingGenerator
// **************************************************************************

@GeneratedFrom(_Class0)
class Class0 extends JsInterface {
  Class0() : this.created(JsObject(context['Class0']));
  Class0.created(JsObject o) : super.created(o);
  static int getI() => context['Class0'].callMethod('getI');
  static void setI(int i) {
    context['Class0'].callMethod('setI', [i]);
  }
}

@GeneratedFrom(_ClassPrivateMethod)
@JsName('Class0')
class ClassPrivateMethod extends JsInterface {
  ClassPrivateMethod() : this.created(JsObject(context['Class0']));
  ClassPrivateMethod.created(JsObject o) : super.created(o);
  static int _getI() => context['Class0'].callMethod('getI');
}

@GeneratedFrom(_ClassRenamedMethod)
@JsName('Class0')
class ClassRenamedMethod extends JsInterface {
  ClassRenamedMethod() : this.created(JsObject(context['Class0']));
  ClassRenamedMethod.created(JsObject o) : super.created(o);

  static int getIBis() => context['Class0'].callMethod('getI');
}

@GeneratedFrom(_ClassRenamedPrivateMethod)
@JsName('Class0')
class ClassRenamedPrivateMethod extends JsInterface {
  ClassRenamedPrivateMethod() : this.created(JsObject(context['Class0']));
  ClassRenamedPrivateMethod.created(JsObject o) : super.created(o);

  static int _getIBis() => context['Class0'].callMethod('getI');
}
