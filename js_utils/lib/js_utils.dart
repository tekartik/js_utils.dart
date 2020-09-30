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

String jsObjectToDebugString(dynamic jsObject, {int depth}) {
  if (jsObject == null) {
    return null;
  }
  return js_converter.jsObjectAsCollection(jsObject, depth: depth).toString();
}
