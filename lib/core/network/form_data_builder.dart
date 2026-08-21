import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Builds multipart [FormData] for legacy ILMS endpoints that expect nested
/// bracket notation (`company_details[company_name]`, `images[0][file]`, …).
class FormDataBuilder {
  const FormDataBuilder();

  Future<FormData> fromMap(Map<String, dynamic> data) async {
    final formData = FormData();
    final tasks = <Future<void>>[];

    void processEntry(String key, dynamic value, {String parentKey = ''}) {
      final fullKey = parentKey.isEmpty ? key : '$parentKey[$key]';

      if (value is Uint8List) {
        tasks.add(_addBytes(formData, fullKey, value));
      } else if (value is File) {
        tasks.add(_addFile(formData, fullKey, value));
      } else if (value is List<Map<String, dynamic>>) {
        tasks.add(_addMapList(formData, fullKey, value));
      } else if (value is Map<String, dynamic>) {
        if (_isSimpleMap(value)) {
          value.forEach((nestedKey, nestedValue) {
            _addField(formData, '$key[$nestedKey]', nestedValue);
          });
        } else {
          value.forEach((nestedKey, nestedValue) {
            processEntry(nestedKey, nestedValue, parentKey: fullKey);
          });
        }
      } else if (value is List) {
        tasks.add(_addGenericList(formData, key, value, parentKey: parentKey));
      } else {
        _addField(formData, fullKey, value);
      }
    }

    data.forEach(processEntry);
    await Future.wait(tasks);
    return formData;
  }

  bool _isSimpleMap(Map<String, dynamic> map) {
    for (final value in map.values) {
      if (value is Uint8List || value is File || value is Map || value is List) {
        return false;
      }
    }
    return true;
  }

  void _addField(FormData formData, String key, dynamic value) {
    formData.fields.add(MapEntry(key, value?.toString() ?? ''));
  }

  Future<void> _addBytes(FormData formData, String key, Uint8List bytes) async {
    final multipart = await _multipartFromBytes(key, bytes);
    formData.files.add(MapEntry(key, multipart));
  }

  Future<void> _addFile(FormData formData, String key, File file) async {
    final filename = file.path.split('/').last;
    formData.files.add(MapEntry(key, await MultipartFile.fromFile(file.path, filename: filename)));
  }

  Future<void> _addMapList(FormData formData, String key, List<Map<String, dynamic>> mapList) async {
    for (var i = 0; i < mapList.length; i++) {
      final map = mapList[i];
      for (final entry in map.entries) {
        final fullKey = '$key[$i][${entry.key}]';
        final nestedValue = entry.value;
        if (nestedValue is Uint8List) {
          await _addBytes(formData, fullKey, nestedValue);
        } else if (nestedValue is File) {
          await _addFile(formData, fullKey, nestedValue);
        } else if (nestedValue is Map<String, dynamic>) {
          nestedValue.forEach((deepKey, deepValue) {
            _addField(formData, '$fullKey[$deepKey]', deepValue);
          });
        } else {
          _addField(formData, fullKey, nestedValue);
        }
      }
    }
  }

  Future<void> _addGenericList(FormData formData, String key, List<dynamic> list, {String parentKey = ''}) async {
    final fullKey = parentKey.isEmpty ? key : '$parentKey[$key]';
    for (var i = 0; i < list.length; i++) {
      final item = list[i];
      final itemKey = '$fullKey[$i]';
      if (item is Map<String, dynamic>) {
        await _addMapList(formData, fullKey, [item]);
      } else {
        _addField(formData, itemKey, item);
      }
    }
  }

  Future<MultipartFile> _multipartFromBytes(String key, Uint8List bytes) async {
    final (subtype, ext) = _sniffImageType(bytes);
    return MultipartFile.fromBytes(
      bytes,
      filename: 'file-${DateTime.now().millisecondsSinceEpoch}-$key.$ext',
      contentType: DioMediaType('image', subtype),
    );
  }

  (String, String) _sniffImageType(Uint8List bytes) {
    if (bytes.length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return ('jpeg', 'jpg');
    }
    if (bytes.length >= 8 && bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
      return ('png', 'png');
    }
    return ('jpeg', 'jpg');
  }
}
