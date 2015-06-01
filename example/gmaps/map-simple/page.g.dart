// GENERATED CODE - DO NOT MODIFY BY HAND
// 2015-06-01T07:08:49.085Z

part of google_maps.sample.simple;

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: abstract class _GMap
// **************************************************************************

@JsName('Map')
class GMap extends JsInterface implements _GMap {
  GMap.created(JsObject o) : super.created(o);
  GMap(Node mapDiv, [MapOptions opts]) : this.created(new JsObject(
          context['google']['maps']['Map'], [mapDiv, __codec19.encode(opts)]));

  num _getZoom() => asJsObject(this).callMethod('getZoom');
  num get zoom => _getZoom();
}
/// codec for google_maps.sample.simple.MapOptions
final __codec19 =
    new JsInterfaceCodec<MapOptions>((o) => new MapOptions.created(o));

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: abstract class _LatLng
// **************************************************************************

class LatLng extends JsInterface implements _LatLng {
  LatLng.created(JsObject o) : super.created(o);
  LatLng(num lat, num lng, [bool noWrap]) : this.created(new JsObject(
          context['google']['maps']['LatLng'], [lat, lng, noWrap]));

  bool equals(LatLng other) =>
      asJsObject(this).callMethod('equals', [__codec20.encode(other)]);
  num get lat => _lat();
  num _lat() => asJsObject(this).callMethod('lat');
  num get lng => _lng();
  num _lng() => asJsObject(this).callMethod('lng');
  String toString() => asJsObject(this).callMethod('toString');
  String toUrlValue([num precision]) =>
      asJsObject(this).callMethod('toUrlValue', [precision]);
}
/// codec for google_maps.sample.simple.LatLng
final __codec20 = new JsInterfaceCodec<LatLng>((o) => new LatLng.created(o));

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: abstract class _MapOptions
// **************************************************************************

@anonymous
class MapOptions extends JsInterface implements _MapOptions {
  MapOptions.created(JsObject o) : super.created(o);
  MapOptions() : this.created(new JsObject(context['Object']));

  void set zoom(int _zoom) {
    asJsObject(this)['zoom'] = _zoom;
  }
  int get zoom => asJsObject(this)['zoom'];
  void set center(LatLng _center) {
    asJsObject(this)['center'] = __codec20.encode(_center);
  }
  LatLng get center => __codec20.decode(asJsObject(this)['center']);
  void set mapTypeId(MapTypeId _mapTypeId) {
    asJsObject(this)['mapTypeId'] = __codec21.encode(_mapTypeId);
  }
  MapTypeId get mapTypeId => __codec21.decode(asJsObject(this)['mapTypeId']);
}
/// codec for google_maps.sample.simple.MapTypeId
final __codec21 = new BiMapCodec<MapTypeId, dynamic>(
    new Map<MapTypeId, dynamic>.fromIterable(MapTypeId.values, value: asJs));

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: class _MapTypeId
// **************************************************************************

class MapTypeId extends JsEnum {
  static final values = <MapTypeId>[HYBRID, ROADMAP, SATELLITE, TERRAIN];
  static final HYBRID = new MapTypeId._(
      'HYBRID', context['google']['maps']['MapTypeId']['HYBRID']);
  static final ROADMAP = new MapTypeId._(
      'ROADMAP', context['google']['maps']['MapTypeId']['ROADMAP']);
  static final SATELLITE = new MapTypeId._(
      'SATELLITE', context['google']['maps']['MapTypeId']['SATELLITE']);
  static final TERRAIN = new MapTypeId._(
      'TERRAIN', context['google']['maps']['MapTypeId']['TERRAIN']);

  final String _name;
  MapTypeId._(this._name, o) : super.created(o);

  String toString() => 'MapTypeId.$_name';

  // dumb code to remove analyzer hint for unused _MapTypeId
  _MapTypeId _dumbMethod1() => _dumbMethod2();
  _MapTypeId _dumbMethod2() => _dumbMethod1();
}

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: abstract class _GEvent
// **************************************************************************

class GEvent extends JsInterface implements _GEvent {
  GEvent.created(JsObject o) : super.created(o);

  MapsEventListener addDomListener(
      dynamic instance, String eventName, Function handler,
      [bool capture]) => __codec22.decode(asJsObject(this).callMethod(
          'addDomListener', [instance, eventName, handler, capture]));
  MapsEventListener addDomListenerOnce(
      dynamic instance, String eventName, Function handler,
      [bool capture]) => __codec22.decode(asJsObject(this).callMethod(
          'addDomListenerOnce', [instance, eventName, handler, capture]));
  MapsEventListener addListener(
      dynamic instance, String eventName, Function handler) => __codec22.decode(
          asJsObject(this).callMethod(
              'addListener', [instance, eventName, handler]));
  MapsEventListener addListenerOnce(
      dynamic instance, String eventName, Function handler) => __codec22.decode(
          asJsObject(this).callMethod(
              'addListenerOnce', [instance, eventName, handler]));
  void clearInstanceListeners(dynamic instance) {
    asJsObject(this).callMethod('clearInstanceListeners', [instance]);
  }
  void clearListeners(dynamic instance, String eventName) {
    asJsObject(this).callMethod('clearListeners', [instance, eventName]);
  }
  void removeListener(MapsEventListener listener) {
    asJsObject(this).callMethod('removeListener', [__codec22.encode(listener)]);
  }
  void trigger(
      dynamic instance, String eventName, /*@VarArgs()*/ List<dynamic> args) {
    asJsObject(this).callMethod(
        'trigger', [instance, eventName, __codec23.encode(args)]);
  }
}
/// codec for google_maps.sample.simple.MapsEventListener
final __codec22 = new JsInterfaceCodec<MapsEventListener>(
    (o) => new MapsEventListener.created(o));

/// codec for dart.core.List<dynamic>
final __codec23 = new JsListCodec<dynamic>(null);

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: abstract class _MapsEventListener
// **************************************************************************

class MapsEventListener extends JsInterface implements _MapsEventListener {
  MapsEventListener.created(JsObject o) : super.created(o);
}
