String timestampedFileName(String prefix, String extension) {
  final now = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
  return '$prefix-$now.$extension';
}
