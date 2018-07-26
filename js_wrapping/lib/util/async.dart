// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

library js_wrapping.util.async;

import 'dart:async';

typedef _EventSinkCallback<T> = void Function(EventSink<T> eventSink);

/// Utility class to create streams from event retrieve with
/// `subscribe`/`unsubscribe`.
class SubscribeStreamProvider<T> implements EventSink<T> {
  final _EventSinkCallback<T> subscribe;
  final _EventSinkCallback<T> unsubscribe;
  final _controllers = <StreamController<T>>[];
  bool _active = false;

  SubscribeStreamProvider({this.subscribe, this.unsubscribe});

  void _addController(StreamController<T> controller) {
    _controllers.add(controller);
    if (!_active && subscribe != null) subscribe(this);
    _active = true;
  }

  void _removeController(StreamController<T> controller) {
    _controllers.remove(controller);
    if (_controllers.isEmpty && unsubscribe != null && _active) {
      unsubscribe(this);
      _active = false;
    }
  }

  Stream<T> get stream {
    StreamController<T> controller;
    controller = StreamController<T>(
        onListen: () => _addController(controller),
        onCancel: () => _removeController(controller),
        sync: true);
    return controller.stream;
  }

  @override
  void add(T event) {
    for (var controller in _controllers.toList()) {
      controller.add(event);
    }
  }

  @override
  void addError(errorEvent, [StackTrace stackTrace]) {
    for (var controller in _controllers.toList()) {
      controller.addError(errorEvent, stackTrace);
    }
  }

  @override
  void close() {
    for (var controller in _controllers.toList()) {
      controller.close();
    }
  }
}
