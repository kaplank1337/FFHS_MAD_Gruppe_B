import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

final log = Logger(
  level: kReleaseMode ? Level.warning : Level.debug,
  printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 5,
    lineLength: 120,
    colors: true,
  ),
);
