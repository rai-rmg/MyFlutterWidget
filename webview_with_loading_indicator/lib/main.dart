import 'package:flutter/material.dart';
import 'custom_webview.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebView personnalisé',
      home: CustomWebView(
        initialUrl: 'https://www.ville-bouillante.fr/', // URL initial
      ),
    );
  }
}
