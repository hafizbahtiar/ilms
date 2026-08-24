import 'package:ilms/features/billboard/data/datasources/billboard_search_remote_data_source.dart';
import 'package:ilms/features/billboard/data/models/billboard_search_models.dart';

/// Canned in-memory search results — test-only, not wired to production DI.
class MockBillboardSearchRemoteDataSource implements BillboardSearchRemoteDataSource {
  const MockBillboardSearchRemoteDataSource();

  static const _records = <BillboardSearchRecordDto>[
    BillboardSearchRecordDto(
      billboardNo: 'BB10000001',
      billboardDate: '2026-01-15',
      mediaOwnerClient: 'Coca-Cola Malaysia',
      location: 'Kuala Lumpur',
      address: 'Jalan Ampang, Kuala Lumpur',
      startDate: '2026-01-01',
      completeDate: '2026-12-31',
    ),
    BillboardSearchRecordDto(
      billboardNo: 'BB10000002',
      billboardDate: '2026-02-10',
      mediaOwnerClient: 'Petronas',
      location: 'Petaling Jaya',
      address: 'Jalan SS2/24, Petaling Jaya',
      startDate: '2026-02-01',
      completeDate: '2026-11-30',
    ),
    BillboardSearchRecordDto(
      billboardNo: 'BB10000003',
      billboardDate: '2026-03-05',
      mediaOwnerClient: 'Maybank',
      location: 'Shah Alam',
      address: 'Persiaran Perbandaran, Shah Alam',
      startDate: '2026-03-01',
      completeDate: '2026-10-31',
    ),
  ];

  @override
  Future<BillboardSearchResultDto> search({
    required BillboardSearchFilterDto filter,
    required int page,
    int perPage = 15,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final start = (page - 1) * perPage;
    if (start >= _records.length) {
      return const BillboardSearchResultDto(items: [], nextPage: 1, hasNextPage: false);
    }

    final end = (start + perPage).clamp(0, _records.length);
    final slice = _records.sublist(start, end);
    final hasNext = end < _records.length;

    return BillboardSearchResultDto(items: slice, nextPage: hasNext ? page + 1 : page, hasNextPage: hasNext);
  }
}
