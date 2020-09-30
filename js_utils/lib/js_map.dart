@JS()
library tekartik_js_utils.js_map;

import 'dart:collection';

import 'package:js/js.dart';
import 'package:js/js_util.dart';

import 'js_utils.dart';

class JsMap<V> extends MapBase<String, dynamic> {
  final _jsObject;

  JsMap(this._jsObject);

  @override
  V operator [](Object key) {
    dynamic prop = getProperty(_jsObject, key.toString());

    // if the map is not generic
    if (V == dynamic) prop = JsMap(prop);

    return prop as V;
  }

  @override
  operator []=(String key, dynamic value) =>
      setProperty(_jsObject, key.toString(), value);

  @override
  dynamic remove(Object key) {
    throw 'Not implemented yet for JsMap, sorry';
  }

  @override
  Iterable<String> get keys => jsObjectKeys(_jsObject);

  @override
  bool containsKey(Object key) => hasProperty(_jsObject, key);

  @override
  void clear() {
    throw 'Not implemented yet for JsMap, sorry';
  }
}
