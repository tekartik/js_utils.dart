// ignore_for_file: deprecated_member_use

@JS()
library;

import 'dart:collection';

import 'package:js/js.dart';
import 'package:js/js_util.dart';

import 'js_utils/js_interop_compat.dart';

class JsMap<V> extends MapBase<String, dynamic> {
  late final Object? _jsObject;

  JsMap(Object? jsObject) {
    _jsObject = jsObject;
  }

  @override
  V? operator [](Object? key) {
    var prop = getProperty<Object?>(_jsObject!, key.toString());

    // if the map is not generic
    if (V == dynamic) prop = JsMap<Object?>(prop);

    return prop as V?;
  }

  @override
  operator []=(String key, dynamic value) =>
  // ignore: void_checks
  setProperty(_jsObject!, key.toString(), value);

  @override
  dynamic remove(Object? key) {
    throw 'Not implemented yet for JsMap, sorry';
  }

  @override
  Iterable<String> get keys => jsObjectKeys(_jsObject!);

  @override
  bool containsKey(Object? key) => hasProperty(_jsObject!, key!);

  @override
  void clear() {
    throw 'Not implemented yet for JsMap, sorry';
  }
}
