import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/qr_generator/qr_screen.dart';

class QrGeneratorApp extends StatelessWidget {
  const QrGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Generator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const QrScreen(),
    );
  }
}
