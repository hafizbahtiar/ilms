import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Builds multipart [FormData] for legacy ILMS endpoints that expect nested
/// bracket notation (`company_details[company_name]`, `images[0][file]`, …).
class FormDataBuilder {
  const FormDataBuilder();

  /// Flat string fields for legacy search/filter endpoints (`searchPrevPhase`, etc.).
  /// Prefer this over [fromMap] when there are no nested maps or file uploads.
  static FormData flatFields(Map<String, dynamic> fields) {
    return FormData.fromMap({for (final entry in fields.entries) entry.key: entry.value?.toString() ?? ''});
  }

  /// Lets Dio set the multipart boundary instead of inheriting `application/json`.
  static Options get multipartOptions => Options(headers: {Headers.contentTypeHeader: null});

  Future<FormData> fromMap(Map<String, dynamic> data) async {
    final formData = FormData();
    await Future.wait(data.entries.map((entry) => _addValue(formData, entry.key, entry.value)));
    return formData;
  }

  /// Recursively flattens [value] under [key] using legacy bracket notation
  /// (`key[0][field]`, `key[field][nested]`, …). Handles arbitrarily nested
  /// maps and lists — e.g. `license_information[0][additional_license_info][1][amount]`
  /// — not just a single level, so a list embedded inside a list-of-maps
  /// entry (like a license's business activities) doesn't fall through to a
  /// stringified Dart literal that the backend can't parse.
  Future<void> _addValue(FormData formData, String key, dynamic value) async {
    if (value is Uint8List) {
      await _addBytes(formData, key, value);
    } else if (value is File) {
      await _addFile(formData, key, value);
    } else if (value is Map<String, dynamic>) {
      await Future.wait(value.entries.map((entry) => _addValue(formData, '$key[${entry.key}]', entry.value)));
    } else if (value is List) {
      if (value.isEmpty) {
        // An empty list produces zero bracket-indexed entries, so the key
        // would vanish from the request entirely — the backend then leaves
        // existing rows (e.g. `license_information`, `business_activities`)
        // untouched instead of deleting them. A plain string value for the
        // key (e.g. "[]") doesn't fix this either — PHP still parses it as
        // a scalar, and the backend's `foreach` over it throws. `key[]` with
        // an empty value is the classic HTML-forms idiom for this: PHP
        // parses it into a real (if not truly empty) array, satisfying
        // `foreach`/`is_array`, with the blank placeholder row expected to
        // be filtered out server-side.
        _addField(formData, '$key[]', '');
        return;
      }
      await Future.wait(value.asMap().entries.map((entry) => _addValue(formData, '$key[${entry.key}]', entry.value)));
    } else {
      _addField(formData, key, value);
    }
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
