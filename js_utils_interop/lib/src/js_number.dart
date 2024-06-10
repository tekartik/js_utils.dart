import 'dart:js_interop';

import 'package:tekartik_common_utils/env_utils.dart';

/// See https://github.com/dart-lang/sdk/issues/55203#issuecomment-2003246663
num wasmDartifyNum(JSNumber value) {
  final jsDouble = value.toDartDouble;
  final jsInt = jsDouble.truncate();
  return (jsInt.toDouble() == jsDouble) ? jsInt : jsDouble;
}

/// In JS everything is a double.
num jsDartifyNum(JSNumber value) {
  return value.toDartDouble;
}

/// JavaScript number extension.
extension TekartikJsInteropJSNumberExt on JSNumber {
  /// Convert JavaScript number to Dart number
  /// /// See https://github.com/dart-lang/sdk/issues/55203#issuecomment-2003246663
  num get toDartNum =>
      isRunningAsJavascript ? jsDartifyNum(this) : wasmDartifyNum(this);
}
