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

    test('create payload omits images — they upload via create-photo after submit', () {
      final json = BillboardSubmitPayloadModel.fromDomain(
        _form(photos: const [BillboardPhoto(localPath: '/tmp/a.jpg')]),
      ).toCreateJson();

      expect(json.containsKey('images'), isFalse);
      expect(json.containsKey('photos'), isFalse);
    });

    test('update payload includes billboard_no and still omits images', () {
      final json = BillboardSubmitPayloadModel.fromDomain(_form(billboardNo: 'BB20260001')).toUpdateJson();

      expect(json['billboard_no'], 'BB20260001');
      expect(json.containsKey('images'), isFalse);
    });
  });
}
