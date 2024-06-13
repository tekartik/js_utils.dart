import 'dart:js_interop';

/// JavaScript Array extension.
extension JSArrayExtension on JSArray {
  /// Get the length of the array
  external int get length;
}

/// JavaScript helpers
extension JSAnyExtension on JSAny {
  /// True if it is a Javascript date object
  bool get isJSDate {
    return instanceOfString('Date');
  }

  /// True if it is a Javascript array object
  bool get isJSArray {
    return instanceOfString('Array');
  }

  /// True if it is a Javascript array buffer object
  bool get isJSArrayBuffer {
    return instanceOfString('ArrayBuffer');
  }

  /// True if it is a Javascript uint8 buffer object
  bool get isJSUint8Array {
    return instanceOfString('Uint8Array');
  }

  /// Could be an array or a data!
  bool get isJSObject {
    return typeofEquals('object');
  }

  /// True if it is a Javascript string object
  bool get isJSString {
    return typeofEquals('string');
  }

  /// True if it is a Javascript number object
  bool get isJSNumber {
    return typeofEquals('number');
  }

  /// True if it is a Javascript boolean object
  bool get isJSBoolean {
    return typeofEquals('boolean');
  }

  /// True if it is a Javascript function
  bool get isJSFunction {
    return typeofEquals('function');
  }
}
