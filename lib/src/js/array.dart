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
  static JsArray toJs(List list, [Transformer instantiator]) => transformIfNotNull(list, (list) => list is JsArray && list._instantiator == instantiator ? list : new JsArray(list, instantiator));

  Transformer _instantiator;

  JsArray(List list, [E instantiator(e)]) : this.fromJsProxy(js.array(list), instantiator);
  JsArray.fromJsProxy(js.Proxy jsProxy, [E instantiator(e)]) : super.fromJsProxy(jsProxy) {
    _instantiator = instantiator != null ? instantiator : (e) => e;
  }

  // Object
  @override String toString() => _asList().toString();

  // Iterable
  @override Iterator<E> get iterator => new _JsIterator<E>(this);
  @override int get length => $proxy.length;

  // Collection
  @override void add(E value) { $proxy.push(value); }
  @override void clear() { $proxy.splice(0, length); }
  @override void remove(Object element) { removeAt(indexOf(element)); }

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
  @override void addLast(E value) { $proxy.push(value); }
  @override List<E> get reversed => _asList().reversed;
  @override void sort([int compare(E a, E b)]) {
    final sortedList = _asList()..sort(compare);
    clear();
    addAll(sortedList);
  }
  @override int indexOf(E element, [int start = 0]) => _asList().indexOf(element, start);
  @override int lastIndexOf(E element, [int start]) => _asList().lastIndexOf(element, start);
  @override E removeAt(int index) => (transformIfNotNull($proxy.splice(index, 1), (proxy) => new JsArray<E>.fromJsProxy(proxy, _instantiator)) as JsArray<E>)[0];
  @override E removeLast() => transformIfNotNull($proxy.pop(), _instantiator);
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

  // -------remove this copy of Iterable when mixin will land

  /**
   * Returns a lazy [Iterable] where each element [:e:] of [this] is replaced
   * by the result of [:f(e):].
   *
   * This method returns a view of the mapped elements. As long as the
   * returned [Iterable] is not iterated over, the supplied function [f] will
   * not be invoked. The transformed elements will not be cached. Iterating
   * multiple times over the the returned [Iterable] will invoke the supplied
   * function [f] multiple times on the same element.
   */
  Iterable mappedBy(f(E element)) => new MappedIterable<E, dynamic>(this, f);

  /**
    * Returns a lazy [Iterable] with all elements that satisfy the
    * predicate [f].
    *
    * This method returns a view of the mapped elements. As long as the
    * returned [Iterable] is not iterated over, the supplied function [f] will
    * not be invoked. Iterating will not cache results, and thus iterating
    * multiple times over the the returned [Iterable] will invoke the supplied
    * function [f] multiple times on the same element.
    */
  Iterable<E> where(bool f(E element)) => new WhereIterable<E>(this, f);

  /**
   * Check whether the collection contains an element equal to [element].
   */
  bool contains(E element) {
    for (E e in this) {
      if (e == element) return true;
    }
    return false;
  }

  /**
   * Applies the function [f] to each element of this collection.
   */
  void forEach(void f(E element)) {
    for (E element in this) f(element);
  }

  /**
   * Reduce a collection to a single value by iteratively combining each element
   * of the collection with an existing value using the provided function.
   * Use [initialValue] as the initial value, and the function [combine] to
   * create a new value from the previous one and an element.
   *
   * Example of calculating the sum of a collection:
   *
   *   collection.reduce(0, (prev, element) => prev + element);
   */
  dynamic reduce(var initialValue,
                 dynamic combine(var previousValue, E element)) {
    var value = initialValue;
    for (E element in this) value = combine(value, element);
    return value;
  }

  /**
   * Returns true if every elements of this collection satisify the
   * predicate [f]. Returns false otherwise.
   */
  bool every(bool f(E element)) {
    for (E element in this) {
      if (!f(element)) return false;
    }
    return true;
  }

  /**
   * Convert each element to a [String] and concatenate the strings.
   *
   * Converts each element to a [String] by calling [Object.toString] on it.
   * Then concatenates the strings, optionally separated by the [separator]
   * string.
   */
  String join([String separator]) {
    Iterator<E> iterator = this.iterator;
    if (!iterator.moveNext()) return "";
    StringBuffer buffer = new StringBuffer();
    if (separator == null || separator == "") {
      do {
        buffer.add("${iterator.current}");
      } while (iterator.moveNext());
    } else {
      buffer.add("${iterator.current}");
      while (iterator.moveNext()) {
        buffer.add(separator);
        buffer.add("${iterator.current}");
      }
    }
    return buffer.toString();
  }

  /**
   * Returns true if one element of this collection satisfies the
   * predicate [f]. Returns false otherwise.
   */
  bool any(bool f(E element)) {
    for (E element in this) {
      if (f(element)) return true;
    }
    return false;
  }

  List<E> toList() => new List<E>.from(this);
  Set<E> toSet() => new Set<E>.from(this);

  /**
   * Find the least element in the iterable.
   *
   * Returns null if the iterable is empty.
   * Otherwise returns an element [:x:] of this [Iterable] so that
   * [:x:] is not greater than [:y:] (that is, [:compare(x, y) <= 0:]) for all
   * other elements [:y:] in the iterable.
   *
   * The [compare] function must be a proper [Comparator<T>]. If a function is
   * not provided, [compare] defaults to [Comparable.compare].
   */
  E min([int compare(E a, E b)]) {
    if (compare == null) compare = Comparable.compare;
    Iterator it = iterator;
    if (!it.moveNext()) return null;
    E min = it.current;
    while (it.moveNext()) {
      E current = it.current;
      if (compare(min, current) > 0) min = current;
    }
    return min;
  }

  /**
   * Find the largest element in the iterable.
   *
   * Returns null if the iterable is empty.
   * Otherwise returns an element [:x:] of this [Iterable] so that
   * [:x:] is not smaller than [:y:] (that is, [:compare(x, y) >= 0:]) for all
   * other elements [:y:] in the iterable.
   *
   * The [compare] function must be a proper [Comparator<T>]. If a function is
   * not provided, [compare] defaults to [Comparable.compare].
   */
  E max([int compare(E a, E b)]) {
    if (compare == null) compare = Comparable.compare;
    Iterator it = iterator;
    if (!it.moveNext()) return null;
    E max = it.current;
    while (it.moveNext()) {
      E current = it.current;
      if (compare(max, current) < 0) max = current;
    }
    return max;
  }

  /**
   * Returns true if there is no element in this collection.
   */
  bool get isEmpty => !iterator.moveNext();

  /**
   * Returns an [Iterable] with at most [n] elements.
   *
   * The returned [Iterable] may contain fewer than [n] elements, if [this]
   * contains fewer than [n] elements.
   */
  Iterable<E> take(int n) {
    return new TakeIterable<E>(this, n);
  }

  /**
   * Returns an [Iterable] that stops once [test] is not satisfied anymore.
   *
   * The filtering happens lazily. Every new [Iterator] of the returned
   * [Iterable] will start iterating over the elements of [this].
   * When the iterator encounters an element [:e:] that does not satisfy [test],
   * it discards [:e:] and moves into the finished state. That is, it will not
   * ask or provide any more elements.
   */
  Iterable<E> takeWhile(bool test(E value)) {
    return new TakeWhileIterable<E>(this, test);
  }

  /**
   * Returns an [Iterable] that skips the first [n] elements.
   *
   * If [this] has fewer than [n] elements, then the resulting [Iterable] will
   * be empty.
   */
  Iterable<E> skip(int n) {
    return new SkipIterable<E>(this, n);
  }

  /**
   * Returns an [Iterable] that skips elements while [test] is satisfied.
   *
   * The filtering happens lazily. Every new [Iterator] of the returned
   * [Iterable] will iterate over all elements of [this].
   * As long as the iterator's elements do not satisfy [test] they are
   * discarded. Once an element satisfies the [test] the iterator stops testing
   * and uses every element unconditionally.
   */
  Iterable<E> skipWhile(bool test(E value)) {
    return new SkipWhileIterable<E>(this, test);
  }

  /**
   * Returns the first element.
   *
   * If [this] is empty throws a [StateError]. Otherwise this method is
   * equivalent to [:this.elementAt(0):]
   */
  E get first {
    Iterator it = iterator;
    if (!it.moveNext()) {
      throw new StateError("No elements");
    }
    return it.current;
  }

  /**
   * Returns the last element.
   *
   * If [this] is empty throws a [StateError].
   */
  E get last {
    Iterator it = iterator;
    if (!it.moveNext()) {
      throw new StateError("No elements");
    }
    E result;
    do {
      result = it.current;
    } while(it.moveNext());
    return result;
  }

  /**
   * Returns the single element in [this].
   *
   * If [this] is empty or has more than one element throws a [StateError].
   */
  E get single {
    Iterator it = iterator;
    if (!it.moveNext()) throw new StateError("No elements");
    E result = it.current;
    if (it.moveNext()) throw new StateError("More than one element");
    return result;
  }

  /**
   * Returns the first element that satisfies the given predicate [f].
   *
   * If none matches, the result of invoking the [orElse] function is
   * returned. By default, when [orElse] is `null`, a [StateError] is
   * thrown.
   */
  E firstMatching(bool test(E value), { E orElse() }) {
    // TODO(floitsch): check that arguments are of correct type?
    for (E element in this) {
      if (test(element)) return element;
    }
    if (orElse != null) return orElse();
    throw new StateError("No matching element");
  }

  /**
   * Returns the last element that satisfies the given predicate [f].
   *
   * If none matches, the result of invoking the [orElse] function is
   * returned. By default, when [orElse] is [:null:], a [StateError] is
   * thrown.
   */
  E lastMatching(bool test(E value), {E orElse()}) {
    // TODO(floitsch): check that arguments are of correct type?
    E result = null;
    bool foundMatching = false;
    for (E element in this) {
      if (test(element)) {
        result = element;
        foundMatching = true;
      }
    }
    if (foundMatching) return result;
    if (orElse != null) return orElse();
    throw new StateError("No matching element");
  }

  /**
   * Returns the single element that satisfies [f]. If no or more than one
   * element match then a [StateError] is thrown.
   */
  E singleMatching(bool test(E value)) {
    // TODO(floitsch): check that argument is of correct type?
    E result = null;
    bool foundMatching = false;
    for (E element in this) {
      if (test(element)) {
        if (foundMatching) {
          throw new StateError("More than one matching element");
        }
        result = element;
        foundMatching = true;
      }
    }
    if (foundMatching) return result;
    throw new StateError("No matching element");
  }

  /**
   * Returns the [index]th element.
   *
   * If [this] [Iterable] has fewer than [index] elements throws a
   * [RangeError].
   *
   * Note: if [this] does not have a deterministic iteration order then the
   * function may simply return any element without any iteration if there are
   * at least [index] elements in [this].
   */
  E elementAt(int index) {
    if (index is! int || index < 0) throw new RangeError.value(index);
    int remaining = index;
    for (E element in this) {
      if (remaining == 0) return element;
      remaining--;
    }
    throw new RangeError.value(index);
  }

  // Collection
  /**
   * Adds all of [elements] to this collection.
   *
   * Equivalent to adding each element in [elements] using [add],
   * but some collections may be able to optimize it.
   */
  void addAll(Iterable<E> elements) {
    for (E element in elements) {
      add(element);
    }
  }

  /**
   * Removes all of [elements] from this collection.
   *
   * Equivalent to calling [remove] once for each element in
   * [elements], but may be faster for some collections.
   */
  void removeAll(Iterable elements) {
    IterableMixinWorkaround.removeAll(this, elements);
  }

  /**
   * Removes all elements of this collection that are not
   * in [elements].
   *
   * For [Set]s, this is the intersection of the two original sets.
   */
  void retainAll(Iterable elements) {
    IterableMixinWorkaround.retainAll(this, elements);
  }

  /**
   * Removes all elements of this collection that satisfy [test].
   *
   * An elements [:e:] satisfies [test] if [:test(e):] is true.
   */
  void removeMatching(bool test(E element)) {
    IterableMixinWorkaround.removeMatching(this, test);
  }

  /**
   * Removes all elements of this collection that fail to satisfy [test].
   *
   * An elements [:e:] satisfies [test] if [:test(e):] is true.
   */
  void retainMatching(bool test(E element)) {
    IterableMixinWorkaround.retainMatching(this, test);
  }
}