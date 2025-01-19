import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

class UrlLaunch {
  final String url;
  final Uri _uri;

  UrlLaunch(this.url) : _uri = Uri.parse(url);

  Future<void> launchUrl() async {
    try {
      if (!await ul.launchUrl(_uri)) {
        throw Exception('Could not launch $_uri');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      rethrow;
    }
  }
}
