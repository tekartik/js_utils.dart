// ignore_for_file: deprecated_member_use_from_same_package

import 'package:tekartik_js_utils/src/js_utils/js_converter.dart'
    as js_converter;

Map<String, Object?>? jsObjectAsMapOrNull(Object? jsObject, {int? depth}) {
  return js_converter
      .jsObjectAsMapOrNull(jsObject, depth: depth)
      ?.cast<String, Object?>();
}

// Prefer [jsObjectAsMapOrNull] for nulls
Map<String, Object?>? jsObjectAsMap(Object? jsObject, {int? depth}) {
  return js_converter
      .jsObjectAsMapOrNull(jsObject, depth: depth)
      ?.cast<String, Object?>();
}

Map<String, Object?> jsObjectAsMapOrThrow(Object jsObject, {int? depth}) {
  return js_converter
      .jsObjectAsMap(jsObject, depth: depth)
      .cast<String, Object?>();
}

String? jsObjectToDebugString(dynamic jsObject, {int? depth}) {
  if (jsObject == null) {
    return null;
  }
  return js_converter.jsObjectAsCollection(jsObject, depth: depth).toString();
}
