@TestOn('js || wasm')
library;

import 'dart:js_interop';

import 'package:tekartik_js_utils_interop/object_keys.dart';

import 'package:test/test.dart';

void main() {
  group('object_keys', () {
    final map = {'one': 1, 'two': 2};
    final jsMap = map.jsify()!;
    test('jsObjectKeys', () {
      expect(jsObjectKeys(jsMap), ['one', 'two']);
      expect(jsObjectGetOwnPropertyNames(jsMap), ['one', 'two']);
    });
    test('extension', () {
      expect(jsMap.keys(), ['one', 'two']);
      expect(jsMap.getOwnPropertyNames(), ['one', 'two']);
    });
  });
}
