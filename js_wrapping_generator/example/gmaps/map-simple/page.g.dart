// GENERATED CODE - DO NOT MODIFY BY HAND

part of google_maps.sample.simple;

// **************************************************************************
// JsWrappingGenerator
// **************************************************************************

@GeneratedFrom(_MapTypeId)
@JS('MapTypeId')
class MapTypeId {
  external static MapTypeId get HYBRID;
  external static MapTypeId get ROADMAP;
  external static MapTypeId get SATELLITE;
  external static MapTypeId get TERRAIN;
}

/// google.maps.Map template
@GeneratedFrom(_GMap)
@JS('Map')
class GMap {
  external GMap(Node mapDiv, [MapOptions opts]);
}

@GeneratedFrom(_GMap)
extension GMap$Ext on GMap {
  num get zoom => _getZoom();

  num _getZoom() => callMethod(this, 'getZoom', []);
}

@GeneratedFrom(_LatLng)
@JS()
class LatLng {
  external LatLng(num lat, num lng, [bool noWrap]);

  external bool equals(LatLng other);

  external String toString();

  external String toUrlValue([num precision]);
}

@GeneratedFrom(_LatLng)
extension LatLng$Ext on LatLng {
  num get lat => _lat();
  num get lng => _lng();

  num _lat() => callMethod(this, 'lat', []);

  num _lng() => callMethod(this, 'lng', []);
}

@GeneratedFrom(_MapOptions)
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

@GeneratedFrom(_MapsEventListener)
@JS()
@anonymous
class MapsEventListener {
  external factory MapsEventListener();

  external void remove();
}
