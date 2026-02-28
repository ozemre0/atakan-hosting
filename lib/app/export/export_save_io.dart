import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Saves export file to local storage (uygulama doküman klasörü). Tam path döner.
Future<String?> saveExportFile(
  Uint8List bytes,
  String name,
  String fileExtension, [
  Object? pickedDirectory,
]) async {
  final fileName = fileExtension.isNotEmpty ? '$name.$fileExtension' : name;
  final dir = await getApplicationDocumentsDirectory();
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);
  return file.path;
}
