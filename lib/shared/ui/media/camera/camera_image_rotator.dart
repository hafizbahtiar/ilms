import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:ilms/shared/ui/media/camera/camera_orientation.dart';
import 'package:image_editor/image_editor.dart';

/// Physically rotates a captured photo's pixels (not just its display
/// widget), so the file that ends up uploaded is actually upright —
/// mirroring legacy `PhotoEditor`, which bakes the rotation in via the same
/// `image_editor` package before the file is saved/uploaded.
class CameraImageRotator {
  const CameraImageRotator._();

  /// Rotates [file] 90° clockwise and writes the result to a new file —
  /// never overwrites [file] in place, since [Image.file] caches decoded
  /// frames by path and would otherwise keep showing the stale, unrotated
  /// image.
  static Future<File> rotateClockwise(File file) => _process(file, additionalDegrees: 90);

  /// Forces a just-captured photo into the same portrait shape the phone's
  /// screen is locked to, using the physical orientation the phone was
  /// actually held in at the moment of capture (from
  /// [CameraOrientationController], the same sensor reading that drives the
  /// control-icon rotation).
  ///
  /// `lockCaptureOrientation` on `CameraController` only promises the
  /// *metadata* is correct — on several devices it hands back a JPEG that is
  /// still physically landscape-shaped pixels (with or without a usable EXIF
  /// tag), so trusting it leaves the photo sideways in the review thumbnail,
  /// the full-screen viewer, and the backend upload alike. This instead
  /// takes the same rotation already proven to keep the on-screen icons
  /// upright (see [CameraDeviceOrientation.turns]) and bakes that same
  /// rotation directly into the photo's pixels — so a photo snapped while
  /// the phone was held sideways comes out portrait, as if it had been
  /// manually rotated upright.
  static Future<File> correctForCapture(File file, {required CameraDeviceOrientation capturedAt}) {
    return _process(file, additionalDegrees: degreesFor(capturedAt));
  }

  /// The clockwise rotation (0/90/180/270) that turns a photo snapped while
  /// the phone was physically held in [orientation] back into the portrait
  /// shape the locked screen expects.
  ///
  /// This is the *opposite* direction from the icon rotation
  /// (`CameraDeviceOrientation.turns`) — confirmed on-device: using the same
  /// direction as the icons produced a correctly-shaped but upside-down
  /// photo for both landscape orientations. The sensor's raw buffer and the
  /// on-screen UI apparently need the correction applied in opposite senses
  /// (a landscape-native sensor mounting is the likely reason), so don't
  /// "simplify" this back to matching `turns` without re-testing on a phone.
  @visibleForTesting
  static int degreesFor(CameraDeviceOrientation orientation) =>
      (360 - (orientation.turns * 360).round()) % 360;

  static Future<File> _process(File file, {required int additionalDegrees}) async {
    final bytes = await file.readAsBytes();

    final option = ImageEditorOption();
    if (additionalDegrees != 0) option.addOption(RotateOption(additionalDegrees));

    final processedBytes = await ImageEditor.editImage(image: bytes, imageEditorOption: option);
    if (processedBytes == null) return file;

    final outputFile = File('${file.path}-r${DateTime.now().microsecondsSinceEpoch}.jpg');
    await outputFile.writeAsBytes(processedBytes, flush: true);
    return outputFile;
  }
}
