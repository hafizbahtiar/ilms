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
        loadStateChanged: enableLoadState ? _loadStateChanged : null,
        printError: true,
      );
    }

    return brokenImage();
  }

  /// Always shows load/failure state — a silently blank thumbnail is
  /// indistinguishable from "no image" and impossible to diagnose.
  static Widget thumbnail(AppImageItem item, {BoxFit fit = BoxFit.cover}) {
    return extendedImage(item, fit: fit, enableLoadState: true);
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
