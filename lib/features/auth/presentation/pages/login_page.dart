import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/auth/presentation/controllers/auth_state.dart';
import 'package:ilms/features/auth/presentation/pages/auth_home_page.dart';
import 'package:ilms/features/auth/presentation/providers/auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;

    ref
        .read(authControllerProvider.notifier)
        .login(email: _emailController.text.trim(), password: _passwordController.text);
  }

  void _onForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset link sent to your email.')));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.user != null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => AuthHomePage(user: next.user!)));
      }
    });

    final state = ref.watch(authControllerProvider);
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  _Logo(size: 150, backgroundColor: cs.primary.withValues(alpha: 0.1), ringColor: cs.secondary),
                  const SizedBox(height: 15),
                  Text(
                    'ILMS',
                    style: textTheme.headlineMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Welcome back, please sign in to continue.',
                    style: textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 10),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'you@example.com',
                              prefixIcon: Icon(Icons.email_outlined, color: cs.onSurface.withValues(alpha: 0.5)),
                            ),
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty) {
                                return 'Email is required.';
                              }
                              if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                                return 'Enter a valid email.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
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
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 20,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (v) => setState(() => _rememberMe = v ?? false),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text('Remember me'),
                                ],
                              ),
                              TextButton(onPressed: _onForgotPassword, child: const Text('Forgot password?')),
                            ],
                          ),
                          if (state.errorMessage != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              state.errorMessage!,
                              style: TextStyle(color: cs.error, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state.isLoading ? null : _onLogin,
                              child: state.isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2.2, color: cs.onPrimary),
                                    )
                                  : const Text('Login'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Demo: demo@ilms.com / password123',
                    style: TextStyle(fontSize: 12, color: cs.secondary.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
