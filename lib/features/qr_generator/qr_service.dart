import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'qr_exporter.dart';

class QrService {
  const QrService();

  int errorCorrectionFromIndex(int index) {
    return switch (index) {
      0 => QrErrorCorrectLevel.L,
      1 => QrErrorCorrectLevel.M,
      2 => QrErrorCorrectLevel.Q,
      _ => QrErrorCorrectLevel.H,
    };
  }

  Future<String> exportPng({
    required String data,
    required int errorCorrectionIndex,
    required Color foregroundColor,
    required double size,
  }) async {
    final painter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: true,
      errorCorrectionLevel: errorCorrectionFromIndex(errorCorrectionIndex),
      eyeStyle: QrEyeStyle(color: foregroundColor, eyeShape: QrEyeShape.square),
      dataModuleStyle: QrDataModuleStyle(
        color: foregroundColor,
        dataModuleShape: QrDataModuleShape.square,
      ),
    );
    final image = await painter.toImage(size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw StateError('Could not encode QR image.');
    }

    return saveQrPng(Uint8List.view(byteData.buffer));
  }
}
