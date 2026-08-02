import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_generator/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows QR generator shell', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: QrGeneratorApp()));
    await tester.pumpAndSettle();

    expect(find.text('QR Generator'), findsOneWidget);
    expect(find.text('CREATE QR CODE'), findsOneWidget);
    expect(find.text('Generate'), findsOneWidget);
  });
}
