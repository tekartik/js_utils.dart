import 'dart:js_interop' as js;

@js.JS('Object.getOwnPropertyNames')
external js.JSArray _jsObjectGetOwnPropertyNames(js.JSAny obj);
@js.JS('Object.keys')
external js.JSArray _jsObjectKeys(js.JSAny obj);

extension on js.JSArray {
  List<String> toDartStringList() =>
      toDart.map((e) => (e as js.JSString).toDart).toList();
}

List<String> jsObjectKeys(js.JSAny object) =>
    _jsObjectKeys(object).toDartStringList();
