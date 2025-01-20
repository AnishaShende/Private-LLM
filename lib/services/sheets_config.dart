class SheetsConfig {
  static final spreadsheetId = "1mXGT1z6lTYQ2EZeVeyqwWH3-PbKMwnR9rvVdYXworSY";
  // static String get spreadsheetId => dotenv.env['SHEET_ID'];
  static const credentials = r'''
    {
      // Add your Google Cloud Service Account credentials here
      // Get this from Google Cloud Console -> Service Accounts -> Create Key (JSON)
    }
  ''';
}
