import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:ilms/shared/models/app_image_item.dart';

/// Builds [ExtendedImage] (or a fallback) from an [AppImageItem].
class AppImageSource {
  AppImageSource._();

  static Widget extendedImage(
    AppImageItem item, {
    BoxFit fit = BoxFit.contain,
    ExtendedImageMode mode = ExtendedImageMode.none,
    GestureConfig? gestureConfig,
    String? cacheKey,
    bool enableLoadState = true,
    bool enableSlideOutPage = false,
  }) {
    final gestureHandler = gestureConfig == null ? null : (_) => gestureConfig;

    if (item.bytes != null && item.bytes!.isNotEmpty) {
      return ExtendedImage.memory(
        item.bytes!,
        fit: fit,
        mode: mode,
        enableSlideOutPage: enableSlideOutPage,
        enableLoadState: enableLoadState,
        initGestureConfigHandler: gestureHandler,
        loadStateChanged: enableLoadState ? _loadStateChanged : null,
      );
    }

    if (item.localPath != null && item.localPath!.isNotEmpty) {
      final file = File(item.localPath!);
      if (file.existsSync()) {
        return ExtendedImage.file(
          file,
          fit: fit,
          mode: mode,
          enableSlideOutPage: enableSlideOutPage,
          enableLoadState: enableLoadState,
          initGestureConfigHandler: gestureHandler,
          loadStateChanged: enableLoadState ? _loadStateChanged : null,
        );
      }
    }

    if (item.networkUrl != null && item.networkUrl!.isNotEmpty) {
      return ExtendedImage.network(
        item.networkUrl!,
        fit: fit,
        mode: mode,
        cacheKey: cacheKey ?? item.networkUrl,
        enableSlideOutPage: enableSlideOutPage,
        enableLoadState: enableLoadState,
        initGestureConfigHandler: gestureHandler,
        loadStateChanged: enableLoadState ? _loadStateChanged : null,
      );
    }

    return brokenImage();
  }

  static Widget thumbnail(AppImageItem item, {BoxFit fit = BoxFit.cover}) {
    return extendedImage(item, fit: fit, enableLoadState: false);
  }

  static Widget? _loadStateChanged(ExtendedImageState state) {
    return switch (state.extendedImageLoadState) {
      LoadState.loading => const Center(child: CircularProgressIndicator.adaptive()),
      LoadState.failed => brokenImage(),
      LoadState.completed => null,
    };
  }

  static Widget brokenImage({Color? background}) {
    return ColoredBox(
      color: background ?? const Color(0xFF2A2A2A),
      child: const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white54, size: 40)),
    );
  }
}
