import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2ecc71)),
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
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
        onWebResourceError: (error) {
          debugPrint('WebView error: ${error.errorCode} - ${error.description}');
          setState(() => _isLoading = false);
        },
      ))
      ..loadRequest(
        Uri.parse('https://getuliomenegattilara-design.github.io/ClassicCourt/login.html'),
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0f0d),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2ecc71),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
