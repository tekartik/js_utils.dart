import 'package:dev_test/package.dart';

Future main() async {
  for (var dir in [
    'js_utils',
  ]) {
    await packageRunCi(dir);
  }
}
