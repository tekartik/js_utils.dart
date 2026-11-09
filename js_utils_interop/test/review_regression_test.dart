@TestOn('js || wasm')
library;

import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe' as js;

import 'package:tekartik_js_utils_interop/js_converter.dart';
import 'package:test/test.dart';

/// A js object `{[key]: value}`.
js.JSObject _jsObject(String key, js.JSAny? value) =>
    js.JSObject()..setProperty(key.toJS, value);

void main() {
  group('regression', () {
    test('shared object converted with the depth left where it is', () {
      // s = {x: {y: 1}}, root = {a: {b: s}, c: s}
      var shared = _jsObject('x', _jsObject('y', 1.toJS));
      var root = _jsObject('a', _jsObject('b', shared))
        ..setProperty('c'.toJS, shared);
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
      // Shared array too.
      var list = [
        [1.toJS].toJS,
      ].toJS;
      var withList = _jsObject('a', _jsObject('b', list))
        ..setProperty('c'.toJS, list);
      expect(jsObjectAsMap(withList, depth: 3), {
        'a': {
          'b': [
            ['..'],
          ],
        },
        'c': [
          [1],
        ],
      });
      // No depth: the same map instance is reused.
      var map = jsObjectAsMap(root);
      expect(identical(map['c'], (map['a'] as Map)['b']), isTrue);
    });

    test('cycle with and without depth', () {
      var a = _jsObject('n', 1.toJS);
      var b = _jsObject('a', a);
      a.setProperty('b'.toJS, b);
      var map = jsObjectAsMap(a);
      expect(identical((map['b'] as Map)['a'], map), isTrue);
      // The ancestor (converted deeper) is reused: the cycle is kept.
      map = jsObjectAsMap(a, depth: 3);
      expect(identical((map['b'] as Map)['a'], map), isTrue);
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}
