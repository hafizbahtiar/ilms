import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/premise/data/datasources/mock_premise_data_source.dart';
import 'package:ilms/features/premise/data/repositories/premise_repository_impl.dart';
import 'package:ilms/features/premise/domain/entities/premise_company_contact.dart';
import 'package:ilms/features/premise/domain/entities/premise_details.dart';
import 'package:ilms/features/premise/domain/entities/premise_form.dart';

void main() {
  group('PremiseRepositoryImpl', () {
    late PremiseRepositoryImpl repository;

    setUp(() {
      repository = PremiseRepositoryImpl(const MockPremiseDataSource());
    });

    test('submitCreate returns visit number and uploads pending images', () async {
      const form = PremiseForm(
        companyContact: PremiseCompanyContact(companyName: 'ACME'),
        details: PremiseDetails(traderName: 'ACME TRADING'),
      );

      final result = await repository.submitCreate(form);

      expect(result.visitNo, startsWith('MOCK-'));
      final uploaded = await repository.uploadPendingImages(visitNo: result.visitNo, form: form);
      expect(uploaded, 0);
    });
  });
}
