import 'package:ilms/features/premise/domain/entities/premise_duplicate_record.dart';

class PremiseDuplicateResult {
  const PremiseDuplicateResult({
    required this.items,
    required this.nextPage,
    required this.hasNextPage,
  });

  final List<PremiseDuplicateRecord> items;
  final int nextPage;
  final bool hasNextPage;
}
