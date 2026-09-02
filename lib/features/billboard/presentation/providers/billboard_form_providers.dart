import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/billboard/presentation/controllers/billboard_form_controller.dart';
import 'package:ilms/features/billboard/presentation/controllers/billboard_form_state.dart';

export 'package:ilms/features/billboard/presentation/controllers/billboard_form_controller.dart';

final billboardFormControllerProvider =
    NotifierProvider.family<BillboardFormController, BillboardFormState, BillboardFormSession>(
      BillboardFormController.new,
    );

final billboardFormFieldsProvider = Provider.family<BillboardFormFields, BillboardFormSession>((ref, session) {
  ref.watch(billboardFormControllerProvider(session));
  return ref.read(billboardFormControllerProvider(session).notifier).formFields;
});

class BillboardFormScope extends InheritedWidget {
  const BillboardFormScope({super.key, required this.session, required super.child});

  final BillboardFormSession session;

  static BillboardFormSession of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<BillboardFormScope>();
    assert(scope != null, 'BillboardFormScope not found in widget tree.');
    return scope!.session;
  }

  @override
  bool updateShouldNotify(BillboardFormScope oldWidget) => session != oldWidget.session;
}
