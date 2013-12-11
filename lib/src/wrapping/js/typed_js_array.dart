part of js_wrapping;

// TODO use JsArray instead
class TypedJsArray<E> extends TypedJsObject with ListMixin
    implements Serializable<JsObject> {
  static final $decode = new TypedJsObjectDecoder<TypedJsArray>(
      (JsObject jsObject) => new TypedJsArray.fromJsObject(jsObject));

  static TypedJsObjectDecoder<TypedJsArray> $getDecode(Codec innerCodec) =>
      new TypedJsObjectDecoder<TypedJsArray>((JsObject jsObject) =>
          new TypedJsArray.fromJsObject(jsObject, innerCodec));

  final Codec<E, dynamic> _codec;

  TypedJsArray.fromJsObject(JsObject jsObject, [Codec<E, dynamic> codec])
      : this._codec = codec,
        super.fromJsObject(jsObject);

  // private methods

  dynamic _toJs(E e) => _codec == null ? e : _codec.encode(e);
  E _fromJs(dynamic value) => _codec == null ? value : _codec.decode(value);

  // method to implement for ListMixin

  @override int get length => $unsafe['length'];
  @override void set length(int length) { $unsafe['length'] = length; }
  @override E operator [](index) {
    if (index is int && (index < 0 || index >= this.length)) {
      throw new RangeError.value(index);
    }
    return _fromJs($unsafe[index]);
  }
  @override void operator []=(int index, E value) {
    if (index < 0 || index >= this.length) {
      throw new RangeError.value(index);
    }
    $unsafe[index] = _toJs(value);
  }

  // overriden methods for better performance

  @override void add(E value) { $unsafe.callMethod('push', [_toJs(value)]); }
  @override void addAll(Iterable<E> iterable) {
    $unsafe.callMethod('push', iterable.map(_toJs).toList());
  }
  @override void sort([int compare(E a, E b)]) {
    final sortedList = toList()..sort(compare);
    setRange(0, sortedList.length, sortedList);
  }
  @override void insert(int index, E element) {
    $unsafe.callMethod('splice', [index, 0, _toJs(element)]);
  }
  @override E removeAt(int index) {
    if (index < 0 || index >= this.length) throw new RangeError.value(index);
    return _fromJs($unsafe.callMethod('splice', [index, 1])[0]);
  }
  @override E removeLast() => _fromJs($unsafe.callMethod('pop'));
  @override void setRange(int start, int length, List<E> from,
                          [int startFrom = 0]) {
    final args = [start, length];
    for(int i = startFrom; i < startFrom + length; i++) {
      args.add(_toJs(from[i]));
    }
    $unsafe.callMethod('splice', args);
  }
  @override void removeRange(int start, int end) {
    $unsafe.callMethod('splice', [start, end - start]);
  }
}
