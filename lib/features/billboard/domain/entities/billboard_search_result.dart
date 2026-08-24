import 'package:ilms/features/billboard/domain/entities/billboard_search_record.dart';

class BillboardSearchResult {
  const BillboardSearchResult({required this.items, required this.nextPage, required this.hasNextPage});

  final List<BillboardSearchRecord> items;
  final int nextPage;
  final bool hasNextPage;
}
