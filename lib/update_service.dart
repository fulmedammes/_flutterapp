import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateService {
  static const String versionUrl = '/version.json'; // Relative URL

  static Future<String?> getLatestVersion() async {
    try {
      final response = await http.get(Uri.parse(versionUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['version'];
      } else {
        print('Failed to fetch version: ${response.statusCode}, body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching version: $e, stacktrace: ${e.toString()}');
      return null;
    }
  }
}