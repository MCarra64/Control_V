import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../services/inventory_service.dart';
import 'tag_management_screen.dart';

class ProductDetailScreen extends StatefulWidget {
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

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _providerController = TextEditingController();
  final TextEditingController _costPriceController = TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.productName;
    _providerController.text = '';
    _costPriceController.text = widget.costPrice.toStringAsFixed(2);
    _salePriceController.text = widget.salePrice.toStringAsFixed(2);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro que deseas eliminar el producto "${widget.productName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await InventoryService().deleteProduct(widget.productId);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Producto eliminado correctamente')),
                  );
                }
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
        title: Text(widget.productName, style: TextStyle(color: AppStyles.cardBackground)),
        backgroundColor: AppStyles.primaryGreen,
        iconTheme: IconThemeData(color: AppStyles.cardBackground),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Eliminar producto',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      backgroundColor: ProductDetailScreen.greenBackground,
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
            Text('Nombre: ${widget.productName}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(thickness: 1.5, color: Colors.grey),
            Text('Precio de costo: Lps. ${widget.costPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
            Text('Precio de venta: Lps. ${widget.salePrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
            Text('Cantidad: ${widget.quantity}', style: const TextStyle(fontSize: 16)),
            const Divider(thickness: 1.5, color: Colors.grey),
            const SizedBox(height: 8),
            const Text('Etiquetas:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ...widget.tags.map((tag) => Chip(label: Text(tag['name']))),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TagManagementScreen(
                          productId: widget.productId,
                          initialTags: widget.tags,
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