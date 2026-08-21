class PremiseVisitStatusModel {
  const PremiseVisitStatusModel({required this.status, required this.value});

  final String status;
  final int value;

  factory PremiseVisitStatusModel.fromJson(Map<String, dynamic> json) {
    return PremiseVisitStatusModel(
      status: json['status']?.toString() ?? '',
      value: json['value'] is int ? json['value'] as int : int.tryParse('${json['value']}') ?? 0,
    );
  }
}

class PremiseStatusSummaryModel {
  const PremiseStatusSummaryModel({
    required this.dateFrom,
    required this.dateTo,
    required this.total,
    required this.visitStatus,
  });

  final String dateFrom;
  final String dateTo;
  final int total;
  final List<PremiseVisitStatusModel> visitStatus;

  factory PremiseStatusSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawVisitStatus = json['visit_status'];
    return PremiseStatusSummaryModel(
      dateFrom: json['date_from']?.toString() ?? '',
      dateTo: json['date_to']?.toString() ?? '',
      total: json['total'] is int ? json['total'] as int : int.tryParse('${json['total']}') ?? 0,
      visitStatus: rawVisitStatus is List
          ? rawVisitStatus
                .whereType<Map>()
                .map((item) => PremiseVisitStatusModel.fromJson(Map<String, dynamic>.from(item)))
                .toList()
          : const [],
    );
  }
}
