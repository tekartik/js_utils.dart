---
name: tekartik-js-utils-legacy
description: >-
  Use when maintaining old Dart web code that depends on the deprecated
  tekartik_js_utils (package:js / dart:js_util, dart2js only, no wasm):
  jsObjectAsMap, jsObjectAsMapOrNull, jsObjectAsMapOrThrow,
  jsObjectAsCollection, jsObjectAsCollectionOrNull, jsArrayAsList,
  jsArrayAsListOrNull, jsArrayAsListOrThrow, jsObjectToDebugString,
  jsObjectKeys, jsRuntimeType, JsMap, js_utils.dart / js_utils_import.dart /
  js_map.dart - and when migrating that code to tekartik_js_utils_interop.
---

# Legacy js utils (tekartik_js_utils)

`tekartik_js_utils` is the **deprecated** `package:js` / `dart:js_util` helper
library of the `js_utils.dart` repo: every library it exposes carries
`@Deprecated('Do not use')`, it only works when the app is compiled to
JavaScript (no dart2wasm), and it is kept for old web code only. New code must
use `tekartik_js_utils_interop` (same repo, `path: js_utils_interop`), which is
built on `dart:js_interop` and works on both dart2js and dart2wasm.

## Guidelines

* Do not add this package to a new project. If a project already depends on it,
  plan the move to `tekartik_js_utils_interop`; the two APIs are deliberately
  close, see the mapping below.
* Dependency (git, not published on pub.dev):
  ```yaml
  dependencies:
    tekartik_js_utils:
      git:
        url: https://github.com/tekartik/js_utils.dart
        path: js_utils
  ```
  It pulls `package:js`, `package:synchronized`, `package:stack_trace` and
  `tekartik_common_utils`.
* Libraries (all deprecated as a whole, expect `deprecated_member_use`
  warnings; the package itself silences them with
  `// ignore_for_file: deprecated_member_use`):
  * `package:tekartik_js_utils/js_utils.dart` - the conversion helpers plus
    `jsObjectKeys` (a direct `Object.keys` binding) and `jsRuntimeType`.
  * `package:tekartik_js_utils/js_utils_import.dart` - `js_utils.dart` plus
    `package:tekartik_common_utils/common_utils_import.dart`.
  * `package:tekartik_js_utils/js_map.dart` - `JsMap`.
* Conversions (every one takes an optional `depth:`; a truncated map becomes
  `{'.': '.'}`, a truncated list becomes `['..']`):
  * `jsObjectAsMap(jsObject)` and `jsObjectAsMapOrNull(jsObject)` are the same
    function, `Map<String, Object?>?`, `null` in, `null` out;
    `jsObjectAsMapOrThrow(jsObject)` takes a non-null object and returns a non
    null map. Keys come from `Object.keys`, so only own enumerable properties.
  * `jsArrayAsList(jsArray)` / `jsArrayAsListOrNull(jsArray)` accept a `List?`
    (a js array reaches Dart as a `List` under dart2js) and return `List?`;
    `jsArrayAsListOrThrow(jsArray)` is the non-null variant.
  * `jsObjectAsCollection(jsValue)` / `jsObjectAsCollectionOrNull(jsValue)`
    dispatch on the value: a `List` for a js array, a `Map` otherwise, `null`
    for `null`.
  * `jsObjectToDebugString(jsValue, {depth})` returns `null` for `null`, else
    the `toString()` of the converted collection. Use a small `depth` in logs.
* `jsRuntimeType(jsObject)` returns the js constructor name (`'Object'`,
  `'Array'`, `'Date'`, ...) and throws `StateError` when the value has no
  `constructor` property. `jsObjectKeys(jsObject)` is `Object.keys`.
* `JsMap<V>(jsObject)` from `js_map.dart` wraps a js object as a
  `Map<String, dynamic>` view: `[]`, `[]=`, `keys` and `containsKey` go through
  `dart:js_util`; `remove()` and `clear()` throw `UnimplementedError`. With
  `V == dynamic` the `[]` operator wraps the value in another `JsMap`, so use
  an explicit type argument (`JsMap<Object?>`) when you want raw values.
* Build js objects with `dart:js_util` (`newObject()`, `setProperty`,
  `getProperty`, `jsify`) - this package only reads them, it has no
  dart-to-js conversion helper.
* Platform: JavaScript only. Tests are `@TestOn('js')` (the repo keeps a dummy
  VM test so `dart test` has something to run); run them with
  `dart test -p chrome` or `dart test -p node`. Do **not** compile a
  dependent app with dart2wasm: `package:js` is not supported there.
* Migration to `tekartik_js_utils_interop` (name it in plain text, the other
  package has its own skill): `jsObjectAsMapOrThrow` -> `jsObjectAsMap`,
  `jsObjectAsCollectionOrNull` -> `jsAnyAsCollectionOrNull`,
  `jsArrayAsListOrThrow` -> `jsArrayAsList`, `jsObjectToDebugString` ->
  `jsAnyToDebugString`, `jsRuntimeType` -> `jsAnyDebugRuntimeType`,
  `jsObjectKeys` -> `jsObjectKeys` (same name, takes a `JSAny`). The `Object?`
  parameters all become `JSAny?`, and `dart:js_util` calls become
  `dart:js_interop` / `dart:js_interop_unsafe` ones. `JsMap` has no
  replacement: convert with `jsObjectAsMap` instead.

## Examples

### Read a raw js value

```dart
// ignore_for_file: deprecated_member_use
import 'package:js/js_util.dart';
import 'package:tekartik_js_utils/js_utils.dart';

/// Dump a js value obtained from an untyped `package:js` binding.
void dumpJsValue(Object jsValue) {
  print(jsRuntimeType(jsValue)); // Object, Array, Date...
  print(jsObjectKeys(jsValue)); // own enumerable keys
  print(jsObjectAsMap(jsValue)); // Map<String, Object?>?
}

void main() {
  var jsObject = newObject() as Object;
  setProperty(jsObject, 'value', 1);
  dumpJsValue(jsObject);
}
```

### Depth limited conversion and debug string

```dart
// ignore_for_file: deprecated_member_use
import 'package:js/js_util.dart';
import 'package:tekartik_js_utils/js_utils.dart';

void main() {
  var jsValue = jsify([
    [1, 2],
    {'a': 1},
  ]);
  print(jsArrayAsList(jsValue as List?)); // [[1, 2], {a: 1}]
  print(jsObjectAsCollection(jsValue, depth: 1)); // [[..], {.: .}]
  print(jsObjectToDebugString(jsValue, depth: 1)); // [[..], {.: .}]
}
```

### Non null variants

```dart
// ignore_for_file: deprecated_member_use
import 'package:tekartik_js_utils/js_utils.dart';

Map<String, Object?> requiredMap(Object jsObject) =>
    jsObjectAsMapOrThrow(jsObject);

List requiredList(List jsArray) => jsArrayAsListOrThrow(jsArray);

Map<String, Object?>? optionalMap(Object? jsObject) =>
    jsObjectAsMapOrNull(jsObject);

List? optionalList(List? jsArray) => jsArrayAsListOrNull(jsArray);
```

### JsMap view over a js object

```dart
// ignore_for_file: deprecated_member_use
import 'package:js/js_util.dart';
import 'package:tekartik_js_utils/js_map.dart';

void main() {
  var jsObject = newObject() as Object;
  setProperty(jsObject, 'value', 1);

  var map = JsMap<Object?>(jsObject);
  print(map.keys); // (value)
  print(map['value']); // 1
  map['other'] = 'text'; // writes back to the js object
  // map.remove('other') and map.clear() throw UnimplementedError.
}
```

### Web test

```dart
@TestOn('js')
library;

// ignore_for_file: deprecated_member_use
import 'package:js/js_util.dart';
import 'package:tekartik_js_utils/js_utils.dart';
import 'package:test/test.dart';

void main() {
  test('jsObjectAsMap', () {
    var jsObject = newObject() as Object;
    setProperty(jsObject, 'value', 1);
    expect(jsObjectKeys(jsObject), ['value']);
    expect(jsObjectAsMap(jsObject), {'value': 1});
    expect(jsRuntimeType(jsObject), 'Object');
  });
}
```
