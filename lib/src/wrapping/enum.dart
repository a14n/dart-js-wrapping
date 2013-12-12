// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of js_wrapping;

class IsEnum<E> implements Serializable<E> {
  E $unsafe;

  IsEnum(this.$unsafe);

  bool operator ==(other) => other is IsEnum && $unsafe == other.$unsafe;
  int get hashCode => $unsafe.hashCode;
}

class EnumFinder<T, E extends IsEnum<T>> {
  final List<E> elements;
  EnumFinder(this.elements);
  E find(o) => o is E ? _findByEquals(o) : o is T ? _findByValue(o) : null;
  E _findByEquals(E o) => elements.firstWhere((E e) => e == o, orElse: () => null);
  E _findByValue(T o) => elements.firstWhere((E e) => e.$unsafe == o, orElse: () => null);
}
