class BillboardTypeCountModel {
  const BillboardTypeCountModel({required this.type, required this.value});

  final String type;
  final int value;

  factory BillboardTypeCountModel.fromJson(Map<String, dynamic> json) {
    return BillboardTypeCountModel(
      type: json['type']?.toString() ?? '',
      value: json['value'] is int ? json['value'] as int : int.tryParse('${json['value']}') ?? 0,
    );
  }
}

class BillboardStatusSummaryModel {
  const BillboardStatusSummaryModel({
    required this.dateFrom,
    required this.dateTo,
    required this.total,
    required this.types,
  });

  final String dateFrom;
  final String dateTo;
  final int total;
  final List<BillboardTypeCountModel> types;

  factory BillboardStatusSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawTypes = json['billboard_type'];
    return BillboardStatusSummaryModel(
      dateFrom: json['date_from']?.toString() ?? '',
      dateTo: json['date_to']?.toString() ?? '',
      total: json['total'] is int ? json['total'] as int : int.tryParse('${json['total']}') ?? 0,
      types: rawTypes is List
          ? rawTypes
                .whereType<Map>()
                .map((item) => BillboardTypeCountModel.fromJson(Map<String, dynamic>.from(item)))
                .toList()
          : const [],
    );
  }
}
