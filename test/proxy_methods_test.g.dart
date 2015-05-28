// GENERATED CODE - DO NOT MODIFY BY HAND
// 2015-05-26T20:27:42.659Z

part of js_wrapping.test.proxy_methods_test;

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: abstract class _Class0
// **************************************************************************

class Class0 extends JsInterface implements _Class0 {
  Class0.created(JsObject o) : super.created(o);
  Class0() : this.created(new JsObject(context['Class0']));

  int getI() => asJsObject(this).callMethod('getI');
  void setI(int i) {
    asJsObject(this).callMethod('setI', [i]);
  }
}

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: abstract class _ClassPrivateMethod
// **************************************************************************

@JsName('Class0')
class ClassPrivateMethod extends JsInterface implements _ClassPrivateMethod {
  ClassPrivateMethod.created(JsObject o) : super.created(o);
  ClassPrivateMethod() : this.created(new JsObject(context['Class0']));

  int _getI() => asJsObject(this).callMethod('getI');
}

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: abstract class _ClassRenamedMethod
// **************************************************************************

@JsName('Class0')
class ClassRenamedMethod extends JsInterface implements _ClassRenamedMethod {
  ClassRenamedMethod.created(JsObject o) : super.created(o);
  ClassRenamedMethod() : this.created(new JsObject(context['Class0']));

  int getIBis() => asJsObject(this).callMethod('getI');
}

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: abstract class _ClassRenamedPrivateMethod
// **************************************************************************

@JsName('Class0')
class ClassRenamedPrivateMethod extends JsInterface
    implements _ClassRenamedPrivateMethod {
  ClassRenamedPrivateMethod.created(JsObject o) : super.created(o);
  ClassRenamedPrivateMethod() : this.created(new JsObject(context['Class0']));

  int _getIBis() => asJsObject(this).callMethod('getI');
}

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: abstract class _Class1
// **************************************************************************

class Class1 extends JsInterface implements _Class1 {
  Class1.created(JsObject o) : super.created(o);
  Class1() : this.created(new JsObject(context['Class1']));

  void set1(String s) {
    asJsObject(this).callMethod('set1', [s]);
  }
  void set2(String s, [int i]) {
    asJsObject(this).callMethod('set2', [s, i]);
  }
  void set3(String s, {int i, bool j}) {
    asJsObject(this).callMethod('set3', [
      s,
      () {
        final o = new JsObject(context['Object']);
        if (i != null) o['i'] = i;
        if (j != null) o['j'] = j;
        return o;
      }()
    ]);
  }
}
