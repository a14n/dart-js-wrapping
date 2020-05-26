// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

@JS('google.maps')
library google_maps.sample.simple;

import 'dart:html';

import 'package:js_wrapping/js_wrapping.dart';

part 'page.g.dart';

/// google.maps.Map template
@JsName('Map')
abstract class _GMap {
  factory _GMap(Node mapDiv, [MapOptions opts]) => $js;

  @JsName('getZoom')
  num _getZoom();
  num get zoom => _getZoom();
}

@JsName()
abstract class _LatLng {
  factory _LatLng(num lat, num lng, [bool noWrap]) => $js;

  bool equals(LatLng other);
  num get lat => _lat();
  @JsName('lat')
  num _lat();
  num get lng => _lng();
  @JsName('lng')
  num _lng();
  String toString();
  String toUrlValue([num precision]);
}

@JsName()
@anonymous
abstract class _MapOptions {
  factory _MapOptions() => $js;

  int zoom;
  LatLng center;
  MapTypeId mapTypeId;
}

@JsName('MapTypeId')
enum _MapTypeId {
  HYBRID,
  ROADMAP,
  SATELLITE,
  TERRAIN,
}

@JS('google.maps.event')
external Object get _Event$namespace;

class Event {
  static MapsEventListener addDomListener(
          Object instance, String eventName, Function handler,
          [bool capture]) =>
      callMethod(_Event$namespace, 'addDomListener',
          [instance, eventName, handler, capture]);
  static MapsEventListener addDomListenerOnce(
          Object instance, String eventName, Function handler,
          [bool capture]) =>
      callMethod(_Event$namespace, 'addDomListenerOnce',
          [instance, eventName, handler, capture]);
  static MapsEventListener addListener(
          Object instance, String eventName, Function handler) =>
      callMethod(
          _Event$namespace, 'addListener', [instance, eventName, handler]);
  static MapsEventListener addListenerOnce(
          Object instance, String eventName, Function handler) =>
      callMethod(
          _Event$namespace, 'addListenerOnce', [instance, eventName, handler]);
  static void clearInstanceListeners(Object instance) =>
      callMethod(_Event$namespace, 'clearInstanceListeners', [instance]);
  static void clearListeners(Object instance, String eventName) =>
      callMethod(_Event$namespace, 'clearListeners', [instance, eventName]);
  static void removeListener(MapsEventListener listener) =>
      callMethod(_Event$namespace, 'removeListener', [listener]);

  static void trigger(
          Object instance, String eventName, List<Object> eventArgs) =>
      callMethod(
          _Event$namespace, 'trigger', [instance, eventName, ...?eventArgs]);
}

@JsName()
@anonymous
abstract class _MapsEventListener {
  factory _MapsEventListener() => $js;
  void remove();
}
void main() {
  final mapOptions = MapOptions()
    ..zoom = 8
    ..center = LatLng(-34.397, 150.644)
    ..mapTypeId = MapTypeId.ROADMAP;
  final map = GMap(querySelector('#map_canvas'), mapOptions);
  Event.addListener(map, 'zoom_changed', () => print(map.zoom));
}
