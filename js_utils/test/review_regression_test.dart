// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package

@TestOn('js')
library;

import 'package:js/js_util.dart';
import 'package:tekartik_js_utils/js_utils.dart';
import 'package:test/test.dart';

/// A js object `{[key]: value}`.
Object _jsObject(String key, Object? value) {
  var object = newObject<Object>();
  setProperty(object, key, value);
  return object;
}

void main() {
  group('regression', () {
    test('shared object converted with the depth left where it is', () {
      // s = {x: {y: 1}}, root = {a: {b: s}, c: s}
      var shared = _jsObject('x', _jsObject('y', 1));
      var root = _jsObject('a', _jsObject('b', shared));
      setProperty(root, 'c', shared);
      expect(jsObjectAsMap(root, depth: 3), {
        'a': {
          'b': {
            'x': {'.': '.'},
          },
        },
        'c': {
          'x': {'y': 1},
        },
      });
      // No depth: the same map instance is reused.
      var map = jsObjectAsMap(root)!;
      expect(identical(map['c'], (map['a'] as Map)['b']), isTrue);
    });
  });
}
