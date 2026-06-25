import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

Future<void> configureWindow() async {
  if (!Platform.isLinux && !Platform.isMacOS && !Platform.isWindows) return;

  await windowManager.ensureInitialized();

  final display = await screenRetriever.getPrimaryDisplay();
  final visibleSize = display.visibleSize ?? display.size;
  final minSize = Size(
    math.min(500, visibleSize.width).toDouble(),
    math.min(750, visibleSize.height - 48).clamp(650, 750).toDouble(),
  );
  final initialSize = Size(
    math.min(900, visibleSize.width - 80).clamp(minSize.width, 900).toDouble(),
    math
        .min(850, visibleSize.height - 80)
        .clamp(minSize.height, 850)
        .toDouble(),
  );

  await windowManager.waitUntilReadyToShow(
    WindowOptions(
      minimumSize: minSize,
      size: initialSize,
      center: true,
    ),
    () async {
      await windowManager.setMinimumSize(minSize);
      await windowManager.setSize(initialSize);
      await windowManager.center();
      await windowManager.show();
      await windowManager.focus();
    },
  );
}
