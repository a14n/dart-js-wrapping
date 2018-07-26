// GENERATED CODE - DO NOT MODIFY BY HAND

part of google_maps.sample.simple;

// **************************************************************************
// JsWrappingGenerator
// **************************************************************************

@GeneratedFrom(_GMap)
@JsName('Map')
class GMap extends JsInterface {
  GMap(Node mapDiv, [MapOptions opts])
      : this.created(JsObject(
            context['google']['maps']['Map'], [mapDiv, __codec0.encode(opts)]));
  GMap.created(JsObject o) : super.created(o);

  num _getZoom() => asJsObject(this).callMethod('getZoom');
  num get zoom => _getZoom();
}

@GeneratedFrom(_LatLng)
class LatLng extends JsInterface {
  LatLng(num lat, num lng, [bool noWrap])
      : this.created(
            JsObject(context['google']['maps']['LatLng'], [lat, lng, noWrap]));
  LatLng.created(JsObject o) : super.created(o);

  bool equals(LatLng other) =>
      asJsObject(this).callMethod('equals', [__codec1.encode(other)]);
  num get lat => _lat();
  num _lat() => asJsObject(this).callMethod('lat');
  num get lng => _lng();
  num _lng() => asJsObject(this).callMethod('lng');
  String toString() => asJsObject(this).callMethod('toString');
  String toUrlValue([num precision]) =>
      asJsObject(this).callMethod('toUrlValue', [precision]);
}

@GeneratedFrom(_MapOptions)
@anonymous
class MapOptions extends JsInterface {
  MapOptions() : this.created(JsObject(context['Object']));
  MapOptions.created(JsObject o) : super.created(o);

  set zoom(int _zoom) {
    asJsObject(this)['zoom'] = _zoom;
  }

  int get zoom => asJsObject(this)['zoom'];
  set center(LatLng _center) {
    asJsObject(this)['center'] = __codec1.encode(_center);
  }

  LatLng get center => __codec1.decode(asJsObject(this)['center']);
  set mapTypeId(MapTypeId _mapTypeId) {
    asJsObject(this)['mapTypeId'] = __codec2.encode(_mapTypeId);
  }

  MapTypeId get mapTypeId => __codec2.decode(asJsObject(this)['mapTypeId']);
}

class MapTypeId extends JsEnum {
  static final values = <MapTypeId>[HYBRID, ROADMAP, SATELLITE, TERRAIN];
  static final HYBRID =
      MapTypeId._('HYBRID', context['google']['maps']['MapTypeId']['HYBRID']);
  static final ROADMAP =
      MapTypeId._('ROADMAP', context['google']['maps']['MapTypeId']['ROADMAP']);
  static final SATELLITE = MapTypeId._(
      'SATELLITE', context['google']['maps']['MapTypeId']['SATELLITE']);
  static final TERRAIN =
      MapTypeId._('TERRAIN', context['google']['maps']['MapTypeId']['TERRAIN']);
  final String _name;
  MapTypeId._(this._name, o) : super.created(o);

  @override
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
      __codec4.decode(asJsObject(this).callMethod('addDomListener',
          [__codec3.encode(instance), eventName, handler, capture]));
  MapsEventListener addDomListenerOnce(
          dynamic instance, String eventName, Function handler,
          [bool capture]) =>
      __codec4.decode(asJsObject(this).callMethod('addDomListenerOnce',
          [__codec3.encode(instance), eventName, handler, capture]));
  MapsEventListener addListener(
          dynamic instance, String eventName, Function handler) =>
      __codec4.decode(asJsObject(this).callMethod(
          'addListener', [__codec3.encode(instance), eventName, handler]));
  MapsEventListener addListenerOnce(
          dynamic instance, String eventName, Function handler) =>
      __codec4.decode(asJsObject(this).callMethod(
          'addListenerOnce', [__codec3.encode(instance), eventName, handler]));
  void clearInstanceListeners(dynamic instance) {
    asJsObject(this)
        .callMethod('clearInstanceListeners', [__codec3.encode(instance)]);
  }

  void clearListeners(dynamic instance, String eventName) {
    asJsObject(this)
        .callMethod('clearListeners', [__codec3.encode(instance), eventName]);
  }

  void removeListener(MapsEventListener listener) {
    asJsObject(this).callMethod('removeListener', [__codec4.encode(listener)]);
  }

  void trigger(
      dynamic instance, String eventName, /*@VarArgs()*/ List<dynamic> args) {
    asJsObject(this).callMethod('trigger',
        [__codec3.encode(instance), eventName, __codec5.encode(args)]);
  }
}

@GeneratedFrom(_MapsEventListener)
class MapsEventListener extends JsInterface {
  MapsEventListener.created(JsObject o) : super.created(o);
}

/// codec for google_maps.sample.simple.MapOptions
final __codec0 = JsInterfaceCodec<MapOptions>((o) => MapOptions.created(o));

/// codec for google_maps.sample.simple.LatLng
final __codec1 = JsInterfaceCodec<LatLng>((o) => LatLng.created(o));

/// codec for google_maps.sample.simple.MapTypeId
final __codec2 = BiMapCodec<MapTypeId, dynamic>(
    Map<MapTypeId, dynamic>.fromIterable(MapTypeId.values, value: asJs));

/// codec for dart.core.dynamic
final __codec3 = DynamicCodec();

/// codec for google_maps.sample.simple.MapsEventListener
final __codec4 =
    JsInterfaceCodec<MapsEventListener>((o) => MapsEventListener.created(o));

/// codec for dart.core.List<dynamic>
final __codec5 = JsListCodec<dynamic>(__codec3);
