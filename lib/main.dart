import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

String selectedUrl = 'https://barfeefood.com/public/auth/login';

// ignore: prefer_collection_literals
final Set<JavascriptChannel> jsChannels = [
  JavascriptChannel(
      name: 'Print',
      onMessageReceived: (JavascriptMessage message) {
        print(message.message);
      }),
].toSet();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barfee Restaurant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (_) => WebApp(),
      },
    );
  }
}

class WebApp extends StatefulWidget {
  @override
  _WebAppState createState() => _WebAppState();
}

class _WebAppState extends State<WebApp> {
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();
    flutterWebViewPlugin.close();
    flutterWebViewPlugin.launch(
      selectedUrl,
      geolocationEnabled: true,
      javascriptChannels: jsChannels,
      withJavascript: true,
    );
    flutterWebViewPlugin.onUrlChanged.listen((String url) async {
      // print("navigating to...$url");
      if (url.startsWith("mailto") || url.startsWith("tel")) {
        await flutterWebViewPlugin.stopLoading();
        if (await canLaunch(url)) {
          await launch(
            url,
            enableJavaScript: true,
          );
          return;
        }
        // print("couldn't launch $url");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WebviewScaffold(
        url: selectedUrl,
        javascriptChannels: jsChannels,
        mediaPlaybackRequiresUserGesture: false,
        withZoom: true,
        withLocalStorage: true,
        hidden: true,
        initialChild: Container(
          color: Colors.black87,
          child: const Center(
            child: SpinKitPulse(
              color: Colors.white,
              size: 50.0,
            ),
          ),
        ),
      ),
    );
  }
}
