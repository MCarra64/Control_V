import 'dart:convert';
import 'package:http/http.dart' as http;

class InventoryService {
  final String baseUrl = 'http://10.0.2.2:3001';

  Future<List<dynamic>> fetchCategories() async {
    final url = Uri.parse('$baseUrl/categories');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener categorías: ${response.reasonPhrase}');
    }
  }

  Future<void> createCategory(String name, String? description) async {
    final url = Uri.parse('http://10.0.2.2:3001/categories');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'description': description ?? ''
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear categoría: ${response.reasonPhrase}');
    }
  }

  Future<void> createProduct({
    required String name,
    required String provider,
    required double costPrice,
    required double salePrice,
    required int stock,
    required int categoryId,
  }) async {
    final url = Uri.parse('http://10.0.2.2:3001/products');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'provider': provider,
        'costPrice': costPrice,
        'salePrice': salePrice,
        'stock': stock,
        'categoryId': categoryId,
        'code': 'AUTO${DateTime.now().millisecondsSinceEpoch}'
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear producto: ${response.reasonPhrase}');
    }
  }

  Future<List<dynamic>> fetchProductsByCategory(int categoryId) async {
    final url = Uri.parse('http://10.0.2.2:3001/products/by-category/$categoryId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded;
      } else {
        throw Exception('Formato inesperado en la respuesta de productos');
      }
    } else {
      throw Exception('Error al obtener productos: ${response.reasonPhrase}');
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    final url = Uri.parse('http://10.0.2.2:3001/categories/$categoryId');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la categoría: ${response.reasonPhrase}');
    }
  }

  Future<List<dynamic>> fetchUsers() async {
    final url = Uri.parse('http://10.0.2.2:3001/auth');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener usuarios: ${response.reasonPhrase}');
    }
  }

  Future<void> createUser({
    required String username,
    required String fullName,
    required String password,
    String role = 'empleado',
    bool canAccessResumen = false,
    bool canAccessControlPersonal = false,
    bool canAddSale = true,
    bool canAddInventory = false,
    bool status = true,
  }) async {
    final url = Uri.parse('http://10.0.2.2:3001/auth');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'fullName': fullName,
        'password': password,
        'role': role,
        'canAccessResumen': canAccessResumen,
        'canAccessControlPersonal': canAccessControlPersonal,
        'canAddSale': canAddSale,
        'canAddInventory': canAddInventory,
        'status': status,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear el empleado: ${response.reasonPhrase}');
    }
  }

  Future<void> updateUser({
    required int id,
    required String username,
    required String fullName,
    String? password,
    String role = 'empleado',
    bool canAccessResumen = false,
    bool canAccessControlPersonal = false,
    bool canAddSale = true,
    bool canAddInventory = false,
    bool status = true,
  }) async {
    final url = Uri.parse('http://10.0.2.2:3001/auth/$id');
    final body = {
      'username': username,
      'fullName': fullName,
      'role': role,
      'canAccessResumen': canAccessResumen,
      'canAccessControlPersonal': canAccessControlPersonal,
      'canAddSale': canAddSale,
      'canAddInventory': canAddInventory,
      'status': status,
    };

    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el empleado: ${response.reasonPhrase}');
    }
  }

  Future<void> deleteUser(int id) async {
    final url = Uri.parse('http://10.0.2.2:3001/auth/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el empleado: ${response.reasonPhrase}');
    }
  }

  Future<List<dynamic>> fetchTags() async {
    final url = Uri.parse('$baseUrl/tags');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener etiquetas: ${response.reasonPhrase}');
    }
  }

  Future<List<dynamic>> fetchProductTags(int productId) async {
    final url = Uri.parse('$baseUrl/products/$productId/tags');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener etiquetas del producto: ${response.reasonPhrase}');
    }
  }

  Future<int> createTag(String name) async {
    final url = Uri.parse('$baseUrl/tags');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'];
    } else {
      throw Exception('Error al crear etiqueta: ${response.reasonPhrase}');
    }
  }

  Future<void> addTagToProduct(int productId, int tagId) async {
    final url = Uri.parse('$baseUrl/products/$productId/tags');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'tagId': tagId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al asignar etiqueta: ${response.reasonPhrase}');
    }
  }

  Future<void> removeTagFromProduct(int productId, int tagId) async {
    final url = Uri.parse('$baseUrl/products/$productId/tags/$tagId');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar etiqueta: ${response.reasonPhrase}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAvailableTags() async {
    final url = Uri.parse('http://10.0.2.2:3001/tags');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Formato inesperado en la respuesta de etiquetas');
      }
    } else {
      throw Exception('Error al obtener etiquetas: ${response.reasonPhrase}');
    }
  }

}
