import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;

// OpenFile.open("/sdcard/example.txt");

//Support for custom add types
const types = {
  ".pdf": "application/pdf",
  ".dwg": "application/x-autocad",
  ".doc": "application/msword",
  ".docx":
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
};
openOtherTypeFile() async {
  final filePath =
      "https://drive.google.com/file/d/1PBfQujmZFcgRYwSSdZfSAJ0IFJ1xN2N4/view?usp=drive_link";
  final extension = path.extension(filePath);
  await OpenFile.open(filePath, type: types[extension]);
}

//OpenFile.open("/sdcard/example.txt", type: "text/plain", uti: "public.plain-text");
