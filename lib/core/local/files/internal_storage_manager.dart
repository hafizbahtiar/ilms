import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class InternalStorageManager {
  InternalStorageManager._();

  static final InternalStorageManager instance = InternalStorageManager._();

  Directory? _rootDirectory;
  static String? _rootPath;
  static Directory? _testRootOverride;

  static void initialize({required String rootPath}) {
    _rootPath = rootPath;
  }

  @visibleForTesting
  static void setTestRoot(Directory directory) {
    _testRootOverride = directory;
    instance._rootDirectory = directory;
  }

  @visibleForTesting
  static void resetTestRoot() {
    _testRootOverride = null;
    instance._rootDirectory = null;
  }

  Future<Directory> getRoot() async {
    final testRoot = _testRootOverride;
    if (testRoot != null) return testRoot;

    if (_rootDirectory != null) return _rootDirectory!;

    final documents = await getApplicationDocumentsDirectory();
    _rootDirectory = Directory('${documents.path}/${_rootPath ?? 'ilms_storage'}');

    if (!await _rootDirectory!.exists()) {
      await _rootDirectory!.create(recursive: true);
    }

    return _rootDirectory!;
  }

  Future<Directory> createSubFolder(String folderPath) async {
    final root = await getRoot();
    final subFolder = Directory('${root.path}/$folderPath');

    if (!await subFolder.exists()) {
      await subFolder.create(recursive: true);
    }

    return subFolder;
  }

  Future<File?> saveFile({required dynamic fileData, required String fileName, String? subFolder}) async {
    final targetDir = subFolder != null ? await createSubFolder(subFolder) : await getRoot();
    final file = File('${targetDir.path}/$fileName');

    if (fileData is File) {
      await fileData.copy(file.path);
    } else if (fileData is Uint8List) {
      await file.writeAsBytes(fileData);
    } else if (fileData is String) {
      await file.writeAsString(fileData);
    } else {
      return null;
    }

    return file;
  }

  Future<File?> getFile(String fileName, {String? subFolder}) async {
    final root = await getRoot();
    final fullPath = subFolder != null ? '${root.path}/$subFolder/$fileName' : '${root.path}/$fileName';
    final file = File(fullPath);
    return file.existsSync() ? file : null;
  }

  Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> deleteFolder(String folderName) async {
    final root = await getRoot();
    final folder = Directory('${root.path}/$folderName');
    if (await folder.exists()) {
      await folder.delete(recursive: true);
    }
  }
}
