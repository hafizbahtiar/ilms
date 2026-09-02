import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:ilms/core/network/dio_client.dart';
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
    Color? failedColor,
    String? failedAsset,
  }) {
    final gestureHandler = gestureConfig == null ? null : (_) => gestureConfig;
    final Widget? Function(ExtendedImageState)? loadStateChanged = enableLoadState
        ? (state) => _loadStateChanged(state, failedColor: failedColor, failedAsset: failedAsset, fit: fit)
        : null;

    if (item.bytes != null && item.bytes!.isNotEmpty) {
      return ExtendedImage.memory(
        item.bytes!,
        fit: fit,
        mode: mode,
        enableSlideOutPage: enableSlideOutPage,
        enableLoadState: enableLoadState,
        initGestureConfigHandler: gestureHandler,
        loadStateChanged: loadStateChanged,
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
          loadStateChanged: loadStateChanged,
        );
      }
    }

    if (item.networkUrl != null && item.networkUrl!.isNotEmpty) {
      // `/get-file/...` sits under the same host as the authenticated API,
      // so attach the bearer token defensively — ExtendedImage.network uses
      // its own HTTP client, not Dio's, and won't carry it otherwise. Sent
      // as an extra header on a request that may not require it, which is
      // harmless if the endpoint turns out to be unauthenticated.
      final token = DioClient.instance.accessToken;
      return ExtendedImage.network(
        item.networkUrl!,
        fit: fit,
        mode: mode,
        // Leave null unless the caller supplies one — extended_image_library
        // MD5-hashes the URL into a safe disk cache filename by default
        // (`keyToMd5(url)`), but takes any non-null cacheKey completely
        // literally. Defaulting this to the raw URL (as before) put
        // `https://…/get-file/UUID` straight into the cache file path,
        // which the filesystem read back as real `/` subdirectories that
        // were never created — every image failed with PathNotFoundException.
        cacheKey: cacheKey,
        headers: token == null || token.isEmpty ? null : {'Authorization': 'Bearer $token'},
        enableSlideOutPage: enableSlideOutPage,
        enableLoadState: enableLoadState,
        initGestureConfigHandler: gestureHandler,
        loadStateChanged: loadStateChanged,
        printError: true,
      );
    }

    return brokenImage(background: failedColor);
  }

  /// Always shows load/failure state — a silently blank thumbnail is
  /// indistinguishable from "no image" and impossible to diagnose.
  ///
  /// [failedColor] overrides the failure state's background (default dark
  /// grey) — e.g. a per-item color so a broken thumbnail still reads as
  /// "this item" instead of a uniform grey box everywhere.
  static Widget thumbnail(
    AppImageItem item, {
    BoxFit fit = BoxFit.cover,
    Color? failedColor,
    String? failedAsset,
  }) {
    return extendedImage(item, fit: fit, enableLoadState: true, failedColor: failedColor, failedAsset: failedAsset);
  }

  static Widget? _loadStateChanged(
    ExtendedImageState state, {
    Color? failedColor,
    String? failedAsset,
    BoxFit fit = BoxFit.cover,
  }) {
    return switch (state.extendedImageLoadState) {
      LoadState.loading => const Center(child: CircularProgressIndicator.adaptive()),
      LoadState.failed => failedAsset != null
          ? Image.asset(failedAsset, fit: fit, width: double.infinity, height: double.infinity)
          : failedColor != null
          ? ColoredBox(color: failedColor)
          : _RetryableBrokenImage(onRetry: state.reLoadImage),
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

class _RetryableBrokenImage extends StatelessWidget {
  const _RetryableBrokenImage({required this.onRetry});

  final void Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF2A2A2A),
      child: Center(
        child: InkWell(
          onTap: onRetry,
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded, color: Colors.white70, size: 22),
                SizedBox(height: 2),
                Icon(Icons.broken_image_outlined, color: Colors.white38, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
