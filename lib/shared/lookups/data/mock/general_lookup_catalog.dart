import 'package:ilms/shared/models/general_model.dart';

/// Bundled master lookup data mirroring legacy `/api/list*` endpoints.
///
/// [GeneralModel.type] carries parent keys for cascading filters:
/// - postcodes → state code
/// - areas (company) → state code
/// - parliaments → state code
/// - areas (address search) → parliament code
class GeneralLookupCatalog {
  GeneralLookupCatalog._();

  static const states = <GeneralModel>[
    GeneralModel(code: 'WP', desc: 'Wilayah Persekutuan Kuala Lumpur'),
    GeneralModel(code: 'PJ', desc: 'Wilayah Persekutuan Putrajaya'),
    GeneralModel(code: 'LB', desc: 'Wilayah Persekutuan Labuan'),
    GeneralModel(code: 'JHR', desc: 'Johor'),
    GeneralModel(code: 'KDH', desc: 'Kedah'),
    GeneralModel(code: 'KTN', desc: 'Kelantan'),
    GeneralModel(code: 'MLK', desc: 'Melaka'),
    GeneralModel(code: 'NSN', desc: 'Negeri Sembilan'),
    GeneralModel(code: 'PHG', desc: 'Pahang'),
    GeneralModel(code: 'PRK', desc: 'Perak'),
    GeneralModel(code: 'PLS', desc: 'Perlis'),
    GeneralModel(code: 'PNG', desc: 'Pulau Pinang'),
    GeneralModel(code: 'SBH', desc: 'Sabah'),
    GeneralModel(code: 'SWK', desc: 'Sarawak'),
    GeneralModel(code: 'SGR', desc: 'Selangor'),
    GeneralModel(code: 'TRG', desc: 'Terengganu'),
  ];

  static const postcodes = <GeneralModel>[
    GeneralModel(code: '50000', desc: 'Kuala Lumpur', type: 'WP'),
    GeneralModel(code: '50100', desc: 'Kuala Lumpur', type: 'WP'),
    GeneralModel(code: '50450', desc: 'Kuala Lumpur', type: 'WP'),
    GeneralModel(code: '50460', desc: 'Kuala Lumpur', type: 'WP'),
    GeneralModel(code: '50470', desc: 'Kuala Lumpur', type: 'WP'),
    GeneralModel(code: '55100', desc: 'Kuala Lumpur', type: 'WP'),
    GeneralModel(code: '59200', desc: 'Kuala Lumpur', type: 'WP'),
    GeneralModel(code: '60000', desc: 'Kuala Lumpur', type: 'WP'),
    GeneralModel(code: '62000', desc: 'Putrajaya', type: 'PJ'),
    GeneralModel(code: '87000', desc: 'Labuan', type: 'LB'),
    GeneralModel(code: '43000', desc: 'Kajang', type: 'SGR'),
    GeneralModel(code: '47500', desc: 'Subang Jaya', type: 'SGR'),
    GeneralModel(code: '47600', desc: 'Subang Jaya', type: 'SGR'),
    GeneralModel(code: '47800', desc: 'Petaling Jaya', type: 'SGR'),
    GeneralModel(code: '46000', desc: 'Petaling Jaya', type: 'SGR'),
    GeneralModel(code: '40000', desc: 'Shah Alam', type: 'SGR'),
    GeneralModel(code: '80000', desc: 'Johor Bahru', type: 'JHR'),
    GeneralModel(code: '81000', desc: 'Kulai', type: 'JHR'),
    GeneralModel(code: '10000', desc: 'Georgetown', type: 'PNG'),
    GeneralModel(code: '10200', desc: 'Georgetown', type: 'PNG'),
    GeneralModel(code: '30000', desc: 'Ipoh', type: 'PRK'),
    GeneralModel(code: '75000', desc: 'Melaka', type: 'MLK'),
  ];

  static const areas = <GeneralModel>[
    GeneralModel(code: 'BB001', desc: 'Bukit Bintang', type: 'WP'),
    GeneralModel(code: 'CT002', desc: 'Chow Kit', type: 'WP'),
    GeneralModel(code: 'BR003', desc: 'Bangsar', type: 'WP'),
    GeneralModel(code: 'KL004', desc: 'Kepong', type: 'WP'),
    GeneralModel(code: 'CT005', desc: 'Cheras', type: 'WP'),
    GeneralModel(code: 'SJ005', desc: 'SS15 Subang Jaya', type: 'SGR'),
    GeneralModel(code: 'SJ006', desc: 'USJ', type: 'SGR'),
    GeneralModel(code: 'PJ007', desc: 'Damansara', type: 'SGR'),
    GeneralModel(code: 'SA008', desc: 'Section 7 Shah Alam', type: 'SGR'),
    GeneralModel(code: 'KJ006', desc: 'Kajang Town', type: 'SGR'),
    GeneralModel(code: 'JB009', desc: 'Taman Sentosa', type: 'JHR'),
    GeneralModel(code: 'PNG010', desc: 'Bayan Baru', type: 'PNG'),
  ];

  static const parliaments = <GeneralModel>[
    GeneralModel(code: 'P118', desc: 'Bukit Bintang', type: 'WP'),
    GeneralModel(code: 'P119', desc: 'Titiwangsa', type: 'WP'),
    GeneralModel(code: 'P120', desc: 'Setiawangsa', type: 'WP'),
    GeneralModel(code: 'P121', desc: 'Lembah Pantai', type: 'WP'),
    GeneralModel(code: 'P122', desc: 'Seputeh', type: 'WP'),
    GeneralModel(code: 'P123', desc: 'Cheras', type: 'WP'),
    GeneralModel(code: 'P124', desc: 'Batu', type: 'WP'),
    GeneralModel(code: 'P125', desc: 'Kepong', type: 'WP'),
    GeneralModel(code: 'P107', desc: 'Subang', type: 'SGR'),
    GeneralModel(code: 'P108', desc: 'Petaling Jaya', type: 'SGR'),
    GeneralModel(code: 'P109', desc: 'Damansara', type: 'SGR'),
    GeneralModel(code: 'P110', desc: 'Bangi', type: 'SGR'),
    GeneralModel(code: 'P161', desc: 'Tebrau', type: 'JHR'),
    GeneralModel(code: 'P049', desc: 'Tanjong', type: 'PNG'),
  ];

  /// Areas used in premise address search — parent is parliament code.
  static const areasByParliament = <GeneralModel>[
    GeneralModel(code: 'N35', desc: 'Bukit Bintang', type: 'P118'),
    GeneralModel(code: 'N36', desc: 'Tun Razak Exchange', type: 'P118'),
    GeneralModel(code: 'N37', desc: 'Maluri', type: 'P119'),
    GeneralModel(code: 'N38', desc: 'Setiawangsa', type: 'P120'),
    GeneralModel(code: 'N39', desc: 'Pantai Dalam', type: 'P121'),
    GeneralModel(code: 'N40', desc: 'Seputeh', type: 'P122'),
    GeneralModel(code: 'N41', desc: 'Bandar Tun Razak', type: 'P123'),
    GeneralModel(code: 'N42', desc: 'Kepong', type: 'P125'),
    GeneralModel(code: 'N25', desc: 'Subang Jaya', type: 'P107'),
    GeneralModel(code: 'N26', desc: 'Seri Kembangan', type: 'P107'),
    GeneralModel(code: 'N27', desc: 'Kelana Jaya', type: 'P108'),
    GeneralModel(code: 'N28', desc: 'Bukit Gasing', type: 'P108'),
    GeneralModel(code: 'N29', desc: 'Bandar Utama', type: 'P109'),
    GeneralModel(code: 'N30', desc: 'Kota Damansara', type: 'P109'),
  ];

  /// Streets for duplicate-search filter — parent is area code.
  static const streets = <GeneralModel>[
    GeneralModel(code: 'ST-BB', desc: 'Jalan Bukit Bintang', type: 'N35'),
    GeneralModel(code: 'ST-TRX', desc: 'Jalan Tun Razak', type: 'N36'),
    GeneralModel(code: 'ST-KJ', desc: 'Jalan SS7/26', type: 'N27'),
    GeneralModel(code: 'ST-USJ', desc: 'Jalan USJ 21/10', type: 'N25'),
    GeneralModel(code: 'ST-BU', desc: 'Lebuh Bandar Utama', type: 'N29'),
    GeneralModel(code: 'ST-KP', desc: 'Jalan Metro Perdana', type: 'N42'),
  ];

  /// Buildings for duplicate-search filter — parent is street code.
  static const buildings = <GeneralModel>[
    GeneralModel(code: 'BL-PBB', desc: 'Plaza BB', type: 'ST-BB'),
    GeneralModel(code: 'BL-TRX', desc: 'Menara TRX', type: 'ST-TRX'),
    GeneralModel(code: 'BL-KS', desc: 'Kelana Square', type: 'ST-KJ'),
    GeneralModel(code: 'BL-USJ', desc: 'USJ 21 Business Centre', type: 'ST-USJ'),
    GeneralModel(code: 'BL-1U', desc: '1 Utama Shopping Centre', type: 'ST-BU'),
    GeneralModel(code: 'BL-KP', desc: 'Metro Perdana Business Park', type: 'ST-KP'),
  ];

  /// Unit numbers for duplicate-search filter — parent is building code.
  static const units = <GeneralModel>[
    GeneralModel(code: 'UN-G12', desc: 'G-12', type: 'BL-PBB'),
    GeneralModel(code: 'UN-8', desc: '8', type: 'BL-TRX'),
    GeneralModel(code: 'UN-L3', desc: 'Lot 3', type: 'BL-KS'),
    GeneralModel(code: 'UN-B02', desc: 'B-02', type: 'BL-USJ'),
    GeneralModel(code: 'UN-1F18', desc: '1F-18', type: 'BL-1U'),
    GeneralModel(code: 'UN-22', desc: '22', type: 'BL-KP'),
  ];

  static const businessTypes = <GeneralModel>[
    GeneralModel(code: '01', desc: 'Makanan & Minuman'),
    GeneralModel(code: '02', desc: 'Runcit / Retail'),
    GeneralModel(code: '03', desc: 'Perkhidmatan'),
    GeneralModel(code: '04', desc: 'Pemborong'),
    GeneralModel(code: '05', desc: 'Pengilangan'),
    GeneralModel(code: '06', desc: 'Pejabat / Office'),
    GeneralModel(code: '07', desc: 'Hotel & Penginapan'),
    GeneralModel(code: '08', desc: 'Kesihatan & Farmasi'),
    GeneralModel(code: '09', desc: 'Pendidikan'),
    GeneralModel(code: '10', desc: 'Lain-lain'),
  ];

  static const premiseTypes = <GeneralModel>[
    GeneralModel(code: 'SL', desc: 'Shoplot'),
    GeneralModel(code: 'KS', desc: 'Kiosk'),
    GeneralModel(code: 'OF', desc: 'Office'),
    GeneralModel(code: 'FC', desc: 'Factory'),
    GeneralModel(code: 'WH', desc: 'Warehouse'),
    GeneralModel(code: 'MX', desc: 'Mixed Development'),
    GeneralModel(code: 'ST', desc: 'Stall / Gerai'),
    GeneralModel(code: 'MK', desc: 'Market Lot'),
  ];

  static const visitBusinessTypes = <GeneralModel>[
    GeneralModel(code: 'NB', desc: 'New Business'),
    GeneralModel(code: 'EB', desc: 'Existing Business'),
    GeneralModel(code: 'CB', desc: 'Closed Business'),
    GeneralModel(code: 'VB', desc: 'Vacant Premise'),
  ];

  static const visitStatuses = <GeneralModel>[
    GeneralModel(code: '01', desc: 'Berjaya Lawati'),
    GeneralModel(code: '02', desc: 'Premis Tutup'),
    GeneralModel(code: '03', desc: 'Premis Kosong'),
    GeneralModel(code: '04', desc: 'Enggan Memberi Maklumat'),
    GeneralModel(code: '05', desc: 'Premis Tidak Wujud'),
  ];

  static const imageTypes = <GeneralModel>[
    GeneralModel(code: '01', desc: 'Front View'),
    GeneralModel(code: '02', desc: 'Signboard'),
    GeneralModel(code: '03', desc: 'Interior'),
    GeneralModel(code: '04', desc: 'License / Permit'),
    GeneralModel(code: '05', desc: 'Other'),
  ];

  static const remarks = <GeneralModel>[
    GeneralModel(code: 'R01', desc: 'Premis bersih'),
    GeneralModel(code: 'R02', desc: 'Premis kotor'),
    GeneralModel(code: 'R03', desc: 'Signboard tidak mematuhi'),
    GeneralModel(code: 'R04', desc: 'Lesen tamat tempoh'),
    GeneralModel(code: 'R05', desc: 'Maklumat tidak lengkap'),
    GeneralModel(code: 'R06', desc: 'Other'),
  ];

  static const businessActivityStatuses = <GeneralModel>[
    GeneralModel(code: 'A', desc: 'Active'),
    GeneralModel(code: 'I', desc: 'Inactive'),
    GeneralModel(code: 'C', desc: 'Closed'),
  ];

  static const businessLicenseStatuses = <GeneralModel>[
    GeneralModel(code: 'V', desc: 'Valid'),
    GeneralModel(code: 'E', desc: 'Expired'),
    GeneralModel(code: 'P', desc: 'Pending'),
    GeneralModel(code: 'N', desc: 'No License'),
  ];

  static const phases = <GeneralModel>[
    GeneralModel(code: 'P1', desc: 'Phase 1'),
    GeneralModel(code: 'P2', desc: 'Phase 2'),
    GeneralModel(code: 'P3', desc: 'Phase 3'),
  ];

  static const yesNo = <GeneralModel>[GeneralModel(code: 'Y', desc: 'Yes'), GeneralModel(code: 'N', desc: 'No')];

  static List<GeneralModel> filterByParent(List<GeneralModel> items, String? parentCode) {
    if (parentCode == null || parentCode.isEmpty) return items;
    return items.where((item) => item.type == parentCode).toList(growable: false);
  }

  static List<GeneralModel> filterPostcodes({String? stateCode, String? postcode}) {
    var result = filterByParent(postcodes, stateCode);
    if (postcode != null && postcode.isNotEmpty) {
      result = result.where((item) => item.code == postcode).toList(growable: false);
    }
    return result;
  }

  static List<GeneralModel> filterAreas({String? stateCode, String? postcode}) {
    var result = filterByParent(areas, stateCode);
    if (postcode != null && postcode.isNotEmpty) {
      // Narrow areas when a postcode city matches (same state bucket for mock data).
      result = result;
    }
    return result;
  }
}
