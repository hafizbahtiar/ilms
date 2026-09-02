import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/premise/data/datasources/mock_premise_duplicate_remote_data_source.dart';
import 'package:ilms/features/premise/data/models/premise_duplicate_models.dart';

void main() {
  group('PremiseDuplicateRecordDto.matches', () {
    test('matches parliament and area only', () {
      const record = PremiseDuplicateRecordDto(
        visitNo: 'VN-1',
        parliament: 'P118',
        area: 'N35',
      );

      expect(record.matches(const PremiseDuplicateFilterDto(parliament: 'P118')), isTrue);
      expect(record.matches(const PremiseDuplicateFilterDto(parliament: 'P107')), isFalse);
    });

    test('matches full address cascade', () {
      const record = PremiseDuplicateRecordDto(
        visitNo: 'VN-1',
        parliament: 'P108',
        area: 'N27',
        street: 'Jalan SS7/26',
        building: 'BL-KS',
        unit: 'Lot 3',
      );

      const filter = PremiseDuplicateFilterDto(
        parliament: 'P108',
        area: 'N27',
        street: 'Jalan SS7/26',
        building: 'BL-KS',
        unit: 'Lot 3',
      );

      expect(record.matches(filter), isTrue);
    });
  });

  group('MockPremiseDuplicateRemoteDataSource', () {
    const dataSource = MockPremiseDuplicateRemoteDataSource();

    test('searchPreviousPhase returns records for Bukit Bintang filter', () async {
      final page = await dataSource.searchPreviousPhase(
        filter: const PremiseDuplicateFilterDto(
          parliament: 'P118',
          area: 'N35',
          street: 'Jalan Bukit Bintang',
          building: 'BL-PBB',
          unit: 'G-12',
        ),
        page: 1,
      );

      expect(page.items, isNotEmpty);
      expect(page.items.first.visitNo, 'VN-2024-001');
    });

    test('checkCanDuplicate blocks processed record', () async {
      final check = await dataSource.checkCanDuplicate('VN-2024-004');
      expect(check.canDuplicate, isFalse);
      expect(check.message, isNotNull);
    });

    test('loadDetail returns populated payload', () async {
      final payload = await dataSource.loadDetail('VN-2024-001');
      expect(payload.fields['companyName'], 'Kedai Runcit Ahmad');
      expect(payload.fields['traderName'], 'Ahmad Trading');
    });
  });
}
