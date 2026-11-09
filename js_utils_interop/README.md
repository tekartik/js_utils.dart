# tekartik_js_utils_interop

Helpers on top of `dart:js_interop` for Dart web code: convert untyped
JavaScript values to Dart maps and lists (for logs or loosely typed results),
list the keys of a js object, read js `Date` and `Number` values.

Web only: browser and node, compiled with dart2js or dart2wasm (not the Dart
VM, use a conditional import for code shared with the VM).

## Getting started

The package is not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_js_utils_interop:
    git:
      url: https://github.com/tekartik/js_utils.dart
      path: js_utils_interop
```

```dart
import 'dart:js_interop';

import 'package:tekartik_js_utils_interop/js_converter.dart';
import 'package:tekartik_js_utils_interop/js_date.dart';
import 'package:tekartik_js_utils_interop/js_number.dart';
import 'package:tekartik_js_utils_interop/object_keys.dart';

void main() {
  var value =
      {
            'name': 'tekartik',
            'tags': ['a', 'b'],
            'nested': {
              'a': {'b': 1},
            },
          }.jsify()
          as JSObject;
  print(jsObjectKeys(value)); // [name, tags, nested]
  print(jsObjectAsMap(value)); // {name: tekartik, tags: [a, b], nested: {a: {b: 1}}}
  print(jsAnyToDebugString(value, depth: 2)); // {name: tekartik, tags: [a, b], nested: {a: {.: .}}}

  var date = DateTime.utc(2026, 11, 9).toJS;
  print(date.toISOString()); // 2026-11-09T00:00:00.000Z
  print(date.toDart); // 2026-11-09 00:00:00.000Z

  print((3.toJS).toDartNum.runtimeType); // int, also on wasm
}
```

## Which library

* `js_converter.dart`: `jsObjectAsMap`, `jsArrayAsList`,
  `jsObjectAsCollection`, `jsAnyAsCollectionOrNull`, `jsAnyIsCollection` (js
  data to Dart maps and lists); `jsAnyToDebugString`, `jsAnyDebugRuntimeType`
  (logs); `jsObjectToPropertyMap` (own and inherited properties, such as the
  ones of `navigator`).
* `object_keys.dart`: `jsObjectKeys` (`Object.keys`),
  `jsObjectGetOwnPropertyNames`, `jsObjectGetAllPropertyNames` (inherited ones
  too).
* `js_date.dart`: `JSDate` (`JSDate(ms)`, `JSDate.now()`, `getTime()`,
  `toISOString()`, `toDart` in UTC), `DateTime.toJS`, `isJSDate`.
* `js_number.dart`: `JSNumber.toDartNum`, an `int` when the number has no
  fraction, on dart2js and dart2wasm.

## Common pitfalls

* The converters are for loosely typed data and logs, they are lossy: a
  function becomes `'(function)'`, any other object is read from its own
  enumerable keys (a `Date` or a class instance gives `{}`). For a json like
  round trip use `jsify()` / `dartify()` from `dart:js_interop`.
* `depth:` limits the conversion: a cut map is `{'.': '.'}`, a cut list
  `['..']`. Without `depth` cycles are kept (the same Dart map is reused).
* `jsAnyDebugRuntimeType` throws a `StateError` for an object without
  constructor (`Object.create(null)`); `JSDate.toDart` throws for an invalid
  date.
* Do not import `package:tekartik_js_utils_interop/src/...`.

## More

* Agent skill:
  [skills/tekartik-js-utils-interop-conversions](skills/tekartik-js-utils-interop-conversions/SKILL.md).
* Tests: `dart test -p chrome -c dart2js`, `dart test -p chrome -c dart2wasm`,
  `dart test -p node`.
* `tekartik_js_utils` in the same repo is the deprecated `package:js` version
  (dart2js only).
