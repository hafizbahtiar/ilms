import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_form_state.dart';
import 'package:ilms/features/premise/presentation/utils/premise_form_focus.dart';
import 'package:ilms/features/premise/presentation/providers/premise_form_providers.dart';
import 'package:ilms/features/premise/presentation/sections/premise_form_sections.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_form_exit_sheet.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_form_more_sheet.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_form_tab_bar.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_photo_upload_sheet.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_section_header.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_visit_status_sheet.dart';
import 'package:ilms/shared/ui/feedback/app_dialog.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';

class PremiseFormPage extends ConsumerStatefulWidget {
  const PremiseFormPage({super.key, required this.session});

  final PremiseFormSession session;

  @override
  ConsumerState<PremiseFormPage> createState() => _PremiseFormPageState();
}

class _PremiseFormPageState extends ConsumerState<PremiseFormPage> {
  final _scrollController = ScrollController();
  final _tabScrollController = ScrollController();

  late final List<GlobalKey> _sectionKeys;
  late final List<GlobalKey> _tabKeys;

  List<double> _sectionOffsets = List.filled(premiseFormSections.length, double.nan);
  int _activeSectionIndex = 0;
  bool _offsetsReady = false;
  bool _programmaticScroll = false;
  bool _leaveConfirmed = false;

  /// Guards against double-tapping Submit — `formState.isSubmitting` only
  /// covers the network call itself, not the visit-status sheet shown
  /// before it, so a fast second tap during that gap could otherwise start
  /// a second submit flow (a second visit-status sheet, a duplicate create).
  bool _isSubmitFlowActive = false;

  static const _scrollAnchor = 24.0;

  PremiseFormSession get _session => widget.session;

  @override
  void initState() {
    super.initState();
    _sectionKeys = [for (final section in premiseFormSections) GlobalKey(debugLabel: 'premise_section_${section.id}')];
    _tabKeys = [for (final section in premiseFormSections) GlobalKey(debugLabel: 'premise_tab_${section.id}')];

    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = ref.read(premiseFormControllerProvider(_session).notifier);
      final loaded = await controller.initialize(_session);
      if (!mounted) return;

      if (!loaded) {
        AppSnackbar.error(context, 'Failed to load premise details.');
        _popForm();
        return;
      }

      if (_session.isVacantIntent) {
        controller.markVacant();
      }

      // Measure section offsets only once the real content is in the tree —
      // scheduling this before initialize() resolves means it fires while
      // the page is still showing the loading spinner (no scroll view, no
      // section keys) for server-loaded sessions with a real network
      // round-trip, permanently leaving the tab bar's scroll-sync unusable
      // since nothing re-triggers the measurement afterward.
      _scheduleOffsetMeasure();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  void _scheduleOffsetMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshSectionOffsets();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _refreshSectionOffsets();
      });
    });
  }

  bool _areOffsetsValid(List<double> offsets) {
    if (offsets.isEmpty || offsets.first.isNaN) return false;
    var previous = offsets.first;
    for (var i = 1; i < offsets.length; i++) {
      final current = offsets[i];
      if (current.isNaN) return false;
      if (current <= previous) return false;
      previous = current;
    }
    return true;
  }

  void _refreshSectionOffsets() {
    if (!mounted || !_scrollController.hasClients) return;

    final offsets = List<double>.filled(_sectionKeys.length, double.nan);

    for (var i = 0; i < _sectionKeys.length; i++) {
      final sectionContext = _sectionKeys[i].currentContext;
      if (sectionContext == null) continue;

      final sectionBox = sectionContext.findRenderObject() as RenderBox?;
      if (sectionBox == null || !sectionBox.hasSize) continue;

      final viewport = RenderAbstractViewport.maybeOf(sectionBox);
      if (viewport == null) continue;

      offsets[i] = viewport.getOffsetToReveal(sectionBox, 0).offset;
    }

    final ready = _areOffsetsValid(offsets);
    setState(() {
      _sectionOffsets = offsets;
      _offsetsReady = ready;
    });
  }

  void _onScroll() {
    if (_programmaticScroll || !_offsetsReady) return;
    _syncActiveSectionFromScroll(animateTab: false);
  }

  int _indexForScrollOffset(double offset) {
    if (!_offsetsReady) return _activeSectionIndex;
    if (offset <= 4) return 0;

    final position = offset + _scrollAnchor;
    var index = 0;
    for (var i = 0; i < _sectionOffsets.length; i++) {
      final sectionOffset = _sectionOffsets[i];
      if (!sectionOffset.isNaN && sectionOffset <= position) {
        index = i;
      }
    }
    return index;
  }

  void _syncActiveSectionFromScroll({required bool animateTab}) {
    if (!_scrollController.hasClients || !_offsetsReady) return;

    final index = _indexForScrollOffset(_scrollController.offset);
    if (index == _activeSectionIndex) return;

    setState(() => _activeSectionIndex = index);
    _centerActiveTab(animated: animateTab);
  }

  void _centerActiveTab({required bool animated}) {
    if (!_tabScrollController.hasClients) return;

    final tabContext = _tabKeys[_activeSectionIndex].currentContext;
    if (tabContext == null) return;

    Scrollable.ensureVisible(
      tabContext,
      duration: animated ? const Duration(milliseconds: 260) : Duration.zero,
      curve: Curves.easeOutCubic,
      alignment: 0.5,
    );
  }

  Future<void> _jumpToSection(int index) async {
    if (index < 0 || index >= premiseFormSections.length) return;

    _programmaticScroll = true;
    setState(() => _activeSectionIndex = index);
    ref.read(premiseFormControllerProvider(_session).notifier).setActiveSection(index);
    _centerActiveTab(animated: true);

    _refreshSectionOffsets();

    final sectionContext = _sectionKeys[index].currentContext;
    if (sectionContext != null) {
      await Scrollable.ensureVisible(
        sectionContext,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        alignment: 0,
      );
    } else if (_offsetsReady && _scrollController.hasClients) {
      final maxExtent = _scrollController.position.maxScrollExtent;
      final targetOffset = _sectionOffsets[index].clamp(0.0, maxExtent);
      await _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    }

    if (!mounted) return;
    _programmaticScroll = false;
    _refreshSectionOffsets();
    _syncActiveSectionFromScroll(animateTab: false);
  }

  void _popForm() {
    if (_leaveConfirmed) return;
    setState(() => _leaveConfirmed = true);
    context.pop();
  }

  Future<void> _handleBack() async {
    if (_leaveConfirmed) return;

    FocusScope.of(context).unfocus();
    final formState = ref.read(premiseFormControllerProvider(_session));
    final controller = ref.read(premiseFormControllerProvider(_session).notifier);

    if (formState.isReadOnly || formState.isSubmitting || formState.isDraftLoading) {
      _popForm();
      return;
    }

    if (!controller.hasUnsavedChanges) {
      _popForm();
      return;
    }

    final isEditSession = formState.mode == PremiseFormMode.edit;
    final choice = await showPremiseFormExitSheet(
      context,
      showDeleteDraft: formState.localDraftId != null,
      isEditSession: isEditSession,
    ).unfocusPremiseFormOnComplete(context);
    if (!mounted || choice == null) return;

    switch (choice) {
      case PremiseFormExitChoice.saveAndExit:
        final ok = await controller.saveDraftOnExit();
        if (!mounted) return;
        if (ok) {
          _popForm();
        } else {
          AppSnackbar.error(context, 'Failed to save draft.');
        }
      case PremiseFormExitChoice.deleteDraft:
        await controller.deleteDraft();
        if (!mounted) return;
        AppSnackbar.success(context, isEditSession ? 'Changes discarded.' : 'Draft deleted.');
        _popForm();
      case PremiseFormExitChoice.exitWithoutSaving:
        _popForm();
    }
  }

  Future<void> _onSaveDraft() async {
    FocusScope.of(context).unfocus();
    final controller = ref.read(premiseFormControllerProvider(_session).notifier);

    if (!controller.hasUnsavedChanges) {
      AppSnackbar.info(context, 'No changes to save.');
      return;
    }

    final ok = await controller.saveDraft();
    if (!mounted) return;

    if (ok) {
      AppSnackbar.success(context, 'Draft saved.');
    } else {
      AppSnackbar.error(context, 'Failed to save draft.');
    }
  }

  Future<void> _onSubmit() async {
    if (_isSubmitFlowActive) return;
    setState(() => _isSubmitFlowActive = true);

    try {
      FocusScope.of(context).unfocus();
      final controller = ref.read(premiseFormControllerProvider(_session).notifier);

      final currentVisitStatus = ref.read(premiseFormControllerProvider(_session)).visitStatus;
      final visitStatus = await showPremiseVisitStatusSheet(
        context,
        ref,
        selectedCode: currentVisitStatus,
      ).unfocusPremiseFormOnComplete(context);
      if (!mounted || visitStatus == null) return;
      controller.selectVisitStatus(visitStatus);

      final ok = await controller.submit();
      if (!mounted) return;

      if (ok) {
        final outcome = controller.lastSubmitOutcome;
        var allUploaded = outcome == null || outcome.pendingImages.isEmpty;

        if (outcome != null && !allUploaded) {
          allUploaded = await showPremisePhotoUploadSheet(
            context,
            ref,
            visitNo: outcome.visitNo,
            process: outcome.process,
            allImages: outcome.allCensusImages,
          );
          if (!mounted) return;
        }

        // Only removes the draft from the resumable Drafts list once photos
        // actually finished — "Save as Draft" in the upload sheet leaves it
        // there, tied to the now-created premise record via its visitNo, so
        // resuming later retries just the photos instead of duplicating.
        await controller.finalizeSubmit(allUploaded: allUploaded);
        if (!mounted) return;

        if (allUploaded) {
          AppSnackbar.success(context, 'Premise census saved.');
        } else {
          AppSnackbar.warning(context, 'Saved as draft — some photos still need to upload. Resume it later to retry.');
        }
        _popForm();
        return;
      }

      final error = controller.lastSubmitError;
      if (error != null) {
        AppSnackbar.error(context, error);
        final sectionIndex = ref.read(premiseFormControllerProvider(_session)).activeSectionIndex;
        await _jumpToSection(sectionIndex);
        return;
      }
    } finally {
      if (mounted) setState(() => _isSubmitFlowActive = false);
    }
  }

  Future<void> _onMoreOptions() async {
    final choice = await showPremiseFormMoreSheet(context).unfocusPremiseFormOnComplete(context);
    if (!mounted || choice == null) return;

    switch (choice) {
      case PremiseFormMoreChoice.markVacant:
        await _confirmMarkVacant();
    }
  }

  Future<void> _confirmMarkVacant() async {
    final confirmed = await confirmAppDialog(
      context: context,
      title: 'Mark as vacant premise?',
      message:
          'Company, contact and trader fields will be set to N/A, and the address, business type and premise type '
          'will be cleared for you to fill in with the actual vacant unit details.',
      confirmLabel: 'Mark Vacant',
    ).unfocusPremiseFormOnComplete(context);
    if (!mounted || !confirmed) return;

    ref.read(premiseFormControllerProvider(_session).notifier).markVacant();
    AppSnackbar.success(context, 'Marked as vacant premise.');
  }

  Future<void> _onDiscardChanges() async {
    final confirmed = await confirmAppDialog(
      context: context,
      title: 'Discard unsaved changes?',
      message: 'Your local edits will be removed and this premise will reload its current saved version.',
      confirmLabel: 'Discard',
      confirmStyle: AppDialogActionStyle.destructive,
    ).unfocusPremiseFormOnComplete(context);
    if (!mounted || !confirmed) return;

    final controller = ref.read(premiseFormControllerProvider(_session).notifier);
    final ok = await controller.discardEditSession();
    if (!mounted) return;

    if (!ok) {
      AppSnackbar.error(context, 'Failed to discard changes.');
      return;
    }

    // The reload tears down and rebuilds the section widgets (same as the
    // initial load), so the tab bar's scroll-sync needs re-measuring —
    // otherwise it's left stuck exactly like the initial-load bug.
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    setState(() {
      _activeSectionIndex = 0;
      _offsetsReady = false;
    });
    _scheduleOffsetMeasure();

    AppSnackbar.success(context, 'Changes discarded.');
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(premiseFormControllerProvider(_session));
    final cs = Theme.of(context).colorScheme;

    if (formState.isDraftLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator.adaptive()));
    }

    return PopScope(
      canPop: formState.isReadOnly || _leaveConfirmed,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _leaveConfirmed || formState.isReadOnly || formState.isSubmitting || formState.isDraftLoading) {
          return;
        }
        await _handleBack();
      },
      child: PremiseFormScope(
        session: _session,
        child: Scaffold(
          appBar: AppBar(
            title: formState.mode == PremiseFormMode.edit && formState.localDraftId != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Premise Census'),
                      Text(
                        'Unsaved changes restored',
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: cs.onPrimary.withValues(alpha: 0.75)),
                      ),
                    ],
                  )
                : const Text('Premise Census'),
            centerTitle: false,
            actions: [
              if (!formState.isReadOnly)
                TextButton(
                  onPressed: formState.isDraftSaving ? null : _onSaveDraft,
                  child: formState.isDraftSaving
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator.adaptive(
                            valueColor: AlwaysStoppedAnimation<Color>(cs.onPrimary),
                          ),
                        )
                      : Text('Save', style: TextStyle(color: cs.onPrimary)),
                ),
              if (formState.mode == PremiseFormMode.view)
                TextButton(
                  onPressed: () => ref.read(premiseFormControllerProvider(_session).notifier).switchToEditMode(),
                  child: Text('Edit', style: TextStyle(color: cs.onPrimary)),
                ),
              if (!formState.isReadOnly) IconButton(onPressed: _onMoreOptions, icon: const Icon(Icons.more_vert)),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                PremiseFormTabBar(
                  activeIndex: _activeSectionIndex,
                  onTabSelected: _jumpToSection,
                  tabKeys: _tabKeys,
                  tabScrollController: _tabScrollController,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < premiseFormSections.length; i++) ...[
                          if (i > 0) const SizedBox(height: 28),
                          KeyedSubtree(
                            key: _sectionKeys[i],
                            child: PremiseSectionHeader(title: premiseFormSections[i].headerTitle),
                          ),
                          premiseFormSections[i].builder(context),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: formState.isReadOnly
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Row(
                      children: [
                        if (formState.mode == PremiseFormMode.edit && formState.localDraftId != null) ...[
                          // Row gives non-flex children an unbounded max-width
                          // constraint (only maxHeight is fixed) — a bare
                          // OutlinedButton here hits that and throws inside
                          // its own internal minimum-size ConstrainedBox.
                          // Flexible forces a real bounded width.
                          Flexible(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: cs.error,
                                side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
                              ),
                              onPressed: (formState.isSubmitting || _isSubmitFlowActive) ? null : _onDiscardChanges,
                              child: const Text('Discard'),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: cs.tertiary,
                              foregroundColor: cs.onTertiary,
                              disabledBackgroundColor: cs.tertiary.withValues(alpha: 0.38),
                              disabledForegroundColor: cs.onTertiary.withValues(alpha: 0.72),
                            ),
                            onPressed: (formState.isSubmitting || _isSubmitFlowActive) ? null : _onSubmit,
                            child: (formState.isSubmitting || _isSubmitFlowActive)
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator.adaptive())
                                : const Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
