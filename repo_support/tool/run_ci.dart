import 'package:dev_build/package.dart';
import 'package:path/path.dart';

var topDir = '..';

Future<void> main() async {
  for (var dir in ['js_utils', 'js_utils_interop']) {
    var path = join(topDir, dir);
    // concurrent test are not supported
    await packageRunCi(path);
  }
}
