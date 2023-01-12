import 'package:js/js_util.dart';
import 'package:tekartik_js_utils/js_utils.dart';

const String jsArrayType = 'Array';
const String jsObjectType = 'Object';

String jsRuntimeType(Object jsObject) {
  var constructor = getProperty(jsObject, 'constructor') as Object?;
  if (constructor == null) {
    throw 'no constructor for ${jsObjectKeys(jsObject)}';
  }
  return getProperty<Object?>(constructor, 'name').toString();
}

bool isJsArray(Object jsObject) {
  return jsRuntimeType(jsObject) == jsArrayType;
}

bool isJsObject(Object jsObject) {
  return jsRuntimeType(jsObject) == jsObjectType;
}
