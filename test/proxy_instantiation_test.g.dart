// GENERATED CODE - DO NOT MODIFY BY HAND
// 2015-05-26T20:27:42.683Z

part of js_wrapping.test.proxy_instantiation_test;

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: abstract class _Class0
// **************************************************************************

class Class0 extends JsInterface implements _Class0 {
  Class0.created(JsObject o) : super.created(o);
  Class0() : this.created(new JsObject(context['Class0']));
}

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: abstract class _Class1
// **************************************************************************

class Class1 extends JsInterface implements _Class1 {
  Class1.created(JsObject o) : super.created(o);
  Class1(String s) : this.created(new JsObject(context['Class1'], [s]));
}

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: abstract class _Class0Alias
// **************************************************************************

@JsName('Class0')
class Class0Alias extends JsInterface implements _Class0Alias {
  Class0Alias.created(JsObject o) : super.created(o);
  Class0Alias() : this.created(new JsObject(context['Class0']));
}

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: abstract class _Class2
// **************************************************************************

@JsName('my.package.Class2')
class Class2 extends JsInterface implements _Class2 {
  Class2.created(JsObject o) : super.created(o);
  Class2() : this.created(new JsObject(context['my']['package']['Class2']));
}

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: abstract class _Class3
// **************************************************************************

class Class3 extends JsInterface implements _Class3 {
  Class3.created(JsObject o) : super.created(o);
  Class3(String s, [int i, int j])
      : this.created(new JsObject(context['Class3'], [s, i, j]));
}

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: abstract class _Class4
// **************************************************************************

class Class4 extends JsInterface implements _Class4 {
  Class4.created(JsObject o) : super.created(o);
  Class4(String s, {int i, int j}) : this.created(new JsObject(
          context['Class4'], [
        s,
        () {
          final o = new JsObject(context['Object']);
          if (i != null) o['i'] = i;
          if (j != null) o['j'] = j;
          return o;
        }()
      ]));
}
