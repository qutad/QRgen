import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../../core/utils/file_name.dart';

Future<String> saveQrPng(Uint8List bytes) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/${timestampedFileName('qr-code', 'png')}');
  final savedFile = await file.writeAsBytes(bytes);
  return savedFile.path;
}
