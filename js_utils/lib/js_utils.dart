library tekartik_js_utils.js_utils;

import 'package:tekartik_common_utils/async_utils.dart';

import 'src/js_utils/js_converter.dart' as js_converter;

export 'src/js_utils/js_converter.dart'
    show jsArrayAsList, jsObjectAsCollection;
export 'src/js_utils/js_interop.dart';
export 'src/js_utils/js_utils.dart' show jsRuntimeType;

Map<String, dynamic> jsObjectAsMap(dynamic jsObject, {int depth}) {
  return js_converter
      .jsObjectAsMap(jsObject, depth: depth)
      ?.cast<String, dynamic>();
}

/*
JsObject jsUint8Array(Uint8List list) {
  return new JsObject(context['Uint8Array'], [list]);
}

bool jsObjectHasLength(JsObject jsObject) {
  return jsObject.hasProperty('length');
}

int jsObjectLength(JsObject jsObject) {
  return jsObject['length'];
}

dynamic jsArrayItem(JsObject jsObject, int index) {
  return jsObject[index];
}

// Good is 2 for deep object
// @return [List]|[Map]
dynamic jsObjectOrAnyAsCollection(dynamic object, {int depth}) {
  if (object is JsObject) {
    return jsObjectAsCollection(object, depth: depth);
  } else if (object == null) {
    return null;
  } else {
    // This does the conversion using the new js package and JS() annotations
    try {
      object = jsObjectAsCollection(new JsObject.fromBrowserObject(object),
          depth: depth);
    } catch (e) {}
    return object;
  }
}

// can be null JsObjact or JsArray
JsObject jsObjectOrAnyAsJsObject(dynamic object) {
  if (object is JsObject) {
    return object;
  } else if (object == null) {
    return null;
  } else {
    // This does the conversion using the new js package and JS() annotations
    try {
      return new JsObject.fromBrowserObject(object);
    } catch (e) {}
    return null;
  }
}

// Good is 2 for deep object
String jsObjectOrAnyToDebugString(dynamic object, {int depth}) {
  if (object == null) {
    return "$object";
  }

  if (object is JsObject) {
    return jsObjectToDebugString(object, depth: depth);
  }
  var jsObject = jsObjectOrAnyAsJsObject(object);
  if (jsObject != null) {
    return jsObjectOrAnyToDebugString(jsObject, depth: depth);
  }

  return object.toString();
}
*/
String jsObjectToDebugString(dynamic jsObject, {int depth}) {
  if (jsObject == null) {
    return null;
  }
  return js_converter.jsObjectAsCollection(jsObject, depth: depth).toString();
}
