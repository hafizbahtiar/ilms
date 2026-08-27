import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/premise/presentation/utils/premise_license_file_no.dart';

void main() {
  group('PremiseLicenseFileNo', () {
    test('masks raw alphanumeric input', () {
      expect(PremiseLicenseFileNo.maskValue('01953122024KM01').text, '01953/12/2024/KM01');
    });

    test('keeps an already-masked value', () {
      expect(PremiseLicenseFileNo.maskValue('01953/12/2024/KM01').text, '01953/12/2024/KM01');
    });

    test('removePrefix strips DBKL.JPPP/', () {
      expect(PremiseLicenseFileNo.removePrefix('DBKL.JPPP/01953/12/2024/KM01'), '01953/12/2024/KM01');
    });

    test('formatForSubmit prepends DBKL.JPPP/', () {
      expect(PremiseLicenseFileNo.formatForSubmit('01953/12/2024/KM01'), 'DBKL.JPPP/01953/12/2024/KM01');
    });

    test('validateMasked accepts 18-char masked value', () {
      expect(PremiseLicenseFileNo.validateMasked('01953/12/2024/KM01'), isNull);
    });

    test('validateMasked rejects incomplete value', () {
      expect(PremiseLicenseFileNo.validateMasked('01953/12/2024/KM0'), 'File no is invalid');
    });
  });
}
