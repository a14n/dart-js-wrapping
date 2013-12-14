part of js_wrapping;

// TODO use JsArray instead
class TypedJsArray<E> extends TypedJsObject with ListMixin
    implements Serializable<JsObject> {
  static TypedJsArray $wrap(JsObject jsObject, {wrap(js), unwrap(dart)}) => jsObject == null ? null : new TypedJsArray.fromJsObject(jsObject, wrap: wrap, unwrap: unwrap);

  static TypedJsArray $wrapSerializables(JsObject jsObject, wrap(js)) => jsObject == null ? null : new TypedJsArray.fromJsObject(jsObject, wrap: wrap, unwrap: Serializable.$unwrap);

  final Mapper<E, dynamic> _unwrap;
  final Mapper<dynamic, E> _wrap;

  TypedJsArray.fromJsObject(JsObject jsObject, {Mapper<dynamic, E> wrap, Mapper<E, dynamic> unwrap})
      : _wrap = ((e) => wrap == null ? e : wrap(e)),
        _unwrap = ((e) => unwrap == null ? e : unwrap(e)),
        super.fromJsObject(jsObject);

  // method to implement for ListMixin

  @override int get length => $unsafe['length'];
  @override void set length(int length) { $unsafe['length'] = length; }
  @override E operator [](index) {
    if (index is int && (index < 0 || index >= this.length)) {
      throw new RangeError.value(index);
    }
    return _wrap($unsafe[index]);
  }
  @override void operator []=(int index, E value) {
    if (index < 0 || index >= this.length) {
      throw new RangeError.value(index);
    }
    $unsafe[index] = _unwrap(value);
  }

  // overriden methods for better performance

  @override void add(E value) { $unsafe.callMethod('push', [_unwrap(value)]); }
  @override void addAll(Iterable<E> iterable) {
    $unsafe.callMethod('push', iterable.map(_unwrap).toList());
  }
  @override void sort([int compare(E a, E b)]) {
    final sortedList = toList()..sort(compare);
    setRange(0, sortedList.length, sortedList);
  }
  @override void insert(int index, E element) {
    $unsafe.callMethod('splice', [index, 0, _unwrap(element)]);
  }
  @override E removeAt(int index) {
    if (index < 0 || index >= this.length) throw new RangeError.value(index);
    return _wrap($unsafe.callMethod('splice', [index, 1])[0]);
  }
  @override E removeLast() => _wrap($unsafe.callMethod('pop'));
  @override void setRange(int start, int length, List<E> from,
                          [int startFrom = 0]) {
    final args = [start, length];
    for(int i = startFrom; i < startFrom + length; i++) {
      args.add(_unwrap(from[i]));
    }
    $unsafe.callMethod('splice', args);
  }
  @override void removeRange(int start, int end) {
    $unsafe.callMethod('splice', [start, end - start]);
  }
}
