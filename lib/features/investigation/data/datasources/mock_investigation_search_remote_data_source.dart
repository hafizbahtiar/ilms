import 'package:ilms/features/investigation/data/datasources/investigation_search_remote_data_source.dart';
import 'package:ilms/features/investigation/data/models/investigation_search_models.dart';

/// Canned in-memory search results — test-only, not wired to production DI.
class MockInvestigationSearchRemoteDataSource implements InvestigationSearchRemoteDataSource {
  const MockInvestigationSearchRemoteDataSource();

  static const _records = <InvestigationSearchRecordDto>[
    InvestigationSearchRecordDto(
      investigationNo: 'INV10000001',
      licenseFileNo: 'LF-0001',
      dateReceived: '2026-01-15',
      applicantName: 'Ahmad bin Ismail',
      companyName: 'Warung Ahmad Sdn Bhd',
      typeCode: 'PEMBAHARUAN',
      priorityCode: 'NORMAL',
      statusCode: 'OPEN',
      areaCode: 'A01',
      investigationOfficer: 'Officer Tan',
      investigationStartDate: '2026-01-16',
      businessType: 'Restoran',
      createdDate: '2026-01-14',
    ),
    InvestigationSearchRecordDto(
      investigationNo: 'INV10000002',
      licenseFileNo: 'LF-0002',
      dateReceived: '2026-02-10',
      applicantName: 'Siti binti Kassim',
      companyName: 'Kedai Siti',
      typeCode: 'RAYUAN',
      priorityCode: 'HIGH',
      statusCode: 'OPEN',
      areaCode: 'A02',
      investigationOfficer: 'Officer Lim',
      investigationStartDate: '2026-02-11',
      businessType: 'Kedai Runcit',
      createdDate: '2026-02-09',
    ),
  ];

  @override
  Future<InvestigationSearchResultDto> search({
    required InvestigationSearchFilterDto filter,
    required int page,
    int perPage = 15,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final start = (page - 1) * perPage;
    if (start >= _records.length) {
      return const InvestigationSearchResultDto(items: [], nextPage: 1, hasNextPage: false);
    }

    final end = (start + perPage).clamp(0, _records.length);
    final slice = _records.sublist(start, end);
    final hasNext = end < _records.length;

    return InvestigationSearchResultDto(items: slice, nextPage: hasNext ? page + 1 : page, hasNextPage: hasNext);
  }
}
