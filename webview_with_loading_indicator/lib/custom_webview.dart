import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomWebView extends StatefulWidget {
  final String initialUrl;
  final double? width;
  final double? height;

  CustomWebView(
      {Key? key, this.width, this.height, required this.initialUrl})
      : super(key: key);

  @override
  _CustomWebViewState createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
    width: widget.width ?? 400,
      height: widget.height ?? 300,
      child: Stack(
        children: <Widget>[
          WebView(
            initialUrl: widget.initialUrl,
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onPageStarted: (url) {
              setState(() {
                _isLoading = true;
              });
            },
            onPageFinished: (url) {
              setState(() {
                _isLoading = false;
              });
            },
          ),
          if (_isLoading)
            const Center(
              child: SpinKitCircle(
                color: Colors.blue, // Couleur de l'indicateur
                size: 50.0, // Taille de l'indicateur
              ),
            ),
        ],
      ),
    );
  }
}
