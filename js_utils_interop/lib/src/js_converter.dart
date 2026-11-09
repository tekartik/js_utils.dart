import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe';

import 'package:tekartik_js_utils_interop/src/js_number.dart';

import 'object_keys.dart';

/// simple jsify
js.JSAny? anyToJsAny(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toJS;
  }
  if (value is String) {
    return value.toJS;
  }
  if (value is bool) {
    return value.toJS;
  }
  if (value is List) {
    return value.map((value) => anyToJsAny(value)).toList().toJS;
  }
  if (value is Map) {
    var jsObject = js.JSObject();
    for (var entry in value.entries) {
      jsObject.setProperty(entry.key.toString().toJS, anyToJsAny(entry.value));
    }
    return jsObject;
  }

  throw UnsupportedError('not supported $value');
}

/// A `List` for a js array, a `Map` (see [jsObjectAsMap]) otherwise.
Object jsObjectAsCollection(js.JSObject jsObject, {int? depth}) {
  if (jsIsList(jsObject)) {
    return jsArrayAsList(jsObject as js.JSArray, depth: depth);
  }

  return jsObjectAsMap(jsObject, depth: depth);
}

/// The collection (see [jsObjectAsCollection]), null for null, a string, a
/// number, a boolean or a function.
Object? jsAnyAsCollectionOrNull(js.JSAny? jsObject, {int? depth}) {
  if (_isCollectionType(jsObject)) {
    return jsObjectAsCollection(jsObject as js.JSObject, depth: depth);
  }
  return null;
}

/// Converts a js array to a Dart list, see [jsObjectAsMap] for the items.
List jsArrayAsList(js.JSArray jsArray, {int? depth}) {
  var converter = _Converter();
  return converter.jsArrayToList(jsArray, [], depth: depth);
}

/// Converts the own enumerable properties of [jsObject] to a Dart map, for
/// logs and loosely typed data (use `dartify()` for a json round trip).
///
/// Nested objects and arrays are converted too, a function becomes
/// `'(function)'`. [depth] limits the nesting: a cut map is
/// `{'.': '.'}`, a cut list `['..']`. Cycles reuse the same Dart map.
Map<String, Object?> jsObjectAsMap(js.JSObject jsObject, {int? depth}) {
  var converter = _Converter();
  return converter.jsObjectToMap(jsObject, <String, Object?>{}, depth: depth);
}

/// Returns `true` if the [value] is a very basic built-in type - e.g.
/// [null], [num], [bool] or [String]. It returns `false` in the other case.
bool _isBasicType(js.JSAny? value) {
  if (value == null ||
      value.isA<js.JSString>() ||
      value.isA<js.JSNumber>() ||
      value.isA<js.JSBoolean>()) {
    return true;
  }
  return false;
}

bool _isCollectionType(js.JSAny? value) {
  if (_isBasicType(value)) {
    return false;
  }
  if (value.isA<js.JSFunction>()) {
    return false;
  }
  return true;
}

/// Fixed in 2020-09-03
bool jsAnyIsCollection(js.JSAny? jsObject) {
  return _isCollectionType(jsObject);
  /*
  return jsObject != null &&
      (jsObject is Iterable ||
          jsObject is Map ||
          isJsArray(jsObject) ||
          isJsObject(jsObject));*/
}

/// True is jsObject is a JSArray
bool jsIsList(js.JSAny? jsObject) {
  return jsObject.isA<js.JSArray>(); // || isJsArray(jsObject);
}

/// Check if the object has an hash code,
/// it fails for functions
bool _checkHasHashCode(js.JSAny jsAny) {
  try {
    jsAny.hashCode;
    return true;
  } catch (_) {
    // Cannot add property Symbol(_identityHashCode), object is not extensible dart:sdk_internal
    // This happens for Type error
    // JSNoSuchMethodError i;
    // Cannot add property Symbol(_identityHashCode), object is not extensible dart:sdk_internal
    // print('weird error error $_ (${_.runtimeType})');
    // print('object $jsObject ${jsObject.runtimeType}');
    // print(__);
    return false;
  }
}

/// True if a conversion done with [cachedDepth] levels left can be reused
/// where [depth] levels are left (null is unlimited).
bool _cachedDepthIsEnough(int? cachedDepth, int? depth) =>
    cachedDepth == null || (depth != null && cachedDepth >= depth);

class _Converter {
  /// Converted collections and the depth left when they were converted.
  Map<dynamic, (Object, int?)> jsCollections = {};
  var jsObjectsNoHashCode = <js.JSObject>[];

  Object jsObjectToCollection(js.JSObject jsObject, {int? depth}) {
    if (_checkHasHashCode(jsObject)) {
      var cached = jsCollections[jsObject];
      // An object met before with less depth left is converted again.
      if (cached != null && _cachedDepthIsEnough(cached.$2, depth)) {
        return cached.$1;
      }
    }
    if (jsIsList(jsObject)) {
      // create the list before
      return jsArrayToList(jsObject as js.JSArray, [], depth: depth);
    } else {
      // create the map before for recursive object
      return jsObjectToMap(jsObject, {}, depth: depth);
    }
  }

  Map<String, Object?> jsObjectToMap(
    js.JSObject jsObject,
    Map<String, Object?> map, {
    int? depth,
  }) {
    // Stop, before caching the map that would stay empty
    if (depth == 0) {
      return {'.': '.'};
    }
    if (_checkHasHashCode(jsObject)) {
      jsCollections[jsObject] = (map, depth);
    }
    final keys = jsObjectKeys(jsObject);

    // Handle recursive objects
    for (var key in keys) {
      if (!jsObject.has(key)) {
        continue;
      }
      var value = jsObject.getProperty(key.toJS);
      map[key] = _convertInnerOrNull(value, depth: depth);
    }
    return map;
  }

  Object? _convertInnerOrNull(js.JSAny? value, {int? depth}) {
    if (value == null) {
      return null;
    }
    return _convertInner(value, depth: depth);
  }

  Object _convertInner(js.JSAny value, {int? depth}) {
    Object? dartValue;
    if (jsAnyIsCollection(value)) {
      // recursive
      dartValue = jsObjectToCollection(
        value as js.JSObject,
        depth: depth == null ? null : depth - 1,
      );
    } else {
      dartValue = _convertAnySimpleValue(value)!;
    }
    return dartValue;
  }

  List jsArrayToList(js.JSArray jsArray, List list, {int? depth}) {
    if (depth == 0) {
      return ['..'];
    }
    var addedList = jsArray.toDart;
    jsCollections[jsArray] = (list, depth);
    for (var value in addedList) {
      list.add(_convertInnerOrNull(value, depth: depth));
    }
    return list;
  }
}

Object? _convertAnySimpleValue(js.JSAny? jsAny) {
  if (jsAny == null) {
    return null;
  } else if (jsAny.isA<js.JSString>()) {
    return (jsAny as js.JSString).toDart;
  } else if (jsAny.isA<js.JSNumber>()) {
    return (jsAny as js.JSNumber).toDartNum;
  } else if (jsAny.isA<js.JSBoolean>()) {
    return (jsAny as js.JSBoolean).toDart;
  } else if (jsAny.isA<js.JSFunction>()) {
    return '(function)';
  } else if (jsAny.isA<js.JSObject>()) {
    // return jsAnyDebugRuntimeType(jsAny);
    return '(object)';
  } else {
    try {
      return jsAny.dartify();
    } catch (_) {
      return '??';
    }
  }
}

/// Any js value to a debug string (null for null), collections converted
/// with [jsObjectAsCollection] up to [depth].
String? jsAnyToDebugString(js.JSAny? jsAny, {int? depth}) {
  if (jsAny == null) {
    return null;
  }
  if (jsAnyIsCollection(jsAny)) {
    return jsAnyAsCollectionOrNull(
      jsAny as js.JSObject,
      depth: depth,
    ).toString();
  } else {
    return _convertAnySimpleValue(jsAny).toString();
  }
}

/// Find run time type.
/// Behavior can change, don't rely on it, only useful for debugging.
String jsAnyDebugRuntimeType(js.JSAny? jsAny) {
  if (jsAny == null) {
    return 'null';
  } else if (jsAny.isA<js.JSString>()) {
    return 'string';
  } else if (jsAny.isA<js.JSNumber>()) {
    return 'number';
  } else if (jsAny.isA<js.JSBoolean>()) {
    return 'boolean';
  } else if (jsAny.isA<js.JSObject>()) {
    var jsObject = jsAny as js.JSObject;
    var constructor = jsObject.getProperty('constructor'.toJS) as js.JSObject?;
    if (constructor == null) {
      throw StateError('no constructor for ${jsObjectKeys(jsObject)}');
    }
    var name = (constructor.getProperty('name'.toJS) as js.JSString).toDart;
    return name;
  } else {
    return '(unknown)';
  }
}

@js.JS('String')
external js.JSString _jsString(js.JSAny? value);

/// Json compatible map of the non function properties of [jsObject], own and
/// inherited (see [jsObjectGetAllPropertyNames]), such as the ones of
/// `navigator`.
///
/// Nested objects are converted up to [depth] levels (arrays do not count),
/// deeper ones and the other values (bigint, symbol) use their JavaScript
/// string representation. A property that cannot be read gets an
/// `error: <error>` value.
Map<String, Object?> jsObjectToPropertyMap(
  js.JSObject jsObject, {
  int depth = 2,
}) => _jsObjectToPropertyMap(jsObject, depth, <js.JSArray>[]);

/// [arrays] are the arrays being converted, to stop on cycles.
Map<String, Object?> _jsObjectToPropertyMap(
  js.JSObject jsObject,
  int depth,
  List<js.JSArray> arrays,
) {
  final map = <String, Object?>{};
  for (var name in jsObjectGetAllPropertyNames(jsObject)) {
    try {
      final value = jsObject.getProperty<js.JSAny?>(name.toJS);
      if (value.isA<js.JSFunction>()) {
        continue;
      }
      map[name] = _jsAnyToPropertyValue(value, depth, arrays);
    } catch (e) {
      map[name] = 'error: $e';
    }
  }
  return map;
}

Object? _jsAnyToPropertyValue(
  js.JSAny? value,
  int depth,
  List<js.JSArray> arrays,
) {
  if (value == null) {
    return null;
  } else if (value.isA<js.JSString>()) {
    return (value as js.JSString).toDart;
  } else if (value.isA<js.JSNumber>()) {
    return (value as js.JSNumber).toDartNum;
  } else if (value.isA<js.JSBoolean>()) {
    return (value as js.JSBoolean).toDart;
  } else if (value.isA<js.JSFunction>()) {
    return '(function)';
  } else if (value.isA<js.JSArray>()) {
    var array = value as js.JSArray;
    if (arrays.any((other) => other.strictEquals(array).toDart)) {
      return _jsString(array).toDart;
    }
    arrays.add(array);
    try {
      return [
        for (var item in array.toDart)
          _jsAnyToPropertyValue(item, depth, arrays),
      ];
    } finally {
      arrays.removeLast();
    }
  } else if (value.isA<js.JSObject>() && depth > 0) {
    return _jsObjectToPropertyMap(value as js.JSObject, depth - 1, arrays);
  }
  return _jsString(value).toDart;
}
