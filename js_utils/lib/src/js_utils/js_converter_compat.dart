// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package

import 'package:js/js_util.dart';
import 'package:tekartik_js_utils/js_utils_import.dart';

import 'js_interop.dart';

/// For JsObject of JsArray
Object? jsObjectAsCollection(Object? jsObject, {int? depth}) =>
    jsObjectAsCollectionOrNull(jsObject, depth: depth);

/// For JsObject of JsArray
Object? jsObjectAsCollectionOrNull(Object? jsObject, {int? depth}) {
  if (jsObject is List) {
    return jsArrayAsList(jsObject, depth: depth);
  }
  return jsObjectAsMapOrNull(jsObject, depth: depth);
}

List? jsArrayAsListOrNull(List? jsArray, {int? depth}) {
  if (jsArray == null) {
    return null;
  }
  return jsArrayAsListOrThrow(jsArray, depth: depth);
}

List jsArrayAsListOrThrow(List jsArray, {int? depth}) {
  var converter = _Converter();
  return converter.jsArrayToList(jsArray, [], depth: depth);
}

// Prefer jsArrayAsListOrNull or jsArrayAsListOrThrow
List? jsArrayAsList(List? jsArray, {int? depth}) =>
    jsArrayAsListOrNull(jsArray, depth: depth);

///
/// Handle element already in jsCollections
///
Map jsObjectAsMap(Object jsObject, {int? depth}) {
  var converter = _Converter();
  return converter.jsObjectToMap(jsObject, {}, depth: depth);
}

Map? jsObjectAsMapOrNull(Object? jsObject, {int? depth}) {
  if (jsObject == null) {
    return null;
  }
  return jsObjectAsMap(jsObject, depth: depth);
}

/// Returns `true` if the [value] is a very basic built-in type - e.g.
/// [null], [num], [bool] or [String]. It returns `false` in the other case.
bool _isBasicType(Object? value) {
  if (value == null || value is num || value is bool || value is String) {
    return true;
  }
  return false;
}

bool _isCollectionType(Object? value) {
  if (_isBasicType(value)) {
    return false;
  }
  return true;
}

/// Fixed in 2020-09-03
bool jsIsCollection(Object jsObject) {
  return _isCollectionType(jsObject);
  /*
  return jsObject != null &&
      (jsObject is Iterable ||
          jsObject is Map ||
          isJsArray(jsObject) ||
          isJsObject(jsObject));*/
}

bool jsIsList(Object jsObject) {
  return jsObject is Iterable; // || isJsArray(jsObject);
}

class _Converter {
  Map<dynamic, dynamic> jsCollections = {};

  dynamic jsObjectToCollection(Object jsObject, {int? depth}) {
    if (jsCollections.containsKey(jsObject)) {
      return jsCollections[jsObject];
    }

    if (jsIsList(jsObject)) {
      // create the list before
      return jsArrayToList(jsObject as List?, [], depth: depth);
    } else {
      // create the map before for recursive object
      return jsObjectToMap(jsObject, {}, depth: depth);
    }
  }

  Map jsObjectToMap(Object jsObject, Map map, {int? depth}) {
    jsCollections[jsObject] = map;
    final keys = jsObjectKeys(jsObject);

    // Stop
    if (depth == 0) {
      return {'.': '.'};
    }

    // Handle recursive objects
    for (var key in keys) {
      var value = getProperty(jsObject, key) as Object?;
      // devPrint('key $key value ${jsObjectKeys(value)}');
      if (value != null && jsIsCollection(value)) {
        // recursive
        value = jsObjectToCollection(
          value,
          depth: depth == null ? null : depth - 1,
        );
      }
      map[key] = value;
    }
    return map;
  }

  List jsArrayToList(List? jsArray, List list, {int? depth}) {
    if (depth == 0) {
      return ['..'];
    }
    jsCollections[jsArray] = list;
    for (var i = 0; i < jsArray!.length; i++) {
      var value = jsArray[i] as Object?;
      if (value != null && jsIsCollection(value)) {
        value = jsObjectToCollection(
          value,
          depth: depth == null ? null : depth - 1,
        );
      }
      list.add(value);
    }
    return list;
  }
}
