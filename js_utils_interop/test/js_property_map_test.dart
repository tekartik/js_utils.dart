@TestOn('js || wasm')
library;

import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe' as js;

import 'package:tekartik_js_utils_interop/js_converter.dart';
import 'package:tekartik_js_utils_interop/object_keys.dart';
import 'package:test/test.dart';

@js.JS('Object.create')
external js.JSObject _objectCreate(js.JSObject? prototype);

@js.JS('Object.defineProperty')
external void _defineProperty(
  js.JSObject object,
  js.JSString name,
  js.JSObject descriptor,
);

@js.JS('Function')
external js.JSFunction _newFunction(js.JSString body);

void _defineGetter(js.JSObject object, String name, js.JSFunction getter) =>
    _defineProperty(
      object,
      name.toJS,
      js.JSObject()..setProperty('get'.toJS, getter),
    );

void main() {
  group('property_map', () {
    test('jsObjectGetAllPropertyNames', () {
      var prototype = js.JSObject()
        ..setProperty('inherited'.toJS, 1.toJS)
        ..setProperty('function'.toJS, (() {}).toJS);
      var jsObject = _objectCreate(prototype)
        ..setProperty('own'.toJS, 'x'.toJS);
      expect(jsObjectGetAllPropertyNames(jsObject), [
        'function',
        'inherited',
        'own',
      ]);
      expect(jsObjectKeys(jsObject), ['own']);
      expect(jsObjectGetAllPropertyNames(js.JSObject()), isEmpty);
      var noPrototype = _objectCreate(null)..setProperty('p'.toJS, 1.toJS);
      expect(jsObjectGetAllPropertyNames(noPrototype), ['p']);
    });

    test('jsObjectToPropertyMap', () {
      var prototype = js.JSObject()..setProperty('inherited'.toJS, 1.toJS);
      _defineGetter(prototype, 'getter', (() => 'got'.toJS).toJS);
      var nested = {
        'a': {
          'b': {'c': 1},
        },
      }.jsify();
      var jsObject = _objectCreate(prototype)
        ..setProperty('own'.toJS, 'x'.toJS)
        ..setProperty('nested'.toJS, nested)
        ..setProperty('null'.toJS, null)
        ..setProperty('nan'.toJS, double.nan.toJS)
        ..setProperty('function'.toJS, (() {}).toJS)
        ..setProperty(
          'list'.toJS,
          [
            1.toJS,
            {'x': true}.jsify(),
            (() {}).toJS,
          ].toJS,
        );
      var map = jsObjectToPropertyMap(jsObject);
      expect(map['nan'], isNaN);
      expect(map..remove('nan'), {
        'getter': 'got',
        'inherited': 1,
        'list': [
          1,
          {'x': true},
          '(function)',
        ],
        'nested': {
          'a': {'b': '[object Object]'},
        },
        'null': null,
        'own': 'x',
      });
      expect(
        jsObjectToPropertyMap(jsObject, depth: 0)['nested'],
        '[object Object]',
      );
    });

    test('jsObjectToPropertyMap errors and cycles', () {
      var jsObject = js.JSObject();
      _defineGetter(
        jsObject,
        'throwing',
        _newFunction('throw new Error("boom")'.toJS),
      );
      var array = <js.JSAny?>[].toJS;
      array.callMethod<js.JSAny?>('push'.toJS, array);
      jsObject
        ..setProperty('array'.toJS, array)
        ..setProperty('self'.toJS, jsObject);
      var map = jsObjectToPropertyMap(jsObject);
      expect(map['throwing'], allOf(startsWith('error: '), contains('boom')));
      // The cycle is shown as its JavaScript string.
      expect(map['array'], ['']);
      expect(map['self'], {
        'array': [''],
        'self': {
          'array': [''],
          'self': '[object Object]',
          'throwing': isA<String>(),
        },
        'throwing': isA<String>(),
      });
    });
  });
}
