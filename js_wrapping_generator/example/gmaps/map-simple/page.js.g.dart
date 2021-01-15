// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// JsWrappingGenerator
// **************************************************************************

// Copyright (c) 2015, Alexandre Ardhuin. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in the
// LICENSE file.

@JS('google.maps')
library google_maps.sample.simple;

import 'dart:html';

import 'package:js_wrapping/js_wrapping.dart';

@JS('Map')
class GMap {
  external GMap(Node mapDiv, [MapOptions opts]);
}

extension GMap$Ext on GMap {
  num get zoom => _getZoom();

  num _getZoom() => callMethod(this, '_getZoom', []);
}

@JS()
class LatLng {
  external LatLng(num lat, num lng, [bool noWrap]);

  external bool equals(LatLng other);

  external String toString();

  external String toUrlValue([num precision]);
}

extension LatLng$Ext on LatLng {
  num get lat => _lat();
  num get lng => _lng();

  num _lat() => callMethod(this, '_lat', []);

  num _lng() => callMethod(this, '_lng', []);
}

@JS()
@anonymous
class MapOptions {
  external factory MapOptions();

  external int get zoom;

  external set zoom(int value);

  external LatLng get center;

  external set center(LatLng value);

  external MapTypeId get mapTypeId;

  external set mapTypeId(MapTypeId value);
}

@JS('MapTypeId')
class MapTypeId {
  external static MapTypeId get HYBRID;
  external static MapTypeId get ROADMAP;
  external static MapTypeId get SATELLITE;
  external static MapTypeId get TERRAIN;
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

@JS()
@anonymous
class MapsEventListener {
  external factory MapsEventListener();

  external void remove();
}

void main() {
  final mapOptions = MapOptions()
    ..zoom = 8
    ..center = LatLng(-34.397, 150.644)
    ..mapTypeId = MapTypeId.ROADMAP;
  final map = GMap(querySelector('#map_canvas'), mapOptions);
  Event.addListener(map, 'zoom_changed', () => print(map.zoom));
}
