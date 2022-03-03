import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> localPath() async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> localFile() async {
  final path = await localPath();
  return File('$path/pigie.json');
}

Future<String> getData() async {
  return (await localFile()).readAsString();
}

Future<File> writeData(String data) async {
  final file = await localFile();

  return file.writeAsString(data);
}

Future<File> localImage(String fileName) async {
  final path = await localPath();
  return File('$path/images/$fileName');
}

Future<File> writeImage(List<int> bytes, String fileName) async {
  final file = await localImage(fileName);

  // write the file
  return file.writeAsBytes(bytes);
}