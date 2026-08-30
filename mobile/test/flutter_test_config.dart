import 'dart:async';

import 'package:anchor/core/logging/app_logger.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Runs around every test file in this package (flutter_test convention).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Keep test output quiet: only warn/error reach the console. The in-memory
  // log buffer still records everything for tests that assert on it.
  AppLogger.instance.consoleLevel = LogLevel.warn;
  // The app does this in initializeApp(); widget tests skip that, and
  // DateFormat needs the symbols before it can format a named locale.
  await initializeDateFormatting();
  await testMain();
}
