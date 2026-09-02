import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/investigation/presentation/controllers/investigation_form_controller.dart';
import 'package:ilms/features/investigation/presentation/controllers/investigation_form_state.dart';

export 'package:ilms/features/investigation/presentation/controllers/investigation_form_controller.dart';

final investigationFormControllerProvider =
    NotifierProvider.family<InvestigationFormController, InvestigationFormState, InvestigationFormSession>(
      InvestigationFormController.new,
    );

final investigationFormFieldsProvider = Provider.family<InvestigationFormFields, InvestigationFormSession>((
  ref,
  session,
) {
  ref.watch(investigationFormControllerProvider(session));
  return ref.read(investigationFormControllerProvider(session).notifier).formFields;
});

class InvestigationFormScope extends InheritedWidget {
  const InvestigationFormScope({super.key, required this.session, required super.child});

  final InvestigationFormSession session;

  static InvestigationFormSession of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<InvestigationFormScope>();
    assert(scope != null, 'InvestigationFormScope not found in widget tree.');
    return scope!.session;
  }

  @override
  bool updateShouldNotify(InvestigationFormScope oldWidget) => session != oldWidget.session;
}
