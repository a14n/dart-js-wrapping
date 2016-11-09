// GENERATED CODE - DO NOT MODIFY BY HAND

part of js_wrapping_generator.test.proxy_instantiation_test;

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: library js_wrapping_generator.test.proxy_instantiation_test
// **************************************************************************

class Class0 extends JsInterface implements _Class0 {
  Class0.created(JsObject o) : super.created(o);
  Class0() : this.created(new JsObject(context['Class0'] as JsFunction));
}

class Class1 extends JsInterface implements _Class1 {
  Class1.created(JsObject o) : super.created(o);
  Class1(String s)
      : this.created(new JsObject(context['Class1'] as JsFunction, [s]));
}

@JsName('Class0')
class Class0Alias extends JsInterface implements _Class0Alias {
  Class0Alias.created(JsObject o) : super.created(o);
  Class0Alias() : this.created(new JsObject(context['Class0'] as JsFunction));
}

@JsName('my.package.Class2')
class Class2 extends JsInterface implements _Class2 {
  Class2.created(JsObject o) : super.created(o);
  Class2()
      : this.created(
            new JsObject(context['my']['package']['Class2'] as JsFunction));
}

class Class3 extends JsInterface implements _Class3 {
  Class3.created(JsObject o) : super.created(o);
  Class3(String s, [int i, int j])
      : this.created(new JsObject(context['Class3'] as JsFunction, [s, i, j]));
}

class Class4 extends JsInterface implements _Class4 {
  Class4.created(JsObject o) : super.created(o);
  Class4(String s, {int i, int j})
      : this.created(new JsObject(context['Class4'] as JsFunction, [
          s,
          () {
            final o = new JsObject(context['Object'] as JsFunction);
            if (i != null) o['i'] = i;
            if (j != null) o['j'] = j;
            return o;
          }()
        ]));
}
