@Deprecated('Do not use')
library;

import 'src/js_utils/js_converter.dart' as js_converter;

export 'src/js_utils/js_converter.dart'
    show
        jsArrayAsList,
        jsObjectAsCollection,
        jsObjectAsCollectionOrNull,
        jsArrayAsListOrNull,
        jsArrayAsListOrThrow;
export 'src/js_utils/js_interop.dart';
export 'src/js_utils/js_utils.dart' show jsRuntimeType;

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
