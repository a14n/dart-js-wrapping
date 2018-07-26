// GENERATED CODE - DO NOT MODIFY BY HAND

part of js_wrapping_generator.test.proxy_instantiation_test;

// **************************************************************************
// JsWrappingGenerator
// **************************************************************************

@GeneratedFrom(_Class0)
class Class0 extends JsInterface {
  Class0() : this.created(JsObject(context['Class0']));
  Class0.created(JsObject o) : super.created(o);
}

@GeneratedFrom(_Class1)
class Class1 extends JsInterface {
  Class1(String s) : this.created(JsObject(context['Class1'], [s]));
  Class1.created(JsObject o) : super.created(o);
}

@GeneratedFrom(_Class0Alias)
@JsName('Class0')
class Class0Alias extends JsInterface {
  Class0Alias() : this.created(JsObject(context['Class0']));
  Class0Alias.created(JsObject o) : super.created(o);
}

@GeneratedFrom(_Class2)
@JsName('my.package.Class2')
class Class2 extends JsInterface {
  Class2() : this.created(JsObject(context['my']['package']['Class2']));
  Class2.created(JsObject o) : super.created(o);
}

@GeneratedFrom(_Class3)
class Class3 extends JsInterface {
  Class3(String s, [int i, int j])
      : this.created(JsObject(context['Class3'], [s, i, j]));
  Class3.created(JsObject o) : super.created(o);
}

@GeneratedFrom(_Class4)
class Class4 extends JsInterface {
  Class4(String s, {int i, int j})
      : this.created(JsObject(context['Class4'], [
          s,
          () {
            final o = JsObject(context['Object']);
            if (i != null) o['i'] = i;
            if (j != null) o['j'] = j;
            return o;
          }()
        ]));
  Class4.created(JsObject o) : super.created(o);
}
