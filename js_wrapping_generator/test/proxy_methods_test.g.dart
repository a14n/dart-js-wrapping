// GENERATED CODE - DO NOT MODIFY BY HAND

part of js_wrapping_generator.test.proxy_methods_test;

// **************************************************************************
// JsWrappingGenerator
// **************************************************************************

@GeneratedFrom(_Class0)
class Class0 extends JsInterface {
  Class0() : this.created(JsObject(context['Class0']));
  Class0.created(JsObject o) : super.created(o);

  int getI() => asJsObject(this).callMethod('getI');
  void setI(int i) {
    asJsObject(this).callMethod('setI', [i]);
  }
}

@GeneratedFrom(_ClassPrivateMethod)
@JsName('Class0')
class ClassPrivateMethod extends JsInterface {
  ClassPrivateMethod() : this.created(JsObject(context['Class0']));
  ClassPrivateMethod.created(JsObject o) : super.created(o);

  int _getI() => asJsObject(this).callMethod('getI');
}

@GeneratedFrom(_ClassRenamedMethod)
@JsName('Class0')
class ClassRenamedMethod extends JsInterface {
  ClassRenamedMethod() : this.created(JsObject(context['Class0']));
  ClassRenamedMethod.created(JsObject o) : super.created(o);

  int getIBis() => asJsObject(this).callMethod('getI');
}

@GeneratedFrom(_ClassRenamedPrivateMethod)
@JsName('Class0')
class ClassRenamedPrivateMethod extends JsInterface {
  ClassRenamedPrivateMethod() : this.created(JsObject(context['Class0']));
  ClassRenamedPrivateMethod.created(JsObject o) : super.created(o);

  int _getIBis() => asJsObject(this).callMethod('getI');
}

@GeneratedFrom(_Class1)
class Class1 extends JsInterface {
  Class1() : this.created(JsObject(context['Class1']));
  Class1.created(JsObject o) : super.created(o);

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
        final o = JsObject(context['Object']);
        if (i != null) o['i'] = i;
        if (j != null) o['j'] = j;
        return o;
      }()
    ]);
  }
}
