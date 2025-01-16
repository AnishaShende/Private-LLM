import 'package:flutter_dotenv/flutter_dotenv.dart';

class SheetsConfig {
  static final spreadsheetId = dotenv.env['SHEET_ID'];
  static const credentials = r'''
    {
      // Add your Google Cloud Service Account credentials here
      // Get this from Google Cloud Console -> Service Accounts -> Create Key (JSON)
    }
  ''';
}
