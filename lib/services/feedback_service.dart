import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gsheets/gsheets.dart';
import 'sheets_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FeedbackService {
  static final String _webAppUrl = dotenv.env['FEEDBACK_WEB_URL'] ?? '';
  static final _gsheets = GSheets(SheetsConfig.credentials);
  static final _spreadsheetId = SheetsConfig.spreadsheetId;
  static Worksheet? _feedbackSheet;

  static Future<void> init() async {
    if (!kIsWeb) {
      try {
        final ss = await _gsheets.spreadsheet(_spreadsheetId!);
        _feedbackSheet = await ss.worksheetByTitle('Feedback');

        // Create headers if sheet is empty
        if ((await _feedbackSheet?.values.row(1))?.isEmpty ?? true) {
          await _feedbackSheet?.values.insertRow(1, [
            'Timestamp',
            'Message',
          ]);
        }
      } catch (e) {
        // debugPrint('Error initializing sheets: $e');
      }
    }
  }

  static Future<bool> submitFeedback(String message) async {
    try {
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
          'platform': kIsWeb ? 'web' : 'desktop',
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['success'] == true;
      }

      // debugPrint('Feedback submission failed with status: ${response.statusCode}');
      // debugPrint('Response body: ${response.body}');
      return false;
    } catch (e) {
      // debugPrint('Error submitting feedback: $e');
      return false;
    }
  }
}
