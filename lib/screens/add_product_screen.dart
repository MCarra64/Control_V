import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../services/inventory_service.dart';

class AddProductScreen extends StatefulWidget {
  final int categoryId;

  const AddProductScreen({
    super.key,
    required this.categoryId,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController providerController = TextEditingController();
  final TextEditingController costPriceController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  String? imagePath;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir producto'),
        backgroundColor: AppStyles.primaryGreen,
      ),
      backgroundColor: const Color(0xFFC8E6C9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    imagePath = 'Imagen seleccionada';
                  });
                },
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: imagePath == null
                      ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                      : const Icon(Icons.check, size: 50, color: Colors.green),
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField(nameController, 'Nombre del producto'),
              _buildTextField(providerController, 'Proveedor'),
              _buildNumberField(costPriceController, 'Precio de costo'),
              _buildNumberField(salePriceController, 'Precio de venta'),
              _buildNumberField(stockController, 'Stock'),

              const SizedBox(height: 16),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 32.0),
                      ),
                      onPressed: _saveProduct,
                      child: const Text(
                        'Guardar producto',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        await InventoryService().createProduct(
          name: nameController.text.trim(),
          provider: providerController.text.trim(),
          costPrice: double.parse(costPriceController.text.trim()),
          salePrice: double.parse(salePriceController.text.trim()),
          stock: int.parse(stockController.text.trim()),
          categoryId: widget.categoryId,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto creado exitosamente')),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pop(context);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Ingrese $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Ingrese $label';
          }
          if (double.tryParse(value) == null) {
            return 'Ingrese un número válido';
          }
          return null;
        },
      ),
    );
  }
}
