import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/billboard/data/mappers/billboard_draft_mapper.dart';
import 'package:ilms/features/billboard/presentation/controllers/billboard_form_state.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_details.dart';

void main() {
  test('preserves phase code when a draft is saved and restored', () {
    final fields = BillboardFormFields()..phase.text = 'Phase 7';
    final state = BillboardFormState(
      mode: BillboardFormMode.create,
      details: const BillboardDetails(phaseCode: 'P7', phaseDesc: 'Phase 7'),
    );

    final payload = BillboardDraftMapper.toPayload(fields: fields, state: state);
    final restoredFields = BillboardFormFields();
    BillboardFormState? restoredState;

    BillboardDraftMapper.applyPayload(
      fields: restoredFields,
      payload: payload,
      currentState: BillboardFormState(mode: BillboardFormMode.draft),
      updateState: (value) => restoredState = value,
    );

    expect(payload.phaseCode, 'P7');
    expect(restoredFields.phase.text, 'Phase 7');
    expect(restoredState?.details.phaseCode, 'P7');

    fields.dispose();
    restoredFields.dispose();
  });
}
