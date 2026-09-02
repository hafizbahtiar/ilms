import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/core/network/form_data_builder.dart';
import 'package:ilms/features/billboard/data/models/billboard_photo_upload_request.dart';

void main() {
  group('BillboardPhotoUploadRequest', () {
    test('sends billboard_no, process, and images[0]{type,seq,file} like premise/investigation', () {
      final bytes = Uint8List.fromList([0xFF, 0xD8, 0xFF]);
      final body = BillboardPhotoUploadRequest.toMap(billboardNo: 'BB20260001', process: 'create', seq: 1, file: bytes);

      expect(body['billboard_no'], 'BB20260001');
      expect(body.containsKey('photo_url'), isFalse);
      expect(body.containsKey('photo'), isFalse);
      expect(body['process'], 'create');

      final images = body['images'] as List<Map<String, dynamic>>;
      expect(images, hasLength(1));
      expect(images[0]['type'], '');
      expect(images[0]['seq'], 1);
      expect(images[0]['file'], same(bytes));
    });

    test('FormDataBuilder emits billboard_no and images[0][file] multipart keys', () async {
      final bytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0x00]);
      final body = BillboardPhotoUploadRequest.toMap(billboardNo: 'BB20260001', process: 'update', seq: 2, file: bytes);

      final formData = await const FormDataBuilder().fromMap(body);
      final fieldKeys = formData.fields.map((e) => e.key).toList();
      final fileKeys = formData.files.map((e) => e.key).toList();

      expect(fieldKeys, contains('billboard_no'));
      expect(formData.fields.firstWhere((e) => e.key == 'billboard_no').value, 'BB20260001');
      expect(fieldKeys, contains('process'));
      expect(fieldKeys, contains('images[0][type]'));
      expect(fieldKeys, contains('images[0][seq]'));
      expect(fileKeys, contains('images[0][file]'));
      expect(fieldKeys, isNot(contains('photo_url')));
      expect(fileKeys, isNot(contains('photo')));
    });
  });
}
