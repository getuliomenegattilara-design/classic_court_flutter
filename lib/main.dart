import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC47850)),
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

  @override
  void initState() {
    super.initState();
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
            setState(() => _isLoading = false);
          }
        },
        onWebResourceError: (error) {
          if (error.isForMainFrame != true) return;
          // ERR_CACHE_MISS (code=-1): limpa cache e recarrega silenciosamente
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0e0b08),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading && !_hasError)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFFC47850)),
              ),
            if (_hasError)
              Container(
                color: const Color(0xFF0e0b08),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎾', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      const Text('Sem conexão',
                          style: TextStyle(color: Color(0xFFF0E8E0),
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Verifique sua internet e tente novamente.',
                          style: TextStyle(color: Color(0xFFA08870), fontSize: 13),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _retry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC47850),
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
    );
  }
}
