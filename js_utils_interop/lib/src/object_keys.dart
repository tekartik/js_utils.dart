import 'dart:js_interop' as js;

@js.JS('Object.getOwnPropertyNames')
// ignore: unused_element
external js.JSArray<js.JSString> _jsObjectGetOwnPropertyNames(js.JSAny obj);
@js.JS('Object.keys')
external js.JSArray<js.JSString> _jsObjectKeys(js.JSAny obj);

/// Convert `JSArray<JSString>` to `List<String>`
extension on js.JSArray<js.JSString> {
  List<String> toDartStringList() => toDart.map((e) => e.toDart).toList();
}

/// JavaScript Object extension
extension JSObjectKeysExtension on js.JSAny {
  /// Convert to Dart List
  List<String> getOwnPropertyNames() {
    return _jsObjectGetOwnPropertyNames(this).toDartStringList();
  }

  /// Convert to Dart List
  List<String> keys() {
    return _jsObjectKeys(this).toDartStringList();
  }
}

/// Get the keys of a js object
List<String> jsObjectKeys(js.JSAny object) =>
    _jsObjectKeys(object).toDartStringList();

/// Get the own keys of a js object, include non enumerable ones.
List<String> jsObjectGetOwnPropertyNames(js.JSAny object) =>
    _jsObjectGetOwnPropertyNames(object).toDartStringList();
