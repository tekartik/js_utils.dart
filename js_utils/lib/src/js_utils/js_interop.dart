@JS()
library;

import 'package:js/js.dart';

@JS('Object.keys')
external List<String> jsObjectKeys(Object obj);
