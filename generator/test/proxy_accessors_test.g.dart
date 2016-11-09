// GENERATED CODE - DO NOT MODIFY BY HAND

part of js_wrapping_generator.test.proxy_accessors_test;

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: library js_wrapping_generator.test.proxy_accessors_test
// **************************************************************************

class Class0 extends JsInterface implements _Class0 {
  Class0.created(JsObject o) : super.created(o);
  Class0() : this.created(new JsObject(context['Class0'] as JsFunction));

  int get i => asJsObject(this)['i'] as int;
}

@JsName('Class0')
class ClassFinalField extends JsInterface implements _ClassFinalField {
  ClassFinalField.created(JsObject o) : super.created(o);
  ClassFinalField()
      : this.created(new JsObject(context['Class0'] as JsFunction));

  int get i => asJsObject(this)['i'] as int;
}

@JsName('Class0')
class ClassNotFinalField extends JsInterface implements _ClassNotFinalField {
  ClassNotFinalField.created(JsObject o) : super.created(o);
  ClassNotFinalField()
      : this.created(new JsObject(context['Class0'] as JsFunction));

  void set i(int _i) {
    asJsObject(this)['i'] = _i;
  }

  int get i => asJsObject(this)['i'] as int;
}

@JsName('Class0')
class ClassPrivateField extends JsInterface implements _ClassPrivateField {
  ClassPrivateField.created(JsObject o) : super.created(o);
  ClassPrivateField()
      : this.created(new JsObject(context['Class0'] as JsFunction));

  void set _i(int __i) {
    asJsObject(this)['i'] = __i;
  }

  int get _i => asJsObject(this)['i'] as int;
}

@JsName('Class0')
class ClassRenamedField extends JsInterface implements _ClassRenamedField {
  ClassRenamedField.created(JsObject o) : super.created(o);
  ClassRenamedField()
      : this.created(new JsObject(context['Class0'] as JsFunction));

  void set iBis(int _iBis) {
    asJsObject(this)['i'] = _iBis;
  }

  int get iBis => asJsObject(this)['i'] as int;
}

@JsName('Class0')
class ClassRenamedPrivateField extends JsInterface
    implements _ClassRenamedPrivateField {
  ClassRenamedPrivateField.created(JsObject o) : super.created(o);
  ClassRenamedPrivateField()
      : this.created(new JsObject(context['Class0'] as JsFunction));

  void set _iBis(int __iBis) {
    asJsObject(this)['i'] = __iBis;
  }

  int get _iBis => asJsObject(this)['i'] as int;
}

@JsName('Class0')
class ClassWithGetter extends JsInterface implements _ClassWithGetter {
  ClassWithGetter.created(JsObject o) : super.created(o);
  ClassWithGetter()
      : this.created(new JsObject(context['Class0'] as JsFunction));

  int get i => asJsObject(this)['i'] as int;
}

@JsName('Class0')
class ClassWithSetter extends JsInterface implements _ClassWithSetter {
  ClassWithSetter.created(JsObject o) : super.created(o);
  ClassWithSetter()
      : this.created(new JsObject(context['Class0'] as JsFunction));

  set i(int i) {
    asJsObject(this)['i'] = i;
  }
}

@JsName('Class0')
class ClassWithPrivateGetter extends JsInterface
    implements _ClassWithPrivateGetter {
  ClassWithPrivateGetter.created(JsObject o) : super.created(o);
  ClassWithPrivateGetter()
      : this.created(new JsObject(context['Class0'] as JsFunction));

  int get _i => asJsObject(this)['i'] as int;
}

@JsName('Class0')
class ClassWithPrivateSetter extends JsInterface
    implements _ClassWithPrivateSetter {
  ClassWithPrivateSetter.created(JsObject o) : super.created(o);
  ClassWithPrivateSetter()
      : this.created(new JsObject(context['Class0'] as JsFunction));

  set _i(int i) {
    asJsObject(this)['i'] = i;
  }
}

@JsName('Class0')
class ClassWithRenamedGetter extends JsInterface
    implements _ClassWithRenamedGetter {
  ClassWithRenamedGetter.created(JsObject o) : super.created(o);
  ClassWithRenamedGetter()
      : this.created(new JsObject(context['Class0'] as JsFunction));

  int get iBis => asJsObject(this)['i'] as int;
}

@JsName('Class0')
class ClassWithRenamedSetter extends JsInterface
    implements _ClassWithRenamedSetter {
  ClassWithRenamedSetter.created(JsObject o) : super.created(o);
  ClassWithRenamedSetter()
      : this.created(new JsObject(context['Class0'] as JsFunction));

  set iBis(int i) {
    asJsObject(this)['i'] = i;
  }
}
