import 'package:js/js_util.dart';
import 'package:tekartik_js_utils/js_utils.dart';

const String jsArrayType = 'Array';
const String jsObjectType = 'Object';

String jsRuntimeType(dynamic jsObject) {
  var constructor = getProperty(jsObject, 'constructor');
  if (constructor == null) {
    throw 'no constructor for ${jsObjectKeys(jsObject)}';
  }
  return getProperty(constructor, 'name').toString();
}

bool isJsArray(dynamic jsObject) {
  return jsRuntimeType(jsObject) == jsArrayType;
}

bool isJsObject(dynamic jsObject) {
  return jsRuntimeType(jsObject) == jsObjectType;
}
