// GENERATED CODE - DO NOT MODIFY BY HAND

part of js_wrapping_generator.test.proxy_instantiation_test;

// **************************************************************************
// Generator: JsInterfaceGenerator
// **************************************************************************

@GeneratedFrom(_Class0)
class Class0 extends JsInterface {
  Class0.created(JsObject o) : super.created(o);
  Class0() : this.created(new JsObject(context['Class0']));
}

@GeneratedFrom(_Class1)
class Class1 extends JsInterface {
  Class1.created(JsObject o) : super.created(o);
  Class1(String s) : this.created(new JsObject(context['Class1'], [s]));
}

@GeneratedFrom(_Class0Alias)
@JsName('Class0')
class Class0Alias extends JsInterface {
  Class0Alias.created(JsObject o) : super.created(o);
  Class0Alias() : this.created(new JsObject(context['Class0']));
}

@GeneratedFrom(_Class2)
@JsName('my.package.Class2')
class Class2 extends JsInterface {
  Class2.created(JsObject o) : super.created(o);
  Class2() : this.created(new JsObject(context['my']['package']['Class2']));
}

@GeneratedFrom(_Class3)
class Class3 extends JsInterface {
  Class3.created(JsObject o) : super.created(o);
  Class3(String s, [int i, int j])
      : this.created(new JsObject(context['Class3'], [s, i, j]));
}

@GeneratedFrom(_Class4)
class Class4 extends JsInterface {
  Class4.created(JsObject o) : super.created(o);
  Class4(String s, {int i, int j})
      : this.created(new JsObject(context['Class4'], [
          s,
          () {
            final o = new JsObject(context['Object']);
            if (i != null) o['i'] = i;
            if (j != null) o['j'] = j;
            return o;
          }()
        ]));
}
