@TestOn('js || wasm')
library;

import 'dart:js_interop';
import 'package:tekartik_common_utils/env_utils.dart';
import 'package:tekartik_js_utils_interop/js_date.dart';
import 'package:test/test.dart';

void main() {
  group('JSDate', () {
    test('JSDate', () async {
      var jsDate = JSDate(1);
      // True since dart 3.4!
      expect(jsDate, isA<JSDate>());
      expect(jsDate.toISOString(), '1970-01-01T00:00:00.001Z');
      expect(jsDate.getTime(), 1);
      expect(jsDate.isJSDate, isTrue);

      var dartDate = jsDate.toDart;
      expect(dartDate, isA<DateTime>());
      expect(dartDate, DateTime.fromMillisecondsSinceEpoch(1, isUtc: true));

      var jsDateFromDart = dartDate.toJS;
      expect(jsDateFromDart, isA<JSDate>());
      expect(jsDateFromDart.toISOString(), '1970-01-01T00:00:00.001Z');
      expect(jsDateFromDart.getTime(), 1);
      expect(jsDateFromDart.isJSDate, isTrue);

      // Temp bug!
      try {
        var rawJisifiedDateTime = dartDate.jsify();
        expect(rawJisifiedDateTime, isA<DateTime>());
        // ignore: avoid_print
        print(
            'rawJisifiedDateTime: $rawJisifiedDateTime ${rawJisifiedDateTime.runtimeType}');
      } catch (e) {
        // ignore: avoid_print
        print('Temp DateTime().jisify bug fixed: $e');
      }

      // Compare with dartify()! same as dartifyValue
      var rawDartDate = jsDate.dartify()!;
      //print('dartDate: $dartDate');
      if (isRunningAsJavascript) {
        expect(rawDartDate, isA<DateTime>());
        expect(
            rawDartDate, DateTime.fromMillisecondsSinceEpoch(1, isUtc: true));
      } else {
        // In wasm all numbers are double!
        expect(rawDartDate, isNot(isA<DateTime>()));
      }
    });
    test('now', () {
      var now = JSDate.now();
      expect(now.toDart.isUtc, isTrue);
    });
  });
}
