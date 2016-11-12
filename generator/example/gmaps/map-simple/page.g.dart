// GENERATED CODE - DO NOT MODIFY BY HAND

part of google_maps.sample.simple;

// **************************************************************************
// Generator: JsInterfaceGenerator
// Target: library google_maps.sample.simple
// **************************************************************************

/// codec for google_maps.sample.simple.MapsEventListener
final __codec4 = new JsInterfaceCodec<MapsEventListener>(
    (o) => new MapsEventListener.created(o));

/// codec for google_maps.sample.simple.MapTypeId
final __codec3 = new BiMapCodec<MapTypeId, dynamic>(
    new Map<MapTypeId, dynamic>.fromIterable(MapTypeId.values, value: asJs));

/// codec for google_maps.sample.simple.LatLng
final __codec2 = new JsInterfaceCodec<LatLng>((o) => new LatLng.created(o));

/// codec for google_maps.sample.simple.MapOptions
final __codec1 =
    new JsInterfaceCodec<MapOptions>((o) => new MapOptions.created(o));

/// codec for dart.core.List<dynamic>
final __codec0 = new JsListCodec<dynamic>(null);

@GeneratedFrom(_GMap)
@JsName('Map')
class GMap extends JsInterface {
  GMap.created(JsObject o) : super.created(o);
  GMap(Node mapDiv, [MapOptions opts])
      : this.created(new JsObject(
            context['google']['maps']['Map'] as JsFunction,
            [mapDiv, __codec1.encode(opts)]));

  num _getZoom() => asJsObject(this).callMethod('getZoom') as num;
  num get zoom => _getZoom();
}

@GeneratedFrom(_LatLng)
class LatLng extends JsInterface {
  LatLng.created(JsObject o) : super.created(o);
  LatLng(num lat, num lng, [bool noWrap])
      : this.created(new JsObject(
            context['google']['maps']['LatLng'] as JsFunction,
            [lat, lng, noWrap]));

  bool equals(LatLng other) =>
      asJsObject(this).callMethod('equals', [__codec2.encode(other)]) as bool;
  num get lat => _lat();
  num _lat() => asJsObject(this).callMethod('lat') as num;
  num get lng => _lng();
  num _lng() => asJsObject(this).callMethod('lng') as num;
  String toString() => asJsObject(this).callMethod('toString') as String;
  String toUrlValue([num precision]) =>
      asJsObject(this).callMethod('toUrlValue', [precision]) as String;
}

@GeneratedFrom(_MapOptions)
@anonymous
class MapOptions extends JsInterface {
  MapOptions.created(JsObject o) : super.created(o);
  MapOptions() : this.created(new JsObject(context['Object'] as JsFunction));

  void set zoom(int _zoom) {
    asJsObject(this)['zoom'] = _zoom;
  }

  int get zoom => asJsObject(this)['zoom'] as int;
  void set center(LatLng _center) {
    asJsObject(this)['center'] = __codec2.encode(_center);
  }

  LatLng get center => __codec2.decode(asJsObject(this)['center'] as JsObject);
  void set mapTypeId(MapTypeId _mapTypeId) {
    asJsObject(this)['mapTypeId'] = __codec3.encode(_mapTypeId);
  }

  MapTypeId get mapTypeId =>
      __codec3.decode(asJsObject(this)['mapTypeId'] as JsObject);
}

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

@GeneratedFrom(_GEvent)
class GEvent extends JsInterface {
  GEvent.created(JsObject o) : super.created(o);

  MapsEventListener addDomListener(
          dynamic instance, String eventName, Function handler,
          [bool capture]) =>
      __codec4.decode(asJsObject(this).callMethod(
              'addDomListener', [instance, eventName, handler, capture])
          as JsObject);
  MapsEventListener addDomListenerOnce(
          dynamic instance, String eventName, Function handler,
          [bool capture]) =>
      __codec4.decode(asJsObject(this).callMethod(
              'addDomListenerOnce', [instance, eventName, handler, capture])
          as JsObject);
  MapsEventListener addListener(
          dynamic instance, String eventName, Function handler) =>
      __codec4.decode(asJsObject(this).callMethod(
          'addListener', [instance, eventName, handler]) as JsObject);
  MapsEventListener addListenerOnce(
          dynamic instance, String eventName, Function handler) =>
      __codec4.decode(asJsObject(this).callMethod(
          'addListenerOnce', [instance, eventName, handler]) as JsObject);
  void clearInstanceListeners(dynamic instance) {
    asJsObject(this).callMethod('clearInstanceListeners', [instance]);
  }

  void clearListeners(dynamic instance, String eventName) {
    asJsObject(this).callMethod('clearListeners', [instance, eventName]);
  }

  void removeListener(MapsEventListener listener) {
    asJsObject(this).callMethod('removeListener', [__codec4.encode(listener)]);
  }

  void trigger(
      dynamic instance, String eventName, /*@VarArgs()*/ List<dynamic> args) {
    asJsObject(this)
        .callMethod('trigger', [instance, eventName, __codec0.encode(args)]);
  }
}

@GeneratedFrom(_MapsEventListener)
class MapsEventListener extends JsInterface {
  MapsEventListener.created(JsObject o) : super.created(o);
}
