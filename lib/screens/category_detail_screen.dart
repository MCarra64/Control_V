import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../services/inventory_service.dart';
import 'product_detail_screen.dart';
import 'add_product_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryName;
  final int categoryId;

  const CategoryDetailScreen({
    super.key,
    required this.categoryName,
    required this.categoryId,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late Future<List<dynamic>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    _productsFuture = InventoryService().fetchProductsByCategory(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: TextStyle(color: AppStyles.cardBackground),
        ),
        backgroundColor: AppStyles.primaryGreen,
        iconTheme: IconThemeData(color: AppStyles.cardBackground), // Cambia el color de la flecha
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            color: AppStyles.cardBackground,
            onPressed: _confirmDelete,
          ),
        ],
      ),
      backgroundColor: Colors.green[100],
      body: FutureBuilder<List<dynamic>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos en esta categoría.'));
          }

          final products = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          productId: product['id'],
                          productName: product['name'],
                          salePrice: (product['salePrice'] as num).toDouble(),
                          costPrice: (product['costPrice'] as num).toDouble(),
                          quantity: product['stock'],
                          imageUrl: 'https://via.placeholder.com/150',
                          tags: (product['tags'] as List<dynamic>).map((tag) {
                            return {
                              'id': tag['id'],
                              'name': tag['name'],
                            };
                          }).toList(),
                        ),
                      ),
                    );
                  },
                  leading: Icon(Icons.shopping_bag, color: AppStyles.primaryGreen),
                  title: Text(product['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Precio venta: Lps. ${product['salePrice']}'),
                      Text('Stock: ${product['stock']}'),
                      Text('Proveedor: ${product['provider'] ?? 'N/A'}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppStyles.primaryGreen,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddProductScreen(categoryId: widget.categoryId),
            ),
          );
          setState(() {
            _loadProducts();
          });
        },
        child: const Icon(Icons.add, color: AppStyles.cardBackground),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: const Text('¿Estás seguro de que quieres eliminar esta categoría?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: _deleteCategory,
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory() async {
    Navigator.pop(context);
    try {
      await InventoryService().deleteCategory(widget.categoryId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoría eliminada')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
