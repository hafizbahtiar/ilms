import 'package:ilms/features/premise/domain/entities/premise_search_record.dart';

class PremiseSearchResult {
  const PremiseSearchResult({
    required this.items,
    required this.nextPage,
    required this.hasNextPage,
  });

  final List<PremiseSearchRecord> items;
  final int nextPage;
  final bool hasNextPage;
}
