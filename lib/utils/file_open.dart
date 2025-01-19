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
      "https://docs.google.com/document/d/1Iw5ekASUbM8rtqI7i6MZdN5901bHYAsJxaF4lH0J4wM/edit?tab=t.0";
  final extension = path.extension(filePath);
  await OpenFile.open(filePath, type: types[extension]);
}

//OpenFile.open("/sdcard/example.txt", type: "text/plain", uti: "public.plain-text");
