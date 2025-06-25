import 'dart:convert';
import 'package:http/http.dart' as http;

class SummaryData {
  final double bruto;
  final double neto;
  final double gasto;

  SummaryData({required this.bruto, required this.neto, required this.gasto});

  factory SummaryData.fromJson(Map<String, dynamic> json) {
    return SummaryData(
      bruto: json['bruto']?.toDouble() ?? 0,
      neto: json['neto']?.toDouble() ?? 0,
      gasto: json['gasto']?.toDouble() ?? 0,
    );
  }
}

class SummaryService {
  final String baseUrl = 'http://10.0.2.2:3001/api';

  Future<SummaryData> fetchSummary(String period, {int? year, int? month}) async {
    final queryParams = {
      'period': period,
      if (year != null) 'year': '$year',
      if (month != null) 'month': '$month',
    };

    final uri = Uri.parse('$baseUrl/summary').replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return SummaryData.fromJson(jsonData);
    } else {
      throw Exception('Fallo al cargar el resumen');
    }
  }
}
