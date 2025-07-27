import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gsheets/gsheets.dart';
import 'sheets_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'platform_service.dart';

class FeedbackService {
  static const String _webAppUrl =
      'https://script.google.com/macros/s/AKfycbxfizWFuTqAT_a0_72hr1-NC3_fCWtiGkV-_sDt8TP_j3oWKqDTkzlo5sHQ9xeG2sEZfA/exec';
  static final _gsheets = GSheets(SheetsConfig.credentials);
  static const _spreadsheetId = "1mXGT1z6lTYQ2EZeVeyqwWH3-PbKMwnR9rvVdYXworSY";
  static Worksheet? _feedbackSheet;
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      if (PlatformService.isDesktop) {
        print('*******************************************');
        print('Fetching spreadsheet...');
        final ss = await _gsheets.spreadsheet(_spreadsheetId);
        print('Fetched: ${ss}');
        _feedbackSheet = await ss.worksheetByTitle('Feedback');
        print('Worksheet found: ${_feedbackSheet?.title}');

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
        print('Submitting web feedback...');
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
    print('Submitting web feedback to $_webAppUrl');
    final response = await http.post(
      Uri.parse(_webAppUrl),
      headers: {
        'Content-Type': 'application/json',
        // 'Access-Control-Allow-Origin': '*',
        // 'Access-Control-Allow-Methods': 'POST, OPTIONS',
      },
      body: jsonEncode({
        'message': message,
        // 'timestamp': DateTime.now().toIso8601String(),
        'platform': 'web',
      }),
    );
    print("sent web feedback: $message");

    if (response.statusCode == 200) {
      print('Web feedback submitted successfully');
      final result = jsonDecode(response.body);
      print('Web feedback response: $result');
      return result['success'] == true;
    } else {
      print(
          'Failed to submit web feedback: ${response.statusCode} - ${response.body}');
      print('Web feedback error: ${response.statusCode} - ${response.body}');
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
