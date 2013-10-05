// Copyright (c) 2013, Alexandre Ardhuin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

part of js_wrapping;

class EnumFinder<T, E extends IsEnum<T>> {
  final List<E> elements;
  EnumFinder(this.elements);
  E find(o) => o is E ? _findByEquals(o) : o is T ? _findByValue(o) : null;
  E _findByEquals(E o) => elements.firstWhere((E e) => e == o, orElse: () => null);
  E _findByValue(T o) => elements.firstWhere((E e) => e.value == o, orElse: () => null);
}

class IsEnum<E> implements Serializable<E> {
  E value;

  IsEnum(this.value);

  @override E toJs() => value;
}

typedef _EventSinkCallback<T>(EventSink<T> eventSink);
/// Utility class to create streams from event retrieve with subscribe/unsubscribe
class SubscribeStreamProvider<T> implements EventSink<T> {
  final _EventSinkCallback<T> subscribe;
  final _EventSinkCallback<T> unsubscribe;
  final _controllers = new List<StreamController<T>>();

  SubscribeStreamProvider({subscribe(EventSink<T> eventSink), unsubscribe(EventSink<T> eventSink)})
      : subscribe = subscribe,
        unsubscribe = unsubscribe;

  void _addController(StreamController<T> controller) {
    _controllers.add(controller);
    if (_controllers.length == 1 && subscribe != null) subscribe(this);
  }

  void _removeController(StreamController<T> controller) {
    _controllers.remove(controller);
    if (_controllers.isEmpty && unsubscribe != null) unsubscribe(this);
  }

  Stream<T> get stream {
    StreamController<T> controller;
    controller = new StreamController<T>(
        onListen: () => _addController(controller),
        onCancel: () => _removeController(controller),
        sync: true);
    return controller.stream;
  }

  void add(T event) => _controllers.toList().forEach((controller) => controller.add(event));
  void addError(errorEvent) => _controllers.toList().forEach((controller) => controller.addError(errorEvent));
  void close() => _controllers.toList().forEach((controller) => controller.close());
}

const _DART_CONVERTED_ELEMENT = 'data-dart_converted_element';

Element convertElementToDart(JsObject jsElement) {
  final jsDocument = context['document'];
  if (jsElement['ownerDocument'] == jsDocument) {
    final retrieveElement = () {
      final element = query("[$_DART_CONVERTED_ELEMENT]");
      element.attributes.remove(_DART_CONVERTED_ELEMENT);
      return element;
    };

    jsElement.callMethod('setAttribute', [_DART_CONVERTED_ELEMENT, true]);
    final jsDocumentElement = jsDocument['documentElement'];
    JsObject jsCurrentElement = jsElement;
    if (jsCurrentElement == jsDocumentElement) {
      return retrieveElement();
    }
    while (true) {
      final jsParentElement = jsCurrentElement['parentElement'];
      if (jsParentElement == null) {
        jsDocumentElement.callMethod('appendChild', [jsCurrentElement]);
        Element element = retrieveElement();
        jsDocumentElement.callMethod('removeChild', [jsCurrentElement]);
        return element;
      } else if (jsParentElement == jsDocumentElement) {
        // jsElement was already attached to dom
        return retrieveElement();
      }
      jsCurrentElement = jsParentElement;
    }
  }
  return null;
}

JsObject convertElementToJs(Element element) {
  if (element.document == document) {
    final retrieveJsElement = () {
      final jsElement = context['document'].callMethod('querySelector',
          ["[$_DART_CONVERTED_ELEMENT]"]);
      jsElement.callMethod('removeAttribute' ,[_DART_CONVERTED_ELEMENT]);
      return jsElement;
    };

    element.attributes[_DART_CONVERTED_ELEMENT] = "true";
    final documentElement = document.documentElement;
    Element currentElement = element;
    if (currentElement == documentElement) {
      return retrieveJsElement();
    }
    while (true) {
      final parentElement = currentElement.parent;
      if (parentElement == null) {
        documentElement.children.add(currentElement);
        final jsElement = retrieveJsElement();
        documentElement.children.remove(currentElement);
        return jsElement;
      } else if (parentElement == documentElement) {
        // element was already attached to dom
        return retrieveJsElement();
      }
      currentElement = parentElement;
    }
  }
  return null;
}