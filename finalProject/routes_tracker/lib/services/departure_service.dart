import 'dart:convert';
import 'package:http/http.dart' as http;

class DepartureService {
  final String baseUrl;
  final String tzOffset;

  DepartureService({
    this.baseUrl = 'http://localhost:3000',
    this.tzOffset = '-06:00',
  });

  Future<Map<String, dynamic>> fetchBestDepartureTime({
    required String origin,
    required String destination,
    required String date,
  }) async {
    final url =
        '$baseUrl/api/best-departure-time'
        '?origin=${Uri.encodeComponent(origin)}'
        '&destination=${Uri.encodeComponent(destination)}'
        '&date=${Uri.encodeComponent(date)}'
        '&tzOffset=${Uri.encodeComponent(tzOffset)}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      String message = 'Request failed with status: ${response.statusCode}';

      try {
        final errorData = jsonDecode(response.body);
        message = errorData['error']?.toString() ?? message;
      } catch (_) {}

      throw Exception(message);
    }

    return jsonDecode(response.body);
  }
}