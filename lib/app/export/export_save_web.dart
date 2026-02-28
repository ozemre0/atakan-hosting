import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';

/// Saves export file on web (browser download). Returns null as path is not applicable.
/// [pickedDirectory] is ignored on web.
Future<String?> saveExportFile(
  Uint8List bytes,
  String name,
  String fileExtension, [
  Object? pickedDirectory,
]) async {
  final mimeType = fileExtension == 'xlsx'
      ? MimeType.microsoftExcel
      : MimeType.text;
  await FileSaver.instance.saveFile(
    name: name,
    bytes: bytes,
    fileExtension: fileExtension,
    mimeType: mimeType,
  );
  return null;
}
