import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/data/mappers/premise_form_mapper.dart';
import 'package:ilms/features/premise/domain/entities/premise_census_image.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_form_state.dart';
import 'package:ilms/features/premise/presentation/providers/premise_providers.dart';
import 'package:ilms/features/premise/presentation/sections/premise_form_sections.dart';

class PremiseFormController extends FamilyNotifier<PremiseFormState, PremiseFormMode> {
  late final PremiseFormFields fields;

  @override
  PremiseFormState build(PremiseFormMode mode) {
    fields = PremiseFormFields();
    ref.onDispose(fields.dispose);
    return PremiseFormState(mode: mode);
  }

  PremiseFormFields get formFields => fields;

  void setActiveSection(int index) {
    if (index == state.activeSectionIndex) return;
    if (index < 0 || index >= premiseFormSections.length) return;
    state = state.copyWith(activeSectionIndex: index);
  }

  void addCensusImage(PremiseCensusImage image) {
    if (state.isReadOnly) return;
    state = state.copyWith(censusImages: [...state.censusImages, image]);
  }

  void removeCensusImageAt(int index) {
    if (state.isReadOnly) return;
    if (index < 0 || index >= state.censusImages.length) return;
    final next = [...state.censusImages]..removeAt(index);
    state = state.copyWith(censusImages: next);
  }

  Future<bool> submit() async {
    if (state.isReadOnly || state.isSubmitting) return false;

    final validators = [
      fields.companyFormKey,
      fields.detailsFormKey,
      // Address list validation added when address CRUD is implemented.
    ];

    var firstInvalid = -1;
    for (var i = 0; i < validators.length; i++) {
      final valid = validators[i].currentState?.validate() ?? false;
      if (!valid && firstInvalid == -1) firstInvalid = i;
    }

    if (firstInvalid != -1) {
      state = state.copyWith(activeSectionIndex: firstInvalid);
      return false;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final form = PremiseFormMapper.fromPresentation(fields: fields, censusImages: state.censusImages);
      final repository = ref.read(premiseRepositoryProvider);
      final result = form.isUpdate ? await repository.submitUpdate(form) : await repository.submitCreate(form);

      if (result.pendingImageUploads > 0) {
        await repository.uploadPendingImages(
          visitNo: result.visitNo,
          form: form.copyWith(visitNo: result.visitNo),
        );
      }

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(isSubmitting: false);
      return false;
    }
  }
}

final premiseFormControllerProvider = NotifierProvider.family<PremiseFormController, PremiseFormState, PremiseFormMode>(
  PremiseFormController.new,
);

final premiseFormFieldsProvider = Provider.family<PremiseFormFields, PremiseFormMode>((ref, mode) {
  ref.watch(premiseFormControllerProvider(mode));
  return ref.read(premiseFormControllerProvider(mode).notifier).formFields;
});

/// Exposes the active [PremiseFormMode] to section widgets under [PremiseFormPage].
class PremiseFormScope extends InheritedWidget {
  const PremiseFormScope({super.key, required this.mode, required super.child});

  final PremiseFormMode mode;

  static PremiseFormMode of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PremiseFormScope>();
    assert(scope != null, 'PremiseFormScope not found in widget tree.');
    return scope!.mode;
  }

  @override
  bool updateShouldNotify(PremiseFormScope oldWidget) => mode != oldWidget.mode;
}
