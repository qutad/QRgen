import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/utils/window_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureWindow();
  runApp(const ProviderScope(child: QrGeneratorApp()));
}
