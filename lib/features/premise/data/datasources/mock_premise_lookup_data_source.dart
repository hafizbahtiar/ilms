import 'package:ilms/features/premise/data/datasources/premise_lookup_data_source.dart';
import 'package:ilms/shared/models/general_model.dart';

class MockPremiseLookupDataSource implements PremiseLookupDataSource {
  const MockPremiseLookupDataSource();

  static const businessTypes = <GeneralModel>[
    GeneralModel(code: 'RETAIL', desc: 'Retail'),
    GeneralModel(code: 'F&B', desc: 'Food & Beverage'),
    GeneralModel(code: 'SERVICE', desc: 'Service'),
    GeneralModel(code: 'WHOLESALE', desc: 'Wholesale'),
    GeneralModel(code: 'MANUFACTURING', desc: 'Manufacturing'),
    GeneralModel(code: 'OFFICE', desc: 'Office'),
  ];

  static const premiseTypes = <GeneralModel>[
    GeneralModel(code: 'SHOPLOT', desc: 'Shoplot'),
    GeneralModel(code: 'KIOSK', desc: 'Kiosk'),
    GeneralModel(code: 'OFFICE', desc: 'Office'),
    GeneralModel(code: 'FACTORY', desc: 'Factory'),
    GeneralModel(code: 'WAREHOUSE', desc: 'Warehouse'),
    GeneralModel(code: 'MIXED', desc: 'Mixed Development'),
  ];

  static const states = <GeneralModel>[
    GeneralModel(code: 'WP', desc: 'Wilayah Persekutuan'),
    GeneralModel(code: 'JHR', desc: 'Johor'),
    GeneralModel(code: 'SGR', desc: 'Selangor'),
    GeneralModel(code: 'PNG', desc: 'Pulau Pinang'),
  ];

  static const postcodes = <GeneralModel>[
    GeneralModel(code: '50000', desc: '50000 - Kuala Lumpur'),
    GeneralModel(code: '50100', desc: '50100 - Kuala Lumpur'),
    GeneralModel(code: '50450', desc: '50450 - Kuala Lumpur'),
    GeneralModel(code: '55100', desc: '55100 - Kuala Lumpur'),
    GeneralModel(code: '43000', desc: '43000 - Kajang'),
    GeneralModel(code: '47500', desc: '47500 - Subang Jaya'),
  ];

  static const areas = <GeneralModel>[
    GeneralModel(code: 'BB001', desc: 'Bukit Bintang'),
    GeneralModel(code: 'CT002', desc: 'Chow Kit'),
    GeneralModel(code: 'BR003', desc: 'Bangsar'),
    GeneralModel(code: 'KL004', desc: 'Kepong'),
    GeneralModel(code: 'SJ005', desc: 'SS15 Subang Jaya'),
    GeneralModel(code: 'KJ006', desc: 'Kajang Town'),
  ];

  static const imageTypes = <GeneralModel>[
    GeneralModel(code: 'FRONT', desc: 'Front View'),
    GeneralModel(code: 'SIGN', desc: 'Signboard'),
    GeneralModel(code: 'INTERIOR', desc: 'Interior'),
    GeneralModel(code: 'OTHER', desc: 'Other'),
  ];

  @override
  Future<List<GeneralModel>> fetchAreas() async => areas;

  @override
  Future<List<GeneralModel>> fetchBusinessTypes() async => businessTypes;

  @override
  Future<List<GeneralModel>> fetchImageTypes() async => imageTypes;

  @override
  Future<List<GeneralModel>> fetchPostcodes() async => postcodes;

  @override
  Future<List<GeneralModel>> fetchPremiseTypes() async => premiseTypes;

  @override
  Future<List<GeneralModel>> fetchStates() async => states;
}
