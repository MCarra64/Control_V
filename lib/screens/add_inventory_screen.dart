import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_styles.dart';

class Product {
  final int id;
  final String name;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.stock,
  });

  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      id: data['id'],
      name: data['name'],
      stock: data['stock'],
    );
  }
}

class AddInventoryScreen extends StatefulWidget {
  const AddInventoryScreen({super.key});

  @override
  State<AddInventoryScreen> createState() => _AddInventoryScreenState();
}

class _AddInventoryScreenState extends State<AddInventoryScreen> {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  Product? _selectedProduct;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3001/products'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final products = data.map((item) => Product.fromMap(item)).toList();
        setState(() {
          _allProducts = products;
          _filteredProducts = products;
          _isLoading = false;
        });
      } else {
        _showMessage('Error al cargar productos');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showMessage('Error de conexión: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterProducts(String query) {
    setState(() {
      _filteredProducts = _allProducts
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _addStock() async {
    if (_selectedProduct == null) {
      _showMessage('Seleccione un producto');
      return;
    }
    final quantityStr = _quantityController.text.trim();
    if (quantityStr.isEmpty || int.tryParse(quantityStr) == null || int.parse(quantityStr) <= 0) {
      _showMessage('Ingrese una cantidad válida');
      return;
    }
    final quantity = int.parse(quantityStr);

    setState(() => _isSubmitting = true);

    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3001/products/${_selectedProduct!.id}/stock'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'quantityToAdd': quantity}),
      );

      if (response.statusCode == 200) {
        _showMessage('Stock actualizado');
        _quantityController.clear();
        _loadProducts();
        setState(() => _selectedProduct = null);
      } else {
        _showMessage('Error: ${response.body}');
      }
    } catch (e) {
      _showMessage('Error de conexión: $e');
    }

    setState(() => _isSubmitting = false);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Inventario', style: TextStyle(color: AppStyles.cardBackground)),
        backgroundColor: AppStyles.primaryGreen,
        iconTheme: const IconThemeData(color: AppStyles.cardBackground),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar producto',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _filterProducts,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredProducts.length,
                      itemBuilder: (_, index) {
                        final product = _filteredProducts[index];
                        return ListTile(
                          title: Text(product.name),
                          subtitle: Text('Stock actual: ${product.stock}'),
                          onTap: () {
                            setState(() {
                              _selectedProduct = product;
                              _quantityController.clear();
                            });
                          },
                          selected: _selectedProduct?.id == product.id,
                        );
                      },
                    ),
                  ),
                  if (_selectedProduct != null) ...[
                    Text('Producto seleccionado: ${_selectedProduct!.name}'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad a añadir',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    _isSubmitting
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppStyles.primaryGreen),
                            onPressed: _addStock,
                            child: const Text('Añadir al inventario', style: TextStyle(color: Colors.white)),
                          ),
                  ],
                ],
              ),
            ),
    );
  }
}
