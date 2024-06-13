@TestOn('js || wasm')
library;

import 'dart:js_interop' as js;
import 'dart:typed_data';

import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_js_utils_interop/src/js_utils.dart';
import 'package:test/test.dart';

extension type Car._(js.JSObject _) implements js.JSObject {
  external factory Car();
}

extension CarExt on Car {
  external int drive(num distance);

  external int crash(num distance);
}

extension type WithIntValue._(js.JSObject _) implements js.JSObject {
  external factory WithIntValue({int? value});
}

extension WithIntValueExt on WithIntValue {
  external int get value;

  external set value(int value);
}

extension type WithMapValue._(js.JSObject _) implements js.JSObject {
  external factory WithMapValue({WithIntValue? value});
}

extension WithMapValueExt on WithMapValue {
  external WithIntValue get value;

  external set value(WithIntValue value);
}

extension type CustomType._(js.JSObject _) implements js.JSObject {
  factory CustomType() => js.JSObject() as CustomType;
}
void main() {
  test('isJSFunction', () {
    expect('text'.toJS.isJSString, isTrue);
    expect(1.toJS.isJSString, isFalse);
    expect(1.5.toJS.isJSString, isFalse);
    expect({'test': 1}.jsify()?.isJSString, isFalse);
  });
  test('isJSString', () {
    expect('text'.toJS.isJSString, isTrue);
    expect(1.toJS.isJSString, isFalse);
    expect(1.5.toJS.isJSString, isFalse);
    expect({'test': 1}.jsify()?.isJSString, isFalse);
  });
  test('is JSString', () {
    if (kDartIsWeb) {
      if (kDartIsWebWasm) {
        expect(1.toJS is js.JSString, isTrue);
      } else {
        expect(1.toJS is js.JSString, isFalse);
      }
    } else {
      expect(1.toJS is js.JSString, isTrue);
    }
  });
  test('JSString', () {
    var jsString = 'test'.toJS;
    expect(jsString.isJSString, isTrue);
    var dartString = jsString.dartify();
    expect(dartString, isA<String>());
    expect(dartString, 'test');
    var jsStringFromDart = dartString.jsify() as js.JSString;
    expect(jsStringFromDart.toDart, 'test');
  });
  test('JSNumber(int)', () {
    var jsNumber = 1.toJS;
    expect(jsNumber.isJSNumber, isTrue);
    var jsNumberFromDart = jsNumber.toDartInt.toJS;
    expect(jsNumberFromDart.toDartInt, 1);
    var dartNumber = jsNumber.dartify()!;

    if (isRunningAsJavascript) {
      expect(dartNumber, isA<int>());
    } else {
      // In wasm all numbers are double!
      expect(dartNumber, isA<double>());
    }
  });
  test('JSNumber(double)', () {
    var jsNumber = 1.5.toJS;
    expect(jsNumber.isJSNumber, isTrue);
    var dartNumber = jsNumber.dartify();
    expect(dartNumber, isA<double>());
    expect(dartNumber, 1.5);
    var jsNumberFromDart = dartNumber.jsify() as js.JSNumber;
    expect(jsNumberFromDart.toDartDouble, 1.5);
  });
  test('JSBoolean', () {
    var jsBoolean = true.toJS;
    expect(jsBoolean.isJSBoolean, isTrue);
    var dartBoolean = jsBoolean.dartify();
    expect(dartBoolean, isA<bool>());
    expect(dartBoolean, true);
    var jsBooleanFromDart = dartBoolean.jsify() as js.JSBoolean;
    expect(jsBooleanFromDart.toDart, true);
    // Same as dartify
    dartBoolean = jsBoolean.dartify()!;
    expect(dartBoolean, isA<bool>());
    expect(dartBoolean, true);
  });
  // no longer supported.
  test('JSArrayBuffer', () {
    var jsArrayBuffer = Uint8List.fromList([1]).buffer.toJS;
    expect(jsArrayBuffer.isJSObject, isTrue);
    expect(jsArrayBuffer.isJSArrayBuffer, isTrue);
    expect(jsArrayBuffer.isJSArray, isFalse);

    Object dartList = jsArrayBuffer.toDart;
    expect(dartList, isA<ByteBuffer>());
    expect(dartList, isNot(isA<List>()));

    // Compare with dartify()
    dartList = jsArrayBuffer.dartify()!;
    expect(dartList, isA<ByteBuffer>());
    expect(dartList, isNot(isA<List>()));
  });
  test('JSUint8Array', () {
    var jsUint8Array = Uint8List.fromList([1]).toJS;
    expect(jsUint8Array.isJSObject, isTrue);
    expect(jsUint8Array.isJSUint8Array, isTrue);
    expect(jsUint8Array.isJSArrayBuffer, isFalse);
    expect(jsUint8Array.isJSArray, isFalse);

    var dartList = jsUint8Array.dartify();
    expect(dartList, isA<List>());
    expect(dartList, isA<Uint8List>());
    expect(dartList, [1]);

    var jsUint8ArrayFromDart = dartList.jsify()!;
    expect(jsUint8ArrayFromDart.isJSArrayBuffer, isFalse);
    expect(jsUint8ArrayFromDart.isJSUint8Array, isTrue);
    expect(jsUint8ArrayFromDart.isJSArray, isFalse);
    expect(jsUint8ArrayFromDart.isJSObject, isTrue);

    // Compare with dartify()
    dartList = jsUint8Array.dartify()!;
    expect(dartList, isA<List>());
    expect(dartList, isA<Uint8List>());
    expect(dartList, [1]);
  });
  test('JSObject', () {
    var jsObject = {'test': 1}.jsify()!;
    expect(jsObject.isJSObject, isTrue);
    var dartMap = jsObject.dartify();
    expect(dartMap, isA<Map>());
    expect(dartMap, {'test': 1});

    var jsObjectFromDart = dartMap.jsify()!;
    expect(jsObjectFromDart.isJSObject, isTrue);
  });
  test('JSFunction', () {
    var jsFunction = () {}.toJS;
    expect(jsFunction.isJSFunction, isTrue);
  });
  test('customtype', () {
    var jsCustomType = CustomType();
    expect(jsCustomType.isJSObject, isTrue);
    expect(jsCustomType.isA<CustomType>(), isFalse);
    expect(jsCustomType.isA<js.JSObject>(), isTrue);
  });
}
