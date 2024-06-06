@TestOn('js || wasm')
library;

import 'dart:js_interop';

import 'package:tekartik_js_utils_interop/object_keys.dart';
import 'package:test/test.dart';

void main() {
  group('object_keys', () {
    test('jsObjectKeys', () {
      var map = {'one': 1, 'two': 2};
      expect(jsObjectKeys(map.jsify()!), ['one', 'two']);
    });
  });
}
