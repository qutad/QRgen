import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'qr_service.dart';

const _textKey = 'qr_text';
const _sizeKey = 'qr_size';
const _errorCorrectionKey = 'qr_error_correction';
const _colorKey = 'qr_color';

final qrServiceProvider = Provider<QrService>((ref) => const QrService());

final qrControllerProvider =
    AsyncNotifierProvider<QrController, QrState>(QrController.new);

class QrController extends AsyncNotifier<QrState> {
  @override
  Future<QrState> build() async {
    final prefs = await SharedPreferences.getInstance();
    return QrState(
      text: prefs.getString(_textKey) ?? '',
      sizeIndex: prefs.getInt(_sizeKey) ?? 1,
      errorCorrectionIndex: prefs.getInt(_errorCorrectionKey) ?? 0,
      colorValue: prefs.getInt(_colorKey) ?? Colors.black.toARGB32(),
    );
  }

  Future<void> setText(String value) =>
      _update((state) => state.copyWith(text: value));

  Future<void> generate() async {
    final current = state.valueOrNull ?? const QrState();
    final text = current.text.trim();
    if (text.isEmpty) return;
    state = AsyncData(current.copyWith(generatedText: text));
  }

  Future<void> setSizeIndex(int value) =>
      _update((state) => state.copyWith(sizeIndex: value));

  Future<void> setErrorCorrectionIndex(int value) =>
      _update((state) => state.copyWith(errorCorrectionIndex: value));

  Future<void> setColor(Color value) =>
      _update((state) => state.copyWith(colorValue: value.toARGB32()));

  Future<String> exportPng() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasGeneratedQr) {
      throw StateError('Generate a QR code before exporting.');
    }

    final service = ref.read(qrServiceProvider);
    return service.exportPng(
      data: current.generatedText,
      errorCorrectionIndex: current.errorCorrectionIndex,
      foregroundColor: current.color,
      size: current.exportSize,
    );
  }

  Future<void> _update(QrState Function(QrState state) update) async {
    final current = state.valueOrNull ?? const QrState();
    final next = update(current);
    state = AsyncData(next);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_textKey, next.text);
    await prefs.setInt(_sizeKey, next.sizeIndex);
    await prefs.setInt(_errorCorrectionKey, next.errorCorrectionIndex);
    await prefs.setInt(_colorKey, next.colorValue);
  }
}

@immutable
class QrState {
  const QrState({
    this.text = '',
    this.generatedText = '',
    this.sizeIndex = 1,
    this.errorCorrectionIndex = 0,
    this.colorValue = 0xFF000000,
  });

  final String text;
  final String generatedText;
  final int sizeIndex;
  final int errorCorrectionIndex;
  final int colorValue;

  bool get canGenerate => text.trim().isNotEmpty;
  bool get hasGeneratedQr => generatedText.isNotEmpty;
  Color get color => Color(colorValue);
  double get previewSize => [180.0, 250.0, 320.0][sizeIndex];
  double get exportSize => [512.0, 768.0, 1024.0][sizeIndex];

  QrState copyWith({
    String? text,
    String? generatedText,
    int? sizeIndex,
    int? errorCorrectionIndex,
    int? colorValue,
  }) {
    return QrState(
      text: text ?? this.text,
      generatedText: generatedText ?? this.generatedText,
      sizeIndex: sizeIndex ?? this.sizeIndex,
      errorCorrectionIndex: errorCorrectionIndex ?? this.errorCorrectionIndex,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}
