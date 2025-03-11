import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gsheets/gsheets.dart';
import 'sheets_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'platform_service.dart';

class FeedbackService {
  static const String _webAppUrl =
      'https://script.google.com/macros/s/AKfycbyskNJRZOHoZV1Jxp6wBx-IMYJ_q7LxY9RO5yVIcNlmrSnSEeyWoku3gvWnDcSU3X5aTA/exec';
  static final _gsheets = GSheets(SheetsConfig.credentials);
  static const _spreadsheetId = "1mXGT1z6lTYQ2EZeVeyqwWH3-PbKMwnR9rvVdYXworSY";
  static Worksheet? _feedbackSheet;
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      if (PlatformService.isDesktop) {
        final ss = await _gsheets.spreadsheet(_spreadsheetId);
        _feedbackSheet = await ss.worksheetByTitle('Feedback');

        // Create headers if sheet is empty
        if ((await _feedbackSheet?.values.row(1))?.isEmpty ?? true) {
          await _feedbackSheet?.values
              .insertRow(1, ['Timestamp', 'Message', 'Platform']);
        }
      }
      _isInitialized = true;
    } catch (e) {
      // debugPrint('Error initializing feedback service: $e');
    }
  }

  static Future<bool> submitFeedback(String message) async {
    if (!_isInitialized) await init();

    try {
      if (PlatformService.isWeb) {
        return await _submitWebFeedback(message);
      } else {
        return await _submitDesktopFeedback(message);
      }
    } catch (e) {
      // debugPrint('Error submitting feedback: $e');
      return false;
    }
  }

  static Future<bool> _submitWebFeedback(String message) async {
    final response = await http.post(
      Uri.parse(_webAppUrl),
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
      },
      body: jsonEncode({
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': 'web',
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['success'] == true;
    }
    return false;
  }

  static Future<bool> _submitDesktopFeedback(String message) async {
    try {
      if (_feedbackSheet == null) return false;

      await _feedbackSheet!.values.appendRow([
        DateTime.now().toIso8601String(),
        message,
        'desktop',
      ]);
      return true;
    } catch (e) {
      // debugPrint('Error submitting desktop feedback: $e');
      return false;
    }
  }
}
