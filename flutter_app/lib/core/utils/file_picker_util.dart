import 'package:file_picker/file_picker.dart';

Future<String?> pickFile() async {
  final result = await FilePicker.platform.pickFiles();
  return result?.files.single.path;
}
