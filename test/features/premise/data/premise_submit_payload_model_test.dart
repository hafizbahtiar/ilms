import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/premise/data/models/premise_submit_payload_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_business_activity.dart';
import 'package:ilms/features/premise/domain/entities/premise_company_contact.dart';
import 'package:ilms/features/premise/domain/entities/premise_address.dart';
import 'package:ilms/features/premise/domain/entities/premise_details.dart';
import 'package:ilms/features/premise/domain/entities/premise_form.dart';
import 'package:ilms/features/premise/domain/entities/premise_gps.dart';
import 'package:ilms/features/premise/domain/entities/premise_license.dart';
import 'package:ilms/features/premise/domain/entities/premise_license_activity.dart';

/// Locks the `license_information` wire shape against legacy
/// `LicenseInformation.toJson()` / `toJsonUpdate()`. Create and update do NOT
/// accept the same columns — sending update-only fields on create failed the
/// whole submit whenever the form carried any license.
void main() {
  PremiseForm formWith(
    List<PremiseLicense> licenses, {
    String? visitNo,
    List<PremiseBusinessActivity> businessActivities = const [],
    PremiseGps gps = const PremiseGps(),
    List<PremiseAddress> addresses = const [],
  }) => PremiseForm(
    visitNo: visitNo,
    companyContact: const PremiseCompanyContact(),
    details: const PremiseDetails(),
    licenses: licenses,
    businessActivities: businessActivities,
    gps: gps,
    addresses: addresses,
  );

  final license = PremiseLicense(
    id: 77,
    licenseNo: null,
    licenseFileNo: 'DBKL.JPPP/12234/56/7899/4CJL',
    validFrom: '01/09/2026',
    validTo: '30/09/2026',
    status: 'INA',
    statusDesc: 'INA : Inactive',
    businessActivities: const [
      PremiseLicenseActivity(
        id: 5,
        businessType: 'A112',
        businessTypeDesc: 'A112 : Something',
        status: 'E5',
        statusDesc: 'E5 : Active',
        description: 'TEST',
        amount: '350',
      ),
    ],
  );

  group('toCreateJson', () {
    late Map<String, dynamic> entry;
    late Map<String, dynamic> activity;

    setUp(() {
      final payload = PremiseSubmitPayloadModel.fromDomain(formWith([license])).toCreateJson();
      entry = (payload['license_information'] as List).first as Map<String, dynamic>;
      activity = (entry['additional_license_info'] as List).first as Map<String, dynamic>;
    });

    test('sends exactly the keys /create accepts', () {
      expect(
        entry.keys,
        containsAll(<String>['license_no', 'license_file_no', 'license_from', 'license_to', 'status']),
      );
      expect(entry.containsKey('file_no'), isFalse);
      expect(entry.containsKey('status_desc'), isFalse);
    });

    test('sends dates as yyyy-MM-dd', () {
      expect(entry['license_from'], '2026-09-01');
      expect(entry['license_to'], '2026-09-30');
    });

    test('keeps license_no present but empty when the form never captured one', () {
      expect(entry['license_no'], '');
    });

    test('prefixes the file no', () {
      expect(entry['license_file_no'], 'DBKL.JPPP/12234/56/7899/4CJL');
    });

    test('additional_license_info carries only the four create columns', () {
      expect(activity.keys.toSet(), {'business_type', 'status', 'description', 'amount'});
      expect(activity['amount'], '350');
    });
  });

  group('toUpdateJson', () {
    late Map<String, dynamic> entry;
    late Map<String, dynamic> activity;

    setUp(() {
      final payload = PremiseSubmitPayloadModel.fromDomain(formWith([license], visitNo: 'V1')).toUpdateJson();
      entry = (payload['license_information'] as List).first as Map<String, dynamic>;
      activity = (entry['additional_license_info'] as List).first as Map<String, dynamic>;
    });

    test('keeps the display columns /update does accept', () {
      expect(entry['id'], 77);
      expect(entry['status_desc'], 'INA : Inactive');
      expect(activity['id'], 5);
      expect(activity['business_type_desc'], 'A112 : Something');
      expect(activity['status_desc'], 'E5 : Active');
    });

    test('still drops file_no and normalises dates', () {
      expect(entry.containsKey('file_no'), isFalse);
      expect(entry['license_from'], '2026-09-01');
    });
  });

  test('passes through an unparseable date instead of inventing one', () {
    final payload = PremiseSubmitPayloadModel.fromDomain(
      formWith([const PremiseLicense(validFrom: '', validTo: 'not-a-date')]),
    ).toCreateJson();
    final entry = (payload['license_information'] as List).first as Map<String, dynamic>;
    expect(entry['license_from'], '');
    expect(entry['license_to'], 'not-a-date');
  });

  group('gps_details', () {
    test('create payload sends one top-level coordinate, like billboard', () {
      final payload = PremiseSubmitPayloadModel.fromDomain(
        formWith(const [], gps: const PremiseGps(latitude: '3.139012', longitude: '101.686901')),
      ).toCreateJson();

      final gps = payload['gps_details'] as Map<String, dynamic>;
      expect(gps['latitude'], '3.139012');
      expect(gps['longitude'], '101.686901');
    });

    test('update payload sends the same shape', () {
      final payload = PremiseSubmitPayloadModel.fromDomain(
        formWith(
          const [],
          visitNo: 'V1',
          gps: const PremiseGps(latitude: '3.139012', longitude: '101.686901'),
        ),
      ).toUpdateJson();

      final gps = payload['gps_details'] as Map<String, dynamic>;
      expect(gps['latitude'], '3.139012');
      expect(gps['longitude'], '101.686901');
    });

    test('premise_addresses entries no longer carry latitude/longitude', () {
      final payload = PremiseSubmitPayloadModel.fromDomain(
        formWith(const [], addresses: const [PremiseAddress(unitNo: '12A')]),
      ).toCreateJson();

      final address = (payload['premise_addresses'] as List).first as Map<String, dynamic>;
      expect(address.containsKey('latitude'), isFalse);
      expect(address.containsKey('longitude'), isFalse);
    });
  });

  group('business_activities', () {
    const activity = PremiseBusinessActivity(
      id: 9,
      businessType: 'A105',
      businessTypeDesc: 'A105 : JMB',
      status: 'E5',
      statusDesc: 'E5 : Active',
      description: 'DESC',
    );

    test('create drops the display-only desc columns', () {
      final payload = PremiseSubmitPayloadModel.fromDomain(formWith(const [], businessActivities: const [activity]))
          .toCreateJson();
      final entry = (payload['business_activities'] as List).first as Map<String, dynamic>;

      expect(entry.keys.toSet(), {'business_type', 'status', 'description'});
    });

    test('update keeps id and the desc columns', () {
      final payload = PremiseSubmitPayloadModel.fromDomain(
        formWith(const [], visitNo: 'V1', businessActivities: const [activity]),
      ).toUpdateJson();
      final entry = (payload['business_activities'] as List).first as Map<String, dynamic>;

      expect(entry['id'], 9);
      expect(entry['business_type_desc'], 'A105 : JMB');
      expect(entry['status_desc'], 'E5 : Active');
    });
  });
}
