import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_styles.dart';

class Product {
  final int id;
  final String name;
  final double salePrice;

  Product({
    required this.id,
    required this.name,
    required this.salePrice,
  });
}

class SaleItem {
  final Product product;
  int quantity;
  double price;

  SaleItem({
    required this.product,
    required this.quantity,
    required this.price,
  });
}

class AddSaleScreen extends StatefulWidget {
  final bool canModifyPrice;
  final int empleadoId;

  const AddSaleScreen({
    super.key,
    required this.canModifyPrice,
    required this.empleadoId,
  });

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<SaleItem> _cart = [];

  Product? _selectedProduct;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3001/products'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final products = data.map((item) => Product(
          id: item['id'],
          name: item['name'],
          salePrice: (item['salePrice'] as num).toDouble(),
        )).toList();

        setState(() {
          _allProducts = products;
          _filteredProducts = products;
        });
      } else {
        _showMessage('Error al cargar productos: ${response.body}');
      }
    } catch (e) {
      _showMessage('Error de conexión: $e');
    }
  }

  void _filterProducts(String query) {
    setState(() {
      _filteredProducts = _allProducts
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectProduct(Product product) {
    setState(() {
      _selectedProduct = product;
      _priceController.text = product.salePrice.toStringAsFixed(2);
      _quantityController.text = '';
    });
  }

  void _addToCart() {
    if (_selectedProduct == null) {
      _showMessage('Seleccione un producto');
      return;
    }
    if (_quantityController.text.trim().isEmpty ||
        int.tryParse(_quantityController.text.trim()) == null ||
        int.parse(_quantityController.text.trim()) <= 0) {
      _showMessage('Ingrese una cantidad válida');
      return;
    }
    if (_priceController.text.trim().isEmpty ||
        double.tryParse(_priceController.text.trim()) == null ||
        double.parse(_priceController.text.trim()) <= 0) {
      _showMessage('Ingrese un precio válido');
      return;
    }

    final quantity = int.parse(_quantityController.text.trim());
    final price = double.parse(_priceController.text.trim());

    final index = _cart.indexWhere((item) => item.product.id == _selectedProduct!.id);
    if (index >= 0) {
      setState(() {
        _cart[index].quantity += quantity;
        _cart[index].price = price;
      });
    } else {
      setState(() {
        _cart.add(SaleItem(
          product: _selectedProduct!,
          quantity: quantity,
          price: price,
        ));
      });
    }

    setState(() {
      _selectedProduct = null;
      _priceController.clear();
      _quantityController.clear();
    });
  }

  double _calculateTotal() {
    return _cart.fold(0, (sum, item) => sum + item.price * item.quantity);
  }

  void _showCartModal() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Carrito', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ..._cart.map((item) => ListTile(
                title: Text('${item.product.name} x${item.quantity}'),
                subtitle: Text('Lps. ${(item.price * item.quantity).toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _cart.remove(item);
                    });
                    Navigator.pop(context);
                    _showCartModal();
                  },
                ),
              )),
              Text(
                'Total: Lps. ${_calculateTotal().toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppStyles.primaryGreen),
                      onPressed: _submitSale,
                      child: const Text('Registrar venta', style: TextStyle(color: Colors.white)),
                    ),
            ],
          ),
        );
      },
    );
  }

  void _submitSale() async {
    if (_cart.isEmpty) {
      _showMessage('Agregue al menos un producto al carrito');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final saleData = {
      'venta': {
        'fecha': DateTime.now().toIso8601String(),
        'total': _calculateTotal(),
        'empleadoId': widget.empleadoId,
      },
      'detalles': _cart.map((item) => {
        'productoId': item.product.id,
        'cantidad': item.quantity,
        'precioUnitario': item.price,
      }).toList(),
    };

    print('DEBUG SALE DATA -> ${jsonEncode(saleData)}');

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3001/ventas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(saleData),
      );

      if (response.statusCode == 201) {
        _showMessage('Venta registrada correctamente');
        Navigator.pop(context);
      } else {
        _showMessage('Error al registrar venta: ${response.body}');
      }
    } catch (e) {
      _showMessage('Error de conexión: $e');
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Venta'),
        backgroundColor: AppStyles.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _cart.isNotEmpty ? _showCartModal : null,
          )
        ],
      ),
      body: Padding(
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
                    subtitle: Text('Lps. ${product.salePrice.toStringAsFixed(2)}'),
                    onTap: () => _selectProduct(product),
                  );
                },
              ),
            ),
            if (_selectedProduct != null) ...[
              const SizedBox(height: 8),
              Text('Producto: ${_selectedProduct!.name}'),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio de venta',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                enabled: widget.canModifyPrice,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppStyles.primaryGreen),
                onPressed: _addToCart,
                child: const Text('Agregar al carrito', style: TextStyle(color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
