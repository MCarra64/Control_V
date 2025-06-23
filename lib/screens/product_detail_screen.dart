import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../services/inventory_service.dart';
import 'tag_management_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final int productId;
  final String productName;
  final double costPrice;
  final double salePrice;
  final int quantity;
  final List<Map<String, dynamic>> tags;
  final String imageUrl;

  static const Color greenBackground = Color(0xFFC8E6C9);

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.costPrice,
    required this.salePrice,
    required this.quantity,
    required this.tags,
    required this.imageUrl,
  });

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro que deseas eliminar el producto "$productName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context); // Cierra el diálogo
              try {
                await InventoryService().deleteProduct(productId);
                Navigator.pop(context); // Vuelve a la pantalla anterior
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Producto eliminado correctamente')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al eliminar producto: $e')),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productName, style: TextStyle(color: AppStyles.cardBackground)),
        backgroundColor: AppStyles.primaryGreen,
        iconTheme: IconThemeData(color: AppStyles.cardBackground), // Cambia el color de la flecha
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Eliminar producto',
            color: AppStyles.cardBackground,
            onPressed: () {
              _confirmDelete(context);
            },
          ),
        ],
      ),
      backgroundColor: greenBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image, size: 60, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Text('Nombre: $productName', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(thickness: 1.5, color: Colors.grey),
            Text('Precio de costo: \$${costPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
            Text('Precio de venta: \$${salePrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
            Text('Cantidad: $quantity', style: const TextStyle(fontSize: 16)),
            const Divider(thickness: 1.5, color: Colors.grey),
            const SizedBox(height: 8),
            const Text('Etiquetas:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ...tags.map((tag) => Chip(label: Text(tag['name']))),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TagManagementScreen(
                          productId: productId,
                          initialTags: tags,
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppStyles.primaryGreen,
                    child: const Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1.5, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
