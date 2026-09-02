import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/app/theme/app_theme.dart';
import 'package:ilms/shared/ui/home/home_module_button.dart';

void main() {
  testWidgets(
    'dark home tile sits on surfaceContainerHigh with a visible outline',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: HomeModuleButton(
              label: 'View All',
              icon: Icons.list_alt_outlined,
              accentColor: AppTheme.navy,
              onTap: () {},
            ),
          ),
        ),
      );

      final material = tester.widget<Material>(find.byType(Material).last);
      final cs = AppTheme.dark.colorScheme;
      expect(material.color, cs.surfaceContainerHigh);

      final shape = material.shape as RoundedRectangleBorder;
      expect(shape.side.color, cs.outlineVariant);
      expect(shape.side.width, greaterThan(0));
    },
  );

  testWidgets('dark home tile lifts a dark accent so the icon stays readable', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: HomeModuleButton(
            label: 'View All',
            icon: Icons.list_alt_outlined,
            accentColor: AppTheme.navy,
            onTap: () {},
          ),
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byIcon(Icons.list_alt_outlined));
    expect(icon.color, AppTheme.yellow);
  });
}
