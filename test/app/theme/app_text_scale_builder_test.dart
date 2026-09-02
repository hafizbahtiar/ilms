import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/app/theme/app_text_scale.dart';
import 'package:ilms/app/theme/text_scale.dart';

void main() {
  test('combinedTextScale multiplies and clamps', () {
    expect(combinedTextScale(appFactor: 1.15, osFactor: 1.5), 1.6);
    expect(combinedTextScale(appFactor: 0.85, osFactor: 0.5), 0.8);
    expect(combinedTextScale(appFactor: 1.0, osFactor: 1.2), 1.2);
  });

  test('mediaTextScaleFactor applies only the OS portion', () {
    expect(mediaTextScaleFactor(appFactor: 1.15, osFactor: 1.2), closeTo(1.2, 0.001));
    expect(mediaTextScaleFactor(appFactor: 1.0, osFactor: 1.3), 1.3);
  });

  testWidgets('wrapWithTextScale applies OS TextScaler to descendants', (tester) async {
    late TextScaler captured;
    const mediaQuery = MediaQueryData(textScaler: TextScaler.linear(1.2));
    await tester.pumpWidget(
      MediaQuery(
        data: mediaQuery,
        child: wrapWithTextScale(
          appScale: AppTextScale.large,
          mediaQuery: mediaQuery,
          child: Builder(
            builder: (context) {
              captured = MediaQuery.textScalerOf(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(captured.scale(14), closeTo(14 * 1.2, 0.01));
  });
}
