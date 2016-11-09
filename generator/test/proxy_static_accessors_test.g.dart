// GENERATED CODE - DO NOT MODIFY BY HAND

part of js_wrapping_generator.test.proxy_static_accessors_test;

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: library js_wrapping_generator.test.proxy_static_accessors_test
// **************************************************************************

@JsName('Class0')
class ClassNotFinalField extends JsInterface implements _ClassNotFinalField {
  ClassNotFinalField.created(JsObject o) : super.created(o);

  static void set i(int _i) {
    context['Class0']['i'] = _i;
  }

  static int get i => context['Class0']['i'] as int;
}

@JsName('Class0')
class ClassPrivateField extends JsInterface implements _ClassPrivateField {
  ClassPrivateField.created(JsObject o) : super.created(o);

  static void set _i(int __i) {
    context['Class0']['i'] = __i;
  }

  static int get _i => context['Class0']['i'] as int;
}

@JsName('Class0')
class ClassRenamedField extends JsInterface implements _ClassRenamedField {
  ClassRenamedField.created(JsObject o) : super.created(o);

  static void set iBis(int _iBis) {
    context['Class0']['i'] = _iBis;
  }

  static int get iBis => context['Class0']['i'] as int;
}

@JsName('Class0')
class ClassRenamedPrivateField extends JsInterface
    implements _ClassRenamedPrivateField {
  ClassRenamedPrivateField.created(JsObject o) : super.created(o);

  static void set _iBis(int __iBis) {
    context['Class0']['i'] = __iBis;
  }

  static int get _iBis => context['Class0']['i'] as int;
}

@JsName('Class0')
class ClassWithGetter extends JsInterface implements _ClassWithGetter {
  ClassWithGetter.created(JsObject o) : super.created(o);

  static int get i => context['Class0']['i'] as int;
}

@JsName('Class0')
class ClassWithSetter extends JsInterface implements _ClassWithSetter {
  ClassWithSetter.created(JsObject o) : super.created(o);

  static set i(int i) {
    context['Class0']['i'] = i;
  }
}

@JsName('Class0')
class ClassWithPrivateGetter extends JsInterface
    implements _ClassWithPrivateGetter {
  ClassWithPrivateGetter.created(JsObject o) : super.created(o);

  static int get _i => context['Class0']['i'] as int;
}

@JsName('Class0')
class ClassWithPrivateSetter extends JsInterface
    implements _ClassWithPrivateSetter {
  ClassWithPrivateSetter.created(JsObject o) : super.created(o);

  static set _i(int i) {
    context['Class0']['i'] = i;
  }
}

@JsName('Class0')
class ClassWithRenamedGetter extends JsInterface
    implements _ClassWithRenamedGetter {
  ClassWithRenamedGetter.created(JsObject o) : super.created(o);

  static int get iBis => context['Class0']['i'] as int;
}

@JsName('Class0')
class ClassWithRenamedSetter extends JsInterface
    implements _ClassWithRenamedSetter {
  ClassWithRenamedSetter.created(JsObject o) : super.created(o);

  static set iBis(int i) {
    context['Class0']['i'] = i;
  }
}
