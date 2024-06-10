import 'dart:js_interop';

/// JavaScript Date
@JS('Date')
extension type JSDate._(JSObject _) implements JSObject {
  /// Create a JavaScript date object
  external factory JSDate(int value);

  /// Convert JavaScript date object to ISO string
  external String toISOString();

  /// Convert JavaScript date object to milliseconds since epoch
  external int getTime();
}

/// Conversions from [JSDate] to [DateTime].
extension JSDateExt on JSDate {
  /// to utc date
  DateTime get toDart =>
      DateTime.fromMillisecondsSinceEpoch(getTime(), isUtc: true);
}

/// Conversions from [DateTime] to [JSDate].
extension TekartikJsInteropDateTimeExt on DateTime {
  /// Convert to JSDate
  JSDate get toJS => JSDate(millisecondsSinceEpoch);
}

/// JavaScript helpers
extension JSDateAnyExt on JSAny {
  /// True if it is a Javascript date object
  bool get isJSDate {
    return instanceOfString('Date');
  }
}
