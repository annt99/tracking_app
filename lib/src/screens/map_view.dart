import 'package:flutter/material.dart';
import 'package:tracking_app/src/screens/tracking_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GoogleMapsWebViewScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String label;

  GoogleMapsWebViewScreen(
      {required this.latitude, required this.longitude, required this.label});

  @override
  Widget build(BuildContext context) {
    String url =
        'https://www.google.com/maps?q=$latitude,$longitude&label=$label';
    WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse(url));
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Location History',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        toolbarHeight: 65,
        centerTitle: false,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [Color(0xff40A9F8), Color(0xff1CCBCB)],
            stops: [0, 1],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          )),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 100,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              colors: [Color(0xff40A9F8), Color(0xff1CCBCB)],
              stops: [0, 1],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )),
          ),
          ClipPath(
            clipper: TopBorderRadiusClipper(),
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height,
              child: WebViewWidget(
                controller: controller, // Enable JavaScript
              ),
            ),
          ),
        ],
      ),
    );
  }
}
