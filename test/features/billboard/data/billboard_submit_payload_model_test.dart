import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/billboard/data/models/billboard_submit_payload_model.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_asset_owner.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_details.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_form.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_gps.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_license.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_location.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_media_owner.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_photo.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_remark.dart';

BillboardForm _form({BillboardDetails? details, List<BillboardPhoto>? photos, String? billboardNo}) {
  return BillboardForm(
    billboardNo: billboardNo,
    details: details ?? const BillboardDetails(hoardingStartDate: '2026-01-01', hoardingCompleteDate: '2026-01-15'),
    location: const BillboardLocation(),
    gps: const BillboardGps(),
    mediaOwner: const BillboardMediaOwner(),
    assetOwner: const BillboardAssetOwner(),
    license: const BillboardLicense(),
    remark: const BillboardRemark(),
    photos: photos ?? const [],
  );
}

void main() {
  group('BillboardSubmitPayloadModel', () {
    test('maps hoarding dates onto the legacy hording_* API keys', () {
      final json = BillboardSubmitPayloadModel.fromDomain(_form()).toCreateJson();
      final details = json['billboard_details'] as Map<String, dynamic>;

      expect(details['hording_start_date'], '2026-01-01');
      expect(details['hording_complete_date'], '2026-01-15');
      expect(details.containsKey('hoarding_start_date'), isFalse);
      expect(details.containsKey('hoarding_complete_date'), isFalse);
    });

    test('create payload sends photo bytes inline under images, like legacy', () {
      final bytes = Uint8List.fromList([0xFF, 0xD8, 0xFF]);
      final json = BillboardSubmitPayloadModel.fromDomain(
        _form(photos: const [BillboardPhoto(localPath: '/tmp/a.jpg')]),
      ).toCreateJson(images: [bytes]);

      expect(json['images'], [bytes]);
      expect(json.containsKey('photos'), isFalse);
    });

    test('create payload defaults images to an empty list when there are no local photos', () {
      final json = BillboardSubmitPayloadModel.fromDomain(_form()).toCreateJson();

      expect(json['images'], isEmpty);
    });

    test('update payload includes billboard_no and inline images', () {
      final bytes = Uint8List.fromList([0xFF, 0xD8, 0xFF]);
      final json = BillboardSubmitPayloadModel.fromDomain(
        _form(billboardNo: 'BB20260001'),
      ).toUpdateJson(images: [bytes]);

      expect(json['billboard_no'], 'BB20260001');
      expect(json['images'], [bytes]);
    });
  });
}
