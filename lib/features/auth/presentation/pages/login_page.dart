import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/app/theme/theme_mode_controller.dart';
import 'package:ilms/core/config/app_flavor.dart';
import 'package:ilms/features/auth/presentation/providers/auth_providers.dart';
import 'package:ilms/flavors.dart' as flavors;
import 'package:ilms/shared/ui/controls/environment_switcher.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;

    ref
        .read(authControllerProvider.notifier)
        .login(username: _usernameController.text.trim(), password: _passwordController.text);
  }

  void _onForgotPassword() {
    AppSnackbar.info(context, 'Reset link sent to your email.');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: _Logo(
                          size: 120,
                          backgroundColor: cs.primary.withValues(alpha: 0.1),
                          ringColor: cs.secondary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'ILMS',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Welcome back, please sign in to continue.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                      ),
                      const SizedBox(height: 28),
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _usernameController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'Username',
                                hintText: 'admin',
                                prefixIcon: Icon(Icons.person_outline, color: cs.onSurface.withValues(alpha: 0.5)),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Username is required.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _onLogin(),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline, color: cs.onSurface.withValues(alpha: 0.5)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: cs.onSurface.withValues(alpha: 0.5),
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required.';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          onChanged: (v) => setState(() => _rememberMe = v ?? false),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Flexible(child: Text('Remember me', overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: _onForgotPassword,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    minimumSize: Size.zero,
                                  ),
                                  child: const Text('Forgot password?'),
                                ),
                              ],
                            ),
                            if (state.errorMessage != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                state.errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: cs.error, fontWeight: FontWeight.w500),
                              ),
                            ],
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: state.isLoading ? null : _onLogin,
                                child: state.isLoading
                                    ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator.adaptive())
                                    : const Text('Login'),
                              ),
                            ),
                            if (AppFlavor.fromName(flavors.appFlavor) != AppFlavor.prod) ...[
                              const SizedBox(height: 16),
                              const EnvironmentSwitcher(),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: cs.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Demo: admin / admin123456',
                            style: TextStyle(fontSize: 12, color: cs.secondary.withValues(alpha: 0.9)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(top: 8, right: 8, child: _ThemeModeMenu(iconColor: cs.onSurface)),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeMenu extends ConsumerWidget {
  const _ThemeModeMenu({required this.iconColor});

  final Color iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeModeControllerProvider);

    return IconButton(
      onPressed: () => _showThemeBottomSheet(context, ref),
      icon: Icon(_themeModeIcon(current)),
      tooltip: 'Theme',
    );
  }

  Future<void> _showThemeBottomSheet(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(themeModeControllerProvider.notifier);
    final current = ref.read(themeModeControllerProvider);

    await showAppBottomSheet<void>(
      context: context,
      preset: AppBottomSheetPreset.compact,
      title: 'Theme',
      subtitle: 'Choose how the app looks',
      itemCount: themeModeOptions().length,
      builder: (context, scrollController) {
        return RadioGroup<ThemeMode>(
          groupValue: current,
          onChanged: (selected) {
            if (selected != null) {
              controller.setMode(selected);
              Navigator.of(context).pop();
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final mode in themeModeOptions())
                RadioListTile<ThemeMode>(
                  value: mode,
                  secondary: Icon(_themeModeIcon(mode)),
                  title: Text(themeModeLabel(mode)),
                ),
            ],
          ),
        );
      },
    );
  }

  IconData _themeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
    }
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.size, required this.backgroundColor, required this.ringColor});

  final double size;
  final Color backgroundColor;
  final Color ringColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: 2),
      ),
      alignment: Alignment.center,
      child: ClipOval(
        child: Image.asset(
          'assets/logo.png',
          width: size * 0.56,
          height: size * 0.56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Icon(Icons.apps_sharp, size: size * 0.42, color: ringColor),
        ),
      ),
    );
  }
}
