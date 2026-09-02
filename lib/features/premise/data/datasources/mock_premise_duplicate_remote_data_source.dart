import 'package:ilms/features/premise/data/datasources/premise_duplicate_remote_data_source.dart';
import 'package:ilms/features/premise/data/mappers/premise_detail_mapper.dart';
import 'package:ilms/features/premise/data/models/premise_draft_payload_model.dart';
import 'package:ilms/features/premise/data/models/premise_duplicate_models.dart';
import 'package:ilms/features/premise/domain/entities/premise_duplicate_check.dart';
import 'package:ilms/shared/lookups/data/mock/general_lookup_catalog.dart';

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
      parliament: 'P118',
      area: 'N35',
      street: 'Jalan Bukit Bintang',
      building: 'BL-PBB',
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
      parliament: 'P108',
      area: 'N27',
      street: 'Jalan SS7/26',
      building: 'BL-KS',
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
      parliament: 'P119',
      area: 'N36',
      street: 'Jalan Tun Razak',
      building: 'BL-TRX',
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
      parliament: 'P107',
      area: 'N25',
      street: 'Jalan USJ 21/10',
      building: 'BL-USJ',
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
      parliament: 'P109',
      area: 'N29',
      street: 'Lebuh Bandar Utama',
      building: 'BL-1U',
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
      parliament: 'P125',
      area: 'N42',
      street: 'Jalan Metro Perdana',
      building: 'BL-KP',
      unit: '22',
    ),
  ];

  static Map<String, dynamic> detailApiDataFor(String visitNo) {
    final record = records.firstWhere((item) => item.visitNo == visitNo, orElse: () => records.first);

    final state = GeneralLookupCatalog.states.first;
    final postcode = GeneralLookupCatalog.postcodes.firstWhere((item) => item.type == state.code);

    return {
      'company_details': {
        'company_name': record.companyName ?? '',
        'register_no': 'ROC-${record.visitNo}',
        'tel_no': '03-12345678',
        'sticker_no': 'ST-${record.visitNo.substring(record.visitNo.length - 3)}',
        'census_date': record.visitDate ?? '2024-01-01',
        'state': state.code,
        'postcode': postcode.code,
        'unit': record.unit ?? '',
        'building': record.building ?? '',
        'street1': record.street ?? '',
        'area': record.area ?? '',
      },
      'contact_person': const {},
      'premise_details': {
        'trader_name': record.traderName ?? '',
        'business_type': GeneralLookupCatalog.businessTypes.first.code,
        'business_type_desc': GeneralLookupCatalog.businessTypes.first.desc,
        'premise_type': GeneralLookupCatalog.premiseTypes.first.code,
        'premise_type_desc': GeneralLookupCatalog.premiseTypes.first.desc,
        'width': '12',
        'length': '18',
      },
      'premise_addresses': [
        {
          'paid': 1001,
          'vpa_id': 2001,
          'unit_no': record.unit ?? '',
          'building': record.building ?? '',
          'street_name': record.street ?? '',
          'area': record.area ?? '',
          'postcode': postcode.code,
          'state': state.code,
        },
      ],
      'business_activities': [
        {
          'id': 501,
          'business_type': GeneralLookupCatalog.businessTypes.first.code,
          'business_type_desc': GeneralLookupCatalog.businessTypes.first.desc,
          'status': 'A',
          'status_desc': 'Active',
          'description': 'Mock business activity',
        },
      ],
      'remarks': [
        {
          'id': 601,
          'code': 'R01',
          'remark': 'Mock remark from previous phase',
          'remark_type': 'O',
          'description': 'Carried over on duplicate',
        },
      ],
    };
  }

  static PremiseDraftPayloadModel detailPayloadFor(String visitNo) {
    return PremiseDetailMapper.fromApiDetailForDuplicate(detailApiDataFor(visitNo));
  }
}

class MockPremiseDuplicateRemoteDataSource implements PremiseDuplicateRemoteDataSource {
  const MockPremiseDuplicateRemoteDataSource();

  @override
  void cancelSearch() {}

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

    return PremiseDuplicateResultDto(items: slice, nextPage: hasNext ? page + 1 : page, hasNextPage: hasNext);
  }
}
