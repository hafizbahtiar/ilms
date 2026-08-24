import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Full-screen in-app browser for flows the backend serves as a hosted web
/// page (forgot password, terms, external links) instead of a native form.
///
/// Improvements over the legacy `ForgotPasswordWebview` this replaces:
/// themed (no hardcoded black/white), a real error state with retry instead
/// of a silently blank page, a manual reload action, and the
/// "close automatically when navigation leaves the flow" behavior is a
/// reusable [closeWhenUrlDoesNotContain] parameter instead of a hardcoded
/// `"forgot-password"` string — any caller can reuse this page for its own
/// hosted-web flow.
class AppWebViewPage extends StatefulWidget {
  const AppWebViewPage({super.key, required this.url, required this.title, this.closeWhenUrlDoesNotContain});

  final String url;
  final String title;

  /// If set, any navigation (including redirects) to a URL that does NOT
  /// contain this substring closes the page automatically — e.g. the
  /// backend's forgot-password page redirects elsewhere once the flow
  /// completes, which is this page's signal to hand control back.
  final String? closeWhenUrlDoesNotContain;

  static Future<T?> open<T>(
    BuildContext context, {
    required String url,
    required String title,
    String? closeWhenUrlDoesNotContain,
  }) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        fullscreenDialog: true,
        opaque: true,
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) =>
            AppWebViewPage(url: url, title: title, closeWhenUrlDoesNotContain: closeWhenUrlDoesNotContain),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<AppWebViewPage> createState() => _AppWebViewPageState();
}

class _AppWebViewPageState extends State<AppWebViewPage> {
  late final WebViewController _controller;
  int _progress = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) => setState(() => _progress = progress),
          onPageStarted: (url) {
            setState(() => _errorMessage = null);
            _closeIfLeftFlow(url);
          },
          onPageFinished: (_) => setState(() => _progress = 100),
          onNavigationRequest: (request) {
            final needle = widget.closeWhenUrlDoesNotContain;
            if (needle != null && !request.url.contains(needle)) {
              Navigator.of(context).pop();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (change) {
            final url = change.url;
            if (url != null) _closeIfLeftFlow(url);
          },
          onWebResourceError: (error) {
            // Ignore subresource failures (a missing tracking pixel etc.) —
            // only the main document failing to load is worth blocking on.
            if (error.isForMainFrame == false) return;
            setState(() => _errorMessage = error.description);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _closeIfLeftFlow(String url) {
    final needle = widget.closeWhenUrlDoesNotContain;
    if (needle == null || url.contains(needle)) return;
    if (mounted) Navigator.of(context).pop();
  }

  void _reload() {
    setState(() => _errorMessage = null);
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLoading = _progress > 0 && _progress < 100;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [IconButton(onPressed: _reload, icon: const Icon(Icons.refresh_rounded), tooltip: 'Reload')],
        bottom: isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _progress / 100,
                  minHeight: 3,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(cs.secondary),
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_errorMessage != null) _WebViewErrorState(message: _errorMessage!, onRetry: _reload, cs: cs),
            if (isLoading && _errorMessage == null)
              ColoredBox(
                color: cs.surface,
                child: const Center(child: CircularProgressIndicator.adaptive()),
              ),
          ],
        ),
      ),
    );
  }
}

class _WebViewErrorState extends StatelessWidget {
  const _WebViewErrorState({required this.message, required this.onRetry, required this.cs});

  final String message;
  final VoidCallback onRetry;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: cs.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 40, color: cs.onSurface.withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              Text(
                'Unable to load this page.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
