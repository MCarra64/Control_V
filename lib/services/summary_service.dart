import 'dart:convert';
import 'package:http/http.dart' as http;

class SummaryService {
  final String apiUrl = 'http://TUSERVIDOR/api/ventas';  // Cambia por tu endpoint real

  Future<List<Map<String, dynamic>>> fetchVentas() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Error al cargar ventas');
    }
  }
}
