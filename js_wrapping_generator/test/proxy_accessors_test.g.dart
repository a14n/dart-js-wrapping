// GENERATED CODE - DO NOT MODIFY BY HAND

part of js_wrapping_generator.test.proxy_accessors_test;

// **************************************************************************
// JsWrappingGenerator
// **************************************************************************

@GeneratedFrom(_Class0)
class Class0 extends JsInterface {
  Class0.created(JsObject o) : super.created(o);
  Class0() : this.created(new JsObject(context['Class0']));

  int get i => asJsObject(this)['i'];
}

@GeneratedFrom(_ClassFinalField)
@JsName('Class0')
class ClassFinalField extends JsInterface {
  ClassFinalField.created(JsObject o) : super.created(o);
  ClassFinalField() : this.created(new JsObject(context['Class0']));

  int get i => asJsObject(this)['i'];
}

@GeneratedFrom(_ClassNotFinalField)
@JsName('Class0')
class ClassNotFinalField extends JsInterface {
  ClassNotFinalField.created(JsObject o) : super.created(o);
  ClassNotFinalField() : this.created(new JsObject(context['Class0']));

  void set i(int _i) {
    asJsObject(this)['i'] = _i;
  }

  int get i => asJsObject(this)['i'];
}

@GeneratedFrom(_ClassPrivateField)
@JsName('Class0')
class ClassPrivateField extends JsInterface {
  ClassPrivateField.created(JsObject o) : super.created(o);
  ClassPrivateField() : this.created(new JsObject(context['Class0']));

  void set _i(int __i) {
    asJsObject(this)['i'] = __i;
  }

  int get _i => asJsObject(this)['i'];
}

@GeneratedFrom(_ClassRenamedField)
@JsName('Class0')
class ClassRenamedField extends JsInterface {
  ClassRenamedField.created(JsObject o) : super.created(o);
  ClassRenamedField() : this.created(new JsObject(context['Class0']));

  void set iBis(int _iBis) {
    asJsObject(this)['i'] = _iBis;
  }

  int get iBis => asJsObject(this)['i'];
}

@GeneratedFrom(_ClassRenamedPrivateField)
@JsName('Class0')
class ClassRenamedPrivateField extends JsInterface {
  ClassRenamedPrivateField.created(JsObject o) : super.created(o);
  ClassRenamedPrivateField() : this.created(new JsObject(context['Class0']));

  void set _iBis(int __iBis) {
    asJsObject(this)['i'] = __iBis;
  }

  int get _iBis => asJsObject(this)['i'];
}

@GeneratedFrom(_ClassWithGetter)
@JsName('Class0')
class ClassWithGetter extends JsInterface {
  ClassWithGetter.created(JsObject o) : super.created(o);
  ClassWithGetter() : this.created(new JsObject(context['Class0']));

  int get i => asJsObject(this)['i'];
}

@GeneratedFrom(_ClassWithSetter)
@JsName('Class0')
class ClassWithSetter extends JsInterface {
  ClassWithSetter.created(JsObject o) : super.created(o);
  ClassWithSetter() : this.created(new JsObject(context['Class0']));

  set i(int i) {
    asJsObject(this)['i'] = i;
  }
}

@GeneratedFrom(_ClassWithPrivateGetter)
@JsName('Class0')
class ClassWithPrivateGetter extends JsInterface {
  ClassWithPrivateGetter.created(JsObject o) : super.created(o);
  ClassWithPrivateGetter() : this.created(new JsObject(context['Class0']));

  int get _i => asJsObject(this)['i'];
}

@GeneratedFrom(_ClassWithPrivateSetter)
@JsName('Class0')
class ClassWithPrivateSetter extends JsInterface {
  ClassWithPrivateSetter.created(JsObject o) : super.created(o);
  ClassWithPrivateSetter() : this.created(new JsObject(context['Class0']));

  set _i(int i) {
    asJsObject(this)['i'] = i;
  }
}

@GeneratedFrom(_ClassWithRenamedGetter)
@JsName('Class0')
class ClassWithRenamedGetter extends JsInterface {
  ClassWithRenamedGetter.created(JsObject o) : super.created(o);
  ClassWithRenamedGetter() : this.created(new JsObject(context['Class0']));

  int get iBis => asJsObject(this)['i'];
}

@GeneratedFrom(_ClassWithRenamedSetter)
@JsName('Class0')
class ClassWithRenamedSetter extends JsInterface {
  ClassWithRenamedSetter.created(JsObject o) : super.created(o);
  ClassWithRenamedSetter() : this.created(new JsObject(context['Class0']));

  set iBis(int i) {
    asJsObject(this)['i'] = i;
  }
}
