import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_form_controller.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_form_state.dart';

export 'package:ilms/features/premise/presentation/controllers/premise_form_controller.dart';

final premiseFormControllerProvider =
    NotifierProvider.family<PremiseFormController, PremiseFormState, PremiseFormSession>(PremiseFormController.new);

final premiseFormFieldsProvider = Provider.family<PremiseFormFields, PremiseFormSession>((ref, session) {
  ref.watch(premiseFormControllerProvider(session));
  return ref.read(premiseFormControllerProvider(session).notifier).formFields;
});

class PremiseFormScope extends InheritedWidget {
  const PremiseFormScope({super.key, required this.session, required super.child});

  final PremiseFormSession session;

  static PremiseFormSession of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PremiseFormScope>();
    assert(scope != null, 'PremiseFormScope not found in widget tree.');
    return scope!.session;
  }

  @override
  bool updateShouldNotify(PremiseFormScope oldWidget) => session != oldWidget.session;
}
