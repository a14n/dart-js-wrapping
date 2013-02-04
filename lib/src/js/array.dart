part of js_wrap;

class _JsIterator<E> implements Iterator<E> {
  final JsArray<E> _jsArray;
  final int length;
  int _currentIndex = -1;

  _JsIterator(JsArray<E> jsArray) : this._jsArray = jsArray, length = jsArray.length;

  // Iterator
  @override bool moveNext() {
    if (_currentIndex + 1 < length) {
      _currentIndex++;
      return true;
    }
    return false;
  }
  @override E get current => _jsArray[_currentIndex];
}

class JsArray<E> extends TypedProxy implements List<E> {
  static JsArray cast(js.Proxy jsProxy, [Transformer instantiator]) => transformIfNotNull(jsProxy, (jsProxy) => new JsArray.fromJsProxy(jsProxy, instantiator));
  static JsArray jsify(List list, [Transformer instantiator]) => transformIfNotNull(list, (list) => list is JsArray && list._instantiator == instantiator ? list : new JsArray(list, instantiator));

  Transformer _instantiator;

  // TODO use js.array once merge into js-interop
  //JsArray(List list, [E instantiator(e)]) : this.fromJsProxy(js.array(list), instantiator);
  JsArray(List list, [E instantiator(e)]) : this.fromJsProxy(js.array(list.mappedBy(_transform)), instantiator);
  JsArray.fromJsProxy(js.Proxy jsProxy, [E instantiator(e)]) : super.fromJsProxy(jsProxy) {
    _instantiator = instantiator != null ? instantiator : (e) => e;
  }

  // Object
  @override String toString() => _asList().toString();

  // Iterable
  @override Iterator<E> get iterator => new _JsIterator<E>(this);
  @override int get length => $unsafe.length;

  // Collection
  @override void add(E value) { $unsafe.push(value); }
  @override void clear() { $unsafe.splice(0, length); }
  @override void remove(Object element) { removeAt(indexOf(element)); }

  // List
  @override E operator [](int index) => transformIfNotNull($unsafe[index], _instantiator);
  @override void operator []=(int index, E value) { $unsafe[index] = value; }
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
  @override void addLast(E value) { $unsafe.push(value); }
  @override List<E> get reversed => _asList().reversed;
  @override void sort([int compare(E a, E b)]) {
    final sortedList = _asList()..sort(compare);
    clear();
    addAll(sortedList);
  }
  @override int indexOf(E element, [int start = 0]) => _asList().indexOf(element, start);
  @override int lastIndexOf(E element, [int start]) => _asList().lastIndexOf(element, start);
  @override E removeAt(int index) => (transformIfNotNull($unsafe.splice(index, 1), (proxy) => new JsArray<E>.fromJsProxy(proxy, _instantiator)) as JsArray<E>)[0];
  @override E removeLast() => transformIfNotNull($unsafe.pop(), _instantiator);
  @override List<E> getRange(int start, int length) => _asList().getRange(start, length);
  @override void setRange(int start, int length, List<E> from, [int startFrom = 0]) {
    final args = [start, 0];
    for(int i = startFrom; i < length; i++) {
      args.add(from[i]);
    }
    $unsafe.noSuchMethod(new ProxyInvocationMirror.method("splice", args));
  }
  @override void removeRange(int start, int length) { $unsafe.splice(start, length); }
  @override void insertRange(int start, int length, [E initialValue]) {
    final args = [start, 0];
    for (int i = 0; i < length; i++) {
      args.add(initialValue);
    }
    $unsafe.noSuchMethod(new ProxyInvocationMirror.method("splice", args));
  }

  List<E> _asList() {
    final list = new List<E>();
    for (int i = 0; i < length; i++) {
      list.add($unsafe[i]);
    }
    return list;
  }

  // -------remove this copy of Iterable when mixin will land
  @override Iterable mappedBy(f(E element)) => IterableMixinWorkaround.mappedByList(this, f);
  @override Iterable<E> where(bool f(E element)) => IterableMixinWorkaround.where(this, f);
  @override bool contains(E element) => IterableMixinWorkaround.contains(this, element);
  @override void forEach(void f(E element)) => IterableMixinWorkaround.forEach(this, f);
  @override dynamic reduce(var initialValue, dynamic combine(var previousValue, E element)) => IterableMixinWorkaround.reduce(this, initialValue, combine);
  @override bool every(bool f(E element)) => IterableMixinWorkaround.every(this, f);
  @override String join([String separator]) => IterableMixinWorkaround.join(this, separator);
  @override bool any(bool f(E element)) => IterableMixinWorkaround.any(this, f);
  @override List<E> toList() => new List<E>.from(this);
  @override Set<E> toSet() => new Set<E>.from(this);
  @override E min([int compare(E a, E b)]) => IterableMixinWorkaround.min(this, compare);
  @override E max([int compare(E a, E b)]) => IterableMixinWorkaround.max(this, compare);
  @override bool get isEmpty => IterableMixinWorkaround.isEmpty(this);
  @override Iterable<E> take(int n) => IterableMixinWorkaround.takeList(this, n);
  @override Iterable<E> takeWhile(bool test(E value)) =>IterableMixinWorkaround.takeWhile(this, test);
  @override Iterable<E> skip(int n) => IterableMixinWorkaround.skipList(this, n);
  @override Iterable<E> skipWhile(bool test(E value)) => IterableMixinWorkaround.skipWhile(this, test);
  @override E get first => IterableMixinWorkaround.first(this);
  @override E get last => IterableMixinWorkaround.last(this);
  @override E get single => IterableMixinWorkaround.single(this);
  @override E firstMatching(bool test(E value), { E orElse() }) => IterableMixinWorkaround.firstMatching(this, test, orElse);
  @override E lastMatching(bool test(E value), {E orElse()}) => IterableMixinWorkaround.lastMatching(this, test, orElse);
  @override E singleMatching(bool test(E value)) => IterableMixinWorkaround.singleMatching(this, test);
  @override E elementAt(int index) => IterableMixinWorkaround.elementAt(this, index);

  // Collection
  @override void addAll(Iterable<E> elements) {
    for (E element in elements) {
      add(element);
    }
  }
  @override void removeAll(Iterable elements) => IterableMixinWorkaround.removeAll(this, elements);
  @override void retainAll(Iterable elements) => IterableMixinWorkaround.retainAll(this, elements);
  @override void removeMatching(bool test(E element)) => IterableMixinWorkaround.removeMatching(this, test);
  @override void retainMatching(bool test(E element)) => IterableMixinWorkaround.retainMatching(this, test);
}