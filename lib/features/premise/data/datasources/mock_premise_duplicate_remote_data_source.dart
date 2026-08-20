import 'package:ilms/features/premise/data/datasources/premise_duplicate_remote_data_source.dart';
import 'package:ilms/features/premise/data/models/premise_draft_payload_model.dart';
import 'package:ilms/features/premise/data/models/premise_duplicate_models.dart';
import 'package:ilms/features/premise/domain/entities/premise_duplicate_check.dart';
import 'package:ilms/shared/lookups/data/mock/general_lookup_catalog.dart';
import 'package:ilms/shared/lookups/lookup_labels.dart';

/// Bundled previous-phase records for offline duplicate search.
class MockPremiseDuplicateCatalog {
  MockPremiseDuplicateCatalog._();

  static const records = <PremiseDuplicateRecordDto>[
    PremiseDuplicateRecordDto(
      visitNo: 'VN-2024-001',
      companyName: 'Kedai Runcit Ahmad',
      traderName: 'Ahmad Trading',
      address: 'G-12, Plaza BB, Jalan Bukit Bintang, Kuala Lumpur',
      visitStatus: 'Berjaya Lawati',
      phase: 'Phase 1',
      visitDate: '2024-06-15',
      createdBy: 'pembanci01',
      parliament: 'Bukit Bintang',
      area: 'Bukit Bintang',
      street: 'Jalan Bukit Bintang',
      building: 'Plaza BB',
      unit: 'G-12',
    ),
    PremiseDuplicateRecordDto(
      visitNo: 'VN-2024-002',
      companyName: 'Mutiara Retail Sdn Bhd',
      traderName: 'Mutiara Retail',
      address: 'Lot 3, Kelana Square, Kelana Jaya',
      visitStatus: 'Berjaya Lawati',
      phase: 'Phase 1',
      visitDate: '2024-07-02',
      createdBy: 'pembanci02',
      parliament: 'Petaling Jaya',
      area: 'Kelana Jaya',
      street: 'Jalan SS7/26',
      building: 'Kelana Square',
      unit: 'Lot 3',
    ),
    PremiseDuplicateRecordDto(
      visitNo: 'VN-2024-003',
      companyName: 'Warung Kopi Senja',
      traderName: 'Senja Cafe',
      address: 'No. 8, Jalan Tun Razak, Kuala Lumpur',
      visitStatus: 'Premis Tutup',
      phase: 'Phase 1',
      visitDate: '2024-05-20',
      createdBy: 'pembanci01',
      parliament: 'Titiwangsa',
      area: 'Tun Razak Exchange',
      street: 'Jalan Tun Razak',
      building: 'Menara TRX',
      unit: '8',
    ),
    PremiseDuplicateRecordDto(
      visitNo: 'VN-2024-004',
      companyName: 'Subang Tech Hub',
      traderName: 'Tech Hub',
      address: 'B-02, USJ 21, Subang Jaya',
      visitStatus: 'Berjaya Lawati',
      phase: 'Phase 2',
      visitDate: '2024-08-11',
      createdBy: 'pembanci03',
      parliament: 'Subang',
      area: 'Subang Jaya',
      street: 'Jalan USJ 21/10',
      building: 'USJ 21 Business Centre',
      unit: 'B-02',
      canDuplicate: false,
      blockMessage: 'Premise status: Already Processed.',
    ),
    PremiseDuplicateRecordDto(
      visitNo: 'VN-2024-005',
      companyName: 'Damansara Grocer',
      traderName: 'DG Mart',
      address: '1F-18, 1 Utama, Bandar Utama',
      visitStatus: 'Berjaya Lawati',
      phase: 'Phase 1',
      visitDate: '2024-04-03',
      createdBy: 'pembanci04',
      parliament: 'Damansara',
      area: 'Bandar Utama',
      street: 'Lebuh Bandar Utama',
      building: '1 Utama Shopping Centre',
      unit: '1F-18',
    ),
    PremiseDuplicateRecordDto(
      visitNo: 'VN-2024-006',
      companyName: 'Kepong Hardware',
      traderName: 'KH Supplies',
      address: '22, Jalan Metro Perdana, Kepong',
      visitStatus: 'Berjaya Lawati',
      phase: 'Phase 1',
      visitDate: '2024-03-28',
      createdBy: 'pembanci05',
      parliament: 'Kepong',
      area: 'Kepong',
      street: 'Jalan Metro Perdana',
      building: 'Metro Perdana Business Park',
      unit: '22',
    ),
  ];

  static PremiseDraftPayloadModel detailPayloadFor(String visitNo) {
    final record = records.firstWhere((item) => item.visitNo == visitNo, orElse: () => records.first);

    final state = GeneralLookupCatalog.states.first;
    final postcode = GeneralLookupCatalog.postcodes.firstWhere((item) => item.type == state.code);

    return PremiseDraftPayloadModel(
      companyStateCode: state.code,
      companyPostcode: postcode.code,
      fields: {
        'companyName': record.companyName ?? '',
        'traderName': record.traderName ?? '',
        'registerNumber': 'ROC-${record.visitNo}',
        'companyTelNo': '03-12345678',
        'stickerNo': 'ST-${record.visitNo.substring(record.visitNo.length - 3)}',
        'censusDate': record.visitDate ?? '',
        'unit': record.unit ?? '',
        'building': record.building ?? '',
        'street1': record.street ?? '',
        'state': generalLookupLabel(state),
        'postcode': generalPostcodeLabel(postcode),
        'area': record.area ?? '',
        'businessType': generalLookupLabel(GeneralLookupCatalog.businessTypes.first),
        'premiseType': generalLookupLabel(GeneralLookupCatalog.premiseTypes.first),
        'width': '12',
        'length': '18',
      },
    );
  }
}

class MockPremiseDuplicateRemoteDataSource implements PremiseDuplicateRemoteDataSource {
  const MockPremiseDuplicateRemoteDataSource();

  @override
  Future<PremiseDuplicateCheck> checkCanDuplicate(String visitNo) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final record = MockPremiseDuplicateCatalog.records.firstWhere(
      (item) => item.visitNo == visitNo,
      orElse: () => const PremiseDuplicateRecordDto(visitNo: '', canDuplicate: false),
    );

    if (record.visitNo.isEmpty) {
      return const PremiseDuplicateCheck(canDuplicate: false, message: 'Record not found.');
    }

    return PremiseDuplicateCheck(canDuplicate: record.canDuplicate, message: record.blockMessage);
  }

  @override
  Future<PremiseDraftPayloadModel> loadDetail(String visitNo) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return MockPremiseDuplicateCatalog.detailPayloadFor(visitNo);
  }

  @override
  Future<PremiseDuplicateResultDto> searchPreviousPhase({
    required PremiseDuplicateFilterDto filter,
    required int page,
    int perPage = 15,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final matched = MockPremiseDuplicateCatalog.records.where((record) => record.matches(filter)).toList();

    final start = (page - 1) * perPage;
    if (start >= matched.length) {
      return const PremiseDuplicateResultDto(items: [], nextPage: 1, hasNextPage: false);
    }

    final end = (start + perPage).clamp(0, matched.length);
    final slice = matched.sublist(start, end);
    final hasNext = end < matched.length;

    return PremiseDuplicateResultDto(
      items: slice,
      nextPage: hasNext ? page + 1 : page,
      hasNextPage: hasNext,
    );
  }
}
