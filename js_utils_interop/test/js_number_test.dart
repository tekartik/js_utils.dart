@TestOn('js || wasm')
library;

import 'dart:js_interop';
import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_js_utils_interop/js_number.dart';
import 'package:tekartik_js_utils_interop/src/js_number.dart'
    show jsDartifyNum, wasmDartifyNum;
import 'package:test/test.dart';

void main() {
  group('JSNumber', () {
    test('dartifyNum', () {
      var jsInt = 1.toJS;
      var jsDouble = 1.5.toJS;

      var dartInt = jsDartifyNum(jsInt);

      if (isRunningAsJavascript) {
        var dartDouble = jsDartifyNum(jsDouble);
        expect(dartInt, 1);
        expect(dartInt, isA<int>());
        expect(dartDouble, closeTo(1.5, 0.00001));
        expect(dartDouble, isA<double>());

        jsInt = 1.0.toJS;
        dartInt = jsDartifyNum(jsInt);

        expect(dartInt, 1);
        expect(dartInt, isA<int>());
      } else {
        expect(dartInt, 1.0);
        expect(dartInt, isA<double>());

        var dartWasmInt = wasmDartifyNum(jsInt);
        var dartWasmDouble = wasmDartifyNum(jsDouble);
        expect(dartWasmInt, 1);
        expect(dartWasmInt, isA<int>());
        expect(dartWasmDouble, closeTo(1.5, 0.00001));
        expect(dartWasmDouble, isA<double>());

        dartWasmInt = wasmDartifyNum(jsInt);
        expect(dartWasmInt, 1);
        expect(dartWasmInt, isA<int>());
      }
      var dartAnyInt = jsInt.toDartNum;
      var dartAnyDouble = jsDouble.toDartNum;

      expect(dartAnyInt, 1);
      expect(dartAnyInt, isA<int>());
      expect(dartAnyDouble, closeTo(1.5, 0.00001));
      expect(dartAnyDouble, isA<double>());

      dartAnyInt = jsInt.toDartNum;
      expect(dartAnyInt, 1);
      expect(dartAnyInt, isA<int>());
    });
  });
}
