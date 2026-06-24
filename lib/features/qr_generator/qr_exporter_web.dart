import 'dart:convert';
import 'dart:typed_data';

import 'package:universal_html/html.dart' as html;

import '../../core/utils/file_name.dart';

Future<String> saveQrPng(Uint8List bytes) async {
  final fileName = timestampedFileName('qr-code', 'png');
  final base64Data = base64Encode(bytes);
  final anchor = html.AnchorElement(
    href: 'data:image/png;base64,$base64Data',
  )
    ..download = fileName
    ..style.display = 'none';

  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();

  return fileName;
}
