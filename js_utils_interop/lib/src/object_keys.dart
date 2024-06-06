import 'dart:js_interop' as js;

@js.JS('Object.getOwnPropertyNames')
// ignore: unused_element
external js.JSArray _jsObjectGetOwnPropertyNames(js.JSAny obj);
@js.JS('Object.keys')
external js.JSArray _jsObjectKeys(js.JSAny obj);

extension on js.JSArray {
  List<String> toDartStringList() =>
      toDart.map((e) => (e as js.JSString).toDart).toList();
}

/// Get the keys of a js object
List<String> jsObjectKeys(js.JSAny object) =>
    _jsObjectKeys(object).toDartStringList();

/// Get the own keys of a js object, include non enumerable ones.
List<String> jsObjectGetOwnPropertyNames(js.JSAny object) =>
    _jsObjectGetOwnPropertyNames(object).toDartStringList();
