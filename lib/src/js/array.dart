part of js_wrap;

class _JsIterator<E> implements Iterator<E> {
  JsArray<E> jsArray;
  int current = 0;

  _JsIterator(this.jsArray);

  // Iterator
  @override E next() => jsArray[current++];
  @override bool get hasNext => current < jsArray.length;
}

class JsArray<E> extends TypedProxy implements List<E> {
  static JsArray toJs(List list, [Transformer instantiator]) => transformIfNotNull(list, (list) => list is JsArray && list._instantiator == instantiator ? list : new JsArray(list, instantiator));

  Transformer _instantiator;

  JsArray(List list, [E instantiator(e)]) : this.fromJsProxy(js.array(list), instantiator);
  JsArray.fromJsProxy(js.Proxy jsProxy, [E instantiator(e)]) : super.fromJsProxy(jsProxy) {
    _instantiator = instantiator != null ? instantiator : (e) => e;

  }

  // Object
  @override String toString() => _asList().toString();

  // Iterable
  @override Iterator<E> iterator() => new _JsIterator<E>(this);

  // Collection
  @override void forEach(void f(E element)) => _asList().forEach(f);
  @override Collection map(f(E element)) => _asList().map(f);
  @override dynamic reduce(dynamic initialValue, dynamic combine(dynamic previousValue, E element)) => _asList().reduce(initialValue, combine);
  @override Collection<E> filter(bool f(E element)) => _asList().filter(f);
  @override bool every(bool f(E element)) => _asList().every(f);
  @override bool some(bool f(E element)) => _asList().some(f);
  @override bool get isEmpty => length == 0;
  @override int get length => $proxy.length;
  @override bool contains(E element) => _asList().contains(element);

  // List
  @override E operator [](int index) => transformIfNotNull($proxy[index], _instantiator);
  @override void operator []=(int index, E value) { $proxy[index] = value; }
  @override void set length(int newLength) {
    final length = this.length;
    if (length < newLength) {
      final nulls = new List<E>(newLength - length);
      addAll(nulls);
    }
    if (length > newLength) {
      throw new UnsupportedError("New length has to be greater than actual length");
    }
  }
  @override void add(E value) { $proxy.push(value); }
  @override void addLast(E value) { $proxy.push(value); }
  @override void addAll(Collection<E> collection) { setRange(length, collection.length, collection); }
  @override void sort([int compare(E a, E b)]) {
    final sortedList = _asList()..sort(compare);
    clear();
    addAll(sortedList);
  }
  @override int indexOf(E element, [int start = 0]) => _asList().indexOf(element, start);
  @override int lastIndexOf(E element, [int start]) => _asList().lastIndexOf(element, start);
  @override void clear() { $proxy.splice(0, length); }
  @override E removeAt(int index) => (transformIfNotNull($proxy.splice(index, 1), (proxy) => new JsArray<E>.fromJsProxy(proxy, _instantiator)) as JsArray<E>)[0];
  @override E removeLast() => transformIfNotNull($proxy.pop(), _instantiator);
  @override E get first => $proxy[0];
  @override E get last => $proxy[length - 1];
  @override List<E> getRange(int start, int length) => _asList().getRange(start, length);
  @override void setRange(int start, int length, List<E> from, [int startFrom = 0]) {
    final args = [start, 0];
    for(int i = startFrom; i < length; i++) {
      args.add(from[i]);
    }
    $proxy.noSuchMethod(new ProxyInvocationMirror.method("splice", args));
  }
  @override void removeRange(int start, int length) { $proxy.splice(start, length); }
  @override void insertRange(int start, int length, [E initialValue]) {
    final args = [start, 0];
    for (int i = 0; i < length; i++) {
      args.add(initialValue);
    }
    $proxy.noSuchMethod(new ProxyInvocationMirror.method("splice", args));
  }

  List<E> _asList() {
    final list = new List<E>();
    for (int i = 0; i < length; i++) {
      list.add($proxy[i]);
    }
    return list;
  }
}