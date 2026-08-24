import 'package:ilms/features/investigation/domain/entities/investigation_search_record.dart';

class InvestigationSearchResult {
  const InvestigationSearchResult({required this.items, required this.nextPage, required this.hasNextPage});

  final List<InvestigationSearchRecord> items;
  final int nextPage;
  final bool hasNextPage;
}
