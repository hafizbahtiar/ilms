import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/investigation/presentation/controllers/investigation_form_state.dart';
import 'package:ilms/features/investigation/presentation/providers/investigation_form_providers.dart';
import 'package:ilms/features/investigation/presentation/sections/investigation_form_sections.dart';
import 'package:ilms/features/investigation/presentation/widgets/investigation_form_exit_sheet.dart';
import 'package:ilms/features/investigation/presentation/widgets/investigation_form_tab_bar.dart';
import 'package:ilms/features/investigation/presentation/widgets/investigation_section_header.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/layout/app_unfocus_on_tap.dart';

/// Single-scroll + sticky-tab-bar form, mirroring `PremiseFormPage`'s /
/// `BillboardFormPage`'s structure. Unlike billboard, investigation DOES
/// have offline drafts (edit-session Save & Exit) — legacy's real,
/// actively-used behavior — so back navigation offers a 3-way choice
/// instead of a plain confirm dialog.
class InvestigationFormPage extends ConsumerStatefulWidget {
  const InvestigationFormPage({super.key, required this.session});

  final InvestigationFormSession session;

  @override
  ConsumerState<InvestigationFormPage> createState() => _InvestigationFormPageState();
}

class _InvestigationFormPageState extends ConsumerState<InvestigationFormPage> {
  final _scrollController = ScrollController();
  final _tabScrollController = ScrollController();

  late final List<GlobalKey> _sectionKeys;
  late final List<GlobalKey> _tabKeys;

  List<double> _sectionOffsets = List.filled(investigationFormSections.length, double.nan);
  int _activeSectionIndex = 0;
  bool _offsetsReady = false;
  bool _programmaticScroll = false;
  bool _leaveConfirmed = false;

  static const _scrollAnchor = 24.0;

  InvestigationFormSession get _session => widget.session;

  @override
  void initState() {
    super.initState();
    _sectionKeys = [
      for (final section in investigationFormSections) GlobalKey(debugLabel: 'investigation_section_${section.id}'),
    ];
    _tabKeys = [
      for (final section in investigationFormSections) GlobalKey(debugLabel: 'investigation_tab_${section.id}'),
    ];

    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = ref.read(investigationFormControllerProvider(_session).notifier);
      final loaded = await controller.initialize(_session);
      if (!mounted) return;

      if (!loaded) {
        AppSnackbar.error(context, 'Failed to load investigation details.');
        _popForm();
        return;
      }

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
    if (index < 0 || index >= investigationFormSections.length) return;

    _programmaticScroll = true;
    setState(() => _activeSectionIndex = index);
    ref.read(investigationFormControllerProvider(_session).notifier).setActiveSection(index);
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
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _handleBack() async {
    if (_leaveConfirmed) return;

    FocusScope.of(context).unfocus();
    final formState = ref.read(investigationFormControllerProvider(_session));

    if (formState.isReadOnly || formState.isSubmitting || formState.isLoading) {
      _popForm();
      return;
    }

    final choice = await showInvestigationFormExitSheet(context, hasDraft: formState.isResumedFromDraft);
    if (!mounted || choice == null) return;

    final controller = ref.read(investigationFormControllerProvider(_session).notifier);
    switch (choice) {
      case InvestigationFormExitChoice.saveAndExit:
        await controller.saveDraft();
        if (!mounted) return;
        AppSnackbar.success(context, 'Draft saved.');
        _popForm();
      case InvestigationFormExitChoice.discardChanges:
        await controller.discardDraft();
        if (!mounted) return;
        _popForm();
      case InvestigationFormExitChoice.exitWithoutSaving:
        _popForm();
    }
  }

  Future<void> _onSubmit() async {
    FocusScope.of(context).unfocus();
    final controller = ref.read(investigationFormControllerProvider(_session).notifier);

    if (!controller.isMinutesValid) {
      AppSnackbar.warning(context, 'Please complete the Minit section before submitting.');
      return;
    }

    final ok = await controller.submit();
    if (!mounted) return;

    if (ok) {
      AppSnackbar.success(context, 'Investigation saved.');
      _popForm();
      return;
    }

    final error = controller.lastSubmitError;
    if (error != null) {
      AppSnackbar.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(investigationFormControllerProvider(_session));
    final cs = Theme.of(context).colorScheme;

    if (formState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator.adaptive()));
    }

    return PopScope(
      canPop: formState.isReadOnly || _leaveConfirmed,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _leaveConfirmed || formState.isReadOnly || formState.isSubmitting || formState.isLoading) {
          return;
        }
        await _handleBack();
      },
      child: InvestigationFormScope(
        session: _session,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Investigation'),
            centerTitle: false,
            actions: [
              if (formState.mode == InvestigationFormMode.view)
                TextButton(
                  onPressed: () => ref.read(investigationFormControllerProvider(_session).notifier).switchToEditMode(),
                  child: Text('Edit', style: TextStyle(color: cs.onPrimary)),
                ),
            ],
          ),
          body: AppUnfocusOnTap(
            child: SafeArea(
              child: Column(
                children: [
                  InvestigationFormTabBar(
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
                          for (var i = 0; i < investigationFormSections.length; i++) ...[
                            if (i > 0) const SizedBox(height: 28),
                            KeyedSubtree(
                              key: _sectionKeys[i],
                              child: InvestigationSectionHeader(title: investigationFormSections[i].headerTitle),
                            ),
                            investigationFormSections[i].builder(context),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: formState.isReadOnly
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.tertiary,
                        foregroundColor: cs.onTertiary,
                        disabledBackgroundColor: cs.tertiary.withValues(alpha: 0.38),
                        disabledForegroundColor: cs.onTertiary.withValues(alpha: 0.72),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: formState.isSubmitting ? null : _onSubmit,
                      child: formState.isSubmitting
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator.adaptive())
                          : const Text('Submit'),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
