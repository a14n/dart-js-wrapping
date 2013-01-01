part of js_wrap;

class JsDate extends TypedProxy implements Date {
  static JsDate toJs(Date date) => transformIfNotNull(date, (date) => date is JsDate ? date : new JsDate(date));

  JsDate(Date date) : super(js.context.Date, [date.millisecondsSinceEpoch]);
  JsDate.fromJsProxy(js.Proxy jsProxy) : super.fromJsProxy(jsProxy);

  // from Date->Comparable
  @override int compareTo(Date other) => _asDate().compareTo(other);

  // from Date
  @override bool operator ==(Date other) => _asDate() == other;
  @override bool operator <(Date other) => _asDate() < other;
  @override bool operator <=(Date other) => _asDate() <= other;
  @override bool operator >(Date other) => _asDate() > other;
  @override bool operator >=(Date other) => _asDate() >= other;
  @override Date toLocal() => _asDate().toLocal();
  @override Date toUtc() => _asDate().toUtc();
  @override String get timeZoneName => _asDate().timeZoneName;
  @override Duration get timeZoneOffset => _asDate().timeZoneOffset;
  @override int get year => _asDate().year;
  @override int get month => _asDate().month;
  @override int get day => _asDate().day;
  @override int get hour => _asDate().hour;
  @override int get minute => _asDate().minute;
  @override int get second => _asDate().second;
  @override int get millisecond => _asDate().millisecond;
  @override int get weekday => _asDate().weekday;
  @override int get millisecondsSinceEpoch => _asDate().millisecondsSinceEpoch;
  @override bool get isUtc => _asDate().isUtc;
  @override String toString() => _asDate().toString();
  @override Date add(Duration duration) => _asDate().add(duration);
  @override Date subtract(Duration duration) => _asDate().subtract(duration);
  @override Duration difference(Date other) => _asDate().difference(other);

  Date _asDate() => new Date.fromMillisecondsSinceEpoch($proxy.getTime());
}