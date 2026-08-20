import 'package:flutter/material.dart';

enum PasswordStrength { weak, fair, good, strong }

final _upperRegExp = RegExp(r'[A-Z]');
final _lowerRegExp = RegExp(r'[a-z]');
final _digitRegExp = RegExp(r'[0-9]');
final _symbolRegExp = RegExp(r'[^A-Za-z0-9]');

PasswordStrength passwordStrength(String password) {
  var score = 0;
  if (password.length >= 8) score++;
  if (_upperRegExp.hasMatch(password)) score++;
  if (_lowerRegExp.hasMatch(password)) score++;
  if (_digitRegExp.hasMatch(password)) score++;
  if (_symbolRegExp.hasMatch(password)) score++;

  if (score >= 5) return PasswordStrength.strong;
  if (score >= 3) return PasswordStrength.good;
  if (score == 2) return PasswordStrength.fair;
  return PasswordStrength.weak;
}

const _metColor = Color(0xFF2E7D32);

class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({super.key, required this.password});

  final String password;

  static const _segments = 4;

  @override
  Widget build(BuildContext context) {
    final strength = passwordStrength(password);
    final isEmpty = password.isEmpty;

    final activeSegments = switch (strength) {
      PasswordStrength.weak => 1,
      PasswordStrength.fair => 2,
      PasswordStrength.good => 3,
      PasswordStrength.strong => 4,
    };

    final color = switch (strength) {
      PasswordStrength.weak => const Color(0xFFD32F2F),
      PasswordStrength.fair => const Color(0xFFF57C00),
      PasswordStrength.good => const Color(0xFFF9A825),
      PasswordStrength.strong => _metColor,
    };

    final label = switch (strength) {
      PasswordStrength.weak => 'Weak',
      PasswordStrength.fair => 'Fair',
      PasswordStrength.good => 'Good',
      PasswordStrength.strong => 'Strong',
    };

    return Row(
      children: [
        for (var i = 0; i < _segments; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 4,
              decoration: BoxDecoration(
                color: isEmpty || i >= activeSegments ? Theme.of(context).colorScheme.outlineVariant : color,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          if (i < _segments - 1) const SizedBox(width: 4),
        ],
        const SizedBox(width: 10),
        SizedBox(
          width: 48,
          child: isEmpty
              ? const SizedBox.shrink()
              : Text(
                  label,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
                ),
        ),
      ],
    );
  }
}

class PasswordRequirements extends StatelessWidget {
  const PasswordRequirements({super.key, required this.password, required this.currentPassword});

  final String password;
  final String currentPassword;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final requirements = <(String, bool)>[
      ('At least 8 characters', password.length >= 8),
      ('An uppercase letter (A-Z)', _upperRegExp.hasMatch(password)),
      ('A lowercase letter (a-z)', _lowerRegExp.hasMatch(password)),
      ('A number (0-9)', _digitRegExp.hasMatch(password)),
      ('A symbol (!@#\$%)', _symbolRegExp.hasMatch(password)),
      ('Different from current password', password.isNotEmpty && password != currentPassword),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password must include:',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          for (final (label, met) in requirements)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      met ? Icons.check_circle : Icons.circle_outlined,
                      key: ValueKey(met),
                      size: 16,
                      color: met ? _metColor : cs.outline,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: textTheme.bodySmall?.copyWith(
                        color: met ? _metColor : cs.onSurface.withValues(alpha: 0.6),
                        fontWeight: met ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
