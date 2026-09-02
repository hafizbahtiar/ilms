import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/domain/entities/premise_duplicate_filter.dart';
import 'package:ilms/features/premise/domain/entities/premise_duplicate_record.dart';
import 'package:ilms/features/premise/domain/entities/premise_duplicate_result.dart';
import 'package:ilms/features/premise/domain/repositories/premise_duplicate_repository.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_duplicate_controller.dart';
import 'package:ilms/features/premise/presentation/providers/premise_duplicate_providers.dart';
import 'package:ilms/shared/models/general_model.dart';

class _FakePremiseDuplicateRepository implements PremiseDuplicateRepository {
  var cancelCount = 0;
  PremiseDuplicateFilter? lastFilter;

  @override
  void cancelSearch() => cancelCount++;

  @override
  Future<PremiseDuplicateResult> searchPreviousPhase({
    required PremiseDuplicateFilter filter,
    required int page,
    int perPage = 15,
  }) async {
    lastFilter = filter;
    return PremiseDuplicateResult(
      items: [PremiseDuplicateRecord(visitNo: 'VN-TEST-001', companyName: 'Sample Co', parliament: filter.parliament)],
      nextPage: 2,
      hasNextPage: false,
    );
  }

  @override
  Future<int> createDraftFromRecord(String visitNo) async => 1;
}

void main() {
  test('PremiseDuplicateController persists state after provider rebuild', () async {
    final fakeRepository = _FakePremiseDuplicateRepository();
    final container = ProviderContainer(
      overrides: [premiseDuplicateRepositoryProvider.overrideWithValue(fakeRepository)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(premiseDuplicateControllerProvider.notifier);
    notifier.setParliament(const GeneralModel(code: 'P118', desc: 'Bukit Bintang'));
    await notifier.search();

    expect(fakeRepository.cancelCount, 1);

    final first = container.read(premiseDuplicateControllerProvider);
    expect(first.hasSearched, isTrue);
    expect(first.filter.parliament?.desc, 'Bukit Bintang');
    expect(fakeRepository.lastFilter?.parliament, 'P118');
    expect(first.items, hasLength(1));

    final second = container.read(premiseDuplicateControllerProvider);
    expect(second.hasSearched, isTrue);
    expect(second.items, first.items);
    expect(second.filter.parliament?.desc, 'Bukit Bintang');
  });

  test('clearing area clears area and downstream fields only', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(premiseDuplicateControllerProvider.notifier);
    notifier.setParliament(const GeneralModel(code: 'P118', desc: 'Bukit Bintang'));
    notifier.setArea(const GeneralModel(code: 'A1', desc: 'Area 1'));
    notifier.setStreet(const GeneralModel(code: 'S1', desc: 'Street 1'));

    notifier.setArea(null);

    final filter = container.read(premiseDuplicateControllerProvider).filter;
    expect(filter.parliament?.desc, 'Bukit Bintang');
    expect(filter.area, isNull);
    expect(filter.street, isNull);
  });
}
