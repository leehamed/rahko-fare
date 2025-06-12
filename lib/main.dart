import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext c) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late InAppWebViewController webViewController;

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri('https://fare.rahko.ir')),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            cacheEnabled: true,
            sharedCookiesEnabled: true,
            thirdPartyCookiesEnabled: true,
          ),
          initialOptions: InAppWebViewGroupOptions(
            android: AndroidInAppWebViewOptions(useHybridComposition: true),
            ios: IOSInAppWebViewOptions(sharedCookiesEnabled: true),
          ),
          onWebViewCreated: (ctrl) {
            webViewController = ctrl;
          },
          onLoadStop: (ctrl, url) async {
            await saveCookies();
          },
        ),
      ),
    );
  }

  Future<void> saveCookies() async {
    final uri = WebUri('https://fare.rahko.ir');
    List<Cookie> cookies = await CookieManager.instance().getCookies(url: uri);
    final prefs = await SharedPreferences.getInstance();
    final cookieString = cookies.map((c) => '${c.name}=${c.value}').join('; ');
    await prefs.setString('saved_cookies', cookieString);
  }

  Future<void> restoreCookies() async {
    final prefs = await SharedPreferences.getInstance();
    final cookieString = prefs.getString('saved_cookies');
    if (cookieString != null) {
      final uri = WebUri('https://fare.rahko.ir');
      for (var pair in cookieString.split('; ')) {
        final parts = pair.split('=');
        if (parts.length == 2) {
          await CookieManager.instance().setCookie(
            url: uri,
            name: parts[0],
            value: parts[1],
            domain: 'fare.rahko.ir',
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    restoreCookies().then((_) => setState(() {}));
  }
}
