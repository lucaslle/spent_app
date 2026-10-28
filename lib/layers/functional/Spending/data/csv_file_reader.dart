import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

class PickedCsv {
  const PickedCsv(this.name, this.text);

  final String name;
  final String text;
}

Future<PickedCsv?> pickCsvFile() async {
  final res = await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
  final file = res?.files.single;
  if (file == null) return null;
  final bytes = file.bytes ?? await File(file.path!).readAsBytes();
  final utf8Text = utf8.decode(bytes, allowMalformed: true);
  return PickedCsv(file.name, utf8Text.contains('\uFFFD') ? latin1.decode(bytes) : utf8Text);
}
