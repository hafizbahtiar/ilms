import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/domain/entities/premise_census_image.dart';
import 'package:ilms/features/premise/domain/exceptions/premise_exception.dart';
import 'package:ilms/features/premise/presentation/utils/premise_form_focus.dart';
import 'package:ilms/features/premise/presentation/providers/premise_providers.dart';
import 'package:ilms/shared/models/app_image_item.dart';
import 'package:ilms/shared/ui/media/app_image_source.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';

enum _UploadTaskStatus { pending, uploading, success, failed }

/// One locally captured census photo queued for `/create-photo`.
class _UploadTask {
  _UploadTask({required this.image, required this.typeCode, required this.seq});

  final PremiseCensusImage image;
  final String typeCode;
  final int seq;

  _UploadTaskStatus status = _UploadTaskStatus.pending;
  double progress = 0;
  String? error;

  double get displayProgress => switch (status) {
    _UploadTaskStatus.success => 1,
    // Dio send-progress reaches 1.0 once bytes leave the device — reserve the
    // last ~12% for the server round-trip so the bar only hits 100% on success.
    _UploadTaskStatus.uploading => (progress * 0.88).clamp(0, 0.88),
    _UploadTaskStatus.pending => 0,
    _UploadTaskStatus.failed => progress.clamp(0, 0.88),
  };

  int get displayPercent => switch (status) {
    _UploadTaskStatus.success => 100,
    _UploadTaskStatus.uploading => (displayProgress * 100).round().clamp(0, 99),
    _UploadTaskStatus.pending => 0,
    _UploadTaskStatus.failed => (displayProgress * 100).round(),
  };

  bool get isDone => status == _UploadTaskStatus.success;

  PremiseCensusImage get payloadImage => image.copyWith(typeCode: typeCode, uploadSeq: seq);

  String get label => '$typeCode  #$seq';
}

/// Builds upload tasks from the full census image list.
///
/// Mirrors legacy `PremisPhotoUploadController.initTasks`: seq is counted per
/// `type` across ALL images (including already-uploaded server photos) so new
/// local photos continue the sequence instead of colliding with the server.
/// Resumed drafts that already have [PremiseCensusImage.uploadSeq] keep it.
List<_UploadTask> _buildUploadTasks(List<PremiseCensusImage> allImages) {
  final seqByType = <String, int>{};
  final tasks = <_UploadTask>[];

  for (final image in allImages) {
    final typeCode = _resolveTypeCode(image);

    if (image.isLocalOnly && image.localPath != null) {
      final seq = image.uploadSeq ?? seqByType[typeCode] ?? 0;
      tasks.add(_UploadTask(image: image, typeCode: typeCode, seq: seq));
      seqByType[typeCode] = seq + 1;
      continue;
    }

    // Server image — no upload task, but it occupies the next seq slot.
    final nextSeq = seqByType[typeCode] ?? 0;
    seqByType[typeCode] = nextSeq + 1;
  }

  return tasks;
}

String _resolveTypeCode(PremiseCensusImage image) {
  final code = image.typeCode?.trim();
  if (code != null && code.isNotEmpty) return code;
  return PremiseCensusImageDefaults.typeCode;
}

/// Drives one upload run — shared between the sheet header, photo list, and
/// pinned action bar (legacy `PremisPhotoUploadController`).
class _PhotoUploadController extends ChangeNotifier {
  _PhotoUploadController({
    required this.ref,
    required this.visitNo,
    required this.process,
    required List<PremiseCensusImage> allImages,
  }) : tasks = _buildUploadTasks(allImages);

  final WidgetRef ref;
  final String visitNo;
  final String process;
  final List<_UploadTask> tasks;
  var isUploading = false;

  int get completedCount => tasks.where((t) => t.isDone).length;
  bool get allSuccess => tasks.isNotEmpty && tasks.every((t) => t.isDone);
  bool get isBusy => isUploading || tasks.any((t) => t.status == _UploadTaskStatus.uploading);

  double get overallProgress {
    if (tasks.isEmpty) return 0;
    final sum = tasks.fold<double>(0, (acc, t) => acc + t.displayProgress);
    return sum / tasks.length;
  }

  Future<void> uploadAll() async {
    if (isBusy || tasks.isEmpty) return;
    isUploading = true;
    notifyListeners();

    for (final task in tasks) {
      if (task.isDone) continue;
      await _uploadTask(task);
    }

    isUploading = false;
    notifyListeners();
  }

  Future<void> retryTask(_UploadTask task) async {
    if (task.isDone || isBusy) return;
    await _uploadTask(task);
  }

  Future<void> _uploadTask(_UploadTask task) async {
    task.status = _UploadTaskStatus.uploading;
    task.progress = 0;
    task.error = null;
    notifyListeners();

    try {
      await ref.read(premiseRepositoryProvider).uploadImage(
            visitNo: visitNo,
            image: task.payloadImage,
            process: process,
            onProgress: (p) {
              task.progress = p;
              notifyListeners();
            },
          );
      await _markSuccess(task);
    } catch (e, st) {
      if (_isAlreadyUploadedError(e, typeCode: task.typeCode, seq: task.seq)) {
        dev.log(
          'Already on server [${task.typeCode}#${task.seq}], treating as success',
          name: 'PremisePhotoUpload',
        );
        await _markSuccess(task);
      } else {
        dev.log(
          'Photo upload failed [${task.typeCode}#${task.seq}]: $e',
          name: 'PremisePhotoUpload',
          error: e,
          stackTrace: st,
        );
        task.status = _UploadTaskStatus.failed;
        task.error = e is PremiseException ? e.message : e.toString();
      }
    }
    notifyListeners();
  }

  Future<void> _markSuccess(_UploadTask task) async {
    task.status = _UploadTaskStatus.success;
    task.progress = 1;
    task.error = null;
  }

  /// True when the server reports this exact type+seq already exists — the
  /// photo was saved by a prior attempt (e.g. client timeout after success).
  static bool _isAlreadyUploadedError(Object error, {required String typeCode, required int seq}) {
    final msg = error is PremiseException ? error.message : error.toString();
    if (msg.isEmpty) return false;

    final lower = msg.toLowerCase();
    if (!lower.contains('already exists')) return false;

    final seqMatch = RegExp('sequence +$seq\\b', caseSensitive: false).hasMatch(lower);
    final typeMatch = RegExp(
      'type +${RegExp.escape(typeCode.toLowerCase())}\\b',
      caseSensitive: false,
    ).hasMatch(lower);
    return seqMatch && typeMatch;
  }
}

/// Non-dismissible sheet that uploads census photos one-by-one after submit,
/// showing per-image progress and a retry action for any that fail (legacy
/// `PremisPhotoUploadSheet`). Returns `true` once every photo is uploaded,
/// or `false` if the user finishes with some still failed/pending.
///
/// [allImages] must include both server and local photos so seq numbers for
/// new uploads continue past photos already on the server (edit mode).
Future<bool> showPremisePhotoUploadSheet(
  BuildContext context,
  WidgetRef ref, {
  required String visitNo,
  required String process,
  required List<PremiseCensusImage> allImages,
}) {
  final controller = _PhotoUploadController(
    ref: ref,
    visitNo: visitNo,
    process: process,
    allImages: allImages,
  );

  if (controller.tasks.isEmpty) {
    controller.dispose();
    return Future.value(true);
  }

  WidgetsBinding.instance.addPostFrameCallback((_) => controller.uploadAll());

  return showAppBottomSheet<bool>(
    context: context,
    preset: AppBottomSheetPreset.scrollable,
    isDismissible: false,
    enableDrag: false,
    showCloseButton: false,
    header: ListenableBuilder(
      listenable: controller,
      builder: (context, _) => _UploadHeader(
        completed: controller.completedCount,
        total: controller.tasks.length,
        progress: controller.overallProgress,
      ),
    ),
    bottomBar: ListenableBuilder(
      listenable: controller,
      builder: (context, _) => _UploadActions(controller: controller),
    ),
    builder: (context, scrollController) {
      return ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return ListView.separated(
            controller: scrollController,
            itemCount: controller.tasks.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final task = controller.tasks[index];
              return _PhotoRow(
                key: ValueKey('${task.typeCode}_${task.seq}_${task.image.localPath}'),
                task: task,
                isBusy: controller.isBusy,
                onRetry: () => controller.retryTask(task),
              );
            },
          );
        },
      );
    },
  ).then((value) {
    controller.dispose();
    if (context.mounted) unfocusPremiseForm(context);
    return value ?? false;
  });
}

class _UploadHeader extends StatelessWidget {
  const _UploadHeader({required this.completed, required this.total, required this.progress});

  final int completed;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Uploading Photos', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(
                '$completed/$total',
                style: textTheme.labelLarge?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: cs.surfaceContainerHighest,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                style: textTheme.labelSmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UploadActions extends StatelessWidget {
  const _UploadActions({required this.controller});

  final _PhotoUploadController controller;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.55)))),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          child: _content(context),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    if (controller.allSuccess) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Done'),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: controller.isBusy
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(child: Text('Please wait, uploading…')),
                )
              : FilledButton.icon(
                  onPressed: controller.uploadAll,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry Failed'),
                ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: controller.isBusy ? null : () => Navigator.of(context).pop(false),
            child: const Text('Save as Draft'),
          ),
        ),
      ],
    );
  }
}

class _PhotoRow extends StatefulWidget {
  const _PhotoRow({super.key, required this.task, required this.isBusy, required this.onRetry});

  final _UploadTask task;
  final bool isBusy;
  final VoidCallback onRetry;

  @override
  State<_PhotoRow> createState() => _PhotoRowState();
}

class _PhotoRowState extends State<_PhotoRow> {
  // Thumbnail path is stable for a row — avoid rebuilding the image provider
  // on every Dio progress tick (same rationale as legacy _PhotoRow).
  late final AppImageItem _thumbnail = AppImageItem(localPath: widget.task.image.localPath);

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 44,
            height: 44,
            child: AppImageSource.thumbnail(_thumbnail),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              if (task.status == _UploadTaskStatus.failed)
                Text(
                  task.error ?? 'Upload failed',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(color: cs.error),
                )
              else
                TweenAnimationBuilder<double>(
                  tween: Tween(end: task.displayProgress),
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  builder: (context, value, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: value,
                            minHeight: 4,
                            backgroundColor: cs.surfaceContainerHighest,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${(value * 100).round()}%',
                          style: textTheme.labelSmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.55),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _statusIcon(context),
      ],
    );
  }

  Widget _statusIcon(BuildContext context) {
    final task = widget.task;
    final cs = Theme.of(context).colorScheme;

    return switch (task.status) {
      _UploadTaskStatus.success => Icon(Icons.check_circle, color: Colors.green.shade600, size: 22),
      _UploadTaskStatus.failed => IconButton(
        icon: Icon(Icons.error, color: cs.error, size: 22),
        tooltip: 'Retry this photo',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: widget.isBusy ? null : widget.onRetry,
      ),
      _UploadTaskStatus.uploading => SizedBox(
        width: 28,
        height: 28,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
          ),
        ),
      ),
      _UploadTaskStatus.pending => Icon(Icons.schedule, color: cs.onSurface.withValues(alpha: 0.35), size: 22),
    };
  }
}
