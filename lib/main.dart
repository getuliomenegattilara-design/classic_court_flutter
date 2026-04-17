import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:local_auth/local_auth.dart';
import 'package:share_plus/share_plus.dart';

const String _homeUrl =
    'https://getuliomenegattilara-design.github.io/ClassicCourt/login.html';

const Map<String, String> _noCache = {
  'Cache-Control': 'no-cache, no-store, must-revalidate',
  'Pragma': 'no-cache',
};

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ClassicCourtApp());
}

class ClassicCourtApp extends StatelessWidget {
  const ClassicCourtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Classic Court',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: const ClassicCourtScreen(),
    );
  }
}

class ClassicCourtScreen extends StatefulWidget {
  const ClassicCourtScreen({super.key});

  @override
  State<ClassicCourtScreen> createState() => _ClassicCourtScreenState();
}

class _ClassicCourtScreenState extends State<ClassicCourtScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  bool _clearedCache = false;
  bool _autenticado = false;
  String _currentUrl = _homeUrl;

  @override
  void initState() {
    super.initState();
    _tentarBiometria();
    _initWebView();
  }

  Future<void> _tentarBiometria() async {
    final auth = LocalAuthentication();
    try {
      final disponivel = await auth.canCheckBiometrics || await auth.isDeviceSupported();
      if (!disponivel) {
        setState(() => _autenticado = true);
        return;
      }
      final ok = await auth.authenticate(
        localizedReason: 'Autentique-se para acessar o Classic Court',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      setState(() => _autenticado = ok);
      if (!ok) {
        _tentarBiometria();
      }
    } catch (e) {
      setState(() => _autenticado = true);
    }
  }

  void _initWebView() {
    _controller = WebViewController();

    if (_controller.platform is AndroidWebViewController) {
      final android = _controller.platform as AndroidWebViewController;
      AndroidWebViewController.enableDebugging(true);
      android.setMediaPlaybackRequiresUserGesture(false);
    }

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          if (!url.startsWith('chrome-error://') && !url.startsWith('about:')) {
            setState(() { _isLoading = true; _hasError = false; });
          }
        },
        onPageFinished: (url) {
          if (!url.startsWith('chrome-error://') && !url.startsWith('about:')) {
            setState(() {
              _isLoading = false;
              _currentUrl = url;
            });
          }
        },
        onWebResourceError: (error) {
          if (error.isForMainFrame != true) return;
          if (error.errorCode == -1 && !_clearedCache) {
            _clearedCache = true;
            _controller.clearCache().then((_) {
              _controller.loadRequest(Uri.parse(_homeUrl), headers: _noCache);
            });
            return;
          }
          setState(() { _isLoading = false; _hasError = true; });
        },
      ))
      ..loadRequest(Uri.parse(_homeUrl), headers: _noCache);
  }

  void _retry() {
    setState(() { _hasError = false; _isLoading = true; });
    _clearedCache = false;
    _controller.clearCache().then((_) {
      _controller.loadRequest(Uri.parse(_homeUrl), headers: _noCache);
    });
  }

  void _compartilhar() {
    Share.share('Classic Court — Tênis do Classic Boulevard\n$_currentUrl');
  }

  @override
  Widget build(BuildContext context) {
    if (!_autenticado) {
      return Scaffold(
        backgroundColor: const Color(0xFFDDE4EC),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎾', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text('Classic Court',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF2563EB))),
              const SizedBox(height: 8),
              const Text('Autenticação necessária',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _tentarBiometria,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Autenticar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFDDE4EC),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading && !_hasError)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFF2563EB)),
              ),
            if (_hasError)
              Container(
                color: const Color(0xFFDDE4EC),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎾', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      const Text('Sem conexão',
                          style: TextStyle(color: Color(0xFF1E293B),
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Verifique sua internet e tente novamente.',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _retry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Tentar novamente',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: (!_isLoading && !_hasError)
          ? FloatingActionButton.small(
              onPressed: _compartilhar,
              backgroundColor: const Color(0xFF2563EB),
              child: const Icon(Icons.share, color: Colors.white, size: 20),
            )
          : null,
    );
  }
}
