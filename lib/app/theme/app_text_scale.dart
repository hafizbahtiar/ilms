import 'package:flutter/material.dart';
import 'package:ilms/app/theme/text_scale.dart';

double combinedTextScale({required double appFactor, required double osFactor}) {
  return (appFactor * osFactor).clamp(0.8, 1.6);
}

/// Applies the OS accessibility multiplier. The in-app preset is baked into
/// [AppTheme] via [AppTypography.scale] so Google Fonts text styles scale
/// together with the rest of the theme.
double mediaTextScaleFactor({required double appFactor, required double osFactor}) {
  if (appFactor <= 0) return combinedTextScale(appFactor: appFactor, osFactor: osFactor);
  return combinedTextScale(appFactor: appFactor, osFactor: osFactor) / appFactor;
}

Widget wrapWithTextScale({required AppTextScale appScale, required Widget child, MediaQueryData? mediaQuery}) {
  final mq = mediaQuery ?? MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first);
  final appFactor = appTextScaleFactor(appScale);
  final osFactor = mq.textScaler.scale(1.0);
  final factor = mediaTextScaleFactor(appFactor: appFactor, osFactor: osFactor);
  return MediaQuery(
    data: mq.copyWith(textScaler: TextScaler.linear(factor)),
    child: child,
  );
}
