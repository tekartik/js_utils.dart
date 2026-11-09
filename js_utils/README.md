# tekartik_js_utils (deprecated)

Legacy JavaScript helpers built on `package:js` / `dart:js_util`: every library
is `@Deprecated('Do not use')`, they only run when compiled with dart2js
(browser or node), not with dart2wasm.

New code: use `tekartik_js_utils_interop` (same repo, `path:
js_utils_interop`), built on `dart:js_interop`, which works with dart2js and
dart2wasm. The function names are close (`jsObjectAsMap`, `jsArrayAsList`,
`jsObjectKeys`...), see the migration table in the
[skill](skills/tekartik-js-utils-legacy/SKILL.md).

## Setup (existing code only)

```yaml
dependencies:
  tekartik_js_utils:
    git:
      url: https://github.com/tekartik/js_utils.dart
      path: js_utils
```

Tests run in a JavaScript runtime only: `dart test -p chrome`,
`dart test -p node`.
