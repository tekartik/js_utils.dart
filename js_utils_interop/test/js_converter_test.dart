@TestOn('js || wasm')
library;

import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe' as js;

import 'package:tekartik_js_utils_interop/js_converter.dart';
import 'package:tekartik_js_utils_interop/js_date.dart';
import 'package:tekartik_js_utils_interop/object_keys.dart';
import 'package:tekartik_js_utils_interop/src/js_converter.dart'
    show anyToJsAny;
import 'package:test/test.dart';

import 'js_utils_test.dart';

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

void main() {
  group('JsObject', () {
    test('anyToJsAny', () {
      expect(anyToJsAny(null), isNull);
      expect((anyToJsAny(1) as js.JSNumber).toDartInt, 1);
      expect((anyToJsAny(1.5) as js.JSNumber).toDartDouble, 1.5);
      expect(anyToJsAny('test'), 'test'.toJS);
      expect(anyToJsAny([1]).dartify(), [1.toJS].toJS.dartify());
      expect(anyToJsAny([1]).dartify(), [1]);
      expect([1].jsify().dartify(), [1]);
      expect(anyToJsAny({'test': 1}).dartify(),
          (js.JSObject()..setProperty('test'.toJS, 1.toJS)).dartify());
      expect(anyToJsAny({'test': 1}).dartify(), {'test': 1});
      expect({'test': 1}.jsify().dartify(), {'test': 1});
      expect(
          anyToJsAny([
            {'test': 1}
          ]).dartify(),
          [js.JSObject()..setProperty('test'.toJS, 1.toJS)].toJS.dartify());
      expect(
          anyToJsAny([
            {
              'test': [1]
            }
          ]).dartify(),
          [
            js.JSObject()..setProperty('test'.toJS, [1.toJS].toJS)
          ].toJS.dartify());
      final map1 = {'int': 1, 'string': 'text'};
      final list1 = [1, 'test', null, 1.1, map1];
      final map2 = {'map1': map1, 'list1': list1};

      final list2 = [list1, map2];
      expect(anyToJsAny(list2).dartify(), list2);
      expect(list2.jsify().dartify(), list2);
    });
    test('jsAnyIsCollection', () {
      expect(jsAnyIsCollection([1].jsify()), isTrue);
      expect(jsAnyIsCollection({'test': 1}.jsify()), isTrue);
      expect(jsAnyIsCollection(1.jsify()), isFalse);
    });
    test('anonymous', () {
      var withIntValue = WithIntValue();
      expect(jsObjectKeys(withIntValue), isEmpty);
      withIntValue.value = 1;
      expect(jsObjectKeys(withIntValue), ['value']);
      expect(withIntValue.value, 1);
      // print('withIntValue ${withIntValue.value}');
    });

    test('type', () {
      var jsObject = {'test': 'value'}.jsify();
      expect(jsAnyDebugRuntimeType(jsObject), 'Object');

      var jsArray = <int>[].jsify();
      expect(jsAnyDebugRuntimeType(jsArray), 'Array');

      expect(jsAnyDebugRuntimeType(JSDate.now()), 'Date');
      expect(jsAnyDebugRuntimeType(1.toJS), 'number');
      expect(jsAnyDebugRuntimeType('text'.toJS), 'string');
      expect(jsAnyDebugRuntimeType(true.toJS), 'boolean');
      expect(jsAnyDebugRuntimeType(1.5.toJS), 'number');
      expect(jsAnyDebugRuntimeType(() {}.toJS), 'Function');
      expect(jsAnyDebugRuntimeType(null), 'null');
      expect(jsAnyDebugRuntimeType(CustomType()), 'Object');
    });

    test('jsObjectAsMap', () {
      var jsObject = js.JSObject();
      expect(jsObjectAsMap(jsObject), isEmpty);
      jsObject.setProperty('value'.toJS, 1.toJS);
      expect(jsObjectAsMap(jsObject), {'value': 1});

      var withIntValue = WithIntValue();
      expect(jsObjectAsMap(withIntValue), isEmpty);
      withIntValue.value = 2;
      expect(jsObjectAsMap(withIntValue), {'value': 2});
    });

    test('jsObjectAsMapRecursive', () {
      var testDart = {'int': 1, 'string': 'text', 'null': null};
      var jsObject = testDart.jsify() as js.JSObject;
      expect(jsObjectAsMap(jsObject), testDart);

      testDart = {};
      testDart['test'] = testDart;
      expect(testDart.toString(), '{test: {...}}');
      jsObject = <String, Object?>{}.jsify() as js.JSObject;
      jsObject.setProperty('test'.toJS, jsObject);

      //TODO
      expect(jsObjectAsMap(jsObject).toString(), '{test: {...}}');
      //expect(jsObjectAsMap(jsObject).toString(), '{test: {test: {...}}}');

      var parentValue = WithMapValue(value: WithIntValue(value: 183));
      expect(jsObjectAsMap(parentValue).toString(), '{value: {value: 183}}');
    });

    test('asList', () {
      var testDart = [1, 'text', null];
      expect(testDart.toString(), '[1, text, null]');
      var jsArray = testDart.jsify() as js.JSArray;
      expect(jsArrayAsList(jsArray), testDart);

      testDart = [];
      testDart.add(testDart);
      expect(testDart.toString(), '[[...]]');
      jsArray = <int>[].jsify() as js.JSArray;
      jsArray.setProperty(1.toJS, jsArray);
      expect(jsArrayAsList(jsArray).toString(), '[null, [...]]');
    });

    test('asCollection no depth', () {
      expect(jsAnyAsCollectionOrNull(null), isNull);
      expect(jsAnyAsCollectionOrNull(1.toJS), isNull);
      var list = [1];
      expect(jsAnyAsCollectionOrNull([1.toJS].toJS), list);
      expect(jsAnyAsCollectionOrNull(anyToJsAny(list)), list);
      expect(jsAnyAsCollectionOrNull(list.jsify()), list);
      var map = <String, Object?>{'test': 1};
      expect(jsAnyAsCollectionOrNull(map.jsify()), map);
      map = {
        'test': [1]
      };
      expect(jsAnyAsCollectionOrNull(map.jsify()), map);

      final map1 = {'int': 1, 'string': 'text'};
      final list1 = [1, 'test', null, 1.1, map1];
      final map2 = {'map1': map1, 'list1': list1};

      final list2 = [list1, map2];
      expect(jsAnyAsCollectionOrNull(map2.jsify()), map2);
      expect(jsAnyAsCollectionOrNull(list2.jsify()), list2);
    });

    test('asCollectionDepth', () {
      expect(jsAnyAsCollectionOrNull(null, depth: 1), isNull);

      var map1 = {'int': 1, 'string': 'text'};
      var list1 = [1, 'test', null, 1.1, map1];
      var map2 = {'map1': map1, 'list1': list1};
      var list2 = [list1, map2];
      var jsList2 = list2.jsify();
      var jsMap2 = map2.jsify();
      expect(jsAnyAsCollectionOrNull(jsMap2, depth: 0), {'.': '.'});
      expect(jsAnyAsCollectionOrNull(jsList2, depth: 0), ['..']);
      expect(jsAnyAsCollectionOrNull(jsMap2, depth: 1), {
        'map1': {'.': '.'},
        'list1': ['..']
      });
      expect(jsAnyAsCollectionOrNull(jsList2, depth: 1), [
        ['..'],
        {'.': '.'}
      ]);
      expect(jsAnyAsCollectionOrNull(jsList2, depth: 1), [
        ['..'],
        {'.': '.'}
      ]);
      expect(jsAnyToDebugString(jsList2),
          '[[1, test, null, 1.1, {int: 1, string: text}], {map1: {int: 1, string: text}, list1: [1, test, null, 1.1, {int: 1, string: text}]}]');
      expect(jsAnyToDebugString(jsList2, depth: 2),
          '[[1, test, null, 1.1, {.: .}], {map1: {}, list1: [1, test, null, 1.1, {.: .}]}]');
      expect(jsAnyToDebugString(jsList2, depth: 1), '[[..], {.: .}]');
      expect(jsAnyToDebugString(jsMap2, depth: 2),
          '{map1: {int: 1, string: text}, list1: [1, test, null, 1.1, {int: 1, string: text}]}');
      expect(
          jsAnyToDebugString(jsMap2, depth: 1), '{map1: {.: .}, list1: [..]}');
    });

    test('toDebugString', () {
      expect(jsAnyToDebugString(null), null);
      expect(jsAnyToDebugString(<String, Object?>{}.jsify()), '{}');
      expect(jsAnyToDebugString(<int>[].jsify()), '[]');
    });
  });
}
