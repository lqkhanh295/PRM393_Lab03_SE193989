import 'dart:io';

void main() {
  final dir = Directory('lib');
  final dartFiles = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  int normalized = 0;
  for (final file in dartFiles) {
    String text = file.readAsStringSync();
    if (text.contains('\r\n')) {
      file.writeAsStringSync(text.replaceAll('\r\n', '\n'));
      normalized++;
    }
  }
  print('Normalized line endings in $normalized files to LF.');
}
