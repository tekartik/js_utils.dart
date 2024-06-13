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
  throw 'not supported $value';
}

/// For JsObject of JsArray if _isCollectionType
Object jsObjectAsCollection(js.JSObject jsObject, {int? depth}) {
  if (jsIsList(jsObject)) {
    return jsArrayAsList(jsObject as js.JSArray, depth: depth);
  }
  return jsObjectAsMap(jsObject, depth: depth);
}

/// Null if not a collection
Object? jsAnyAsCollectionOrNull(js.JSAny? jsObject, {int? depth}) {
  if (_isCollectionType(jsObject)) {
    return jsObjectAsCollection(jsObject as js.JSObject, depth: depth);
  }
  return null;
}

/// JSArray conversion
List jsArrayAsList(js.JSArray jsArray, {int? depth}) {
  var converter = _Converter();
  return converter.jsArrayToList(jsArray, [], depth: depth);
}

///
/// Handle element already in jsCollections
///
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

class _Converter {
  Map<dynamic, dynamic> jsCollections = {};

  Object jsObjectToCollection(js.JSObject jsObject, {int? depth}) {
    if (jsCollections.containsKey(jsObject)) {
      return jsCollections[jsObject]!;
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
      js.JSObject jsObject, Map<String, Object?> map,
      {int? depth}) {
    jsCollections[jsObject] = map;
    final keys = jsObjectKeys(jsObject);

    // Stop
    if (depth == 0) {
      return {'.': '.'};
    }

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
      dartValue = jsObjectToCollection(value as js.JSObject,
          depth: depth == null ? null : depth - 1);
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
    jsCollections[jsArray] = list;
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
  } else if (jsAny is js.JSFunction) {
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

/// Any native type to a simple debug string
String? jsAnyToDebugString(js.JSAny? jsAny, {int? depth}) {
  if (jsAny == null) {
    return null;
  }
  if (jsAnyIsCollection(jsAny)) {
    return jsAnyAsCollectionOrNull(jsAny as js.JSObject, depth: depth)
        .toString();
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
      throw 'no constructor for ${jsObjectKeys(jsObject)}';
    }
    var name = (constructor.getProperty('name'.toJS) as js.JSString).toDart;
    return name;
  } else {
    return '(unknown)';
  }
}
