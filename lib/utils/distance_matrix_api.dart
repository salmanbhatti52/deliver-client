import 'dart:convert';
import 'package:http/http.dart' as http;

class DistanceMatrixAPI {
  final String apiKey;

  DistanceMatrixAPI(this.apiKey);

  Future<Map<String, dynamic>> getDistanceAndTime(
      String origin, String destination) async {
    final url =
        'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$origin&destinations=$destination&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load distance matrix data');
    }
  }
}
