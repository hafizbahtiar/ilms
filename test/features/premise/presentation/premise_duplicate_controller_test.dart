import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_duplicate_controller.dart';
import 'package:ilms/shared/models/general_model.dart';

void main() {
  test('PremiseDuplicateController persists state after provider rebuild', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(premiseDuplicateControllerProvider.notifier);
    notifier.setParliament(const GeneralModel(code: 'P118', desc: 'Bukit Bintang'));
    await notifier.search();

    final first = container.read(premiseDuplicateControllerProvider);
    expect(first.hasSearched, isTrue);
    expect(first.filter.parliament?.desc, 'Bukit Bintang');

    // Simulate leaving and re-entering the page — same provider container, state kept.
    final second = container.read(premiseDuplicateControllerProvider);
    expect(second.hasSearched, isTrue);
    expect(second.items, first.items);
    expect(second.filter.parliament?.desc, 'Bukit Bintang');
  });
}
