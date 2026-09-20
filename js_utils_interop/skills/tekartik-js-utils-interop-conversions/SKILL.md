---
name: tekartik-js-utils-interop-conversions
description: >-
  Use when reading, converting or debugging raw JavaScript values from Dart web
  code (dart2js or dart2wasm) with tekartik_js_utils_interop: jsObjectAsMap,
  jsArrayAsList, jsObjectAsCollection, jsAnyAsCollectionOrNull,
  jsAnyIsCollection, jsAnyToDebugString, jsAnyDebugRuntimeType, jsObjectKeys,
  jsObjectGetOwnPropertyNames, the JSDate extension type (toDart, toISOString,
  getTime, DateTime.toJS, isJSDate) and JSNumber.toDartNum, imported from
  js_converter.dart, object_keys.dart, js_date.dart and js_number.dart.
---

# dart:js_interop helpers (tekartik_js_utils_interop)

Small helper library on top of the modern `dart:js_interop` (works with both
dart2js and dart2wasm): turn an untyped `JSAny?` into Dart maps, lists and
strings, list a js object keys, and convert js `Date` / `Number` values. It is
the current package of the `js_utils.dart` repo; `tekartik_js_utils` in the same
repo is the older `package:js` / `dart:js` one.

## Guidelines

* Dependency (git, not published on pub.dev):
  ```yaml
  dependencies:
    tekartik_js_utils_interop:
      git:
        url: https://github.com/tekartik/js_utils.dart
        path: js_utils_interop
  ```
* Four public libraries, each exporting a short list of names:
  * `package:tekartik_js_utils_interop/js_converter.dart`: `jsObjectAsMap`,
    `jsArrayAsList`, `jsObjectAsCollection`, `jsAnyAsCollectionOrNull`,
    `jsAnyIsCollection`, `jsAnyToDebugString`, `jsAnyDebugRuntimeType`.
  * `package:tekartik_js_utils_interop/object_keys.dart`: `jsObjectKeys`,
    `jsObjectGetOwnPropertyNames`, `JSObjectKeysExtension` (`keys()`,
    `getOwnPropertyNames()` on any `JSAny`).
  * `package:tekartik_js_utils_interop/js_date.dart`: `JSDate`, `JSDateExt`,
    `TekartikJsInteropDateTimeExt` (`DateTime.toJS`) and `JSDateAnyExt`
    (`JSAny.isJSDate`).
  * `package:tekartik_js_utils_interop/js_number.dart`:
    `TekartikJsInteropJSNumberExt` (`JSNumber.toDartNum`).
  Import `dart:js_interop` next to them for `JSAny`, `JSObject`, `.toJS`,
  `.jsify()`, `.dartify()` and `isA<T>()`.
* Conversion entry points, all web-only at runtime:
  * `jsObjectAsMap(jsObject)` -> `Map<String, Object?>` built from
    `Object.keys` (enumerable own properties only).
  * `jsArrayAsList(jsArray)` -> `List`, `jsObjectAsCollection(jsObject)` ->
    a `List` if the object is a js `Array`, a `Map` otherwise.
  * `jsAnyAsCollectionOrNull(jsAny)` -> the map/list, or `null` when the value
    is a scalar, a function or null. `jsAnyIsCollection(jsAny)` is the matching
    test (false for null, string, number, boolean and function).
  * All of them take an optional `depth:`. `depth` counts down through nested
    collections: a truncated map becomes `{'.': '.'}` and a truncated list
    becomes `['..']`, so `depth: 0` on a map returns `{'.': '.'}`. Omit it for
    a full conversion (recursive objects are handled by an identity cache).
* These converters are lossy on purpose, for logging and for reading loosely
  typed js results: a nested function becomes the string `'(function)'`, an
  object that is neither array nor plain data becomes `'(object)'`. For a
  faithful round trip of json-like data use `dartify()` / `jsify()` from
  `dart:js_interop` instead.
* `jsAnyToDebugString(jsAny, {depth})` returns `null` for null and the
  `toString()` of the converted collection otherwise - use it in log lines with
  a small `depth` rather than converting the whole graph.
* `jsAnyDebugRuntimeType(jsAny)` returns `'null'`, `'string'`, `'number'`,
  `'boolean'` or the js constructor name (`'Object'`, `'Array'`, `'Date'`,
  `'Function'`). Debugging only, the exact values may change, and it throws
  `StateError` on an object with no `constructor` property.
* Keys: `jsObjectKeys(any)` is `Object.keys` (own enumerable),
  `jsObjectGetOwnPropertyNames(any)` is `Object.getOwnPropertyNames` (also the
  non enumerable ones); both return `List<String>`. Note that an anonymous
  extension type object created with no argument has no key at all until a
  property is set.
* Numbers: on wasm, `dartify()` gives a `double` for every js number. Use
  `(jsAny as JSNumber).toDartNum` to get an `int` back when the value has no
  fractional part on both compilers (that is what the converters use).
* Dates: `JSDate` is an extension type on the js `Date` constructor.
  `JSDate(millisecondsSinceEpoch)` and `JSDate.now()` build one, `getTime()`,
  `toISOString()` and `toDart` (a **UTC** `DateTime`) read it, and
  `dateTime.toJS` (extension on `DateTime`) goes the other way. `jsAny.isJSDate`
  tests `instanceof Date`. Do not rely on `dateTime.jsify()` / `jsDate.dartify()`
  for dates: the result differs between dart2js and wasm.
* Only the names in the four libraries above are public API. Do not import
  `package:tekartik_js_utils_interop/src/...` (`anyToJsAny`, `jsIsList`,
  `jsDartifyNum`, `wasmDartifyNum`, the `isJSString` / `isJSArray` /
  `isJSUint8Array` getters of `src/js_utils.dart`): the package's own tests do
  it, consumers should use `jsify()` and `isA<JSArray>()` / `isA<JSString>()`.
* Everything here throws or fails to compile on the Dart VM: mark tests
  `@TestOn('js || wasm')` and keep VM-side logic out of these calls. Guard
  shared code with `isRunningAsJavascript` / `kDartIsWeb` from
  `package:tekartik_common_utils/env_utils.dart` when needed.
* Run the tests on every web compiler, as the package does:
  `dart test -p chrome -c dart2js`, `dart test -p chrome -c dart2wasm`,
  `dart test -p node`.

## Examples

### Read a loosely typed js value

```dart
import 'dart:js_interop';

import 'package:tekartik_js_utils_interop/js_converter.dart';

/// Turn a value returned by an untyped interop call into plain Dart data.
Object? readJsValue(JSAny? value) {
  if (!jsAnyIsCollection(value)) {
    return value.dartify();
  }
  if (value.isA<JSArray>()) {
    return jsArrayAsList(value as JSArray);
  }
  return jsObjectAsMap(value as JSObject);
}

void main() {
  var jsValue = {
    'name': 'tekartik',
    'tags': ['a', 'b'],
  }.jsify();
  print(readJsValue(jsValue)); // {name: tekartik, tags: [a, b]}
}
```

### Log an unknown js object without dumping the whole graph

```dart
import 'dart:js_interop';

import 'package:tekartik_js_utils_interop/js_converter.dart';

void logJsAny(String label, JSAny? value) {
  print('$label (${jsAnyDebugRuntimeType(value)}): '
      '${jsAnyToDebugString(value, depth: 2)}');
}

void main() {
  var jsValue = {
    'a': {
      'b': {'c': 1},
    },
  }.jsify();
  logJsAny('config', jsValue); // config (Object): {a: {b: {.: .}}}
}
```

### List the properties of a js object

```dart
import 'dart:js_interop';

import 'package:tekartik_js_utils_interop/object_keys.dart';

void dumpKeys(JSObject jsObject) {
  // Object.keys: own enumerable properties.
  print(jsObjectKeys(jsObject));
  print(jsObject.keys()); // same, as an extension
  // Object.getOwnPropertyNames: also the non enumerable ones.
  print(jsObjectGetOwnPropertyNames(jsObject));
}

void main() {
  dumpKeys({'one': 1, 'two': 2}.jsify() as JSObject); // [one, two]
}
```

### js Date and js number to Dart

```dart
import 'dart:js_interop';

import 'package:tekartik_js_utils_interop/js_date.dart';
import 'package:tekartik_js_utils_interop/js_number.dart';

/// A raw field that can be a js `Date` or a number of milliseconds.
DateTime? readTimestamp(JSAny? value) {
  if (value == null) {
    return null;
  }
  if (value.isJSDate) {
    return (value as JSDate).toDart; // utc DateTime
  }
  if (value.isA<JSNumber>()) {
    return DateTime.fromMillisecondsSinceEpoch(
      (value as JSNumber).toDartNum.toInt(),
      isUtc: true,
    );
  }
  return null;
}

void main() {
  var jsDate = DateTime.now().toUtc().toJS;
  print(jsDate.toISOString());
  print(jsDate.getTime());
  print(readTimestamp(jsDate));
  print(readTimestamp(JSDate.now()));
}
```

### Web test

```dart
@TestOn('js || wasm')
library;

import 'dart:js_interop';

import 'package:tekartik_js_utils_interop/js_converter.dart';
import 'package:tekartik_js_utils_interop/object_keys.dart';
import 'package:test/test.dart';

void main() {
  test('read a js object', () {
    var jsObject = {
      'int': 1,
      'list': [1, 2],
    }.jsify() as JSObject;
    expect(jsObjectKeys(jsObject), ['int', 'list']);
    expect(jsObjectAsMap(jsObject), {
      'int': 1,
      'list': [1, 2],
    });
    expect(jsAnyToDebugString(jsObject, depth: 1), '{int: 1, list: [..]}');
  });
}
```
